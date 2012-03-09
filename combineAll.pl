#!/usr/bin/env perl

use strict;
use warnings;
use Text::Iconv;
use Spreadsheet::XLSX;
#use Getopt::Std;
#use v5.14;

######
# 
# Combine all subjects to one master list
#
# run like:
#  ./combineAll.pl > combined.tsv
#
# stdoutput:
#
#   subject id, condtion num, test/mem, long roiid, trial, ROIID, X,Y, start, end, roitype 
#
# stderr:
#   prints working file
#
#####

my $converter = Text::Iconv -> new ("utf-8", "windows-1251");

my %ROIID = (
   1 =>  'Memorization left-facing BOB',
   2 =>  'Memorization center-facing BOB',
   3 =>  'Memorization right-facing BOB',
   4 =>  'Test Left-facing B/J/M/N/Z left',
   5 =>  'Test Left-facing B/J/M/N/Z center',
   6 =>  'Test Left-facing B/J/M/N/Z right',
   7 =>  'Test Center-facing ALL left',
   8 =>  'Test Center-facing ALL center',
   9 =>  'Test Center-facing ALL right',
   10 => 'Test right-facing B/J/M/N/Z left',
   11 => 'Test right-facing B/J/M/N/Z center',
   12 => 'Test right-facing B/J/M/N/Z right',
   13 => 'Memorization left-facing D/J/M/N/Z',
   14 => 'Memorization center-facing D/J/M/N/Z',
   15 => 'Memorization right-facing D/J/M/N/Z',
   16 => 'Test Left-facing DAN left',
   17 => 'Test Left-facing DAN center',
   18 => 'Test Left-facing DAN right',
   19 => 'Test Right-facing DAN left',
   20 => 'Test Right-facing DAN center',
   21 => 'Test Right-facing DAN right',
   22 => 'Memorization Bob in array of six',
   23 => 'Memorization Dan in array of six',
   24 => 'Memorization Jim in array of six',
   25 => 'Memorization Matt in array of six',
   26 => 'Memorization Nate in array of six',
   27 => 'Memorization Zach in array of six'
);

my @files = glob('~/remotes/B/bea_res/Personal/Andrew/Autism/Experiments\ \&\ Data/K\ Award/Behavioral\ Tasks/Raw\ Data/Cambridge\ Face\ Task/[0-9]*/[0-9]*_Fixation\&ROI.xlsx');

for my $file (@files) {
   print STDERR "$file\n";
   $file =~ m:Face Task/(\d+)/:;
   my $subjectID = $1;
   #next if -r "$file";
   my $excel = Spreadsheet::XLSX -> new($file,$converter);
   
   foreach my $sheet (@{$excel -> {Worksheet}}) {

     # find the right sheet
     next unless $sheet->{Name} eq "results.fix";

     # get subject id (B1), not always there, use id from file
     #my $subjectID = $sheet->{Cells}[0][1]->{Val} ;

     # list all values (Trial ROIID XfixationMean Yfixation LatencyFixStart LatencyFixEnd ROIType)
     # start on row 5 (4 if 0-index) from A to G (0 to 6)
     my $condition=0;
     my $prevTrial=0;
     my $prev='Test';
     
     for my $row   (4 .. $sheet->{MaxRow} ) {
         # whate does the roiid really mean
         my $roiid    =  $ROIID{$sheet->{Cells}[$row][1]->{Val}};


         my $memOrTest='Test';
            $memOrTest='Mem' if $roiid =~ /^Mem/;

         if ($prev eq 'Test' and $memOrTest eq 'Mem') {
            my $curTrial = $sheet->{Cells}[$row][0]->{Val};

            my $lengthOfTest =  $curTrial - $prevTrial;


            # new condition occurs at first transition from test to mem
            # and again only after 48 and then 35 trials
            if ($condition == 0                              # first time see new mem after test, new condition
                || ($condition == 1 && $lengthOfTest == 48)  # go from 1 to 2 after 48 trails
                || ($condition == 2 && $lengthOfTest == 35)  #         2 to 3 after 35 trials
               ){

               # new codition, new prevTrialStart
               $condition++;
               $prevTrial = $curTrial;

               #print STDERR $condition ,"\t", $lengthOfTest, "\n";
            }
         }
         $prev = $memOrTest;


         print join("\t", $subjectID, $condition, $memOrTest,$roiid,
           map { $sheet->{Cells}[$row][$_]->{Val} }  (0..6)
         ), "\n";
         #  subject id, condtion num, test/mem, long roiid, trial, ROIID, X,Y, start, end, roitype 
     }
   }

}
