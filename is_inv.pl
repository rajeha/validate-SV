#!/usr/bin/env perl
use strict; use warnings;
use List::Util qw/ min max/;

my $usage = 'cat hits.blast | is_inv.pl <chr> <coord>';

my $tchr = shift @ARGV or die "$usage\n";
my $tcoord = shift @ARGV or die "$usage\n";

sub within {
	$_[0] eq $_[2] &&
		$_[1] + 100 >= $_[3] && $_[1] - 100 <= $_[4];
}

while (<>) {
	if ((split)[8] > (split)[9]) {
		my $len = (split)[3];
		my $chr = (split)[1];
		my $coor1 = (split)[9];
		my $coor2 = (split)[8];

		if ($len > 100) { 
			if (within($tchr, $tcoord, $chr, $coor1, $coor2)) {
				print "1\n";

				print STDERR $_; 
				print STDERR "$chr\t$coor1\t$coor2\tINV\t$len\n"; 
				exit;
			}
		}
	}
}

print "0\n";
