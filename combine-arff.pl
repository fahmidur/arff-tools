#!/usr/bin/env perl

=head1 NAME

COMBINE-ARF.pl

=head1 AUTHOR

Syed Reza

=head1 SYNOPSIS

combine-arff.pl <first.arff> <second.arff>

Outputs to STDOUT.

I advise you to forward to some file

=head1 DESCRIPTION

Combine two arff files into one arff file

=cut

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