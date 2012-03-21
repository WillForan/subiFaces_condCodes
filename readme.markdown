## Run ##
### create per condition-phase xls for each subject ###
	./combineAll.pl > combined.tsv
	./subj_cond_phase.pl 
### get averages ###
	[ryan does magic macro templating ]
	./transposeAverages.pl > averages.tsv
	cp averages.tsv /home/foranw/remotes/B/bea_res/Personal/Andrew/Autism/Experiments\ \&\ Data/K\ Award/Behavioral\ Tasks/Raw\ Data/Cambridge\ Face\ Task/
### Also for Fixation ###
	./combineAllFixation.pl > combined_lat.tsv
	./subj_cond_phase.pl combined_lat.tsv xls-lat


## BAD DATA ##
### Fixation ###
based on output of ./cond-phaseTest.pl
entries where phase transtion doesn't match expected count
    106 (empty)
    112
    123
    126
    145
    154
    158
    168
    169 (empty)
    182 (empty)

wouldn't catch if 3rd test/mem is off
### Latency ###



## Objective ##
* take per subject xls of trail number, ROID, x,y,latency to start, lat to end,roi type
* add "condition" (1-3) and phase (mem or test)
* seperate into 6 worksheets.

## Data ##

* ROI referes to fixation type
* each trail number can be repeated  (many fixatiosn per trail)

* condition 1 should have 48 trials (6x m/t) with memorization ROIs 1-3,13-14
*           2             35        (1x m/t)                        22-27
*           3             26        (1x m/t)                        22-27

* test ROIs are 4-11,16-21

- see below for file locations
## Approach ##

### combineAll.pl creates combined.tsv ###

* read line of xls
* find mem->test transition (phase change)
    - check count given codition (1-3)
    - increment condtion 
* print subj, condition, phase, decoded roi, and other data

### subj_cond_phase.pl ###
* works on combined.tsv to create xls/\*xls
* assumes sort, partitions condition-phase into worksheets of per subject xls

## transposeAverages.pl ###
 take ryans script output and make row for each subject-condtion-phase pairing

## Files ##
From:
      B:\bea_res\Personal\Andrew\Autism\Experiments & Data\K Award\Behavioral Tasks\Raw Data\Cambridge Face Task\${subjdirectory}\${subjID}_Fixation&ROI

      ~/remotes/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/Raw Data/Cambridge Face Task/${subjdirectory}/${subjID}_Fixation&ROI

      ~/remotes/B/bea_res/Personal/Andrew/Autism/Experiments\ \&\ Data/K\ Award/Behavioral\ Tasks/Raw\ Data/Cambridge\ Face\ Task/
 
