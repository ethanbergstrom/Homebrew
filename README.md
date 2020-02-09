# Chocolatier
Chocolatier is Package Management (OneGet) provider that facilitates installing Chocolatey packages from any NuGet repository. The provider is heavily influenced by the work of @jianyunt and the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) project.

[![Build status](https://ci.appveyor.com/api/projects/status/14pwjwch40ww0cxd?svg=true)](https://ci.appveyor.com/project/ethanbergstrom/chocolatier)

## Get the Chocolatier installed
```PowerShell
Find-PackageProvider Chocolatier -verbose

Install-PackageProvider Chocolatier -verbose

Import-PackageProvider Chocolatier

# Run Get-Packageprovider to check if the Chocolatier provider is imported
Get-Packageprovider -verbose
```

## Sample usages
### find-packages
```PowerShell
find-package -ProviderName Chocolatier -name  nodejs

find-package -ProviderName Chocolatier -name firefox*
```

### install-packages
```PowerShell
find-package nodejs -verbose -provider Chocolatier -AdditionalArguments --exact | install-package

install-package -name 7zip -verbose -ProviderName Chocolatier
```
### get-packages
```PowerShell
get-package nodejs -verbose -provider Chocolatier
```
### uninstall-package
```PowerShell
get-package nodejs -provider Chocolatier -verbose | uninstall-package -AdditionalArguments '-y --remove-dependencies' -Verbose
```
### save-package

save-package is not supported for Chocolatier provider.
It is because Chocolatier is a wrapper of choco.exe which currently does not support downloading packages only.

### register-packagesource / unregister-packagesource
```PowerShell
register-packagesource privateRepo -provider Chocolatier -location 'https://somewhere/out/there/api/v2/'
find-package nodejs -verbose -provider Chocolatier -source privateRepo -AdditionalArguments --exact | install-package
unregister-packagesource privateRepo -provider Chocolatier
```

OneGet integrates with Chocolatey sources to manage source information

## Pass in choco arguments
If you need to pass in some of choco arguments to the Find, Install, Get and Uninstall-package cmdlets, you can use AdditionalArguments PowerShell property.

## DSC Compatability
Fully compatable with the PackageManagement DSC resources
```PowerShell
Configuration ChocoNodeJS {
	PackageManagement Chocolatier {
		Name = 'Chocolatier'
		Source = 'PSGallery'
	}
	PackageManagementSource ChocoPrivateRepo {
		Name = 'privateRepo'
		ProviderName = 'Chocolatier'
		SourceLocation = 'https://somewhere/out/there/api/v2/'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]Chocolatier'
	}
	PackageManagement NodeJS {
		Name = 'nodejs'
		Source = 'privateRepo'
		DependsOn = '[PackageManagementSource]ChocoPrivateRepo'
	}
}
```

## Keep packages up to date
A common complaint of PackageManagement/OneGet is it doesn't allow for updating installed packages, while Chocolatey does.
  In order to reconile the two, Chocolatier has a reserved keyword 'latest' that when passed as a Required Version can compare the version of what's currently installed against what's in the repository.
```PowerShell
PS C:\Users\ethan> Install-Package curl -RequiredVersion 7.60.0 -ProviderName chocolatier -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           v7.60.0          chocolatey


PS C:\Users\ethan> Get-Package curl -ProviderName chocolatier

Name                           Version          Source                           ProviderName
----                           -------          ------                           ------------
curl                           7.60.0           Chocolatey                       Chocolatier


PS C:\Users\ethan> Get-Package curl -RequiredVersion latest -ProviderName chocolatier
Get-Package : No package found for 'curl'.
At line:1 char:1
+ Get-Package curl -RequiredVersion latest -ProviderName chocolatier
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (Microsoft.Power...lets.GetPackage:GetPackage) [Get-Package], Exception
    + FullyQualifiedErrorId : NoMatchFound,Microsoft.PowerShell.PackageManagement.Cmdlets.GetPackage

PS C:\Users\ethan> Find-Package curl -ProviderName chocolatier

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           7.68.0           chocolatey


PS C:\Users\ethan> Find-Package curl -RequiredVersion latest -ProviderName chocolatier

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           7.68.0           chocolatey


PS C:\Users\ethan> Find-Package curl -RequiredVersion latest -ProviderName chocolatier | Install-Package -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           v7.68.0          chocolatey


PS C:\Users\ethan> Get-Package curl -ProviderName chocolatier

Name                           Version          Source                           ProviderName
----                           -------          ------                           ------------
curl                           7.68.0           Chocolatey                       Chocolatier


PS C:\Users\ethan> Get-Package curl -RequiredVersion latest -ProviderName chocolatier

Name                           Version          Source                           ProviderName
----                           -------          ------                           ------------
curl                           7.68.0           Chocolatey                       Chocolatier

```

This feature can be combined with a PackageManagement-compatible configuration management system (ex: PowerShell DSC) to regularly keep certain packages up to date:
```PowerShell
	PackageManagement SysInternals {
		Name = 'sysinternals'
		RequiredVersion = 'latest'
		ProviderName = 'chocolatier'
	}
```

## Known Issues
Currently Chocolatier works on Full CLR.
It is not supported on CoreClr.
This means Chocolatier provider is not supported on Nano server or Linux OSs.
The primarily reason is that the current version of choco.exe does not seem to support on CoreClr yet.

## Legal and Licensing
Chocolatier is licensed under the [MIT license](./LICENSE.txt).
