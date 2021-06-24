############################################################################################################
# Script to make changes to all AD User Objects in an OU
# Written By: Paul Arquette
# Last Modified: June 23, 2021
# Last Modified For: Github
#
# NOTES:
# The purpose of this script to make attribute changes to all AD User Objects limited by OU Scope. This
# script was used to make changes to accounts so they would sync to Azure AD.
#
# Criteria I was given to accomplish:
# 
# 1. displayName cannot be null
# 2. userPrincipalName must be user@domain.com
# 3. proxyAddresses must contain sip:user@domain.com & smtp:user@domain.com
# 4. mail must match user@domain.com
# 5. mailNickname must match samAccountName
# 6. extensionAttribute15 must match "SYNC"
#
############################################################################################################

#Variables You Need To Modify
######################################################
$OUPath = "OU=XXX,DC=AD,DC=DOMAIN,DC=COM" 
$OGDomainSuffix = "@ad.domain.com"
$NewDomainSuffix = "@domain.com"

#Grab User Attributes That Need Changed
######################################################
$ADUserInfo = Get-ADUser -Filter * -SearchBase $OUPath -SearchScope OneLevel -Properties * |Select-Object displayName,userPrincipalName,proxyAddresses,mail,mailNickname,extensionAttribute15,samAccountName

#ForEach User Object Check Fields and Make Changes
######################################################
ForEach ($ADUser in $ADUserInfo)
{
    #Gather Variables For Each User
    ######################################################
    $UserSAM = $ADUser.samAccountName
    $UserSAMOG = $UserSAM + $OGDomainSuffix
    $UserSAMNew = $UserSAM + $NewDomainSuffix
    $UserDisplayName = $ADUser.displayName
    $UserUPN = $ADUser.userPrincipalName
    $UserProxy = $ADUser.proxyAddresses
    $Usermail = $ADUser.mail
    $UsermailNickName = $ADUser.mailNickname
    $Userex15 = $ADUser.extensionAttribute15

    #Write-Host Executing Script for Account $UserSAM
    ######################################################
    Write-Host "Currently Modifying $UserSAM"
    
    #Replace Display Name Field if blank
    ######################################################
    if (!$UserDisplayName)
    {
        #DisplayName Can't Be Blank, Set to samAccountName
        ######################################################
        Get-Aduser $UserSAM -Properties displayName |Set-ADUser -Replace @{displayName=$UserSAM}
    }

    #Set UPN to @domain.com if set to @ad.domain.com
    ######################################################
    if ($UserUPN -like "*$OGDomainSuffix")
    {
        Get-ADuser $UserSAM -Properties userPrincipalName |Set-ADuser -Replace @{userPrincipalName=$UserSAMNew}
    }

    #Set proxyAddresses if they are unset
    #Needs sip:user@domain.com & smtp:user@domain.com
    ######################################################
    if (($UserProxy -like "*sip:$UserSAMNew*") -and ($UserProxy -like "*smtp:$UserSAMNew*"))
    {
        #Everything is good, skip
    } else {
        Get-ADUser $UserSAM -Properties proxyAddresses |Set-Aduser -add @{ProxyAddresses="smtp:$UserSAMNew","sip:$UserSAMNew"}
    }

    #Set Mail if Not Set
    ######################################################
    if ($Usermail -eq "$UserSAMNew")
    {
        #Everything is good, skip
    } else {
        Get-ADUser $UserSAM -Properties mail | Set-ADUser -Replace @{mail="$UserSAMNew"}
    }

    #Set Mail Nickname if its not correct
    ######################################################
    if ($UsermailNickName -like $UserSAM)
    {

    } else {
        Get-ADUser $UserSAM -Properties mailNickname |Set-ADUser -Replace @{mailNickname=$UserSAM} 
    }

    #Set extensionAttribute15 if not set
    ######################################################
    if ($Userex15 -eq "SYNC")
    {
    } else {
        Get-ADUser $UserSAM -Properties extensionAttribute15 |Set-ADuser -Replace @{extensionAttribute15="SYNC"}
    }
}