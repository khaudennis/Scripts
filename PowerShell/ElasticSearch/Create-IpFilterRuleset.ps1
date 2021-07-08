# Creates IP filtering rule set for filtering traffic in Elastic Cloud.
# Dennis Khau, 5/26/2021

$apiKey = "" #Elastic Cloud API Key
$filterName = "" #e.g.: Plan-Service-Test-EUS2-001
$filterDesc = "" #e.g.: Test environment for microservices
$filterRegion = "azure-eastus2"
$sourceIPs = @('') #List of IPs, e.g.: '1.2.3.4', '5.6.7.8', 1.1.2.3
$url = "https://api.elastic-cloud.com/api/v1/deployments/traffic-filter/rulesets"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", 'ApiKey '+$apiKey+'')
$headers.Add("Content-Type", 'application/json')

$rules = ""
foreach ($ip in $sourceIPs) {
    if ($ip -eq $sourceIPs[-1])
    {
        $rules += '{ "source" : "' +$ip+ '" }'
    } else {
        $rules += '{ "source" : "' +$ip+ '" },'
    }    
}

$body = '
{
   "description" : "' +$filterDesc+ '",
   "include_by_default" : false,
   "name" : "' +$filterName+ '",
   "region" : "' +$filterRegion+ '",
   "rules" : [
      ' +$rules+ '
   ],
   "type" : "ip"
}
'

#$jsonBody = $body | ConvertTo-Json

Invoke-RestMethod -Method 'Post' -Uri $url -Headers $headers -Body $body
