<?php

// populate this $trans variable with the command below. specify a filepath and a word that matches the line your key is on
// grep -rnw 'src/GdsServiceBundle/Form/Model/' -e "message"

$trans = '';

$trans = explode("\n", $trans);
$missingKeys = [];
foreach ($trans as $translation) {
    $key = [];
    $search = preg_match("/\"(.*)\"/", $translation, $key);
    $key = $key[1];
    if (!exec('grep -rnw /checkouts/core/app/DoctrineMigrations/ -e '.escapeshellarg($key))) {
        $missingKeys[] = $key;
    }
}

var_dump($missingKeys);

// run with 
// php translationLookup.php