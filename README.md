# validate-SV

Perl scripts to validate structural variation (SV) events from de-novo assembly.

- __is\_{del,ins,dup,inv}.pl__ <br>
Detect deletions, insertions, duplications, and inversions. <br>
Input is tab-delimted BLAST-like alignment results. 
Standard output: 1 for valid/supported, 0 for invalid/no support.
Prints additional information to standard error.
Requires chromosome and coordinate of supposed breakpoint as arguments. 

- __is\_tra.pl__ <br>
Detects inter-chromosomal translocations. <br>
Input is BEDPE split-alignments. 
Standard output: 1 for valid/supported, 0 for invalid/no support.
Prints additional information to standard error.
Requires chromosme and coordinate of supposed breakpoint as arguments.

- __greedy.pl__ <br>
Greedily finds a subset of non-overlapping hits in both the reference and the contig. <br>
Input hits should be sorted by preferred _significance_. Requires [the interval tree module](http://search.cpan.org/~benbooth/Set-IntervalTree-0.01/lib/Set/IntervalTree.pm). <br>
In this example, I choose to favor hits with higher bit score:

`$ cat blast.out | sort -k11,11 -g -r | greedy.pl > non_overlapping.out`

---
## Example Workflow
Note: I will use some in-house scripts from [misc](http://github.com/rajeha/misc) and [fixpairs](http://github.com/rajeha/fixpairs).

Say you suspect there is a deletion in chromosome 1, coordinate 50000.

__1)__ Extract reads +/- 1Kbp from the suspected breakpoint
```
$ get_reads.sh sorted.bam 'chr1:49000-51000'  
```

__2)__ De-novo assemble a contig from sampled reads

[fermi-lite](http://github.com/lh3/fermi-lite) is an overlap-based assembler that I found perfect for this purpose.
```
$ run_fermi.sh r1.fq r2.fq
```

__3)__ Re-align the contig

[yaha](http://github.com/GregoryFaust/yaha) is an aligner that is optimized for finding split-mappings. <br>
It will not consider splits on two chromosomes, so use `-FBS Y` for translocations and convert the alignment to BEDPE (bedtools). Also, `-FBS Y` is necessary for finding duplications.
```
$ yaha -x ref.yhidx -q frm.fa -o8 yh
```

__4)__ Infer validity of SV from alignment
```
$ cat yh | is_del.pl chr1 50000
0
```

We find that the deletion is not supported by de-novo assembly!

---

### (Deprecated) Example Workflow
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
1-c) fix header information in the new SAM file:
```
$ echo -e "$(samtools view -H ../alignment.sam)\n$(cat subset.sam" > subset.sam
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
