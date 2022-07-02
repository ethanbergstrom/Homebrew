# Make sure the SWID passed to us has a valid version in the range requested by the user
function Test-PackageVersion {
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$true)]
		$Package,

		[Parameter()]
		[string]
		$RequiredVersion,

		[Parameter()]
		[string]
		$MinimumVersion,

		[Parameter()]
		[string]
		$MaximumVersion
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Test-PackageVersion'))

	# User didn't have any version requirements
	if (-Not ($RequiredVersion -Or $MinimumVersion -Or $MaximumVersion)) {
		return $true
	}

	# User specified a specific version - it either matches or it doesn't
	if ($RequiredVersion) {
		return $Package.Version -eq $RequiredVersion
	}

	# Conditional filtering of the version based on optional minimum and maximum version requirements
	(-Not $MinimumVersion -Or (
		$Package.Version -ge $MinimumVersion
	)) -And (-Not $MaximumVersion -Or (
		$Package.Version -le $MaximumVersion
	))
}
