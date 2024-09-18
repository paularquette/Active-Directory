#########################################################
# Script to fix Computer Ownership of AD Objects
# 
# Written By: Paul Arquette
# Date: September 17, 2024
#########################################################
Import-Module ActiveDirectory

#VARIABLES YOU NEED TO UPDATE
##############################
$NetBIOSName = "NETBIOSNAME"
$SearchBase = "OU=OUNAME,DC=business,DC=lab"

# Get Non-Standard Ownership in OU
#########################################################
$Remediate = Get-ADComputer -Filter * -SearchBase $SearchBase  -Properties ntSecurityDescriptor |Select-Object -Property Name, @{Name='ntSecurityDescriptorOwner';
Expression={$_.ntSecurityDescriptor.Owner }}, DistinguishedName |Where {
$_.ntSecurityDescriptorOwner -notlike "$NetBIOSName\Domain Admins" -and
$_.ntSecurityDescriptorOwner -notlike "$NetBIOSName\Enterprise Admins" -and
$_.ntSecurityDescriptorOwner -notlike "NT AUTHORITY\SYSTEM" -and
$_.ntSecurityDescriptorOwner -notlike "BUILTIN\ADMINISTRATORS" -and
$_.ntSecurityDescriptorOwner -notlike "$NetBIOSName\*$"  #Skip any objects created by other computer objects
}

ForEach ($item in $Remediate)
{

    $compname = $item.Name
    
    if ($item.ntSecurityDescriptorOwner)  #Needed to make sure Security Descriptor can be read and is not "blank"
    {
        
        $DN = $item.DistinguishedName
        $ntSDO = $item.ntSecurityDescriptorOwner

        #Check to see if Owner is Broken SID
        if ($ntSDO -like "O:S*")
        {
            $ntSDO = $ntSDO.Substring(2)  #Fix Broken SID in Variable so object can be removed with script
        }

        Write-Host "Working on $compname"

        $ACLs = (Get-ACL -Path "AD:\$DN")
        $BadACLs = (Get-ACL -Path "AD:\$DN").Access |Where {$_.IdentityReference -like $ntSDO -and $_.IsInherited -eq $false -and $_.AccessControlType -eq "Allow"}

        $ACLCount = 0

        ForEach ($ACE in $BadACLs)
        {
            if($ACE.ActiveDirectoryRights -eq "DeleteTree, ExtendedRight, Delete, GenericRead" -and
               $ACE.ObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "None" -and
               $ACE.AccessControlType -eq "Allow")
                {
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }
        
            if($ACE.ActiveDirectoryRights -eq "WriteProperty" -and
               $ACE.ObjectType -eq "4c164200-20c0-11d0-a768-00aa006e0529" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }  

            if($ACE.ActiveDirectoryRights -eq "Self" -and
               $ACE.ObjectType -eq "f3a64788-5306-11d1-a9c5-0000f80367c1" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }
        
        
            if($ACE.ActiveDirectoryRights -eq "Self" -and
               $ACE.ObjectType -eq "72e39547-7b18-11d1-adef-00c04fd8d5cd" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }        
        
        
            if($ACE.ActiveDirectoryRights -eq "WriteProperty" -and
               $ACE.ObjectType -eq "3e0abfd0-126a-11d0-a060-00aa006c33ed" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }       
        
            if($ACE.ActiveDirectoryRights -eq "WriteProperty" -and
               $ACE.ObjectType -eq "bf967953-0de6-11d0-a285-00aa003049e2" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }       
        
            if($ACE.ActiveDirectoryRights -eq "WriteProperty" -and
               $ACE.ObjectType -eq "bf967950-0de6-11d0-a285-00aa003049e2" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }        

            if($ACE.ActiveDirectoryRights -eq "WriteProperty" -and
               $ACE.ObjectType -eq "5f202010-79a5-11d0-9020-00c04fc2d4cf" -and
               $ACE.InheritedObjectType -eq "00000000-0000-0000-0000-000000000000" -and
               $ACE.ObjectFlags -eq "ObjectAceTypePresent" -and
               $ACE.AccessControlType -eq "Allow")
                { 
                    Write-Host "Critera Matched, Removing ACE" 
                    $ACLs.RemoveAccessRule($ACE)
                    $ACLCount = $ACLCount + 1
                }        
        
        }

        if ($ACLCount -eq 8)
        {
            $NewOwner = New-Object System.Security.Principal.NTAccount((Get-ADDomain).NetBIOSName, "Domain Admins")
            $ACLs.SetOwner($NewOwner)
            Set-ACL "AD:\$DN" $ACLs
        } else {
            Write-Host "Computer: $compname has a different creator than owner, does not have default 8 ACEs, or other issue, investigate"
        }
    }
}
