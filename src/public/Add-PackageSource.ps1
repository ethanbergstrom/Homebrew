function Add-PackageSource {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Location,

		[Parameter()]
		[bool]
		$Trusted
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Add-PackageSource'))
	Write-Verbose "New package source: $Name, $Location"

	# For reasons I don't fully understand, Homebrew sometimes writes non-error informational output to stderr
	# PowerShell will see this and think an error has occured, and return a non-zero exit code.
	# Therefore, we unfortunately need to suppress otherwise-helpful error output in the provider.
	# We can't suppress it in Croze because Crescendo doesn't support that.
	Croze\Register-HomebrewTap -Name $Name -Location $Location 2>$null

	# Croze doesn't return anything after new sources are registered, but PackageManagement expects a response
	$packageSource = @{
		Name = $Name
		Location = $Location
		Trusted = $Trusted
		Registered = $true
	}

	New-PackageSource @packageSource
}
