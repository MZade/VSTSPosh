$FunctionsToExport = @(
'Get-VstsProject',
'New-VstsProject',
'Remove-VstsProject',
'Get-VstsWorkItem',
'New-VstsWorkItem',
'Get-VstsWorkItemQuery',
'Get-VstsCodePolicy',
'New-VstsCodePolicy',
'New-VstsGitRepository',
'Get-VstsGitRepository')

New-ModuleManifest -ModuleVersion $ENV:APPVEYOR_BUILD_VERSION -Path .\VSTS.psd1 -Author 'Adam Driscoll' -Company 'Concurrency, Inc' -Description 'Visual Studio Team Services PowerShell Integration' -RootModule '.\VSTS.psm1'  -FunctionsToExport $FunctionsToExport