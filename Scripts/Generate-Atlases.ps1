#Requires -Version 7.1

<#
.SYNOPSIS
    Generates an output document of atlases pulled from WoW client databases
    suitable for use with the Texture Atlas Viewer addon.
#>
[CmdletBinding()]
param (
	# Product name to generate atlases for, using the latest CDN version.
    [Parameter(Mandatory=$true)]
	[ValidateNotNull()]
    [string] $Product
)

function New-LookupTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Object[]] $InputObject,

        [Parameter(Mandatory=$true)]
        [string] $Property
    )

    begin {
        $Table = @{}
    }

    process {
        foreach ($Object in $InputObject) {
            $Table[$Object.$Property] = $Object
        }
    }

    end {
        $Table
    }
}

function Get-ProductVersion([string] $Product) {
	$Socket = New-Object System.Net.Sockets.TcpClient("us.version.battle.net", 1119)
	$Stream = $Socket.GetStream()
	$Reader = New-Object System.IO.StreamReader($Stream)
	$Writer = New-Object System.IO.StreamWriter($Stream)
	$Writer.AutoFlush = $true

	$Writer.WriteLine("v2/products/$Product/versions")
	$Header = $Reader.ReadLine() -Replace "![^|]+", "" -Split "\|"
	$Reader.ReadLine() >$null
	$Result = $Reader.ReadToEnd() | ConvertFrom-Csv -Delimiter "|" -Header $Header | Where-Object -Property Region -eq "us"
	$Socket.Close()

	$Result.VersionsName
}

function Get-WowToolsDatabase([string] $Name, [string] $Version) {
    Invoke-WebRequest "https://wow.tools/dbc/api/export/?name=${Name}&build=${Version}&useHotfixes=true" `
        | ConvertFrom-Csv
}

function Get-WowToolsListfile {
    Invoke-WebRequest "https://wow.tools/casc/listfile/download/csv/unverified" `
        | ConvertFrom-Csv -Delimiter ";" -Header "ID", "Name"
}

function Get-Atlases([string] $Version) {
	$Version = Get-ProductVersion -Product $Product
    $Atlases = Get-WowToolsDatabase -Name "uitextureatlas" -Version $Version | New-LookupTable -Property ID
    $Elements = Get-WowToolsDatabase -Name "uitextureatlaselement" -Version $Version | New-LookupTable -Property ID
    $Members = Get-WowToolsDatabase -Name "uitextureatlasmember" -Version $Version
    $Files = Get-WowToolsListfile | New-LookupTable -Property ID

    $Members | ForEach-Object {
        $Atlas = $Atlases[$_.UiTextureAtlasID]
        $Element = $Elements[$_.UiTextureAtlasElementID]
        $File = $Files[$Atlas.FileDataID]

        @{
            Name = $Element.Name
            Left = $_.CommittedLeft / $Atlas.AtlasWidth
            Right = $_.CommittedRight / $Atlas.AtlasWidth
            Top = $_.CommittedTop / $Atlas.AtlasHeight
            Bottom = $_.CommittedBottom / $Atlas.AtlasHeight
            Width = ($_.OverrideWidth -ne 0 ? $_.OverrideWidth : $_.CommittedRight - $_.CommittedLeft)
            Height = ($_.OverrideHeight -ne 0 ? $_.OverrideHeight : $_.CommittedBottom - $_.CommittedTop)
            TileHorizontally = [bool] ($_.CommittedFlags -band 0x4)
            TileVertically = [bool] ($_.CommittedFlags -band 0x2)
            AtlasID = $Atlas.ID
            FileDataID = $Atlas.FileDataID
            FileName = ($File ? $File.Name.Substring(0, $File.Name.LastIndexOf(".")) : $Atlas.FileDataID)
        }
    }
}

function Write-GroupedAtlases {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Object[]] $InputObject,

		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string] $Product,

		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string] $Version
    )

    begin {
		# Temporary hack for 10.x datasets coexisting with retail.
		if ($Product -eq "wow_beta") {
			@"
if select(4, GetBuildInfo()) < 100000 then
	return;
end

"@
		}

		if ($Product -eq "wow") {
			# Mainline data sets should include replacement instructions.
@"
local _, _addon = ...

---------------------------------------------
-- Remove everything in between these comment blocks (between the /\/\/\ lines)
-- Go to https://www.townlong-yak.com/framexml/live/Helix/AtlasInfo.lua
-- Copy paste everything from the first 'local' to the last '}'. Do not copy the 'return AtlasInfo' part
-- Update the build number. Not required, but it can help you point out if your data is up to date with the current build or not
-- This is the number on the top left of the web page
local buildNr = $($Version.Split(".")[3])
-- Save the file and reload your UI
-- \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

local AtlasInfo = {
"@
		} else {
			# Classic and any other data sets won't have instructions.
			@"
local _, _addon = ...
local buildNr = $($Version.Split(".")[3])

-- \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

local AtlasInfo = {
"@
		}

    }

    process {
        foreach ($GroupInfo in $InputObject) {
            "`t[`"$($GroupInfo.Name)`"] = {"
            foreach ($_ in $GroupInfo.Group) {
                "`t`t[`"$($_.Name)`"] = { $($_.Width), $($_.Height), $($_.Left), $($_.Right), $($_.Top), $($_.Bottom), $($_.TileHorizontally ? "true" : "false"), $($_.TileVertically ? "true" : "false") },"
            }
            "`t},"
        }
    }

    end {
		@"
}

-- /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- Replace content in this area
-- Make sure the 'return AtlasInfo' at the end is not included
--------------------------------------------

-- Don't remove this!
_addon.data = AtlasInfo
_addon.dataBuild = buildNr
"@
    }
}

$Version = Get-ProductVersion -Product $Product

Get-Atlases -Version $Version `
    | Sort-Object -Property Name `
    | Group-Object -Property FileName `
    | Sort-Object -Property Name `  # Sorts by the grouped-by filename.
    | Write-GroupedAtlases -Product $Product -Version $Version
