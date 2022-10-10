#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_fsrm_setting
short_description: Modify general settings
description:
- Modify the File Server Resource Manager general settings.
options:
  state:
    description:
    - Set to C(present) to ensure setting is set.
    - Set to C(absent) to ensure setting is removed.
    type: str
    choices: [ absent, present ]
  smtp_server:
    description:
    - The FQDN or IP-Address of the smtp server.
    type: str
  admin_email_address:
    description:
    - The default email address to use for notifications.
    type: str
author:
- Dustin Strobel (@d-strobel)
'''

EXAMPLES = r'''
- name: Set an environment variable for all users
  windows.win_fsrm_setting:
    smtp_server: smtp.example.intern
    admin_email_address: fsrm-monitoring@example.com
    state: present
'''