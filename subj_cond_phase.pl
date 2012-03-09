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

open my $allFH, 'combined.tsv' or die "cannot open 'combined.tsv': $!\n";

while(<$allFH>) {
 chomp;
 # get what we need from the file
 ($subj, $cond, $type, $longtype, @rest) = split /\t/;
 $rest[6] =~s/'//g;


 # new subject
  if($prevSubj ne $subj ){
   &writexls;
   # reset prevSubj
   $prevSubj=$subj;
   
  }

 push @{$data{"$cond-$type"}}, [@rest];

}

# get the last one
&writexls;




###### handling spreadsheet writing ######

sub writexls {

  print "new subject $subj\n";
  return if $subj == 0;

  # open new xls
  my $workbook = Spreadsheet::WriteExcel->new("xls/$subj.xls");

  for my $condType (sort keys %data) {
   my $worksheet = $workbook->add_worksheet("$condType");

   unshift @{$data{$condType}}, 
            ['Trial number', 'ROI ID', 'Mean X Coordinate of fixation', 
             'Mean Y coordinate of fixation', 'Latency to start of fix',
             'Latency to end of fix', 'Type of ROI'];

   for my $row (0..$#{$data{$condType}}+1) {

    for my $col (0..6) {
       $worksheet->write($row, $col, $data{$condType}[$row][$col] );
    }
   }

  }

  # close xls
  $workbook->close();


  # clear data
  %data=();
}

