#!/usr/bin/perl
use strict;
use warnings;
use Set::IntervalTree;
use List::Util qw/min max/;

my @in = <>;
my @final;
my %contigs;
my %chromos;

for my $index (0..$#in) {
    my @curr = split /\s/, $in[$index];

    unless ($contigs{$curr[0]}) {
        $contigs{$curr[0]} = Set::IntervalTree->new();
    }

    unless ($chromos{$curr[1]}) {
        $chromos{$curr[1]} = Set::IntervalTree->new();
    }

    next if (@{$contigs{$curr[0]}->fetch(min(@curr[6,7]), max(@curr[6,7]))}
            or @{$chromos{$curr[1]}->fetch(min(@curr[8,9]), max(@curr[8,9]))});

    push @final, $in[$index];

    $contigs{$curr[0]}->insert($in[$index], min(@curr[6,7]), max(@curr[6,7]));
    $chromos{$curr[1]}->insert($in[$index], min(@curr[8,9]), max(@curr[8,9]));
}

print @final;
