#!/usr/bin/env perl
use strict;
use warnings;

my $usage = 'cat yh_FBS.bedpe | is_tra.pl <chr1> <coord1> <chr2> <coord2>';

my $tchra = shift @ARGV or die "$usage\n";
my $tcoorda = shift @ARGV or die "$usage\n";
my $tchrb = shift @ARGV or die "$usage\n";
my $tcoordb = shift @ARGV or die "$usage\n";

sub within {
	$_[0] eq $_[2] &&
		$_[1] + 100 >= $_[3] && $_[1] - 100 <= $_[4];
}

while (<>) {
	my ($chra, $coorda1, $coorda2, $chrb, $coordb1, $coordb2) = (split)[0,1,2,3,4,5];

	if ((within($tchra, $tcoorda, $chra, $coorda1, $coorda2) && ($chrb eq $tchrb)) ||
			(($chra eq $tchra) && within($tchrb, $tcoordb, $chrb, $coordb1, $coordb2)) || 
			(within($tchra, $tcoorda, $chrb, $coordb1, $coordb2) && ($chra eq $tchrb)) ||
			(($chrb eq $tchra) && within($tchrb, $tcoordb, $chra, $coorda1, $coorda2))) {

		print "1\n";
		print STDERR $_;	
		exit;
	}
}

print "0\n";
