#!/usr/bin/perl
use strict; use warnings;

my @in = <>;

for my $index (1..$#in) {
	my @curr = split /\s/, $in[$index];
	my @prev = split /\s/, $in[$index-1];

	@prev[8,9] = @prev[9,8] if $prev[8] > $prev[9];
	@curr[8,9] = @curr[9,8] if $curr[8] > $curr[9];
	
	my $intra = (($curr[6] < $prev[7]) and ($curr[8] > $prev[9])) or
				 (($curr[6] > $prev[7]) and  ($curr[8] < $prev[9]));
	my $inter = ($curr[0] eq $prev[0]) and !($curr[1] eq $prev[1]);
	
	if ($intra or $inter) {
		print "1\n";
		exit;
	}
}

print "0\n";
