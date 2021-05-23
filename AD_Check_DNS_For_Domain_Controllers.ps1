############################################################################################################
# Script to monitor external DNS for DC records
# Written By: Paul Arquette
# Last Modified: May 23, 2021
# Last Modified For: Github
#
# NOTES:
# The purpose of this script was to monitor our external DNS servers for Domain Controller records.
# Since we don't run DNS and had an issue in the past with DC records disappearing I wrote a script
# to monitor DNS to see if we ever lost any of the DC records.  I run this every 15 minutes from our 
# scripting server.
############################################################################################################

############################################################################################################
# DEFINE VARIABLES
####################
$dnsdomainname = "" #ad.site.com
$IPHosts = @('10.0.0.0','10.0.0.1') #Add as many DCs as you want to monitor

$EmailFrom = ""
$EmailTo = "" #Add multiple people comma seperated "email1@domain.com","email2@domain.com"
$emailSubject = "Domain Controller DNS Objects Missing!"
$EmailServer = ""
############################################################################################################

$ADHosts = Resolve-DnsName $dnsdomainname
$MissingHosts = @()

if ($ADHosts.Count -lt $IPHosts.Count)
{
    ForEach ($ip in $IPHosts)
    {      
        if ($ADHosts.IPAddress -contains $ip)
        {
            Write-Host "DC Found For IP Address: $ip"
        } else {
            Write-Host "DC Not Found For IP Address: $ip"
            $MissingHosts += "The Domain Controller with IP $ip is missing in dns!" 
        }
    }
}

if($MissingHosts)
{
    Write-Host $MissingHosts
    $date = Get-Date
    Write-Host "Sending Email"
    $emailBody = "
    The Following DCs Are NOT in $dnsdomainname (DNS) <br />
    ========================================================
<br />
"
    $emailBody += $MissingHosts -join "<br />" |Out-String
    $emailBody +="<br /><br />This message was automatically generated at $date"    
    
    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $emailSubject -Body $emailBody -BodyAsHtml -SmtpServer $EmailServer
}