<#
 See https://github.com/MZade/VSTSPosh to get the VSTS.psm1

 DESCRIPTION:
    This script will collect all changesets between a given From/To datetime
    The script will also provide the abulity to tag these changesets with a given tag.
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

<# ............. #>
# PowerShell module
#
$VSTSModuleRoot = "C:\Scripts\VSTSPosh\VSTS.psm1" # This is the place where you place the VSTS.psm1 module downloaded from https://github.com/MZade/VSTSPosh
Import-Module $VSTSModuleRoot -Force
<# ............. #>

<# PARAMETER INPUT - BEGIN #>
$fromDateStr = Read-Host -Prompt 'Input from date/time'
$fromMergeDate = Get-Date $fromDateStr 

$toDateStr = Read-Host -Prompt 'Input to date/time'
$toMergeDate = Get-Date $toDateStr 

Write-Host "Collecting all workitems for changesets created between '$fromMergeDate' and '$toMergeDate'" 
<# PARAMETER INPUT - END #>


<# ..................................................................................... #>
$session = New-VstsSession -AccountName $AccountName -User $User -Token $Token
$changesets = Get-VstsTfvcChangeSet -Session $session -FromDate $fromMergeDate -ToDate $toMergeDate

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
            $wi = Get-VstsWorkItem -Session $session -Ids $wiID 

            $workItemsToReport += @{$wiID =  $wiTitle}            
        }
        
        #Write-Host "'$wiID' - '$wiTitle'"
    }
    #Write-Host "-------------------------------------------------------------------"
}

$workItemsToReport = Get-Unique -InputObject $workItemsToReport
$workItemsToReport

<# ..................................................................................... #>
$confirmation = Read-Host "Do you want to add a release tag to these work items? [y/n]"
while($confirmation -ne "y")
{
    if ($confirmation -eq 'n') {exit}
    $confirmation = Read-Host "Do you want to add a release tag to these work items? [y/n]"
}

if($confirmation -eq "y")
{
    $tags = Read-Host "Input the tag value you want to add"


    $confirmation = Read-Host "Final confirmation - Ready to add tags? [y/n]"
    while($confirmation -ne "y")
    {
        if ($confirmation -eq 'n') {exit}
        $confirmation = Read-Host "Final confirmation - Ready to add tags? [y/n]"
    }

    if($confirmation -eq "y")
    {
        $workItemsToReport.Keys | % {          
            $updateResult = Update-VstsWorkItemAddTags -Session $session -Project $Project -Id $_ -Tags $tags              
            $wiTitle = $workItemsToReport.Item($_) 
            Write-Host "Tag '$tags' has been added to '$_ : $wiTitle'"            
        }
    }
}
<# ..................................................................................... #>

pause 'Press any key to exit...';
