# The first part of the script to obtain the access token remains the same...

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
#
## Second request with updated Bearer token
#$urlCommand = "$apiEndpoint/v3/process/restreamer-ui%3Aegress%3Afacebook%3A10fc828f-964b-43b7-b981-67ac6e3b234d/command"
#$headersCommand = @{
#    'User-Agent'      = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0'
#    'Accept'          = '*/*'
#    'Accept-Language' = 'en-US,en;q=0.5'
#    'Accept-Encoding' = 'gzip, deflate'
#    'Referer'         = 'http://192.168.2.118:8080/ui/'
#    'Content-Type'    = 'application/json'
#    'Authorization'   = "Bearer $access_token"
#    'Origin'          = 'http://192.168.2.118:8080'
#    'DNT'             = '1'
#    'Sec-GPC'         = '1'
#}
#
#$bodyCommand = @{
#    command = 'start'
#} | ConvertTo-Json
#
#$responseCommand = Invoke-RestMethod -Uri $urlCommand -Method Put -Headers $headersCommand -Body $bodyCommand
#
## Output or use $responseCommand as needed
#Write-Host "Response from the second request: $($responseCommand)"

function Send-CommandToRestreamer($instanceId)
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
        command = 'start'
    } | ConvertTo-Json

    $responseCommand = Invoke-RestMethod -Uri $urlCommand -Method Put -Headers $headersCommand -Body $bodyCommand

    # Output or use $responseCommand as needed
    Write-Host "Response from enabling $instanceId\: $responseCommand"

}

Send-CommandToRestreamer -instanceId 'restreamer-ui%3Aegress%3Afacebook%3A10fc828f-964b-43b7-b981-67ac6e3b234d'

Send-CommandToRestreamer -instanceId 'restreamer-ui%3Aegress%3Ayoutube%3A00f4f510-2949-4607-bfc6-9434622ee78f'

