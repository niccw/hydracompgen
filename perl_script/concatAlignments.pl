#!/usr/bin/perl -w
use strict;

my @f=<*.$ARGV[0]>;

my %aln=();
for my $x (@f) {
 open(I,"<$x");
 my $n="";
 while (<I>) {
  chomp;
  if (/^>([^\_]*)\_/) { $n=$1 } else { s/\s+//g; $aln{$n}.=$_ }
 }
 close I;
}

for my $x (keys %aln) {
 print ">$x\n$aln{$x}\n";
}
