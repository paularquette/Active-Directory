############################################################################################################
# Script to monitor AD Recycle Bin For Accidental Account Deletions
# Written By: Paul Arquette
# Last Modified: May 23, 2021
# Last Modified For: Github
#
# NOTES:
# The purpose of this script was to monitor AD recycle bin.  In an environment with multiple OU admins that
# are allowed ownership of users for GPO purposes we needed a mechanism to monitor for accidental user
# deletion. I run this from our scripting server every 15 minutes.
############################################################################################################

############################################################################################################
# Define Variables
####################
$changedate = Get-Date
$changedate = $changedate.AddDays(-3)  #Number of days to look back for deleted accounts
$badusers = @()

$EmailFrom = ""
$EmailTo = "" #Add multiple people comma seperated "email1@domain.com","email2@domain.com"
$emailSubject = "Active Directory Deleted Users Found!"
$EmailServer = ""
############################################################################################################

$usersDel = Get-ADObject -filter 'whenChanged -gt $changedate -and isDeleted -eq $true' -includeDeletedObjects -property * 

ForEach ($i in $usersDel)
{
    $sam = $i.sAMAccountName
        if ($sam -match "^[a-zA-Z]{8}$") #Match RegEx of deleted accounts you want to look for (This example is just 8 letters)
        {
            if (($sam -like "zz*"))  #Add exceptions to accounts found you don't want to be notified about
            {
                break
            }

            Write-Host "$sam is in the AD Recycle Bin!"
            $badusers += "$sam is in the AD Recycle Bin!"
        }
}

if ($badusers)
{
        Write-Host "Sending Email"
        $emailBody = ForEach ($row in $badusers) {"<br />",$row}
        Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $emailSubject -Body $($emailBody) -BodyAsHtml -SmtpServer $EmailServer
}