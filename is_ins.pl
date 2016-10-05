#!/usr/bin/perl
use strict; use warnings;

my @in = <>;

for my $index (1..$#in) {
	my @curr = split /\s/, $in[$index];
	my @prev = split /\s/, $in[$index-1];

	@prev[8,9] = @prev[9,8] if $prev[8] > $prev[9];
	@curr[8,9] = @curr[9,8] if $curr[8] > $curr[9];

	my $p_c = $prev[9] <= $curr[8];

	if (($prev[0] eq $curr[0]) and ($prev[1] eq $curr[1]) and $p_c) {
		if (($curr[6] - $prev[7]) > ($curr[8] - $prev[9] + 100)) {
			print "1\n";
			exit;		
		} 
	}	
}

print "0\n";
