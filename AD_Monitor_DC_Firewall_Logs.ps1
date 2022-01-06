############################################################################################################
# Script to monitor Domain Controller Local Firewall Logs
# Written By: Paul Arquette
# Last Modified: January 4, 2022
# Last Modified For: Github
#
# NOTES:
# The purpose of this script is to have an automated way to crawl the local DC firewall logs to look for
# suspicious activity.
#
############################################################################################################

## HTML STYLING FOR E-MAIL
####################################################################################
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
#####################################################################################

# Variables You Need to Modify
####################################################
$DomainControllers = "" #Enter Multiple Servers like "Server1","Server2","Server3"
$EmailFrom = "" #i.e. "ScriptServer@domain.com"
$EmailTo = "" #Add multiple people comma seperated "email1@domain.com","email2@domain.com"
$EmailServer = "" #i.e. "smtp.server.com"
#####################################################

#Variables You DO NOT NEED TO Modify
#####################################################
$incoming = @()
$outgoingHTTP = @()
$outgoingNonHTTP = @()
#####################################################

ForEach ($DC in $DomainControllers)
{
    $FWPath = "\\$DC\c$\Windows\System32\LogFiles\Firewall\pfirewall.log"
    $FWPathOld = "\\$DC\c$\Windows\System32\LogFiles\Firewall\pfirewall.log.old"
    $GetFWLogs = Get-Content $FWPath |Where {$_ -like "*DROP*" -and $_ -notlike "*UDP 127.0.0.1 127.0.0.1*"}
    $GetFWLogsOld = Get-Content $FWPathOld |Where {$_ -like "*DROP*" -and $_ -notlike "*UDP 127.0.0.1 127.0.0.1*"}

    $CurrentDCIP = [System.Net.Dns]::GetHostAddresses($DC)
    $IP = $CurrentDCIP.IPAddressToString

    ForEach ($row in $GetFWLogsOld)
    {
        $row = $row -split " "
        
        if (($row[4] -eq $IP) -and (($row[7] -eq "80") -or ($row[7] -eq "443"))) {
            $outgoingHTTP += New-Object PSObject -Property @{Server=$DC;Date=$row[0];Time=$row[1];Protocol=$row[3];SrcIP=$row[4];SrcPort=$row[6];DstIP=$row[5];DstPort=$row[7]}
        }
        elseif (($row[4] -eq $IP) -and (($row[7] -ne "80") -and ($row[7] -ne "443"))) {
            $outgoingNonHttp += New-Object PSObject -Property @{Server=$DC;Date=$row[0];Time=$row[1];Protocol=$row[3];SrcIP=$row[4];SrcPort=$row[6];DstIP=$row[5];DstPort=$row[7]}
        }else{
                $incoming += New-Object PSObject -Property @{Server=$DC;Date=$row[0];Time=$row[1];Protocol=$row[3];SrcIP=$row[4];SrcPort=$row[6];DstIP=$row[5];DstPort=$row[7]}
            }
        } 
    
    if ($GetFWLogs)
    {
        ForEach ($row in $GetFWLogs)
        {
            $row = $row -split " "
            if (($row[4] -eq $IP) -and (($row[7] -eq "80") -or ($row[7] -eq "443"))) {
                $outgoingHTTP += New-Object PSObject -Property @{Server=$DC;Date=$row[0];Time=$row[1];Protocol=$row[3];SrcIP=$row[4];SrcPort=$row[6];DstIP=$row[5];DstPort=$row[7]}
            }
            elseif (($row[4] -eq $IP) -and (($row[7] -ne "80") -and ($row[7] -ne "443"))) {
                $outgoingNonHttp += New-Object PSObject -Property @{Server=$DC;Date=$row[0];Time=$row[1];Protocol=$row[3];SrcIP=$row[4];SrcPort=$row[6];DstIP=$row[5];DstPort=$row[7]}
            }else{
                    $incoming += New-Object PSObject -Property @{Server=$DC;Date=$row[0];Time=$row[1];Protocol=$row[3];SrcIP=$row[4];SrcPort=$row[6];DstIP=$row[5];DstPort=$row[7]}
                }
        } 
    }
}



if ($outgoingHTTP)
{
#Send E-mail To User & Administrator
        Write-Host "Sending Email"
        $emailResponse = $outgoingHTTP |Select-Object Server,Date,Time,Protocol,SrcIP,SrcPort,DstIP,DstPort |ConvertTo-Html -Head $style
        $emailBody ="Domain Controller Blocked Outoing HTTP-HTTPS Firewall Logs <br /> $emailResponse"
        $emailSubject = "Domain Controller Blocked Outgoing Firewall Logs"
        Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $emailSubject -Body $emailBody -BodyAsHtml -SmtpServer $EmailServer       
}
if ($incoming)
{
#Send E-mail To User & Administrator
        Write-Host "Sending Email"
        $emailResponse = $incoming |Select-Object Server,Date,Time,Protocol,SrcIP,SrcPort,DstIP,DstPort |ConvertTo-Html -Head $style
        $emailBody ="Domain Controller Blocked Incoming Firewall Logs <br /> $emailResponse"
        $emailSubject = "Domain Controller Blocked INCOMING Firewall Logs"
        Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $emailSubject -Body $emailBody -BodyAsHtml -SmtpServer $EmailServer 
}

if ($outgoingNonHttp)
{
#Send E-mail To User & Administrator
        Write-Host "Sending Email"
        $emailResponse = $outgoingNonHttp |Select-Object Server,Date,Time,Protocol,SrcIP,SrcPort,DstIP,DstPort |ConvertTo-Html -Head $style
        $emailBody ="Domain Controller Blocked OUTGOING NON HTTP-HTTPS <br /> $emailResponse"
        $emailSubject = "Domain Controller Blocked OUTGOING NON HTTP-HTTPS"
        Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $emailSubject -Body $emailBody -BodyAsHtml -SmtpServer $EmailServer
}
