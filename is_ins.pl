#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw/ max min /;

my $usage = 'cat hits.blast | is_ins.pl <chr> <coord>';

my $tchr = shift @ARGV or die "$usage\n";
my $tcoord = shift @ARGV or die "$usage\n";

sub within {
	$_[0] eq $_[2] &&
		$_[1] + 100 >= $_[3] && $_[1] - 100 <= $_[4];
}

my @in = <>;
for my $index (1..$#in) {
	my @curr = split /\s/, $in[$index];
	my @prev = split /\s/, $in[$index-1];

	@prev[8,9] = @prev[9,8] if $prev[8] > $prev[9];
	@curr[8,9] = @curr[9,8] if $curr[8] > $curr[9];

	my $overlap = $prev[7] <= $curr[6]? 0 : $prev[7] - $curr[6]; 

	if (($prev[0] eq $curr[0]) and ($prev[1] eq $curr[1])) {
	
		if ($overlap / (max($curr[7],$prev[7]) - min($prev[6],$curr[6])) <= 0.75) {
			my $len = ($curr[6] - $prev[7] - $overlap) - (max($prev[8],$curr[8]) - min($curr[9],$prev[9]));
			
			if ($len > 100) {
				my $coor1 = min($prev[9],$curr[9]);
				my $coor2 = max($prev[8],$curr[8]); 
				
				if (within($tchr, $tcoord, $curr[1], $coor1, $coor2)){
					print "1\n";
				
					print STDERR $in[$index-1], $in[$index]; 
					print STDERR "$curr[1]\t$coor1\t$coor2\tINS\t$len\n"; 
					exit;
				}
			}
		}
	}
}

print "0\n";
