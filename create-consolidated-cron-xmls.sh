#!/usr/bin/env bash

# stop on errors
set -e
# turn on debugging
# set -x


cur_dir=$( cd $(dirname $0) ; pwd -P )

if [ -d "$cur_dir/../module-demo-admin-configurations" ]; then 
  dir="$cur_dir/../module-demo-admin-configurations"
elif [ -d "$cur_dir/../module-b2b-admin-configurations" ]; then
  dir="$cur_dir/../module-b2b-admin-configurations"
else
  dir="$cur_dir/../module-admin-configurations"
fi


##############################
#
# consolidated cron_groups.xml
#
##############################

path="${dir}/etc/cron_groups.xml"
rm "$path" || :

# find all cron_groups.xml files and combine them
find $( cd $(dirname $0)/../../ ; pwd -P ) -not -path "*magentoese/*" -name 'cron_groups.xml' -exec cat "{}" >> $path \;

# remove comments
perl -i -pe 'BEGIN{undef $/;} s/<!--.*?-->//smg' $path

# remove config tags, xml tags, and empty lines 
sed -i '/config>/d;/<\?xml/d;/^\s*$/d' $path

perl -i -pe '
  s/(_every.*>)\d+/${1}20/;
  s/(ahead_for.*>)\d+/${1}30/;
  s/(lifetime.*>)\d+/${1}600/;
  s/(schedule_lifetime.*>)\d+/${1}10/;
  s/(process.*>)1/${1}0/;
  ' $path

sed -i '1 s/^/<config>\n/; $ s/$/\n<\/config>/' $path


##########################
#
# consolidated crontab.xml
#
##########################

path="${dir}/etc/crontab.xml"
rm "$path" || :

# find all crontab.xml files and combine them
find $( cd $(dirname $0)/../../ ; pwd -P ) -not -path "*magentoese/*" -name 'crontab.xml' -exec cat "{}" >> $path \;

# remove comments
perl -i -pe 'BEGIN{undef $/;} s/<!--.*?-->//smg' $path

# consolidate tags to a single line for further processing
perl -i -pe 'BEGIN{undef $/;} s/\n//smg; s/>\s*?</></smg' $path

# move groups to their own line
perl -i -pe 's/<group/\n<group/g;s/<\/group>/<\/group>\n/g' $path

# only retain the group lines
perl -i -ne '/^<group/ and print' $path

# only jobs are self-closing; replace w/ explicit close for further processing
perl -i -pe 's/\/></><\/job></g' $path

# wrap each job in a group element to facilitate sorting
perl -i -pe 's{</job><job}{</job></group>\n<group id="$id"><job}g if (/group id="([^"]+)"/ && ($id=$1))' $path

# sort in place
sort -o $path $path

# combine groups w/ the same id by removing all but the 1st unique <group id=".." and close the group when a new id is found
perl -i -pe 's{<group id="([^"]+)">}{($prev_match eq $1 ? "  " : (($prev_match="$1") && "</group>\n$&"))}e' $path
# remove all closing </group> at the end of lines
perl -i -pe 's/><\/group>/>/' $path
# remove the very 1st </group> at the beginning of the file and add it to the end
sed -i '1 s/^<\/group>/<config>/; $ s/$/\n<\/group>\n<\/config>/' $path

# unset job schedules that you do not want to run at all; M2 will check db and not find any
perl -i -pe 's/<schedule.*<\/job>/<\/job>/ if /backend_clean_cache|newsletter_send_all/ ' $path

# change any cron jobs that run more frequently than once every 10 min, to only once every 10 min
perl -i -pe 's/0-59 \* \* \* \*/* * * * */; s/\*(\/[\d])? \* \* \* \*/*\/10 * * * */' $path

# change hourly jobs to random daily jobs
perl -i -pe 's/>[\d,]+ \* \* \* \*/( ">" . int(rand(60)) . " " . int(rand(24)) . " * * *")/e' $path

# change daily jobs to run at random TOD
perl -i -pe 's/>[\d,]+ [\d,]+ \* \* \*/( ">" . int(rand(60)) . " " . int(rand(24)) . " * * *")/e' $path
