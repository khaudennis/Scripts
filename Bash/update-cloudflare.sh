#!/bin/bash

# Source:  https://gist.github.com/Tras2/cba88201b17d765ec065ccbedfb16d9a
# Prerequisite:  curl, jq
# Save script in script directory, make it executable:
#   chmod +x <name.sh> (update-cloudflare.sh)
# Modify zone, dnsrecords, email and key to match Cloudflare instance.
# Add to cron:
#   sudo crontab -u <service_user> -e
#   */1  *  *  *  * <service_user> -f /home/<account>/update-cloudflare.sh

# Cloudflare zone is the zone which holds the record
zone=example.com
# dnsrecords is the A record which will be updated
dnsrecords=(*.example.com www.example.com home.example.com)

## Cloudflare authentication details
## keep these private
cloudflare_auth_email=example@cloudflare.com
cloudflare_auth_key=examplepassword


# Get the current external IP address
ip=$(curl -s -X GET https://checkip.amazonaws.com)

echo "Current IP is $ip"

# get the zone id for the requested zone
zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "X-Auth-Key: $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "Zoneid for $zone is $zoneid"

# loop dnsrecords
for dnsrecord in ${dnsrecords[@]}
do

  # check is host need to update
  if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
    echo "$dnsrecord is currently set to $ip; no changes needed"
    continue
  fi

  # if here, the dns record needs updating

  # get the dns record id
  dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
    -H "X-Auth-Email: $cloudflare_auth_email" \
    -H "X-Auth-Key: $cloudflare_auth_key" \
    -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

  echo "DNSrecordid for $dnsrecord is $dnsrecordid"

  # update the record
  curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
    -H "X-Auth-Email: $cloudflare_auth_email" \
    -H "X-Auth-Key: $cloudflare_auth_key" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq


done