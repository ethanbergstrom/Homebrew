@{
	RootModule = 'Homebrew.psm1'
	ModuleVersion = '0.0.1'
	GUID = '59259a02-2afd-4016-ab22-9afd91fdc6ea'
	Author = 'Ethan Bergstrom'
	Copyright = ''
	Description = 'Package Management (OneGet) provider that facilitates installing Homebrew packages from any NuGet repository.'
	# Refuse to load in CoreCLR if PowerShell below 7.0.1 due to regressions with how 7.0 loads PackageManagement DLLs
	# https://github.com/PowerShell/PowerShell/pull/12203
	PowerShellVersion = '7.0.1'
	RequiredModules = @(
		@{
			ModuleName='PackageManagement'
			ModuleVersion='1.1.7.2'
		},
		@{
			ModuleName='Croze'
			ModuleVersion='0.0.4'
		}
	)
	PrivateData = @{
		PackageManagementProviders = 'Homebrew.psm1'
		PSData = @{
			# Tags applied to this module to indicate this is a PackageManagement Provider.
			Tags = @('PackageManagement','Provider','Homebrew','PSEdition_Core','MacOS','Linux')

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/ethanbergstrom/Homebrew/blob/current/LICENSE.txt'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/ethanbergstrom/Homebrew'

			# ReleaseNotes of this module
			ReleaseNotes = 'Please see https://github.com/ethanbergstrom/Homebrew/blob/master/CHANGELOG.md for release notes'
		}
	}
}
