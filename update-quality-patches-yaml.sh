#!/usr/bin/env bash

# turn on debugging
# set -x

# remove unwanted patches from the list (newline separated)
patches_to_exclude="
ACSD-50276
"
# trim empty lines
patches_to_exclude="$(echo "$patches_to_exclude" | sed '/^$/d')"
echo -e "\033[31mSkipping these patches:
$patches_to_exclude
\033[0m"



patches="$(
  ./vendor/bin/ece-patches status -n |
  grep -E "Not applied.*Optional" |
  sort |
  perl -pe 's/.*?\s+([^\s]+)\s.*/      - \1/' |
  grep -v -F "$patches_to_exclude"
)"

patches="$patches" perl -i -0777 -pe 's/
  (\n\s+QUALITY_PATCHES:)
  [\S\s]*?
  (\n\s+[^\n:]+:)
  /\1\n$ENV{"patches"}\2/mx' .magento.env.yaml