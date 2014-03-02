#!/usr/bin/env perl

=head1 NAME

ARFF REGEX INSTANCE FILTER

=head1 AUTHOR

Syed Reza

=head1 SYNOPSIS

arff-regex-instance-filter.pl -i training.arff -attribute name -regex '(cat|hat)'

=head1 DESCRIPTION

This is a little utility used to filter
an arff into two arffs.
You specify the name of the field, and the regex.
This utility creates an arff containing every matching
instance and another containing every non-matching instance.

=cut

use strict;
use warnings;
use Getopt::Long;


my $input;
my $output_prefix;
my $attribute;
my $regex;

my $basein;

GetOptions(
	'i=s', \$input,
	'o=s', \$output_prefix,
	'attribute=s', \$attribute,
	'regex=s', \$regex,
);

sub die_with_usage { my $msg = shift;
	print "Usage $0 -i [input.arff] -attribute [attribute-name] -regex [regex]\n";
	printf "%20s\t%s\n", "-o", "optional_output_prefix";
	if($msg) {
		print "Error: $msg\n";
	}
	exit(1);
}

unless($regex && $attribute && -e $input) {
	die_with_usage();
}

if($input =~ /^(.+)\.arff$/) {
	$basein = $output_prefix || $1;
} else {
	die_with_usage("input must end in .arff\n");
}
$regex ||= ".+";

my $ofname_match = "$basein.match.arff";
my $ofname_nomatch = "$basein.nomatch.arff";
my $rgx = qr/$regex/;

print "*** RUNNING ARFF REGEX INSTANCE FILTER ***\n";
print "REGEX = $regex\n";
print "BASEIN = $basein\n";
print "MATCH OUTPUT FILENAME = $ofname_match\n";
print "NO-MATCH OUTPUT FILENAME = $ofname_nomatch\n";

my $fh; my $indata = 0;
my $attr_count = 0;
my $attr; 
my $attribute_index = undef;
my @vector; my $value;

my $match_fh;
my $nomatch_fh; my $line;
open($fh, "<$input");
open($match_fh, ">$ofname_match");
open($nomatch_fh, ">$ofname_nomatch");

while(<$fh>) { 
	$line = $_; chomp;
	if($_ =~ /^\s*\@data/) {
		if(defined($attribute_index)){
			print "\nAttribute $attribute found at index $attribute_index\n";
		}
		else {
			print "Attribute not found!!\n";
			last;
		};
		print $match_fh $line;
		print $nomatch_fh $line;

		$indata = 1; next;
	}
	if($indata) {
		@vector = split(/\,\s*/);
		$value = $vector[$attribute_index];
		print "|$value|\n";
		if($value =~ $rgx) {
			print $match_fh $line;
		} else {
			print $nomatch_fh $line;
		}

	} else {
		print $match_fh $line;
		print $nomatch_fh $line;
		
		if($_ =~ /\@attribute\s+(\w+)\s+(\w+)$/) {
			$attr = $1;
			if($attr eq $attribute) {
				$attribute_index = $attr_count;
			}
			$attr_count++;
		}
	}
}
close($match_fh);
close($nomatch_fh);
close($fh);
print "\n\n";