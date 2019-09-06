#!/usr/bin/perl -w
use strict;

my %c=();
open(I,"<$ARGV[0]");
my $t=0;
my %co=();
while (<I>) {
 chomp;
 my @tmp = split /\s+/;
 if ($tmp[5]) { } else {$tmp[5]="Other" }
 $c{$tmp[5]}+=$tmp[0];
 my ($id)=$tmp[5]=~/^([^\/]*)/;
 $co{$id}+=$tmp[0];
 $t+=$tmp[0];
}
close I;

for my $x (reverse sort { $c{$a} <=> $c{$b} } keys %c ) {
 print "$x\t$c{$x}\t".($c{$x}/$t)."\n";
}
print "total=$t\n";

for my $x (keys %co) {
 print STDERR "$x\t$co{$x}\n";
}
