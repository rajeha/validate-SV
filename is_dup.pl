#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw/max min/;

my @in = <>;

for my $index (1..$#in) {
	my @curr = split /\s/, $in[$index];
	my @prev = split /\s/, $in[$index-1];
	
	if (($prev[0] eq $curr[0]) and ((max($prev[6],$curr[6]) + 100) <= min($curr[7],$prev[7]))) {
		print "1\n";
		exit;
	}
}

print "0\n";
	
