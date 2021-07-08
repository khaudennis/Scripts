# Test an endpoint and the HTTP status code.
# Dennis Khau, 7/7/2021

$baseUri = "https://api/v1"
$subKey = "/?&subKey=abcdefgh"
$endpoints = @('endpoint1',
            'endpoint2',
            'endpoint3')
$qs = @('&$select=id',
        '&$select=type',
        '&$select=''type''')

foreach ($endpoint in $endpoints) {
    if ($qs.Length -gt 1) {
        foreach ($q in $qs) {
            Get-Endpoint -Query $q
        }
    } else {
        Get-Endpoint -Query $qs
    }
}
function Get-Endpoint {
    param (
        [Parameter()]
        $Query
    )

    $apiUri = ""
    $sw = [Diagnostics.Stopwatch]::new()
    $apiUri = $baseUri + "/" + $endpoint + $subKey + $Query
    $req = [System.Net.WebRequest]::Create($apiUri)

    try {
        $sw.Start()
        $resp = $req.GetResponse()
        $sw.Stop()
        $httpCode = [int]$resp.StatusCode
        Write-Host ($apiUri + " returned " + $httpCode + "(Response Time: " + [PSCustomObject]@{
            Milliseconds = $sw.ElapsedMilliseconds
        } + ")")
        if ($null -eq $resp) { } else { $resp.Close() }
    } catch {
        $sw.Stop()                
        Write-Host ("Error on " + $apiUri + "(Response Time: " + [PSCustomObject]@{
            Milliseconds = $sw.ElapsedMilliseconds
        } + ")")
        if ($null -eq $resp) { } else { $resp.Close() }
    }
}