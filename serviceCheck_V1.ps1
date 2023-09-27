# Function to send an email via Microsoft Graph API using the provided parameters
function Send-EmailViaGraphAPI {
    param (
        [string]$Sender,
        [string]$Recipient,
        [string]$Subject,
        [string]$Body,
        [string]$ContentType,
        [switch]$SaveToSentItems
    )

    # Import the Microsoft.Graph.Users.Actions module
    Import-Module Microsoft.Graph.Users.Actions

    # Connect to Microsoft Graph with the required permissions
    Connect-MgGraph -Scopes 'Mail.Send', 'Mail.Send.Shared'

    # Define the email parameters
    $params = @{
        Message         = @{
            Subject       = $Subject
            Body          = @{
                ContentType = $ContentType
                Content     = $Body
            }
            ToRecipients  = @(
                @{
                    EmailAddress = @{
                        Address = $Recipient
                    }
                }
            )
        }
    }

    if ($SaveToSentItems) {
        $params.SaveToSentItems = $true
    }

    # Send the email
    Send-MgUserMail -UserId $Sender -BodyParameter $params
}

# Function to get an OAuth access token
function Get-AccessToken {
    param (
        [string]$clientId,
        [string]$clientSecret,
        [string]$tenantId
    )

    # Define the OAuth 2.0 token endpoint
    $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

    # Create a credential object
    $credential = [System.Text.Encoding]::UTF8.GetBytes("${clientId}:${clientSecret}")
    $base64AuthInfo = [System.Convert]::ToBase64String($credential)

    # Define the token request body
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
    }

    # Send a POST request to get the access token
    $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Headers @{
        Authorization = "Basic $base64AuthInfo"
    } -Method POST -ContentType "application/x-www-form-urlencoded" -Body $body

    # Extract the access token
    return $tokenResponse.access_token
}

# Define the name of the service you want to monitor
$ServiceName = "FileMaker Server"

# Check if the service is running
$ServiceStatus = Get-Service -Name $ServiceName

# Set your application's details
$clientId = "<clientID>"
$clientSecret = "<clientSecret>"
$tenantId = "<tenantID>"
$redirectUri = "http://localhost"  # This should match your Azure AD app's redirect URI

# Get the access token using the function
$accessToken = Get-AccessToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId

if ($ServiceStatus.Status -ne "Running") {
    # Service is stopped; send an email alert
    $sender = "<youremailaddress>"
    $EmailRecipient = "<whoYouNeedToSendItTo>"
    $EmailSubject = "FileMaker Server Service Alert"
    $EmailBody = "The FileMaker Server service is stopped on the server."
    $type = "HTML"
    $save = $false

    Send-EmailViaGraphAPI -Sender $sender -Recipient $EmailRecipient -Subject $EmailSubject -Body $EmailBody -ContentType $type -SaveToSentItems $save
}
else {
    # Service is running; send an email alert or perform additional checks here
    $sender = "<youremailaddress>"
    $EmailRecipient = "<whoYouNeedToSendItTo>"
    $EmailSubject = "FileMaker Server Service Alert Running"
    $EmailBody = "The FileMaker Server service is running on the server."
    $type = "HTML"
    $save = $false

    Send-EmailViaGraphAPI -Sender $sender -Recipient $EmailRecipient -Subject $EmailSubject -Body $EmailBody -ContentType $type -SaveToSentItems $save
}

# --------------------------------------------- Checking CPU/Memory Usage --------------------------------------------------------------------

# Define the name of the program (process) you want to monitor
$ProgramName = "fmwipd"

# Check if the program is running
$ProgramProcess = Get-Process | Where-Object { $_.ProcessName -eq $ProgramName }



if ($ProgramProcess) {
    # Get CPU and memory usage for the program
    $CPUPercentage = ($ProgramProcess.CPUUsage / (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors) * 100
    # $MemoryUsageBytes = $ProgramProcess.WorkingSet64
    # $MemoryUsageMB = ($MemoryUsageBytes[0] / 1MB)

    # Define the threshold values for CPU and Memory usage (75% in this example)
    $CPULimit = 75
    # $MemoryLimit = 100

    if ($CPUPercentage -gt $CPULimit) {
        # CPU usage exceeds the threshold; send an email alert
        $sender = "<youremailaddress>"
        $EmailRecipient = "glen@datavast.net"
        $EmailSubject = "Program CPU Usage Alert - $ProgramName"
        $EmailBody = "The CPU usage of the $ProgramName program has exceeded the threshold. Current CPU Usage: $CPUPercentage%"
        $type = "HTML"
        $save = $false

        Send-EmailViaGraphAPI -Sender $sender -Recipient $EmailRecipient -Subject $EmailSubject -Body $EmailBody -ContentType $type -SaveToSentItems $save
    } else {
        # CPU usage below the threshold; send an email alert
        $sender = "<youremailaddress>"
        $EmailRecipient = "<whoYouNeedToSendItTo>"
        $EmailSubject = "Program CPU Usage Below Alert - $ProgramName"
        $EmailBody = "The CPU usage of the $ProgramName program is below the threshold. Current CPU Usage: $CPUPercentage%"
        $type = "HTML"
        $save = $false

        Send-EmailViaGraphAPI -Sender $sender -Recipient $EmailRecipient -Subject $EmailSubject -Body $EmailBody -ContentType $type -SaveToSentItems $save
    }

}
else {
    # Program is not running; send an email alert or perform additional checks here
    $sender = "<youremailaddress>"
    $EmailRecipient = "<whoYouNeedToSendItTo>"
    $EmailSubject = "Program Not Found - $ProgramName"
    $EmailBody = "The program with the name $ProgramName is not running."
    $type = "HTML"
    $save = $false

    Send-EmailViaGraphAPI -Sender $sender -Recipient $EmailRecipient -Subject $EmailSubject -Body $EmailBody -ContentType $type -SaveToSentItems $save
}

Write-Host "Powershell script is done running"
