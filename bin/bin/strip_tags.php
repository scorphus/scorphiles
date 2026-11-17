#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');
while ($line = fgets($stdin)) {
	echo html_entity_decode(strip_tags($line));
}
fclose($stdin);
