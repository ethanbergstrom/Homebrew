# Returns the packages that are installed.
function Get-InstalledPackage {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification='Version may not always be used, but are still required')]
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Name,

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

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Get-InstalledPackage'))

	# If a user wants to check whether the latest version is installed, first check the repo for what the latest version is
	if ($RequiredVersion -eq 'latest') {
		$RequiredVersion = $(Find-HomebrewPackage -Name $Name).Version
	}

	# Convert the PSCustomObject output from Croze into PackageManagement SWIDs, then filter results by version requirements
	# This provides wildcard search behavior for locally installed packages, which Homebrew lacks
	(Get-HomebrewPackage -Cask) + (Get-HomebrewPackage -Formula) | Select-Object Name, Version, Cask, Formula |
		Where-Object {-Not $Name -Or ($_.Name -Like $Name)} |
			Where-Object {Test-PackageVersion -Package $_ -RequiredVersion $RequiredVersion -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion} |
				ConvertTo-SoftwareIdentity
}
