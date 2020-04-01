#!/usr/bin/env bash
# Sample output:
#   ap-northeast-2,52.92.0.0/20,大韓民国
#   ap-northeast-3,52.95.157.0/24,日本

curl --silent https://ip-ranges.amazonaws.com/ip-ranges.json |
( 
  echo "block,region" && 
  jq -r \
  '.prefixes[]|
   select(.region|test("^ap-northeast"))|
   select(.service!="AMAZON")|select(.service!="EC2")|
   "\(.ip_prefix),\(.region)"'
) | 
q -Hd ',' \
  "SELECT GeoIP.region, GeoIP.block, name.country_name
   FROM
   - GeoIP
   LEFT JOIN
   GeoLite2-Country-Blocks-IPv4.csv blocks
   ON GeoIP.block=blocks.network
   LEFT JOIN
   GeoLite2-Country-Locations-ja.csv name
   USING(geoname_id)
   ORDER BY 1"
