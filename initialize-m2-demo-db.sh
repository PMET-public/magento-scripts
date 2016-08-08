#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

# allow the first demo app server to create the sql file in a shared space so other demo app servers of the same release can use it
GENERATED_SQL_FILE="${SHARED_TMP_PATH}/initial-m2-demo-${RELEASE_TAG}.sql"

if [ ! -f "${GENERATED_SQL_FILE}"  -o "${USE_PREV_GENERATED_SQL_FILE}" = "false" ]; then

  # turn off foreign key checks for import
  # allow 0 in autoincrement because already in data but see http://dev.mysql.com/doc/refman/5.0/en/sql-mode.html#sqlmode%5Fno%5Fauto%5Fvalue%5Fon%5Fzero
  # defer commit to end for speed
  # ensure proper encoding

  echo "SET FOREIGN_KEY_CHECKS=0;
  SET unique_checks=0;
  SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
  SET NAMES 'utf8' COLLATE 'utf8_general_ci';
  SET autocommit=0;
  DROP DATABASE IF EXISTS \`${DB_NAME}\`;
  CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8;
  USE \`${DB_NAME}\`;" > "${GENERATED_SQL_FILE}"

  # recombine the tables from the data dir
  for i in "${TABLES_DIR}"/*.structure; do
    cat $i >> "${GENERATED_SQL_FILE}"
    prefix=${i%.*}
    if [ -e ${prefix}.data.sorted ]; then
      # to speed up insertion, convert from single row insert statements to multi-row and append to sql file
      sed 's/;$/,/;
        2,$ s/INSERT INTO.*` VALUES (/(/;
        $ s/,$/;/' ${prefix}.data.sorted >> "${GENERATED_SQL_FILE}"
    fi
    if [ -e ${prefix}.etc ]; then
      cat ${prefix}.etc >> "${GENERATED_SQL_FILE}"
    fi
  done

  echo "SET FOREIGN_KEY_CHECKS=1;
  SET unique_checks=1;
  SET SQL_MODE=@OLD_SQL_MODE;
  COMMIT;" >> "${GENERATED_SQL_FILE}"

fi

# replace previous database name with new one
sed -i "6,8 s/\`.*\`/\`${DB_NAME}\`/;" "${GENERATED_SQL_FILE}"

# populate the db
/usr/bin/mysql -C --host="${DB_SERVER}" --user="${DB_USER}" --password="${DB_PASS}" --default-character-set=utf8 < "${GENERATED_SQL_FILE}"
