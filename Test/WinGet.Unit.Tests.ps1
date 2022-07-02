[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='PSSA does not understand Pester scopes well')]
param()

BeforeAll {
	$Homebrew = 'Homebrew'
	Import-PackageProvider $Homebrew
}

Describe 'basic package search operations' {
	Context 'generic' {
		It 'gets a list of latest installed packages' {
			Get-Package -Provider $Homebrew | Should -Not -BeNullOrEmpty
		}
	}
	Context 'formula' {
		BeforeAll {
			$package = 'tmux'
			$source = 'homebrew/core'
		}
		It 'searches for the latest version of a package' {
			Find-Package -Provider $Homebrew -Name $package -Source $source | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
		}
		It 'searches for the latest version of a package' {
			Find-Package -Provider $Homebrew -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'DSC-compliant package installation and uninstallation' {
	Context 'formula' {
		BeforeAll {
			$package = 'tmux'
			$source = 'homebrew/core'
		}

		It 'searches for a specific version of a package' {
			Find-Package -Provider $Homebrew -Name $package -Source $source | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently installs a specific version of a package' {
			Install-Package -Provider $Homebrew -Name $package -Source $source -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds the locally installed package just installed' {
			Get-Package -Provider $Homebrew -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently uninstalls the locally installed package just installed' {
			Uninstall-Package -Provider $Homebrew -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
		}

		It 'searches for a specific version of a package' {
			Find-Package -Provider $Homebrew -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently installs a specific version of a package' {
			Install-Package -Provider $Homebrew -Name $package -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds the locally installed package just installed' {
			Get-Package -Provider $Homebrew -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently uninstalls the locally installed package just installed' {
			Uninstall-Package -Provider $Homebrew -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'pipeline-based package installation and uninstallation' {
	Context 'formula' {
		BeforeAll {
			$package = 'tmux'
			$source = 'homebrew/core'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Provider $Homebrew -Name $package -Source $source | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed' {
			Get-Package -Provider $Homebrew -Name $package -Source $source | Uninstall-Package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Provider $Homebrew -Name $package | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed' {
			Get-Package -Provider $Homebrew -Name $package | Uninstall-Package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'version tests' {
	Context 'formula' {
		BeforeAll {
			$package = 'tmux'
			$source = 'homebrew/core'
			$version = '2.0'
		}

		It 'retrieves and correctly filters versions above a valid minimum' {
			Find-Package -Provider $Homebrew -Name $package -Source $source -MinimumVersion $version | Where-Object {$_.Name -contains $package} | Should -HaveCount 1
		}
		It 'retrieves and correctly filters versions below an invalid maximum' {
			Find-Package -Provider $Homebrew -Name $package -Source $source -MaximumVersion $version | Where-Object {$_.Name -contains $package} | Should -HaveCount 0
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
			$version = '2.0'
		}

		It 'retrieves and correctly filters versions above a valid minimum' {
			Find-Package -Provider $Homebrew -Name $package -MinimumVersion $version | Where-Object {$_.Name -contains $package} | Should -HaveCount 1
		}
		It 'retrieves and correctly filters versions below an invalid maximum' {
			Find-Package -Provider $Homebrew -Name $package -MaximumVersion $version | Where-Object {$_.Name -contains $package} | Should -HaveCount 0
		}
	}
}

Describe "multi-source support" {
	BeforeAll {
		$altSourceName = 'pyroscope-io/brew'
		$altSourceLocation = 'https://github.com/pyroscope-io/homebrew-brew'
		$package = Join-Path -path $altSourceName -ChildPath 'pyroscope'

		Unregister-PackageSource -Name $altSourceName -Provider $Homebrew -ErrorAction SilentlyContinue
	}
	AfterAll {
		Unregister-PackageSource -Name $altSourceName -Provider $Homebrew -ErrorAction SilentlyContinue
	}

	It 'refuses to register a source with no location' {
		Register-PackageSource -Name $altSourceName -Provider $Homebrew -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $altSourceName} | Should -BeNullOrEmpty
	}
	It 'registers an alternative package source' {
		Register-PackageSource -Name $altSourceName -Provider $Homebrew -Location $altSourceLocation | Where-Object {$_.Name -eq $altSourceName} | Should -Not -BeNullOrEmpty
	}
	It 'searches for and installs the latest version of a package from an alternate source' {
		Find-Package -Provider $Homebrew -Name $package -Source $altSourceName | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
	}
	It 'unregisters an alternative package source' {
		Unregister-PackageSource -Name $altSourceName -Provider $Homebrew
		Get-PackageSource -Provider $Homebrew | Where-Object {$_.Name -eq $altSourceName} | Should -BeNullOrEmpty
	}
}

