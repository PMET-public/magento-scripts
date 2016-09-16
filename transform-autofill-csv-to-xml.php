#!/usr/bin/env php
<?php

// this script assumes first row is column headers and
// subsequent rows are data

const XML_PREFIX = '<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:module:Magento_Store:etc/config.xsd">
    <default>
        <magentoese_autofill>
            <general>
              <enable_autofill>1</enable_autofill>
';
const XML_SUFFIX = '        </magentoese_autofill>
    </default>
</config>
';

$csv_files = glob('*.csv');

if (array_count_values($csv_files) === 0) {
    exit("No csv files found. Please rerun in dir containing csv files");
}

foreach($csv_files as $file) {
    $rows = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    echo XML_PREFIX;
    $headers = explode(",", array_shift($rows));
    foreach ($rows as $row_index => $row_value) {
        echo "<persona_$row_index>\n";
        $fields = explode(",", $row_value);
        foreach ($fields as $index => $value){
            echo "<".$headers[$index]."_value>".trim($value)."</".$headers[$index]."_value>\n";
        }
        echo "</persona_$row_index>\n";
    }
    echo XML_SUFFIX;
}
