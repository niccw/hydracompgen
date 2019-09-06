#!/usr/bin/perl -w
use strict;
use warnings;

my %best=();
my %sel=();
my $self=0;
if ($ARGV[1]) { $self=1 }
while (<*$ARGV[0]*>) {
my $f=$_;
print STDERR "$f\n";
open(I,"<$f");
while (<I>) {
 chomp;
 my @tmp = split /\t/;
 if (($self==1)&&($tmp[0] eq $tmp[1])) { next }
 $sel{$tmp[0]}=1;
 $tmp[3]=$tmp[11];
 if (not exists $best{$tmp[0]}) {
  @{$best{$tmp[0]}}=($tmp[3],$tmp[1]);
 } else {
  if (${$best{$tmp[0]}}[0]<$tmp[3]) { 
   @{$best{$tmp[0]}}=($tmp[3],$tmp[1]);
  }
 }

 if (not exists $best{$tmp[1]}) {
  @{$best{$tmp[1]}}=($tmp[3],$tmp[0]);
 } else {
  if (${$best{$tmp[1]}}[0]<$tmp[3]) {
   @{$best{$tmp[1]}}=($tmp[3],$tmp[0]);
  }
 }
}
close I;
}

for my $x (keys %best) {
 if (not exists $sel{$x}) { next }
 my $g=${$best{$x}}[1];
 if (not exists $best{$g}) { next }
 my $hg=${$best{$g}}[1];
 if ($x eq $hg) {
  print "$g\t$x\t${$best{$x}}[0]\n";
  # if (${$best{$x}}[0]) {} else { die("HERE\n") }
 }
}


