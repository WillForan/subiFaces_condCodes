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

my @key=qw/Subj Cond Phase Fix AvgFix FLat FAvgDur ELat EAvgDur MLat MAvgDur F#Fix E#Fix N#Fix Total#Fix E:A N:A M:A Core:A E:M E:N F%Fix E%Fix N%Fix M%Fix F%TotFix E%TotFix N%TotFix M%TotFix/;
my @AvgRows=qw/5 6 10 11 13 14 16 17 19 20 23 24 25 26 27 30 31 32 33 34 35 41 42 43 44 47 48 49 50/;
my $noValHold="-";
# grab all the fixation spreadsheets
my @files = glob('/home/foranw/remotes/B/bea_res/Personal/Andrew/Autism/Experiments\ \&\ Data/K\ Award/Behavioral\ Tasks/Raw\ Data/Cambridge\ Face\ Task/March19ScriptOutput/[0-9]*xlsx');


print join "\t", @key, "\n";
for my $file (@files) {
   #next if -r "$file"; # list but not read permission?


   # get the subject ID
   #  could use below, but it's not always there. Filename is safer
     # get subject id (B1), not always there, use id from file
     #my $subjectID = $sheet->{Cells}[0][1]->{Val} ;
   $file =~ m:/(\d+)_:;
   my $subjectID = $1;
   
   print STDERR "$file\n$subjectID\n"; # to STDERR so input is not captures with redirect or pipe

   my $excel = Spreadsheet::XLSX -> new($file);
   
   foreach my $sheet (@{$excel -> {Worksheet}}) {

     push my @subjCondPhaseInfo, $subjectID;
     push @subjCondPhaseInfo, (split /-/, $sheet->{Name});

     
     # get all values in rows of AvgRows. repalce no val with -
     push @subjCondPhaseInfo, map { $sheet->{Cells}[$_][9]->{Val} || $noValHold } @AvgRows;
     @subjCondPhaseInfo =     map { $_ eq "#DIV/0!"   ?   $noValHold : $_       } @subjCondPhaseInfo;

     print join "\t", @subjCondPhaseInfo;
     print "\n";
   }

   #last

}
