ConvertFrom-StringData @'
###PSLOC
	ProviderDebugMessage='Homebrew': '{0}'.
	FastPackageReference='Homebrew': The FastPackageReference is '{0}'.

	NotInstalled=Package '{0}' is not installed.
	FailToInstall=Failed to install the package because the package reference '{0}' is incorrect.
	FailToUninstall=Failed to uninstall the package because the package reference '{0}' is incorrect.
	UnexpectedHomebrewResponse=Output from Homebrew.exe for package reference '{0}' did not match the exepected format. Please review Homebrew logs for more information.

	InstallPackageCaption=Are you sure you want to perform this action?

	PackageSourceNotFound=No package source with the name '{0}' was found.
	UnspecifiedSource=Multiple non-default sources are available, but the default source is not. A source name must be specified.
	PackageSourceMissing=During Software Identity conversion, no source could be determined. This should never happen!
	HomebrewFailure=The operation failed. Check the Homebrew logs for more information.
###PSLOC
'@
