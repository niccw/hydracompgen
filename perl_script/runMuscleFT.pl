#!/usr/bin/perl -w
use strict;

my @f=<*clus.fa>;
if ($ARGV[0]) {
 @f=<$ARGV[0]*/*clus.fa>;
}
for my $x (@f) {
	print STDERR " $x ... \n";
	`muscle -in $x -out $x.aln`;
`Gblocks $x.aln -t=p`;
	`FastTree $x.aln > $x.tree`;
}
