#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
set -x

path="/tmp/crontab-$(date +%s).xml"

# find all crontab.xml files and combine them
find ../vendor -not -path "../vendor/magentoese/*" -name 'crontab.xml' -exec cat "{}" >> $path \;

# remove comments
perl -i -pe 'BEGIN{undef $/;} s/<!--.*?-->//smg' $path

# consolidate tags to a single line for further processing
perl -i -pe 'BEGIN{undef $/;} s/\n//smg; s/>\s*?</></smg' $path

# move groups to their own line
perl -i -pe 's/<group/\n<group/g;s/<\/group>/<\/group>\n/g' $path

# only retain the group lines
perl -i -ne '/^<group/ and print' $path

# only jobs are self-closing; replace w/ explicit close
perl -i -pe 's/\/></><\/job></g' $path

# sort in place
sort -o $path $path

# combine groups w/ the same id by removing all but the 1st unique <group id=".." and close the group when a new id is found
perl -i -pe 's{<group id="([^"]+)">}{($prevMatch eq $1 ? "" : (($prevMatch="$1") && "</group>\n$&"))}e' $path
# remove all closing </group> at the end of lines
perl -i -pe 's/><\/group>/>/' $path
# remove the very 1st </group> at the beginning of the file and add it to the end
sed -i '1 s/^<\/group>/<config>/; $ s/$/\n<\/group>\n<\/config>/' $path

# move jobs to their own line
perl -i -pe 's/><job/>\n<job/g;' $path
perl -i -pe 's/^<job/  <job/' $path

# change any cron jobs that run more frequently than once every 10 min, to only once every 10 min
perl -i -pe 's/\*(\/[\d])? \* \* \* \*/*\/10 * * * */' $path

# unset schedules that you do not want to run; M2 will check db and not find any
perl -pe 's/<schedule.*<\/job>/<\/job>/ if /backend_clean_cache|newsletter_send_all/ ' $path



# if can't remove cron, set to once a yr
# what if date is invalid? otherwise 2/29
# can i omit schedule then fall back to DB which would not exist? what happens?

# replace every * w/ */10

# is there a way to stagger the midngiht jobs

# potentially set schedule for random TOD in DB in admin module
# <group id="default"><job name="analytics_subscribe" instance="Magento\Analytics\Cron\SignUp" method="execute" /><job
# name="analytics_update" instance="Magento\Analytics\Cron\Update" method="execute" /><job name="analytics_collect_data"
# instance="Magento\Analytics\Cron\CollectData" method="execute" /></group>
# same for currency_rates_update


# captcha_delete_old_attempts

# changes once an hour to once per random TOD

