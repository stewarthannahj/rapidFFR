# rapidFFR_git
 
These scripts are project specific. More general scripts can be found at Tim Schoof’s repository: https://github.com/timschoof/eeg-analysis-scripts.git

FFR extraction from BioSemi (.bdf) files using EEGLAB.

FFR processing and graphing done in Matlab.

MATLAB version: R2016a EEGLAB version: 2020.0


FFR: Tim data pipeline

1_bdftomat_correctF0
bdf2mat.m
bdf2mat(‘inputDirectory', nListeners, ‘outputDirectory’)
Opens BDF files, references eeg, filters, saves continuous eeg waveforms to .mat. Keeps signal trigger channel (255) but not start of eeg recording trigger channel (254).

whatF0.m
whatF0(‘inputDirectory', ‘outputDirectory’)
Calculates F0, resamples so F0 is 128 Hz. Removes trigger channel.

2_preprocessing
spectralNZfloor_rapid_run <- bootstrapping needs a hell of a lot of time!
Options are hardcoded in to run spectralNZfloor_rapid_chunk_matInput.m
*need participants in individual folders to run*
Exp1 standard: 7 hours per person for 1 chunk, 35 hours per person for 5 chunks and 40-50 hours per person for iterations
Exp1 rapid: 40-50 hours per person for iterations
Exp2 longRapid: 24-30 hours per person for 15 chunks

3_analysis 
Make a csv of all of the output from each experiment from stage 2. 
e.g. Exp1 rapid, all Ps, all nReps, add & sub, phase locked & random
Run SNR_XXX on that csv e.g. SNR_rapidIterations.R
This will output a single summary line for each participant into an experiment labelled output folder
e.g. Routput_rapidIterations
Run SNR_XXXX_concat on the files in that output folder e.g. SNR_stdChunks_concat.R
This will put all of the participants into two csv files together (one add, one sub)
e.g. snr_rapidIterations_concat_add.csv and snr_rapidIterations_concat_sub.csv
Rows for participant, iteration/chunk, var_name (i.e. F1, F2, F3, F4, F5, rms)
Columns for meanNZ, meanSIG, sdNZ, sdSIG, dprime, SNR
Run 
This will put all of the participants into two csv files together (one add, one sub)
e.g. signal_mean_rapid_add.csv and signal_mean_rapid_sub.csv
Rows for participant, run, iteration/chunk
Columns for F1, F2, F3, F4, F5, rms
=> difference between final csv files (SNR_XXXX and signal_mean/NZ_XXXX) are:
Runs averaged in SNR_XXXX, they are separate in signal_mean/NZ_XXXX
F1, F2 etc. are rows in SNR_XXXX, they are columns in signal_mean/NZ_XXXX
Calculates new values (mean, sd, SNR) in SNR_XXXX, no new values calculated in signal_mean/NZ_XXXX

4_Graphing and stats
analysis.Rmd
updates figures and runs stats

Current problems:
Calculating mean SIGNAL and NZ is not working cleanly for standard FFR. They are not different from one another
	=> has been done on the following with no more luck:
100ms epoch *for chunked data*
54.xxx ms epoch *for increasing iterations of data*
7.8xxx ms epoch <- currently running
Decide how long rapid FFR should be

To do:
Need to decide on stats/research question
Figure 1 - study design
Figure 2 - quality of data
Figure 4 - need standard sorted
Figure 5 - correlations & stats. Want z-score between run 1 & run 2?
How long rapid FFR should be? Psychometric fits?
Re-writing 
DONE!

Notes:
No participant log
Everyone had normal hearing
Electrodes used: 
 Cz - active
 C7 - active NOTE not C7 electrode(!) but 7th cervical vertebra 
 CMS - ground
 DRL - ground
Electrode offsets < 40 mV
Sample rate 16,384 Hz
Timing calculations for both experiments are in: rapidFFRcalcs.xlsx

Exp 1
Std:
Sawtooth = 7.815 ms
Stimuli = 7 cycles of sawtooth => 54.6875 ms
ISI = 45.3125 ms
1,500 cycles
About 2.5 mins long
Repeated 5 times (calling this chunks) => 7,500 cycles total
(Not resampled for 128Hz as no problems)
Baseline corrected
1,000 permutations

Rapid
Sawtooth = 7.815 ms
Stimuli = continuous for 1 chunk => 7,500 cycles total
(After resample for 128Hz, get 7,503 cycles total)
About 35 ms long
Not baseline corrected
1,000 permutations

Exp 2
LongRapid:
Same as exp 1 rapid but for 15 chunks of 4,500 cycles => 67,500 cycles total
(After resample for 128Hz, get 67,497 cycles total)
Almost 9 mins long
1,000 permutations
