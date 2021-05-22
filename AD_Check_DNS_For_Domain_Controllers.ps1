# Simple Script To Monitor DNS for DC Entries
# This script was created because we are not using AD DNS, had issue prior with DNS dropping for a DC
# This will monitor to make sure you have the correct number of records in DNS for the DCs
# I run this script on our scripting server every 15 minutes
# Make sure the DCs stay in XX.YYYY.ZZZ DNS
############################################################################################################

############################################################################################################
# DEFINE VARIABLES
############################################################################################################
$dnsdomainname = "" #ad.site.com
$IPHosts = @('10.0.0.0','10.0.0.1') #Add as many DCs as you want to monitor

$EmailFrom = ""
$EmailTo = "" #Add multiple people comma seperated "email1@domain.com","email2@domain.com"
$emailSubject = "Domain Controller DNS Objects Missing!"
$EmailServer = ""
############################################################################################################
$ADHosts = Resolve-DnsName $dnsdomainname
$MissingHosts = @()

if ($ADHosts.Count -ne $IPHosts.Count)
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

    #Send E-mail 
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