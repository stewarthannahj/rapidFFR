%% bootstrap fft & rms (repeats = 100 times)
% change repeats to adjust how many times to draw from the data set
for i=1 % loop through 16 participants    
    i
    if i<10
        listener = ['','L0',num2str(i),'']
    else
        listener = ['','L',num2str(i),'']
    end
    
% % %     % bootstrap Rapid FFR
% % %     for j = 1:15% loop through 500-7500 nReps, in steps of 500
% % %         nReps = j*500
% % %         % phaselocked 
% % %         %                                   (fileDirectory,                                                                                                           OutputDir,                                                                                                                  outFileName,                                FFRtech, condition,     draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% % %         spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/'], ['',listener,'rapid_NZfloor_phaselocked'],  'rapid', 'phaselocked', nReps, 2  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% % %         
% % %         % random
% % %         %                                   (fileDirectory,                                                                                                           OutputDir,                                                                                                                  outFileName,                              FFRtech,    condition,    draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% % %         spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/'], ['',listener,'rapid_NZfloor_random2'],    'rapid',    'random',     nReps, 2  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% % %     end
    
% % %     % bootstrap Standard FFR
% % %     % phaselocked
% % %     %                                   (fileDirectory,                                                                                                                OutputDir,                                                                                                                       outFileName,                                   FFRtech,    condition,     draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% % %     spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/standard_unadjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/standard_unadjusted/', listener, '/'], ['',listener,'standard_NZfloor_phaselocked'],  'standard', 'phaselocked', 1500,  2  ,     1500,           1,      0,      100,     128,       128,    256,    384,    512, 640,   'with')
% % % 
% % %     % random
% % %     %                                   (fileDirectory,                                                                                                                OutputDir,                                                                                                                       outFileName,                                   FFRtech,    condition,   draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% % %     spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/standard_unadjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/standard_unadjusted/', listener, '/'], ['',listener,'standard_NZfloor_phaselocked'],  'standard', 'random',    1500,  2  ,     1500,           1,      0,      100,     128,       128,    256,    384,    512, 640,   'with')
% % %     
end
 
% HC - steps of 4500 (sliding window)
for i=1 % loop through 21 participants
    if i<10
        listener = ['','L0',num2str(i),''];
    else
        listener = ['','L',num2str(i),''];
    end
     
    % bootstrap Rapid FFR
        % phaselocked                                                                                                                                                                                                                                                                                                                                                       % ?????          %64000?
        %                                   (fileDirectory,                                                                                                           OutputDir,                                                                                                                    outFileName,                                    FFRtech, condition,     draws,  repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
        spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['',listener,'longRapid_NZfloor_phaselocked'],  'rapid', 'phaselocked', 4500,   2,       67500,          15,     0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
        
        % random
        %                                   (fileDirectory,                                                                                                           OutputDir,                                                                                                                    outFileName,                                  FFRtech,    condition,    draws,  repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
        spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['',listener,'longRapid_NZfloor_random2'],    'rapid',    'random',     4500,   2,       67500,          15,     0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
    
end