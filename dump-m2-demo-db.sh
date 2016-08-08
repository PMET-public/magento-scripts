#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# excludes comments and uses extended inserts to make comparing diffs easier
# does not require maintaining a separate structure.sql (redundant info), but maintains each table as seperate file
OUTPUT_DIR=/tmp/db-dump-$(date '+%Y-%m-%d-%H%M')
mkdir "${OUTPUT_DIR}"
cd "${OUTPUT_DIR}"

TABLES_TO_EMPTY_BUT_KEEP_STRUCTURE="catalog_category_product_index
catalog_category_product_index_tmp
catalog_product_bundle_price_index
catalog_product_bundle_stock_index
catalog_product_index_eav_decimal_idx
catalog_product_index_eav_decimal_tmp
catalog_product_index_eav_idx
catalog_product_index_eav_tmp
catalog_product_index_price_bundle_idx
catalog_product_index_price_bundle_opt_idx
catalog_product_index_price_bundle_opt_tmp
catalog_product_index_price_bundle_sel_idx
catalog_product_index_price_bundle_sel_tmp
catalog_product_index_price_bundle_tmp
catalog_product_index_price_cfg_opt_agr_idx
catalog_product_index_price_cfg_opt_agr_tmp
catalog_product_index_price_cfg_opt_idx
catalog_product_index_price_cfg_opt_tmp
catalog_product_index_price_downlod_idx
catalog_product_index_price_downlod_tmp
catalog_product_index_price_final_idx
catalog_product_index_price_final_tmp
catalog_product_index_price_idx
catalog_product_index_price_opt_agr_idx
catalog_product_index_price_opt_agr_tmp
catalog_product_index_price_opt_idx
catalog_product_index_price_opt_tmp
catalog_product_index_price_tmp
catalog_product_index_tier_price
catalog_product_index_website
cataloginventory_stock_status_idx
cataloginventory_stock_status_tmp
indexer_state
log_customer
log_quote
log_summary
log_summary_type
log_url
log_url_info
log_url_info
log_visitor
log_visitor
log_visitor_info
log_visitor_online
magento_catalogpermissions_index
magento_catalogpermissions_index_product
magento_catalogpermissions_index_product_tmp
magento_catalogpermissions_index_tmp
report_compared_product_index
report_event
report_viewed_product_index"

COMMON_MYSQL_OPTS="-C --host=${DB_SERVER} --user=${DB_USER} --password=${DB_PASS} --databases ${DB_NAME} \
  --single-transaction \
  --compact --add-drop-table \
  --extended-insert=FALSE \
  --default-character-set=utf8"

ignore_tables() {
  for i in $TABLES_TO_EMPTY_BUT_KEEP_STRUCTURE; do
    echo -n "--ignore-table=$DB_NAME.$i "
  done;
}

remove_unwanted_output () {
  # remove auto_increment= values and prevent using character clients sets
  sed 's!/\*[^*]*DEFINER=[^*]*\*/!!g; /ENGINE=/ s/ AUTO_INCREMENT=[0-9]*\b//; /40101 SET character_set_client/d'
}

/usr/bin/mysqldump $COMMON_MYSQL_OPTS \
  $(ignore_tables) \
  | remove_unwanted_output > magento-database.sql

/usr/bin/mysqldump $COMMON_MYSQL_OPTS \
  -f \
  -d \
  --tables \
  $TABLES_TO_EMPTY_BUT_KEEP_STRUCTURE \
  | remove_unwanted_output >> magento-database.sql

# split dump into tables
csplit -s -n 4 -f table_ magento-database.sql "/^DROP TABLE IF EXISTS/" '{*}'

# remove the 1st table file if it's empty
[ ! -s table_0000 ] && rm table_0000

for i in table_*; do
  # split table into structure and the data, triggers, etc. (_01 files)
  csplit -s -f ${i}_ $i "/^INSERT INTO/" {0} || :
  mv $i ${i}.structure
  [ -e ${i}_00 ] && mv ${i}_00 ${i}.structure
done;

for i in table_*_01; do
  # split the data, triggers, etc. into data and the etc files
  csplit -s -f ${i}_ $i "/^\/\*/" {0} || :
  mv $i ${i}.data
  if [ -e ${i}_00 ]; then
    mv ${i}_00 ${i}.data
    mv ${i}_01 ${i}.etc
  fi
done 

for i in table_*.data; do
  # sort the data
  awk '{print $5 " " $0}' $i | cut -c 2- | sort -n | awk '{$1=""; print substr($0,2)}' >> $i.sorted
  rm $i
done

for i in *.structure; do
  # rename files based on their table name
  table=$(sed -n '1 s/.*`\(.*\)`.*/\1/p' $i)
  mv $i $table.structure || :
  prefix=${i%.*}
  if [ -e ${prefix}_01.data.sorted ]; then
    mv ${prefix}_01.data.sorted $table.data.sorted
  fi
  if [ -e ${prefix}_01.etc ]; then
    mv ${prefix}_01.etc $table.etc
  fi
done
