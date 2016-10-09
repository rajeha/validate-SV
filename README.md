# validate-SV

Perl scripts to validate structural variation (SV) events. Input is tab-delimited, BLAST-like alignment results (hits) of the de-novo-assembled contig across a supposed SV breakpoint onto a reference. Output for is_* scripts is 1 for valid and 0 for invalid.
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

---

#Example Workflow
Say you suspect there is a duplication in chromosome 1 at coordinate 5000 and you want to validate it.

__1)__ Extract reads +/- 1Kbp from the target coordinate

1-a) find IDs of the reads within this range:
```
$ samtools view alignnment_sorted.bam "chr1:4000-6000" | cut -f1 > ids.tmp
```
1-b) grep for reads with those IDs from original SAM file:
```
$ LC_ALL=C grep -w -F -f ids.tmp < alignment.sam > subset.sam
```
1-c) fix header information in the new SAM file. If the genome you're working with has 3 chromosomes, you need the top 4 lines from the original SAM file:
```
$ echo -e "$(head -4 ../alignment.sam)\n$(cat subset.sam" > subset.sam
```
1-d) convert new SAM to reads. If paired-end reads:
```
$ samtools view -b subset.sam | samtools fastq -1 reads_1.fq reads_2.fq - 
```
1-e) fix reads' headers. Here, the headers all start with "@SR":
```
$ perl -pi.bak -e 's/\@SR.+\S/$&\/1/' reads_1.fq
$ perl -pi.bak -e 's/\@SR.+\S/$&\/2/' reads_2.fq
```

__2)__ De-novo assemble a contig from the extracted reads 
```
$ velveth output 31 -shortPaired -separate -fastq reads_1.fq reads_2.fq
$ velvetg output -exp_cov auto -cov_cutoff auto
```

__3)__ BLAST the contig onto a reference sequence
```
$ blastn -db reference.fasta -query contigs.fa -prec_identity 95 -outfmt 6 -out blast.out
```

__4)__ Infer validity of duplication from alignment
```
$ cat blast.out | is_dup.pl
0
```
We find that the duplication is not supported by de-novo assembly!
