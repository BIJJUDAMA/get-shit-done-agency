Describe "GSD Init PowerShell" {
    It "should show help when -Help is passed" {
        $result = pwsh -File bin/gsd-init.ps1 -Help
        $result | Should -Contain "[GSD Integration Bridge]"
    }

    It "should show version when -Version is passed" {
        $result = pwsh -File bin/gsd-init.ps1 -Version
        $result | Should -Not -BeNullOrEmpty
    }
}
