function Remove-PackageSource {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='ShouldProcess support not required by PackageManagement API spec')]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Remove-PackageSource'))

	[array]$RegisteredPackageSources = Croze\Get-HomebrewTap

	# Homebrew.exe will not error if the specified source name isn't already registered, so we will do it here instead.
	if (-not ($RegisteredPackageSources.Name -eq $Name)) {
		ThrowError -ExceptionName "System.ArgumentException" `
			-ExceptionMessage ($LocalizedData.PackageSourceNotFound -f $Name) `
			-ErrorId 'PackageSourceNotFound' `
			-ErrorCategory InvalidArgument
	}

	# For reasons I don't fully understand, Homebrew sometimes writes non-error informational output to stderr
	# PowerShell will see this and think an error has occured, and return a non-zero exit code.
	# Therefore, we unfortunately need to suppress otherwise-helpful error output in the provider.
	# We can't suppress it in Croze because Crescendo doesn't support that.
	Croze\Unregister-HomebrewTap -Name $Name 2>$null
}
