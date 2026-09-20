#Requires -Version 7.1

<#
.SYNOPSIS
	Generates a file ID to texture path lookup table from WoW client databases.
#>
[CmdletBinding()]
param ()

$ActiveProducts = @(
	@{ Name = "wow"; Mandatory = $true }
	@{ Name = "wow_beta"; Mandatory = $false }
	@{ Name = "wowt"; Mandatory = $false }
	@{ Name = "wowxptr"; Mandatory = $false }
	@{ Name = "wow_classic"; Mandatory = $true }
	@{ Name = "wow_classic_beta"; Mandatory = $false }
	@{ Name = "wow_classic_ptr"; Mandatory = $false }
	@{ Name = "wow_classic_era"; Mandatory = $true }
	@{ Name = "wow_classic_era_ptr"; Mandatory = $false }
	@{ Name = "wow_anniversary"; Mandatory = $true }
	@{ Name = "wow_anniversary_ptr"; Mandatory = $false }
	@{ Name = "wow_classic_titan"; Mandatory = $false }
	@{ Name = "wow_classic_titan_ptr"; Mandatory = $false }
)

$OutputPath = Join-Path -Path $PSScriptRoot -ChildPath "..\FilePaths.lua"
$TemporaryOutputPath = "$OutputPath.tmp"

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
	$Version = Invoke-WebRequest "https://wago.tools/api/builds/${Product}/latest" `
		| ConvertFrom-Json `
		| Select-Object -ExpandProperty version

	if ([string]::IsNullOrWhiteSpace([string] $Version)) {
		throw "The product version endpoint returned no version."
	}

	$Version
}

function Get-ClientDatabase([string] $Name, [string] $Version) {
	Invoke-WebRequest "https://wago.tools/db2/${Name}/csv?build=${Version}" `
		| ConvertFrom-Csv
}

function Get-Listfile {
	Invoke-WebRequest "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv" `
		| ConvertFrom-Csv -Delimiter ";" -Header "ID", "Name"
}

function Get-FilePaths([string] $Version, [hashtable] $Files) {
	$Atlases = Get-ClientDatabase -Name "UiTextureAtlas" -Version $Version

	foreach ($Atlas in $Atlases) {
		$File = $Files[$Atlas.FileDataID]

		if (-not $File) {
			continue
		}

		$FileName = $File.Name
		$Extension = [IO.Path]::GetExtension($FileName)

		[PSCustomObject] @{
			FileDataID = [int] $Atlas.FileDataID
			FileName = if ($Extension) { $FileName.Substring(0, $FileName.Length - $Extension.Length) } else { $FileName }
		}
	}
}

function Write-FilePaths {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[Object[]] $InputObject
	)

	begin {
		@"
local _, _addon = ...

_addon.FilePaths = {
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
"@
	}
}

try {
	$Files = Get-Listfile | New-LookupTable -Property ID
	$FilePaths = @{}
	$MissingMandatoryProducts = @()

	foreach ($Product in $ActiveProducts) {
		try {
			$Version = Get-ProductVersion -Product $Product.Name
			foreach ($File in (Get-FilePaths -Version $Version -Files $Files)) {
				$FilePaths[$File.FileDataID] = $File.FileName
			}
		}
		catch {
			Write-Warning "Unable to generate file data for product '$($Product.Name)': $($_.Exception.Message)"
			if ($Product.Mandatory) {
				$MissingMandatoryProducts += $Product.Name
			}
		}
	}

	if ($MissingMandatoryProducts.Count -gt 0) {
		throw "Unable to generate file data for mandatory product(s): $($MissingMandatoryProducts -join ', ')."
	}

	$FilePaths.GetEnumerator()
		| Sort-Object -Property Key
		| ForEach-Object {
			[PSCustomObject] @{
				FileDataID = [int] $_.Key
				FileName = $_.Value
			}
		}
		| Write-FilePaths
		| Set-Content -Path $TemporaryOutputPath -Encoding utf8

	Move-Item -Path $TemporaryOutputPath -Destination $OutputPath -Force
}
finally {
	Remove-Item -Path $TemporaryOutputPath -Force -ErrorAction SilentlyContinue
}
