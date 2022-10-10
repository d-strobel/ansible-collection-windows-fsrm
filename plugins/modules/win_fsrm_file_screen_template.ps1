#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
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
    required_if= @(
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


# Return
$module.ExitJson()