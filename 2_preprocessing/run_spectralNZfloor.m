%% bootstrap fft & rms (repeats = 100 times)
% change repeats to adjust how many times to draw from the data set
disp('Experiment 1')
for i=1:16 % loop through 16 participants    % done random 1, 6, 7:16. To do 2, 3:5
    if i<10
        listener = ['','L0',num2str(i),'']
    else
        listener = ['','L',num2str(i),'']
    end
    
    % bootstrap Rapid FFR
    %   if i == 2
    %      maxj = 14;
    % else
    %        maxj = 15;
    %    end
    
    %  for j = 14:maxj % loop through 500-7500 nReps, in steps of 500
    %  tic
    %      nReps = j*500
       % phaselocked
       %                                     (fileDirectory,                                                                                                           OutputDir,                                                                                                                  outFileName,                                FFRtech, condition,     draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% HJS laptop
       %        spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/', j, '/'], ['',listener,'rapid_NZfloor_phaselocked_'],  'rapid', 'phaselocked', nReps, 1000  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% server
       %        spectralNZfloor_rapid_chunk_matInput(['/home/ucjuhj0/ffr/data/exp1/rapid_adjusted/', listener, '/'],                                                            ['/home/ucjuhj0/ffr/preprocessed/exp1/rapid_adjusted/', listener, '/', j, '/'],                                                     ['',listener,'rapid_NZfloor_phaselocked'],  'rapid', 'phaselocked', nReps, 1000  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% loanPC 
       %        spectralNZfloor_rapid_chunk_matInput(['C:\Users\h.stewart\OneDrive - University College London\rapidFFR\1_data\2_waveformsmat\rapid_adjusted\', listener, '\'], ['C:\Users\h.stewart\Documents\rapidFFR\1_data\3_preprocessedmat\rapid_adjusted\', listener],  ['',listener,'rapid_NZfloor_phaselocked'],  'rapid', 'phaselocked', nReps, 1000  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
       
       % random
       %                                     (fileDirectory,                                                                                                           OutputDir,                                                                                                                  outFileName,                              FFRtech,    condition,   draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% HJS laptop
       %        spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/rapid_adjusted/', listener, '/', j, '/'], ['',listener,'rapid_NZfloor_random_'],    'rapid',    'random',     nReps, 1000  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% server
       %        spectralNZfloor_rapid_chunk_matInput(['/home/ucjuhj0/ffr/data/exp1/rapid_adjusted/', listener, '/'],                                                            ['/home/ucjuhj0/ffr/preprocessed/exp1/rapid_adjusted/', listener, '/', j, '/'],                                                     ['',listener,'rapid_NZfloor_random'],    'rapid',    'random',     nReps, 1000  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% loanPC
       %        spectralNZfloor_rapid_chunk_matInput(['C:\Users\h.stewart\OneDrive - University College London\rapidFFR\1_data\2_waveformsmat\rapid_adjusted\', listener, '\'], ['C:\Users\h.stewart\Documents\rapidFFR\1_data\3_preprocessedmat\rapid_adjusted\', listener], ['',listener,'rapid_NZfloor_random'],    'rapid',    'random',     nReps, 1000  ,     nReps,          1,      0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
 %  toc
 %  end
    
    
    % bootstrap Standard FFR
    % phaselocked
      tic
        %                                         (fileDirectory,                                                                                                                OutputDir,                                                                                                                 outFileName,           FFRtech,    condition,     draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% HJS laptop
        %        spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/standard_unadjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/standard_unadjusted/', listener], ['',listener,'standard_NZfloor_phaselocked_'],  'standard', 'phaselocked', 1500,  1000  ,     1500,           1,      0,      100,     128,       128,    256,    384,    512, 640,   'with')
% server
        %        spectralNZfloor_rapid_chunk_matInput(['/home/ucjuhj0/ffr/data/exp1/standard_unadjusted/', listener, '/'],                                                            ['/home/ucjuhj0/ffr/preprocessed/exp1/standard_unadjusted/', listener],                                                   ['',listener,'standard_NZfloor_phaselocked'],   'standard', 'phaselocked', 1500,  1000  ,     1500,           1,      0,      100,     128,       128,    256,    384,    512, 640,   'with')
% loanPC
        %        spectralNZfloor_rapid_chunk_matInput(['C:\Users\h.stewart\OneDrive - University College London\rapidFFR\1_data\2_waveformsmat\standard_unadjusted\', listener, '/'],   ['C:\Users\h.stewart\Documents\rapidFFR\1_data\3_preprocessedmat\rapid_adjusted\', listener], ['',listener,'standard_NZfloor_phaselocked_5chunks'],   'standard', 'phaselocked',    1500,  1000  ,     1500,           5,      0,      100,     128,       128,    256,    384,    512, 640,   'with')         
        
    % random
        %                                        (fileDirectory,                                                                                                                OutputDir,                                                                                                                 outFileName,        FFRtech,    condition,   draws, repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% HJS laptop
        %        spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment1_normalVrapid/standard_unadjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment1_normalVrapid/standard_unadjusted/', listener], ['',listener,'standard_NZfloor_random_'],  'standard', 'random',    1500,  1000  ,     1500,           1,      0,      100,     128,       128,    256,    384,    512, 640,   'with')
% server
        %          spectralNZfloor_rapid_chunk_matInput(['/home/ucjuhj0/ffr/data/exp1/standard_unadjusted/', listener, '/'],                                                            ['/home/ucjuhj0/ffr/preprocessed/exp1/standard_unadjusted/', listener],                                                   ['',listener,'standard_NZfloor_random'],   'standard', 'random',    1500,  1000  ,     1500,           1,      0,      100,     128,       128,    256,    384,    512, 640,   'with')
% loanPC
        spectralNZfloor_rapid_chunk_matInput(['C:\Users\h.stewart\OneDrive - University College London\rapidFFR\1_data\2_waveformsmat\standard_unadjusted\', listener, '\'],   ['C:\Users\h.stewart\Documents\rapidFFR\1_data\3_preprocessedmat\rapid_adjusted\', listener], ['',listener,'standard_NZfloor_random_5chunks'],   'standard', 'random',    1500,  1000  ,     1500,           5,      0,      100,     128,       128,    256,    384,    512, 640,   'with')         
	toc
end
 
% HC - steps of 4500 (sliding window)
% disp('Experiment 2')
% for i=1:21 % loop through 21 participants
%     if i<10
%         listener = ['','L0',num2str(i),''];
%     else
%         listener = ['','L',num2str(i),''];
%     end
     
%     % bootstrap Rapid FFR
        % phaselocked                                                                                                                                                                                                                                                                                                                                                       
        %                                     (fileDirectory,                                                                                                            OutputDir,                                                                                                                   outFileName,                                    FFRtech, condition,     draws,  repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% HJS laptop
        %         spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['',listener,'longRapid_NZfloor_phaselocked'],  'rapid', 'phaselocked', 4500,   2,       67500,          15,     0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% server
        %         spectralNZfloor_rapid_chunk_matInput(['/home/ucjuhj0/ffr/data/exp2/longRapid_adjusted/', listener, '/'],                                                         ['/home/ucjuhj0/ffr/preprocessed/exp2/longRapid_adjusted/', listener, '/'],                                                  ['',listener,'longRapid_NZfloor_phaselocked'],  'rapid', 'phaselocked', 4500,   1000,       67500,          15,     0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
        
        % random
        %                                     (fileDirectory,                                                                                                            OutputDir,                                                                                                                   outFileName,                                  FFRtech,    condition,   draws,  repeats, totalSweeps,    chunks, s_epoch,e_epoch, prestim,   F0,     F1,     F2,     F3,  F4,    replacement)
% HJS laptop
        %         spectralNZfloor_rapid_chunk_matInput(['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/2_waveformsmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/3_preprocessedmat/Experiment2_longRapid/longRapid_adjusted/', listener, '/'], ['',listener,'longRapid_NZfloor_random'],    'rapid',    'random',     4500,   2,       67500,          15,     0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
% server
        %         spectralNZfloor_rapid_chunk_matInput(['/home/ucjuhj0/ffr/data/exp2/longRapid_adjusted/', listener, '/'],                                                         ['/home/ucjuhj0/ffr/preprocessed/exp2/longRapid_adjusted/', listener, '/'],                                                  ['',listener,'longRapid_NZfloor_random'],    'rapid',    'random',     4500,   1000,       67500,          15,     0,      7.8125,  128,       128,    256,    384,    512, 640,   'with')
    
% end