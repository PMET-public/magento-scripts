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
const XML_SUFFIX = '      </general>
    </magentoese_autofill>
  </default>
</config>
';

$csv_files = glob('*.csv');

if (array_count_values($csv_files) === 0) {
    exit("No csv files found. Please rerun in dir containing csv files");
}

file_put_contents ("config.xml", "");
$xml = XML_PREFIX;
$total_personas = 0;
foreach($csv_files as $file) {
    $rows = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $headers = explode(",", array_shift($rows));
    $num_headers = count($headers);
    foreach ($rows as $row_index => $row_value) {
        $xml .= str_repeat ("  ",4)."<persona_".(++$total_personas).">\n";
        $fields = explode(",", $row_value);
        if (count($fields) !== $num_headers) {
            exit("File: $file, row: ".($row_index + 1).": number of headers != numer of fields. Please ensure field values do not have commas.");
        }
        foreach ($fields as $index => $value){
            $xml .= str_repeat ("  ",5)."<".$headers[$index]."_value>".trim($value)."</".$headers[$index]."_value>\n";
        }
        $xml .= str_repeat ("  ",4)."</persona_$total_personas>\n";
    }
}
$xml .= XML_SUFFIX;
file_put_contents ("config.xml", $xml,FILE_APPEND);
