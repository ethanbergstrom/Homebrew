[![CI](https://github.com/ethanbergstrom/Homebrew/actions/workflows/CI.yml/badge.svg)](https://github.com/ethanbergstrom/Homebrew/actions/workflows/CI.yml)

# Homebrew for PackageManagement
Homebrew for PackageManagement facilitates installing Homebrew packages from any compatible repository. The provider is heavily influenced by the work of the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) project.

## Install Homebrew
```PowerShell
Install-PackageProvider Homebrew -Force
```
Note: Please do **not** use `Import-Module` with Package Management providers, as they are not meant to be imported in that manner. Either use `Import-PackageProvider` or specify the provider name with the `-Provider` argument to the PackageManagement cmdlets, such as in the examples below:

## Sample usages
### Search for a package
```PowerShell
Find-Package vlc -Provider Homebrew

Find-Package tmux -Source homebrew/core -Provider Homebrew -Detailed
```

### Install a package
```PowerShell
Find-Package vlc -Provider Homebrew | Install-Package -Force

Install-Package tmux -Source homebrew/core -Provider Homebrew -Force
```

### Get list of installed packages (with wildcard search support)
```PowerShell
Get-Package Microsoft* -Provider Homebrew
```

### Uninstall a package
```PowerShell
Get-Package vlc -Provider Homebrew | Uninstall-Package

Uninstall-Package tmux -Provider Homebrew
```

### Manage package sources
```PowerShell
Register-PackageSource pyroscope-io/brew -Provider Homebrew -Location 'https://github.com/pyroscope-io/homebrew-brew'
Find-Package pyroscope -Provider Homebrew -Source pyroscope-io/brew | Install-Package
Unregister-PackageSource pyroscope-io/brew -Provider Homebrew
```

## DSC Compatibility
Fully compatible with the PackageManagement DSC resources
```PowerShell
Configuration MyNode {
	Import-DscResource PackageManagement,PackageManagementSource
	PackageManagement Homebrew {
		Name = 'Homebrew'
		Source = 'PSGallery'
	}
	PackageManagementSource PyroscopeRepo {
		Name = 'pyroscope-io/brew'
		ProviderName = 'Homebrew'
		SourceLocation = 'https://github.com/pyroscope-io/homebrew-brew'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]Homebrew'
	}
	PackageManagement Pyroscope {
		Name = 'pyroscope'
		Source = 'pyroscope-io/brew'
		DependsOn = '[PackageManagementSource]PyroscopeRepo'
	}
}
```

## Keep packages up to date
A common complaint of PackageManagement/OneGet is it doesn't allow for updating installed packages, while Homebrew does.
In order to reconcile the two, Homebrew has a reserved keyword 'latest' that when passed as a Required Version can compare the version of what's currently installed against what's in the repository.
```PowerShell

PS C:\Users\ethan> Get-Package vlc -Provider Homebrew

Name                           Version          Source           Summary
----                           -------          ------           -------
vlc                            3.0.16.0         Homebrew

PS C:\Users\ethan> Get-Package vlc -Provider Homebrew -RequiredVersion latest
Get-Package : No package found for 'vlc'.

PS C:\Users\ethan> Install-Package vlc -Provider Homebrew -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
vlc                            3.0.17.3         Homebrew

PS C:\Users\ethan> Get-Package vlc -Provider Homebrew -RequiredVersion latest

Name                           Version          Source           Summary
----                           -------          ------           -------
vlc                            3.0.17.3         Homebrew

```

This feature can be combined with a PackageManagement-compatible configuration management system (ex: [PowerShell DSC LCM in 'ApplyAndAutoCorrect' mode](https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/metaconfig)) to regularly keep certain packages up to date:
```PowerShell
Configuration MyNode {
	Import-DscResource PackageManagement
	PackageManagement Homebrew {
		Name = 'Homebrew'
		Source = 'PSGallery'
	}
	PackageManagement VLC {
		Name = 'vlc'
		RequiredVersion = 'latest'
		ProviderName = 'Homebrew'
		DependsOn = '[PackageManagement]Homebrew'
	}
}
```

**Please note** - Since PackageManagement doesn't support passing source information when invoking `Get-Package`, the 'latest' functionality **will not work** if the default Homebrew package source is removed as a source **and** multiple custom sources are defined.

Furthermore, if both the default Homebrew package source and a custom source are configured, the custom source **will be ignored** when the 'latest' required version is used with `Get-Package`.

Example PowerShell DSC configuration using the 'latest' required version with a custom source:

```PowerShell
Configuration MyNode {
	Import-DscResource PackageManagement,PackageManagementSource
	PackageManagement Homebrew {
		Name = 'Homebrew'
		Source = 'PSGallery'
	}
	PackageManagementSource PyroscopeRepo {
		Name = 'pyroscope-io/brew'
		ProviderName = 'Homebrew'
		SourceLocation = 'https://github.com/pyroscope-io/homebrew-brew'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]Homebrew'
	}
	PackageManagementSource HomebrewRepo {
		Name = 'homebrew/cask'
		ProviderName = 'Homebrew'
		Ensure = 'Absent'
		DependsOn = '[PackageManagement]Homebrew'
	}
	# The source information wont actually be used by the Get-Package step of the PackageManagement DSC resource check, but it helps make clear to the reader where the package should come from
	PackageManagement Pyroscope {
		Name = 'pyroscope'
		ProviderName = 'Homebrew'
		Source = 'pyroscope-io/brew'
		RequiredVersion = 'latest'
		DependsOn = @('[PackageManagementSource]PyroscopeRepo', '[PackageManagementSource]HomebrewRepo')
	}
}
```

If using the 'latest' functionality, best practice is to either:
* use the default Homebrew source
* unregister the default Homebrew source in favor of a **single** custom source

## Legal and Licensing
Homebrew is licensed under the [MIT license](./LICENSE.txt).
