# validate-SV

Perl scripts to validate structural variation (SV) events. Input is tab-delimited, BLAST-like alignment results (hits) of the de-novo-assembled contig across a supposed SV breakpoint onto a reference. Output is 1 for valid and 0 for invalid.
***
- __greedy.pl__ <br>
Greedily finds a subset of non-overlapping hits in both the reference and the contig. Input hits should be sorted by preferred _significance_. Requires [the interval tree module](http://search.cpan.org/~benbooth/Set-IntervalTree-0.01/lib/Set/IntervalTree.pm). (*Will try to write more portable code in the future!*) <br>
In this example, I choose to favor hits with higher bit score.:
```
$ cat blast.out | sort -k11,11 -g -r | greedy.pl > non_overlapping.out
```

- __is_inv.pl__ <br>
Detects an inversion.

- __is_dup.pl__ <br>
Detects a duplication larger than 100 bp.

- __is_tra.pl__ <br>
Detects a translocation. Input hits must be non-overlapping.

- __is_del.pl__ <br>
Detects a deletion larger than 100 bp. Input hits must be non-overlapping.

- __is_ins.pl__ <br>
Detects an insertion larger than 100 bp. Input hits must be non-overlapping.


