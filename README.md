# rapidFFR_git
 
These scripts are project specific. More general scripts can be found at Tim Schoof’s repository: https://github.com/timschoof/eeg-analysis-scripts.git

FFR extraction from BioSemi (.bdf) files using EEGLAB.

FFR processing and graphing done in Matlab.

MATLAB version: R2016a EEGLAB version: 2020.0


FFR: Tim data pipeline

1_bdftomat_correctF0 </br>
bdf2mat.m </br>
bdf2mat(‘inputDirectory', nListeners, ‘outputDirectory’) </br>
Opens BDF files, references eeg, filters, saves continuous eeg waveforms to .mat. Keeps signal trigger channel (255) but not start of eeg recording trigger channel (254).

whatF0.m </br>
whatF0(‘inputDirectory', ‘outputDirectory’) </br>
Calculates F0, resamples so F0 is 128 Hz. Removes trigger channel.

2_preprocessing </br>
spectralNZfloor_rapid_run <- bootstrapping needs a hell of a lot of time! </br>
Options are hardcoded in to run spectralNZfloor_rapid_chunk_matInput.m </br>
Random - for noise - splits data into either chunks (e.g. 0 - 1500, 1500 - 3000 etc.) or 'iterations' (e.g. 0 - 1500, 0 - 3000). In that chunk/iteration it puts in specified number of epochs into data at random points. Works out components (F0, H2 etc.). Spits out into csv. Bootstraps specified number of repeats (1000 atm). Next stage (3_analysis) then deals with all of the data per participant by averaging the values across the repeats. </br>
Phaselocked - for signal - same process of splitting into chunks or 'iterations', putting in epochs etc. BUT epochs are put at regular defined intervals rather than random points. Spits out into a seperate csv from the phaselocked one </br>
*need participants in individual folders to run* </br>
Exp1 standard: 7 hours per person for 1 chunk, 35 hours per person for 5 chunks and 40-50 hours per person for iterations </br>
Exp1 rapid: 40-50 hours per person for iterations </br>
Exp2 longRapid: 24-30 hours per person for 15 chunks

3_analysis  </br>
Make a csv of all of the output from each experiment from stage 2. (phaselocked AND random for ALL participants)  </br>
e.g. Exp1 rapid, all Ps, all nReps, add & sub, phase locked & random </br>
Run SNR_XXX on that csv e.g. SNR_rapidIterations.R </br>
This will output a single summary line for each participant into an experiment labelled output folder </br>
e.g. Routput_rapidIterations </br>
Run SNR_XXXX_concat on the files in that output folder e.g. SNR_stdChunks_concat.R </br>
This will put all of the participants into two csv files together (one add, one sub) </br>
e.g. snr_rapidIterations_concat_add.csv and snr_rapidIterations_concat_sub.csv </br>
Rows for participant, iteration/chunk, var_name (i.e. F1, F2, F3, F4, F5, rms) </br>
Columns for meanNZ, meanSIG, sdNZ, sdSIG, dprime, SNR </br>
Run  </br>
This will put all of the participants into two csv files together (one add, one sub) </br>
e.g. signal_mean_rapid_add.csv and signal_mean_rapid_sub.csv </br>
Rows for participant, run, iteration/chunk </br>
Columns for F1, F2, F3, F4, F5, rms </br>
=> difference between final csv files (SNR_XXXX and signal_mean/NZ_XXXX) are: </br>
Runs averaged in SNR_XXXX, they are separate in signal_mean/NZ_XXXX </br>
F1, F2 etc. are rows in SNR_XXXX, they are columns in signal_mean/NZ_XXXX </br>
Calculates new values (mean, sd, SNR) in SNR_XXXX, no new values calculated in signal_mean/NZ_XXXX </br>

4_Graphing and stats </br>
analysis.Rmd </br>
updates figures and runs stats

Current problems: </br>
1) Standard FFR: calculating mean SIGNAL and NZ is not working cleanly. They are not different from one another </br>
	=> has been done on the following with no more luck: </br>
- 100ms epoch *for chunked data* </br>
- 54.xxx ms epoch *for increasing iterations of data* </br>
- 7.8xxx ms epoch <- not any better </br>
**Stuart currently looking at L05 to figure out**
2) Decide how long rapid FFR should be
**Hannah looking at**

To do: </br>
Exp1 </br>
How long rapid FFR should be? Psychometric fits? **Hannah doing** </br>
Figure 1 - study design **to do** </br>
Figure 2 - quality of data **to do** </br>
Figure 3 - SNR or noise vs. signal plots for standard (red) and rapid (blue) **Stuart investigating standard issue** </br>
Figure 4 - components for standard (red) and rapid (blue) **need to work out how long rapid needs to be to set chunk/iteration for this plot** </br>
Figure 5 - correlations & stats. Want z-score between run 1 & run 2? **need standard fixed to be able to do** </br>

Exp2 </br>
Figure 6 - SNR or noise vs. signal plots for long rapid (purple) **Hannah extracting smaller chunks for start of scan to look for neuroadaptation as not showing at the moment, but chunks are currently 4500 long. So trying 500 sized chunks** </br>
Change ANOVA -> regression **Hannah doing** </br>

Re-writing </br>
**DONE!**

Notes: </br>
No participant log </br>
Everyone had normal hearing </br>
Electrodes used:  </br>
 Cz - active </br>
 C7 - active NOTE not C7 electrode(!) but 7th cervical vertebra  </br>
 CMS - ground </br>
 DRL - ground </br>
Electrode offsets < 40 mV </br>
Sample rate 16,384 Hz </br>
Timing calculations for both experiments are in: rapidFFRcalcs.xlsx

Exp 1 </br>
Std: </br>
Sawtooth = 7.815 ms </br>
Stimuli = 7 cycles of sawtooth => 54.6875 ms </br>
ISI = 45.3125 ms </br>
1,500 cycles </br>
About 2.5 mins long </br>
Repeated 5 times (calling this chunks) => 7,500 cycles total </br>
(Not resampled for 128Hz as no problems) </br>
Baseline corrected </br>
1,000 permutations

Rapid </br>
Sawtooth = 7.815 ms </br>
Stimuli = continuous for 1 chunk => 7,500 cycles total </br>
(After resample for 128Hz, get 7,503 cycles total) </br>
About 35 ms long </br>
Not baseline corrected </br>
1,000 permutations

Exp 2 </br>
LongRapid: </br>
Same as exp 1 rapid but for 15 chunks of 4,500 cycles => 67,500 cycles total </br>
(After resample for 128Hz, get 67,497 cycles total) </br>
Almost 9 mins long </br>
1,000 permutations
