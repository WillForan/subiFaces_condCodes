#!/usr/bin/env perl

use strict;
use warnings;
use Spreadsheet::WriteExcel;
#use Getopt::Std;
#use v5.14;

######
# 
# Create an xls for each subject
#  and a new sheet for each condition and each phase (mem/test)
#
###
#
# assume input is sorted like subj, condition, trail
#   and is tab separated 
#  (produced by combineAll.pl)
#
#####

my %data;
my $prevSubj = 0;
my ($subj, $cond, $type, $longtype, @rest);

$ARGV[0]||='combined.tsv'; # input file
$ARGV[1]||='xls';          # folder to save xls output

# set header based on fold name (xls-lat or not)
my @header = ('Trial number', 'ROI ID', 'Mean X Coordinate of fixation', 
              'Mean Y coordinate of fixation', 'Latency to start of fix',
              'Latency to end of fix', 'Type of ROI' 
             );

   @header = ( 'Trail #','ROIID','Latency (ms)', 'ROI') if $ARGV[1] eq "xls-lat";


# open input file
open my $allFH, $ARGV[0] or die "cannot open '$ARGV[0]': $!\n";

while(<$allFH>) {
 chomp;
 # get what we need from the file
 ($subj, $cond, $type, $longtype, @rest) = split /\t/;
 $rest[6] =~s/'//g if $rest[6];


 # new subject
  if($prevSubj ne $subj ){

   # write previous subjects data
   &writexls;

   # reset prevSubj
   $prevSubj=$subj;
   
  }

 push @{$data{"$cond-$type"}}, [@rest];

}

$prevSubj=$subj;
# get the last (current) subject
&writexls;




###### handling spreadsheet writing ######

sub writexls {

  return if $prevSubj == 0; # because 0 has no data

  print "writing subj $prevSubj data\n";

  # open new xls
  my $workbook = Spreadsheet::WriteExcel->new("$ARGV[1]/$prevSubj.xls");

  # for each cond-type combo, make a new sheet
  for my $condType (sort keys %data) {
   my $worksheet = $workbook->add_worksheet("$condType");

   # add header
   unshift @{$data{$condType}}, [@header];

   # for each row
   for my $row (0..$#{$data{$condType}}+1) {

    # and each column
    for my $col (0..6) {

       # write data
       $worksheet->write($row, $col, $data{$condType}[$row][$col] );
    }

   }

  }

  # close xls
  $workbook->close();

  # clear data
  %data=();
}

