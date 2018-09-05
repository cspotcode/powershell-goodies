# Read entire hosts file as a string
# Find-and-replace fenced block

$configPath = "$( $HOME )/.hostswitcher"
$hostsPath = "C:\windows\System32\drivers\etc\hosts"

function Enable-HostGroup {
    [CmdletBinding()]
    param(
        [switch]
        $dryrun
    )
    DynamicParam {
        $params = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        __addGroupNameParam $params
        return $params
    }
    Begin {
        $group = $PSBoundParameters.group
        $hosts = __gethosts
        $sectionContents = get-content -raw -encoding utf8 "$configPath/groups/$group"
        $newHosts = __addSection $hosts $group $sectionContents
        if($dryrun) {
            write-output $newHosts
        } else {
            __writehosts $newHosts
        }
    }
}

function Disable-HostGroup {
    [CmdletBinding()]
    param(
        [switch]
        $dryrun
    )
    DynamicParam {
        $params= [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        __addGroupNameParam $params
        return $params
    }
    Begin {
        $group = $PSBoundParameters.group
        $hosts = __gethosts
        $newHosts = __removeSection $hosts $group
        if($dryrun) {
            write-output $newHosts
        } else {
            __writehosts $newHosts
        }
    }
}

function InteractiveHostGroupToggle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('enable', 'disable')]
        $action,
        [switch]
        $dryrun
    )
    DynamicParam {
        $params= [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        __addGroupNameParam $params
        return $params
    }
    Begin {
        $group = $PSBoundParameters.group
        switch($action) {
            enable {
                Enable-HostGroup -group $group
            }
            disable {
                Disable-HostGroup -group $group
            }
        }
    }
}

function Get-HostGroups {
    $hosts = __gethosts
    get-childitem "$configPath/groups" | ForEach-Object {
        [pscustomobject]@{
            name = $_.name
            enabled = (__isEnabled $hosts $_.name)
        }
    }
}

function __addGroupNameParam($RuntimeParameterDictionary, $paramName = 'Group') {
    $groupNames = get-hostgroups | foreach-object { $_.name }
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName, [string],
      # Set of [Attribute]s on this param
      [System.Collections.ObjectModel.Collection[System.Attribute]]@((
        # [Parameter()]
        New-Object System.Management.Automation.ParameterAttribute -Property @{
          Mandatory = $True
          Position = 1
        }
      ), (& {
        # [ValidateSet()]
        return New-Object System.Management.Automation.ValidateSetAttribute($groupNames)
      }))
    )
    $RuntimeParameterDictionary.Add($ParamName, $RuntimeParameter)
}

function __addSection($hosts, $groupName, $groupContent) {
    "$hosts`n### START HOSTS GROUP: $groupName`n$groupContent`n### END HOSTS GROUP: $groupName`n"
}

function __removeSection($hosts, $groupName) {
    $hosts -replace "`n{0,2}### START HOSTS GROUP: $( [regex]::escape($groupName) )`n[\s\S]*?### END HOSTS GROUP: $( [regex]::Escape($groupName) )`n{0,2}",'#REMOVED KONG'
}

function __isEnabled($hosts, $groupName) {
    $hosts -match "### START HOSTS GROUP: $( [regex]::escape($groupName) )`n"

}

function __gethosts() {
    get-content -raw -encoding utf8 $hostsPath
}

function __writehosts($value) {
    set-content $hostsPath $value
}
