# Creates IP access list for filtering traffic in an Atlas project.
# Dennis Khau, 5/26/2021

$publicKey = "" #Atlas Project Public Key
$privateKey = "" #Atlas Project Private Key
$filterDesc = "" #e.g.: Test environment for microservices
$projectID = "" #Atlas Project ID
$sourceIPs = @('') #List of IPs, e.g.: '1.2.3.4', '5.6.7.8', 1.1.2.3
$baseUrl = "https://cloud.mongodb.com/api/atlas/v1.0"
$apiEndpoint = "/groups/"+$projectID+"/accessList"

[securestring]$securePass = ConvertTo-SecureString $privateKey -AsPlainText -Force
[pscredential]$credential = New-Object System.Management.Automation.PSCredential ($publicKey, $securePass)

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", 'application/json')
$headers.Add("Content-Type", 'application/json')

$rules = ""
#rulesets types include:  ipAddress, cidrBlock, awsSecurityGroup
foreach ($ip in $sourceIPs) {
    if ($ip -eq $sourceIPs[-1])
    {
        $rules += '{ "ipAddress" : "' +$ip+ '", "comment" : "' +$filterDesc+ '" }'
    } else {
        $rules += '{ "ipAddress" : "' +$ip+ '", "comment" : "' +$filterDesc+ '" },'
    }    
}

$body = '
[
    ' +$rules+ '
]
'

$apiResourceUri = $baseUrl + $apiEndpoint
Invoke-RestMethod -Method 'POST' -Uri $apiResourceUri -Credential $credential -Headers $headers -Body $body
