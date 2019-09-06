#!/usr/bin/perl -w
use strict;

my %c=();
for my $x (@ARGV) {
 open(I,"<$x");
 while (<I>) {
  chomp;
  my @tmp = split /\t/;
  push @{$c{$tmp[0]}}, $tmp[1];
 }
 close I;
}

my $clus=0;
for my $x (keys %c) {
 if ($#{$c{$x}}==$#ARGV) {
  $clus++;
  print "$clus\t".($#{$c{$x}}+1)."\t$x\t".join("\t",@{$c{$x}})."\n";
 }
}

