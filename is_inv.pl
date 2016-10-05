#!/usr/bin/perl
use strict; use warnings;

while (<>) {
	if ((split)[8] > (split)[9]) {
		print "1\n";
		exit;
	}
}

print "0\n";
