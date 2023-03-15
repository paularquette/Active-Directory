############################################################################################################
# Script to check ExtensionAttributes in Active Directory
# Written By: Paul Arquette
# Last Modified: March 14, 2023
# Last Modified For: Github
#
# NOTES:
# The purpose of this script is to check users, computers, and groups to see if extensionAttributes are in use
#
############################################################################################################
#Check Computers
$i = 1
while ($i -lt 16)
{
$exAtrib = "extensionAttribute"
$exAtrib = $exAtrib + "$i"
Write-Host "Checking Computers for $exAtrib"
$inUse = Get-ADComputer -Properties $exAtrib -Filter "$exAtrib -like '*'" |Select Name,$exAtrib

if ($inUse)
{
     Write-Host "Computer Check - $exAtrib is in use"
} else {
     Write-Host "Computer Check - $exAtrib is NOT in use"
}

$i = $i + 1
}
############################################
#Check Groups
$i = 1
while ($i -lt 16)
{
$exAtrib = "extensionAttribute"
$exAtrib = $exAtrib + "$i"
Write-Host "Checking Groups for $exAtrib"
$inUse = Get-ADGroup -Properties $exAtrib -Filter "$exAtrib -like '*'" |Select Name,$exAtrib

if ($inUse)
{
     Write-Host "Group Check - $exAtrib is in use"
} else {
     Write-Host "Group Check - $exAtrib is NOT in use"
}

$i = $i + 1
}
############################################
#Check Users
$i = 1
while ($i -lt 16)
{
$exAtrib = "extensionAttribute"
$exAtrib = $exAtrib + "$i"
Write-Host "Checking Users for $exAtrib"
$inUse = Get-ADUser -Properties $exAtrib -Filter "$exAtrib -like '*'" |Select Name,$exAtrib

if ($inUse)
{
     Write-Host "User Check - $exAtrib is in use"
} else {
     Write-Host "User Check - $exAtrib is NOT in use"
}

$i = $i + 1
}
