#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

host_to_container_id_map_tmpfile=$(mktemp host_map.XXXXX)
echo -n "" > hostname-to-proxy-dest.DEPRECATED.map

all_containers_all_exposed_ports=$(docker ps --format "{{ .ID }} {{ .Ports }}")
http_service_containers=$(echo "${all_containers_all_exposed_ports}" | egrep '\->(80|443)/' | awk '{print $1}')
m2_containers=$(docker ps | grep 'umastory.com'  | awk '{print $1}')
non_m2_http_containers=$(echo -e "${http_service_containers}\n${m2_containers}" | sort | uniq -u)

# for container_id in $non_m2_http_containers; do
#   (
#     hostname=$(docker inspect --format "{{ .Config.Hostname }}.{{ .Config.Domainname }}" ${container_id})
#     echo "${hostname} ${container_id};" >> $host_to_container_id_map_tmpfile
#   ) &
# done

for container_id in $m2_containers; do
  (
    base_url=$(docker exec "${container_id}"  bash -c \
      '/usr/bin/mysql --host="${DB_SERVER:-db-server}" --user="${DB_USER:-super}" --password="${DB_PASS:-dmd_db_password}" --database="${DB_NAME:-magento}" \
      -NBe "select value from core_config_data where path = '\''web/unsecure/base_url'\''"') || continue
    hostname=$(echo "${base_url}" | sed 's/https*:\/\///;s/:.*//;s/\/.*//')
    echo "${hostname} ${container_id};" >> $host_to_container_id_map_tmpfile
  ) &
done

# wait for the child processes to finish
wait

# if any m2 app servers have a base url of {{base_url}}; delete those
sed -i.bak "/base_url/d" $host_to_container_id_map_tmpfile

while read line; do 
  container_hostname=$(echo "$line" | awk '{print $1}')
  container_id=$(echo "$line" | awk '{print $2}' | sed 's/.$//')
  echo "${all_containers_all_exposed_ports}" | \
    egrep "${container_id}.*\->80\/tcp" | perl -pe "s/^([^ ]+).* ([\d\.:]+)->80\/tcp.*/$container_hostname http:\/\/\2;/" >> hostname-to-proxy-dest.DEPRECATED.map
done < $host_to_container_id_map_tmpfile

rm $host_to_container_id_map_tmpfile $host_to_container_id_map_tmpfile.bak
