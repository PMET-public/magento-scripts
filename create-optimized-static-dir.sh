#!/usr/bin/env bash

# stop on errors
# set -e
# turn on debugging
set -x

NUM_PROC=$(nproc)

cd $(readlink -f /magento/pub/static)

# remove unneeded dirs
rm -rf doc

# remove docs dirs 
find -type d -name docs | xargs -P $NUM_PROC -I {} rm -rf {} 

# remove duplicates and replace with symlinks
rdfind -makesymlinks true .

# convert absolute symlinks to relative and remove dangling links (there shouldn't be any though)
symlinks -csrd .

# remove results
rm results.txt

# minify css with yui compressor
find -type f -name "*.css" | xargs -P $NUM_PROC -I {} java -jar /yuicompressor.jar -o {} {}

# yui compressor won't compress many js files that use reserved words as properties
# but closure compiler is too slow 
# so do a 2 pass process
# 1st with yui compressor, 2nd with closure compiler for ones skipped by yui compressor

# find js files with >=1 lines and minify js with yui compressor
find -name "*.js" -type f -exec wc -l {} \; | awk ' $1 >= 1 {print $2}' | \
  xargs -P $NUM_PROC -I {} java -jar /yuicompressor.jar --nomunge --preserve-semi --disable-optimizations -o {} {}
# find -type f -name "*.js" | xargs -P $NUM_PROC -I {} java -jar /yuicompressor.jar -o {} {}

# find js files with >=1 lines and minify js with closure compiler
find -name "*.js" -type f -exec wc -l {} \; | awk ' $1 >= 1 {print $2}' | \
  xargs -P $NUM_PROC -I {} java -jar /compiler.jar --warning_level QUIET --compilation_level WHITESPACE_ONLY --js_output_file {}.tmp {}

# even "SIMPLE" is too agressive
# xargs -P $NUM_PROC -I {} java -jar /compiler.jar --warning_level QUIET --compilation_level SIMPLE --js_output_file {}.tmp {}

# rename those minified with closure compiler
find -type f -name "*.js.tmp" | xargs -P $NUM_PROC -I {} rename -f 's/\.js\.tmp/.js/' {}

# ensure access
find . -type d | xargs -P $NUM_PROC -I {} chmod 755 {}
find . -type f | xargs -P $NUM_PROC -I {} chmod 644 {}
