#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use POSIX;

=head1 NAME

arff-to-fann-data - Converts ARFF files to FANN Data format

=head1 AUTHOR

Syed Reza

=cut

sub die_with_usage { my $error = shift;
	print "Usage: $0 -i [input.arff] -o [output.data]\n";
	print "------------------------------------------\n";
	printf "%-5s\t%s\n", "-attr", "the NAME of the output \@attribute";
	printf "%-5s\t%s\n", "", "(defaults to last \@attribute)";

	if($error) {
		print "\nError: $error\n";
	}
	exit(1);
}

=head1 DESCRIPTION

This is not a very general purpose script. 
It treats all Numeric values in 
the input arff file as input nodes in FANN.

It allows you to specify the target attribute in the ARFF file
for the output node in the NN. By default the target column, 
specified with the -attr option, is the name of the last @attribute

If your target column is of type Nominal (as it is in most classification cases)
this script will automatically create log2(number_of_nominals)

=cut

my $arff;
my $data;
my $attr;

GetOptions(
	"i=s", \$arff,
	"o=s", \$data,
	"attr=s", \$attr,
);

unless(-e $arff) {
	die_with_usage;
}

if($attr) {
	print "Output \@attribute is $attr\n";
	print "Searching for \@attribute $attr\n";
} else {
	$attr = undef;
	print "Output \@attribute is assumed to be the last one\n";
}

my $arff_fh;
my $data_fh;

my $capture = "";
my $attr_name; my $attr_type;
my $target_attr_name = undef;
my $target_attr_type = undef;
my $target_attr_index = undef;
my $count = 0;
my $indata = 0;

my @vector;
my $expected_vector_length = 0;

my $input_node_count = 0;
my $output_node_count = 0;

open($arff_fh, "<$arff");
while(<$arff_fh>) { chomp;
	if($_ =~ /^\s*\@data/) {
		$indata = 1;
		unless(defined($attr)) {
			$target_attr_name = $attr_name;
			$target_attr_type = $attr_type;
			# we have taken the last attribute to be the output attribute
			# we must set the capture to be 0
			chop($capture); $capture .= "0";
			$target_attr_index = length($capture)-1;
		}
		$count = 0;
		$expected_vector_length = length($capture);

		print "TARGET_ATTR_NAME = $target_attr_name\n";
		print "TARGET_ATTR_TYPE = $target_attr_type\n";
		print "TARGET_ATTR_INDEX = $target_attr_index\n\n";
		print "VECTOR LENGTH = ", length($capture), "\n";
		# print "CAPTURE = \n$capture";
		next;
	}
	if($indata) {
		# last;
		if($_ !~ /^\s*$/) {
			@vector = split(/\s*\,\s*/);
			if(scalar(@vector) == $expected_vector_length) { $count++; }
		}
	} else {
		if($_ =~ /^\s*\@attribute\s+(.+)\s+(.+)\s*$/) {
			$attr_name = $1; 
			$attr_type = $2;

			if($attr && $attr_name eq $attr) {
				$target_attr_type = $attr_type;
				$target_attr_name = $attr_name;
				$target_attr_index = $count;
				$capture .= "0";
			}
			else {
				if($attr_type eq "numeric") {
					$capture .= "1";
					$input_node_count++;
				} else {
					$capture .= "0";
				}
			}
			$count++;
		}
	}
}
close($arff_fh);

unless(defined($target_attr_index) && defined($target_attr_name) && defined($target_attr_type)) {
	die_with_usage("Target Attribute Not Found. \nARFF invalid or \@attribute does not exist");
}

print "\n";
my @target_nominals = undef;
if($target_attr_type eq "numeric") {
	print "NOTICE: TARGET ATTRIBUTE TYPE is Numeric.\nAssuming normalized to 0-1 Sigmoid range\n";
	$output_node_count = 1;
} elsif($target_attr_type =~ /^\{(.+)\}$/) {
	print "NOTICE: TARGET ATTRIBUTE TYPE looks Nominal\n";
	print "Fixing to a set of Output Neurons...\n";

	@target_nominals = split(/\s*\,\s*/, $1);
	$output_node_count = ceil(log2(scalar(@target_nominals)));
}

print "\n\n";
print "NUM_INSTANCES = $count\n";
print "NUM_INPUT_NODES = $input_node_count\n";
print "NUM_OUTPUT_NODES: $output_node_count\n";

open($data_fh, ">$data");
open($arff_fh, "<$arff");

print $data_fh "$count $input_node_count $output_node_count\n";
$indata = 0; $count = 0;
open($arff_fh, "<$arff");
while(<$arff_fh>) { chomp;
	if($_ =~ /^\s*\@data/) { $indata = 1; next;}
	if($indata) {
		# last;
		if($_ !~ /^\s*$/) {
			@vector = split(/\s*\,\s*/);
			if(scalar(@vector) == $expected_vector_length) {
				for(my $i = 0; $i < $expected_vector_length; $i++) {
					if(substr($capture, $i, 1)) {
						print $data_fh $vector[$i];
						print $data_fh " " unless $i == ($expected_vector_length-1);
					}
				}
				print $data_fh "\n";
				print $data_fh encode_target($vector[$target_attr_index]), "\n";
				$count++;
			}
		}
	} else { next; }
}

close($data_fh);
close($arff_fh);


sub log2 { my $n = shift;
	return log($n)/log(2);
}
sub encode_target { my $value = shift;
	if(@target_nominals) {
		my $index = 0;
		++$index until $target_nominals[$index] eq $value or $index > $#target_nominals;
		return encode_binary($index, "");
	} else {
		return $value;		
	}
}
sub encode_binary { my $num = shift;
	my @bits = (); my $p;
	for($p = 0; $p < $output_node_count; $p++) {
		if($num&(1<<$p))	{ push(@bits, 1); }
		else				{ push(@bits, 0); }
	}
	return join(" ", @bits);
}
