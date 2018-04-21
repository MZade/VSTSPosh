<#
    .SYNOPSIS
    Get changesets from VSTS.

    .PARAMETER AccountName
    The name of the VSTS account to use.

    .PARAMETER User
    This user name to authenticate to VSTS.

    .PARAMETER Token
    This personal access token to use to authenticate to VSTS.

    .PARAMETER Session
    The session object created by New-VstsSession.

    .PARAMETER Id
    The Id of a single cangeset to lookup.

    .PARAMETER FromDate
    Get changesets from the fromDate.

    .PARAMETER ToDate
    Get changesets until the toDate.
#>
function Get-VstsTfvcChangeSet
{
    [CmdletBinding(DefaultParameterSetName = 'Account')]
    param
    (
        [Parameter(Mandatory = $True, ParameterSetName = 'Account')]
        [String] $AccountName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [String] $User,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [String] $Token,

        [Parameter(Mandatory = $True, ParameterSetName = 'Session')]
        $Session,

        [Parameter()]
        [String] $Id,

        [Parameter()]
        [datetime] $FromDate,

        [Parameter()]
        [datetime] $ToDate        
    )

    if ($PSCmdlet.ParameterSetName -eq 'Account')
    {
        $Session = New-VstsSession -AccountName $AccountName -User $User -Token $Token
    }

    $path = 'tfvc/changesets'    
    $QueryStringParameters = @{}

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $path = ('{0}/{1}' -f $path, $Id)
    }
    else
    {        
        if ($PSBoundParameters.ContainsKey('FromDate'))
        {                        
            $QueryStringParameters += @{'searchCriteria.fromDate' = $FromDate.ToString("yyyy-MM-dd HH:mm:ss")}
        
        }

        if ($PSBoundParameters.ContainsKey('ToDate'))
        {            
            $QueryStringParameters += @{'searchCriteria.toDate' = $ToDate.ToString("yyyy-MM-dd HH:mm:ss")}             
        }
    }

    #$path = [System.Web.HttpUtility]::UrlEncode($path)

    $result = Invoke-VstsEndpoint `
        -Session $Session `
        -Project $Project `
        -Path $path `
        -ApiVersion '' `
        -QueryStringParameters $QueryStringParameters

    return $result.Value
}

<#
    .SYNOPSIS
    Get changesets from VSTS.

    .PARAMETER AccountName
    The name of the VSTS account to use.

    .PARAMETER User
    This user name to authenticate to VSTS.

    .PARAMETER Token
    This personal access token to use to authenticate to VSTS.

    .PARAMETER Session
    The session object created by New-VstsSession.

    .PARAMETER Id
    The Id of a single cangeset to lookup.

#>
function Get-VstsTfvcChangeSetWorkItems
{
    [CmdletBinding(DefaultParameterSetName = 'Account')]
    param
    (
        [Parameter(Mandatory = $True, ParameterSetName = 'Account')]
        [String] $AccountName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [String] $User,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [String] $Token,

        [Parameter(Mandatory = $True, ParameterSetName = 'Session')]
        $Session,

        [Parameter(Mandatory = $True)]
        [String] $Id

    )

    if ($PSCmdlet.ParameterSetName -eq 'Account')
    {
        $Session = New-VstsSession -AccountName $AccountName -User $User -Token $Token
    }

    $path = 'tfvc/changesets'
    $path = ('{0}/{1}/workItems' -f $path, $Id)

    $additionalInvokeParameters = @{}
         
    $result = Invoke-VstsEndpoint `
        -Session $Session `
        -Project $Project `
        -Path $path `
        -IgnoreProject $True `
        @additionalInvokeParameters

    return $result.Value
}