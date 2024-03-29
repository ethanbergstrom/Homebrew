# It is required to implement this function for the providers that support UnInstall-Package.
function Uninstall-Package {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidOverwritingBuiltInCmdlets', '', Justification='Required by PackageManagement')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FastPackageReference
	)

	Write-Debug -Message ($LocalizedData.ProviderDebugMessage -f ('Uninstall-Package'))
	Write-Debug -Message ($LocalizedData.FastPackageReference -f $FastPackageReference)

	# If the fast package reference doesnt match the pattern we expect, throw an exception
	if ((-Not ($FastPackageReference -Match $script:FastReferenceRegex)) -Or (-Not ($Matches.name -And $Matches.version))) {
		ThrowError -ExceptionName "System.ArgumentException" `
			-ExceptionMessage ($LocalizedData.FailToUninstall -f $FastPackageReference) `
			-ErrorId 'FailToUninstall' `
			-ErrorCategory InvalidArgument
	}

	$uninstallArgs = @{
		Name = $Matches.source+'/'+$Matches.name
	}

	switch ($Matches.type) {
		'Cask' {$uninstallArgs.Cask = $true}
		'Formula' {$uninstallArgs.Formula = $true}
	}

	Croze\Uninstall-HomebrewPackage @uninstallArgs

	# Croze doesn't return any output on successful uninstallation, so we have to make up a new SWID to satisfy PackageManagement
	ConvertTo-SoftwareIdentity -InputObject $Matches
}
