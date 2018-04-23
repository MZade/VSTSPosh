<#
 See https://github.com/MZade/VSTSPosh to get the VSTS.psm1

 DESCRIPTION:
    This script collects all work items that are related to the changes sets which are linked to a given work item;
    One of the use cases of this script is when you use two branches like Main and Build branch and want to collect and tag the work items 
    for which the changesets has been done initially on the Main branch and by the Merging are get merged also into the Build branch.

    A typical situation looks like:

        Release work item (this is a reference work item which is used to merge changes from Main branch to the Build branch)
        |
        ---> Changes set 1
        |       |
        |       ---> work item 1
        |       |
        |       ---> work item 2
        |
        ---> Changes set 2
        |       |
        |       ---> work item 3
        |       |
        |       ---> work item 4

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
$releaseWIID = Read-Host -Prompt 'Input the release work item ID'
Write-Host "Collecting all work items related to the changes sets of the release work item '$releaseWIID'"
<# PARAMETER INPUT - END #>


<# ..................................................................................... #>
$session = New-VstsSession -AccountName $AccountName -User $User -Token $Token
$releaseWI = Get-VstsWorkItem -Session $session -Ids $releaseWIID -Expand Relations
$changesetLinks = $releaseWI.relations | where {$_.rel -match 'ArtifactLink' -and $_.url -match 'vstfs:///VersionControl/Changeset/'}
<# ..................................................................................... #>

$workItemsToReport = @{}

Foreach($changesetLink in $changesetLinks)
{
    $arr = $changesetLink.url -split '/'
    $changesetId = $arr[$arr.Length-1]

    Write-Host "-------------------------------------------------------------------"

    $changesetWorkItems = Get-VstsTfvcChangeSetWorkItems -Session $session -Id $changesetId
        
    $csId = $changeset.changesetId
    $csUrl = $changeset.url
    $csAuthor = $changeset.author.displayName
    $csCreatedDate = $changeset.createdDate
    $csComment = $changeset.comment
       
    Write-Host "Changeset ID         : '$csId'"
    Write-Host "Changeset Url        : '$csUrl'"
    Write-Host "Changeset Author     : '$csAuthor'"
    Write-Host "Changeset Created on : '$csCreatedDate'"
    Write-Host "Changeset Comment    : '$csComment'"
    

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
