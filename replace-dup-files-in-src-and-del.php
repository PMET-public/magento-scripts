<?php

/*

BACKUP YOUR FILES BEFORE RUNNING THIS!!!

 This is a short script to:
   replace duplicate files of a specified type
   find references to the files that will be deleted in the specified sources
   replace those file references with the remaining deduped file path
   remove the replaced files

 assumptions :
   1) depends on fdupes
   2) no spaces in filenames

*/

const DUPLICATE_FILETYPE_REGEX = '/\.(jpg|png|gif)$/';
const SOURCE_FILETYPE_GLOB = '*.csv';
const PATH_PREFIX_RELATIVE_TO_CWD_NOT_IN_SOURE_FILES = '/module-b2b-media-sample-data/catalog/product';


function rglob($pattern) {
    $files = glob($pattern);
    foreach (glob(dirname($pattern).'/*', GLOB_ONLYDIR|GLOB_NOSORT) as $dir) {
        $files = array_merge($files, rglob($dir.'/'.basename($pattern)));
    }
    return $files;
}

$cwd = getcwd();
exec("fdupes -1qr $cwd", $rows_of_files, $status);

$all_patterns = [];
$all_replacements = [];

foreach($rows_of_files as $row) {
    $row = str_replace($cwd.PATH_PREFIX_RELATIVE_TO_CWD_NOT_IN_SOURE_FILES,'',$row);
    $current_row_files = explode(' ', $row);
    $replacement_file = array_shift($current_row_files);
    if (preg_match(DUPLICATE_FILETYPE_REGEX,$replacement_file) === 1) {
        foreach ($current_row_files as $pattern_file) {
            $all_patterns[] = $pattern_file;
            $all_replacements[] = $replacement_file;
        }
    }
}

$source_files = rglob(SOURCE_FILETYPE_GLOB);
foreach($source_files as $file) {
    $str = file_get_contents($file);
    $str = str_replace($all_patterns, $all_replacements, $str);
    file_put_contents($file, $str);
}

foreach ($all_patterns as $relative_file){
    $full_path = $cwd . PATH_PREFIX_RELATIVE_TO_CWD_NOT_IN_SOURE_FILES . $relative_file;
    unlink($cwd . PATH_PREFIX_RELATIVE_TO_CWD_NOT_IN_SOURE_FILES . $relative_file);
}
