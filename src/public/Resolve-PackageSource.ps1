# This function gets called during Find-Package, Install-Package, Get-PackageSource etc.
# OneGet uses this method to identify which provider can handle the packages from a particular source location.
function Resolve-PackageSource {

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Resolve-PackageSource'))

	# Get sources from Homebrew
	Croze\Get-HomebrewTap | Croze\Get-HomebrewTapInfo | ForEach-Object {
		Write-Debug "Source detected: $_"
		New-PackageSource -Name $_.Name -Location $_.Remote -Trusted $true -Registered $_.installed
	}
}
