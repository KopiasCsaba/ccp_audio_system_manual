# This script is called by the task scheduler job exported into: scheduled-task-for-enable-restreamer-streams.xml


# arg[0] might be 'start' or 'stop'

if ($args[0] -ne "start" -and $args[0] -ne "stop" -and $args[0] -ne "stop_confirm" -and $args[0] -ne "start_confirm") {
    Write-Error "Invalid argument: $($args[0]). You must specify 'start' or 'stop'."
    exit
}

$command = $args[0]

if ($command -eq "stop_confirm") {
    # Load the assembly for Windows Forms
    Add-Type -AssemblyName System.Windows.Forms

    # Create a message box showing Yes and No buttons
    $messageBoxResult = [System.Windows.Forms.MessageBox]::Show("Do you want to STOP the live stream (yt, fb)?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    # Check the result of the message box
    if ($messageBoxResult -eq [System.Windows.Forms.DialogResult]::No) {
        # Exit the script if No is selected
        Write-Host "Action cancelled."
        exit
    } else {
        Write-Host "Proceeding with the action..."
        # Add the action code here that needs to be executed if confirmed
        $command="stop"
    }
}

if ($command -eq "start_confirm") {
    # Load the assembly for Windows Forms
    Add-Type -AssemblyName System.Windows.Forms

    # Create a message box showing Yes and No buttons
    $messageBoxResult = [System.Windows.Forms.MessageBox]::Show("Do you want to START the live stream (yt, fb)?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    # Check the result of the message box
    if ($messageBoxResult -eq [System.Windows.Forms.DialogResult]::No) {
        # Exit the script if No is selected
        Write-Host "Action cancelled."
        exit
    } else {
        Write-Host "Proceeding with the action..."
        # Add the action code here that needs to be executed if confirmed
        $command="start"
    }
}


# Obtain access token
$apiEndpoint = "http://192.168.2.118:8080/api"
$urlLogin = "$apiEndpoint/login"
$headersLogin = @{
    'User-Agent' = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0'
    'Accept' = '*/*'
    'Accept-Language' = 'en-US,en;q=0.5'
    'Accept-Encoding' = 'gzip, deflate'
    'Referer' = 'http://192.168.2.118:8080/ui/'
    'Content-Type' = 'application/json'
    'Origin' = 'http://192.168.2.118:8080'
    'DNT' = '1'
    'Sec-GPC' = '1'
}

$bodyLogin = @{
    username = 'ccpadmin'
    password = 'door table window pulpit 32424'
} | ConvertTo-Json

$responseLogin = Invoke-RestMethod -Uri $urlLogin -Method Post -Headers $headersLogin -Body $bodyLogin

Write-Host "Response from the login request: $( $responseCommand )"

# Access the access_token in the response
$global:access_token = $responseLogin.access_token

# Output or use $access_token as needed
Write-Host "Access Token: $access_token"


function Send-CommandToRestreamer($instanceId,$command)
{
    $urlCommand = "http://192.168.2.118:8080/api/v3/process/$instanceId/command"

    $headersCommand = @{
        'User-Agent' = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0'
        'Accept' = '*/*'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate'
        'Referer' = 'http://192.168.2.118:8080/ui/'
        'Content-Type' = 'application/json'
        'Authorization' = "Bearer $global:access_token"
        'Origin' = 'http://192.168.2.118:8080'
        'DNT' = '1'
        'Sec-GPC' = '1'
    }

    $bodyCommand = @{
        command = $command
    } | ConvertTo-Json

    $responseCommand = Invoke-RestMethod -Uri $urlCommand -Method Put -Headers $headersCommand -Body $bodyCommand

    # Output or use $responseCommand as needed
    Write-Host "Response from enabling $instanceId\: $responseCommand"

}

Send-CommandToRestreamer -instanceId 'restreamer-ui%3Aegress%3Afacebook%3A10fc828f-964b-43b7-b981-67ac6e3b234d' -command $command

Send-CommandToRestreamer -instanceId 'restreamer-ui%3Aegress%3Ayoutube%3A00f4f510-2949-4607-bfc6-9434622ee78f' -command $command

