<#
 See https://github.com/MZade/VSTSPosh to get the VSTS.psm1

 DESCRIPTION:
    This script provides a list of all changesets that have been checked-in after a given datetime.
    
    If you use a Main and Build branch 
    and merging your changesets on a regular basis from Main to Build branch,
    You might have noticed that the link between the changeset which is checked-in under the Build branch
    and the actual work itemes that have been affecting the Main branch is get lost.

    To have an end-to-end visibility,
    You would need to add these work items during the check-in 
    (this is normally right after the branching/merging wizard in VisualStudio has detected whcih changes should be taken over).

    Using this script you may add work items that have been used to check-in the original changesets in the Main branch,
    also to the changeset that you are going to check-in under the Build branch.
#>

<# ............. #>
# You will need to create a personal access token to get access to VSTS
# See:
#     https://docs.microsoft.com/en-us/vsts/accounts/use-personal-access-tokens-to-authenticate?view=vsts
#
$User = "PUT YOUR OWN E-MAIL ADDRESS HERE"
$Token = "PUT YOUR OWN TOKEN"                   
<# ............. #>

<# ............. #>
# Project specifications
#
$global:Project = "PUT YOUR PROJECT NAME HERE"
$AccountName = "PUT YOUR ACCOUNT NAME HERE"
<# ............. #>

<# PARAMETER INPUT - BEGIN #>
$lastMergeDateStr = Read-Host -Prompt 'Input last merge date/time'
$lastMergeDate = Get-Date $lastMergeDateStr 
Write-Host "Collecting all workitems for changesets created after '$lastMergeDate'" 
<# PARAMETER INPUT - END #>


<# ..................................................................................... #>

$session = New-VstsSession -AccountName $AccountName -User $User -Token $Token
$changesets = Get-VstsTfvcChangeSet -Session $session -FromDate $lastMergeDate

Write-Host "-------------------------------------------------------------------"

$workItemsToReport = @{}
Foreach($changeset in $changesets)
{    
    $changesetWorkItems = Get-VstsTfvcChangeSetWorkItems -Session $session -Id $changeset.changesetId
    

    #Write-Host "-------------------------------------------------------------------"
    foreach($changesetWorkItem in $changesetWorkItems)
    {       
        $wiID = [String]$changesetWorkItem.id
        $wiTitle = $changesetWorkItem.title
        $wiUrl = $changesetWorkItem.webUrl
        
        if($workItemsToReport.ContainsKey($wiID) -eq $false)
        {
            $workItemsToReport += @{$wiID =  $wiTitle}
        }
        
        #Write-Host "'$wiID' - '$wiTitle'"
    }
    #Write-Host "-------------------------------------------------------------------"
}

$workItemsToReport = Get-Unique -InputObject $workItemsToReport
$workItemsToReport

pause 'Press any key to exit...';
