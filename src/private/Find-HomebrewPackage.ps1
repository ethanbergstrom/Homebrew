function Find-HomebrewPackage {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification='Versions may not always be used, but are still required')]
	param (
		[Parameter(Mandatory=$true)]
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

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Find-HomebrewPackage'))

	$options = $request.Options
	[array]$RegisteredPackageSources = Croze\Get-HomebrewTap

	$selectedSource = $(
		if ($options -And $options.ContainsKey('Source')) {
			# Finding the matched package sources from the registered ones
			if ($RegisteredPackageSources.Name -eq $options['Source']) {
				# Found the matched registered source
				$options['Source']
			} else {
				ThrowError -ExceptionName 'System.ArgumentException' `
				-ExceptionMessage ($LocalizedData.PackageSourceMissing) `
				-ErrorId 'PackageSourceMissing' `
				-ErrorCategory InvalidArgument `
			}
		} else {
			# User did not specify a source. Now what?
			if ($RegisteredPackageSources.Count -eq 1) {
				# If no source name is specified and only one source is available, use that source
				$RegisteredPackageSources[0].Name
			} elseif ($RegisteredPackageSources.Name -eq $script:PackageSource) {
				# If multiple sources are avaiable but none specified, default to using Homebrew packages - if present
				$script:PackageSource
			} else {
				# If Homebrew's default source is not present and no source specified, we can't guess what the user wants - throw an exception
				ThrowError -ExceptionName 'System.ArgumentException' `
				-ExceptionMessage $LocalizedData.UnspecifiedSource `
				-ErrorId 'UnspecifiedSource' `
				-ErrorCategory InvalidArgument
			}
		}
	)

	Write-Verbose "Source selected: $selectedSource"

	# Convert the PSCustomObject output from Croze into PackageManagement SWIDs, then filter results by any version requirements
	Croze\Find-HomebrewPackage "$selectedSource/$Name" | Croze\Get-HomebrewPackageInfo | Select-Object -Property (
		@{
			Name = 'Name'
			Expression = {$_.Token ?? $_.Name}
		},@{
			Name = 'Version'
			Expression = {$_.Version ?? $_.Versions.Stable}
		},@{
			Name = 'Source'
			Expression = {$_.Tap}
		}
	 ) | Where-Object {Test-PackageVersion -Package $_ -RequiredVersion $RequiredVersion -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion} | ConvertTo-SoftwareIdentity
}
