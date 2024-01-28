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

	Croze\Unregister-HomebrewTap -Name $Name
}
