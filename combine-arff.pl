#!/usr/bin/env perl

my $a = $ARGV[0];
my $b = $ARGV[1];

sub die_with_usage {
	print "Usage: $0 <first.arff> <second.arfff>\n";
	exit(1);
}
unless($a && $b && -e $a && -e $b) {
	die_with_usage();
}

my $fh;
open($fh, "<$a");
while(<$fh>){print if $_ !~ /^\s*$/m;}
close($fh);

open($fh, "<$b");
my $st = 0;
while(<$fh>) {
	next if $_ =~ /^\s*$/;
	if(!$st && $_ =~ /\@data/) { $st = 1; next;}
	elsif($st) {
		print;
	}
}
close($fh);