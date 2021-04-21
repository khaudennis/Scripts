# Uses a PS-Module by Chrissy LeMaire from netnerds.net, which I've included in the event source is unavailable.
# Article:  https://blog.netnerds.net/2015/12/use-powershell-and-cloudflare-api-v4-to-dynamically-update-cloudflare-dns-to-your-external-ip/
# Dennis Khau, 4/2020

Import-Module .\Libraries\CloudFlareDNSUpdate.psm1

$token = "" #CloudFlare Global Key
$email = "" #CloudFlare Account Email
$primaryZones = @("Adomain.com", "Bdomain.com", "Cdomain.com")
$subZones = @("a.domain.com", "b.domain.com", "c.domain.com")

foreach ($zone in $primaryZones) {
	Write-Output "### BEGIN update on zone $zone"
	Update-CloudFlareDynamicDns -Token $token -Email $email -Zone $zone
	Write-Output "### END update on zone $zone"
	Start-Sleep -Seconds 3
}

foreach ($zone in $subZones) {	
	$record = $zone.subString(0, $zone.indexOf("."))
	$domain = $zone.subString($zone.indexOf(".") +1)
	Write-Output "### BEGIN update on sub-domain $zone with domain of $domain and record, $record"
	Update-CloudFlareDynamicDns -Token $token -Email $email -Zone $domain -Record $record
	Write-Output "### END update on zone $zone"
	Start-Sleep -Seconds 3
}