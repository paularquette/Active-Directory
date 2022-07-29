# Active-Directory

These are the scripts that I use to help maintain Active Directory environments that I'm responsible for or scripts I have written to help automate tasks that I'm willing to share.

## Domain Controller Health Check
- Powershellbros.com DC Health E-mail Report (https://www.powershellbros.com/basic-dc-health-email-report-via-powershell/)
- Full Script: http://www.powershellbros.com/wp-content/uploads/2018/01/DCHealth.txt

## Change AD User Attributes by OU
- This was a script that I wrote in order to make sure all properties on user objects were filled out to sync the user objects up to Azure AD
- [Change AD User Attributes by OU Location](https://github.com/paularquette/Active-Directory/blob/main/AD_Change_User_Account_Properties_ByOU.ps1)

## Check External DNS for DC Records
- This script was written after one of our Domain Controller DNS records disappeared in our external DNS provider.  This script will monitor the DNS records and report back if any of your Domain Controller's disappear from DNS.
- [Check External DNS for DC Records](https://github.com/paularquette/Active-Directory/blob/main/AD_Check_DNS_For_Domain_Controllers.ps1)

## Check For Deleted User Objects in AD Recycle Bin
- This script was written because we have many OU Admins in Active Directory and they all have the ability to delete user objects they own.  In order to monitor for accidently deleted user objects this script was written.
- [Check For Deleted User Objects in AD Recycle Bin](https://github.com/paularquette/Active-Directory/blob/main/AD_Check_For_Deleted_User_Accounts.ps1)
