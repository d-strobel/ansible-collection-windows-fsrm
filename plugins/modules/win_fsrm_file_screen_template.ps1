#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options = @{
        name          = @{ type = "str"; required = $true }
        description   = @{ type = "str" }
        active_check  = @{ type = "bool"; default = $true }
        file_group    = @{ type = "list"; elements = "str" }
        email_notify  = @{ type = "bool"; default = $false }
        email_to      = @{ type = "str"; default = "[Admin Email]" }
        email_subject = @{ type = "str"; }
        email_body    = @{ type = "str" }
        state         = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    required_if = @(
        @("state", "present", @("file_group"))
    )
    required_together = @(
        @("email_notify", "email_to", "email_subject", "email_body")
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# ErrorAction
$ErrorActionPreference = 'Stop'

# Functions
function New-FsrmActionEmail {
    return New-FsrmAction `
        -Type Email `
        -MailTo $module.Params.email_to `
        -Subject $module.Params.email_subject `
        -Body $module.Params.body `
        -RunLimitInterval 120
}

# State
if ($module.Params.state -eq "present") {
    $present = $true
}
else {
    $present = $false
}

# Ensure powershell module is loaded
$fsrm_module = "FileServerResourceManager"

try {
    if ($null -eq (Get-Module $fsrm_module -ErrorAction SilentlyContinue)) {
        Import-Module $fsrm_module
    }
}
catch {
    $module.FailJson("Failed to load PowerShell module $fsrm_module.", $_)
}

# Get template
$fileScreenTemplate = Get-FsrmFileScreenTemplate -Name $module.Params.name -ErrorAction SilentlyContinue

if ($null -eq $fileScreenTemplate -and $present) {
    if ($module.Params.email_notify) {
        try {
            New-FsrmFileScreenTemplate `
                -Name $templateName `
                -IncludeGroup $includedGroups `
                -Notification $(New-FsrmActionEmail) `
                -Active:$module.Params.active_check `
                -WhatIf:$module.CheckMode `
            | Out-Null
        }
        catch {
            $module.FailJson("Failed to create file screen template '$($module.Params.name)'.", $_)
        }
        $module.Result.changed = $true
        $module.ExitJson()
    }
    else {
        try {
            New-FsrmFileScreenTemplate `
                -Name $templateName `
                -IncludeGroup $includedGroups `
                -Active:$moduel.Params.active_check `
                -WhatIf:$module.CheckMode `
            | Out-Null
        }
        catch {
            $module.FailJson("Failed to create file screen template '$($module.Params.name)'.", $_)
        }
        $module.Result.changed = $true
        $module.ExitJson()
    }
}

# Remove template if state == absent
if ($fileScreenTemplate -and -not $present) {
    try {
        Remove-FsrmFileScreenTemplate `
            -Name $module.Params.name `
            -confirm:$false `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to remove file screen template '$($module.Params.name)'.", $_)
    }
    $module.Result.changed = $true
    $module.ExitJson()
}

# Return
$module.ExitJson()