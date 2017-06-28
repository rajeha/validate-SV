#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw/ min max /;

my $usage = 'cat hits.blast | is_del.pl <chr> <coord>';

my $tchr = shift @ARGV or die "$usage\n";
my $tcoord = shift @ARGV or die "$usage\n";

sub within {
	# finds if chr:coord is within chr:coord1-coord2, +/- 100bp

	$_[0] eq $_[2] &&
		$_[1] + 100 >= $_[3] && $_[1] - 100 <= $_[4];
}

# slurp all input into memory
my @in = <>;

for my $index (1..$#in) {
	# read two consecutive alignments	
	my @curr = split /\s/, $in[$index]; # current alignment
	my @prev = split /\s/, $in[$index-1]; # previous alignment

	# an example of a deletion:
	#       [prev] [curr]      alignments
	#        -----------       contig     (0 overlap between prev and curr)
	#       /  /     \  \
	#      /  /       \  \
	#     /  /         \  \
	#    -------------------   reference  (0 overlap between prev and curr)
	
	# deal with reverse-strand alignments 
	@prev[8,9] = @prev[9,8] if $prev[8] > $prev[9];
	@curr[8,9] = @curr[9,8] if $curr[8] > $curr[9];

	
	# calculate the contig-overlap between prev and curr
	my $overlap = $prev[7] <= $curr[6]? 0 : $prev[7] - $curr[6]; 

	# test if same contig and chromosome
	if (($prev[0] eq $curr[0]) and ($prev[1] eq $curr[1])) {
	
		# test if overlap between alignments in the contig is less than 75%
		if ($overlap / (max($curr[7],$prev[7]) - min($prev[6],$curr[6])) <= 0.75) {
			# length of deletion = 
			#   distance between alignments in reference - distance between alignments in contig
			my $len = max($prev[8],$curr[8]) - min($curr[9],$prev[9]) - ($curr[6] - $prev[7] - $overlap);
 
			if ($len > 100) {
				my $coor1 = min($prev[9],$curr[9]);
				my $coor2 = max($prev[8],$curr[8]);
 
				# test if deletion range overlaps with expected range
				if (within($tchr, $tcoord, $curr[1], $coor1, $coor2)) {
					print "1\n";

					# print additional information to standard error 
					print STDERR $in[$index-1], $in[$index]; 
					print STDERR "$curr[1]\t$coor1\t$coor2\tDEL\t$len\n"; 
					exit;
				}
			}
		}
	}
}

print "0\n";
