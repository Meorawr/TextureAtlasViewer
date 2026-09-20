#Requires -Version 7.1

<#
.SYNOPSIS
	Generates a file ID to texture path lookup table from WoW client databases.
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)]
	[ValidateNotNull()]
	[string] $Product,

	[Parameter(Mandatory=$false)]
	[string] $ExpansionLevel
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
	Invoke-WebRequest "https://wago.tools/api/builds/${Product}/latest" `
		| ConvertFrom-Json `
		| Select-Object -ExpandProperty version
}

function Get-ClientDatabase([string] $Name, [string] $Version) {
	Invoke-WebRequest "https://wago.tools/db2/${Name}/csv?build=${Version}" `
		| ConvertFrom-Csv
}

function Get-Listfile {
	Invoke-WebRequest "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv" `
		| ConvertFrom-Csv -Delimiter ";" -Header "ID", "Name"
}

function Get-FilePaths([string] $Version) {
	$Atlases = Get-ClientDatabase -Name "UiTextureAtlas" -Version $Version
	$Files = Get-Listfile | New-LookupTable -Property ID

	$Atlases
		| Where-Object { $Files[$_.FileDataID] }
		| ForEach-Object {
				$File = $Files[$_.FileDataID]
				$FileName = $File.Name
				$Extension = [IO.Path]::GetExtension($FileName)

				[PSCustomObject] @{
					FileDataID = [int] $_.FileDataID
					FileName = if ($Extension) { $FileName.Substring(0, $FileName.Length - $Extension.Length) } else { $FileName }
				}
			}
		| Sort-Object -Property FileDataID -Unique
}

function Write-FilePaths {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[Object[]] $InputObject,

		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string] $Version,

		[Parameter(Mandatory=$false)]
		[string] $ExpansionLevel
	)

	begin {
		"local _, _addon = ..."

		if ($ExpansionLevel) {
			@"

if LE_EXPANSION_LEVEL_CURRENT ~= $($ExpansionLevel) then
    return;
end
"@
		}

		@"

-- \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

local FilePaths = {
"@
	}

	process {
		foreach ($File in $InputObject) {
			$EscapedFileName = $File.FileName.Replace("\", "\\").Replace('"', '\"')
			"`t[$($File.FileDataID)] = `"$EscapedFileName`","
		}
	}

	end {
		@"
}

-- /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

-- Don't remove this!
_addon.data = FilePaths
"@
	}
}

$Version = Get-ProductVersion -Product $Product

Get-FilePaths -Version $Version | Write-FilePaths -Version $Version -ExpansionLevel $ExpansionLevel
