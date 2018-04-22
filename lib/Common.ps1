<#
    .SYNOPSIS
    Helper function to have a pause in the script execution.

    .PARAMETER Message
    The message which will be shown to the user.
#>
Function pause ($Message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$Message")
    }
    else
    {
        Write-Host "$Message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}