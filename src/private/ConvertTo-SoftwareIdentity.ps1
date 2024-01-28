# Convert the objects returned from Croze into Software Identities (SWIDs).
function ConvertTo-SoftwareIdentity {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject
	)

	process {
		Write-Debug ($LocalizedData.ProviderDebugMessage -f ('ConvertTo-SoftwareIdentity'))
		foreach ($package in $InputObject) {
			# Return a new SWID based on the output from Croze
			$metadata = Croze\Get-HomebrewPackageInfo -Name $package.Name

			# Cask installation doesn't return a parseable version, so we have to assume one from package metadata
			$version = $metadata.Version ?? $metadata.Versions.Stable

			$type = @(
				if $metadata.Cask {
					'Cask'
				} elseif $metadata.Formula {
					'Formula'
				} else {
					throw 'Ambiguous package metadata'
				}
			)

			Write-Debug "Package identified: $($package.Name), $version, $($metadata.Tap), $type"
			$swid = @{
				FastPackageReference = $package.Name+"#"+$version+"#"+$metadata.Tap+"#"+$type
				Name = $package.Name
				Version = $version
				versionScheme = "MultiPartNumeric"
				Source = $metadata.Tap
			}

			New-SoftwareIdentity @swid
		}
	}
}
