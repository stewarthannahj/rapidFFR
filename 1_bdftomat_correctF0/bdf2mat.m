function bdf2mat(fileDirectory, nListeners, OutputDir)
% This script opens all BDF files in a folder, references the EEG signals,
% filters them, and saves the continuous EEG waveforms in .mat form

% Dependencies:
%  * eeglab
%  * butter_filtfilt.m
%
%   MATLAB version: R2016a
%   EEGLAB version: eeglab14_1_1b
%
% Tim Schoof - t.schoof@ucl.ac.uk

% 2 Oct 2020 HJS adapted for Mac

% some starting values
Active = 'EXG1'; % active electrode
Reference = 'EXG2'; % reference electrode
Lcut_off = 70;
Hcut_off = 2000; 
order = 2; % filter order

% create output directory
mkdir(OutputDir);

% start eeglab
addpath(genpath('eeglab')) % add eeglab and subfolders to path
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for j = 1:nListeners
    if j < 10
        listener = ['L0',num2str(j)];
    else
        listener = ['L',num2str(j)];
    end
    
    if ismac
    fileDir = ['/' fileDirectory '/' listener '/' listener '-N'];
    elseif ispc
    fileDir = ['\' fileDirectory '\' listener '\' listener '-N'];
    end
    
    % get a list of files
    %% fileList = fullfile(/Users/drhjs/Desktop/L01-N, '*.bdf'); %%testing It's putting fileDir in as a string and it doesn't like it....
    Files = dir(fullfile(fileDir, [listener '*.bdf'])); %% fileDir being weird here! fileDir wants '' and then the Wildcard goes in as text rather than working as a wildcard...
    nFiles = size(Files);    
    
    %%
    for i=1:nFiles(1)
        fileName = Files(i).name;
        [pathstr, name, ext] = fileparts(fileName);
        
        % specify required channels
        if strcmp(Active, 'EXG1')
            Act = 33;
        elseif strcmp(Active, 'EXG2')
            Act = 34;
        else
            error('ERROR: Your active electrode should be EXG1, EXG2, EXG3, or A32')
        end
        
        if strcmp(Reference, 'EXG1')
            Ref = 33;
        elseif strcmp(Reference,'EXG2')
            Ref = 34;
        elseif strcmp(Reference, 'EXG3')
            Ref = 35;
        elseif strcmp(Reference, 'EXG4')
            Ref = 36;
        else
            error('ERROR: Your reference electrode should be EXG2, EXG3, or EXG4')
        end
        
        if Act == Ref
            error('ERROR: Your reference electrode and active electrode cannot be the same')
        end
        
        % load bdf file, extract only active and reference channel, and save as EEG data set
        POS = pop_biosig_TS((fullfile(fileDir,fileName)), 'channels', [Act Ref],'ref',Ref,'blockepoch','off');
        [ALLPOS POS] = eeg_store(ALLEEG, POS, CURRENTSET);
        POS = eeg_checkset( POS );
        
        % re-code channels (only 2 channels remain)
        Act = 1;
        Ref = 2;
        
        % re-reference the data to EXG2 (34) and save as new EEG data set
        POS = pop_reref( POS, Ref);
        [ALLPOS POS] = eeg_store(ALLEEG, POS, CURRENTSET);
        POS = eeg_checkset( POS );
        
%         % filter based on filtfilt (so effectively zero phase shift)
%         % and save as new EEG data set
%         % save figure of frequency response filter
        fprintf('%s', 'Filtering...')
        [POS.data b a] = butter_filtfilt(POS.data, Lcut_off, Hcut_off, order);
        [ALLPOS POS] = eeg_store(ALLPOS, POS, CURRENTSET);
        POS = eeg_checkset( POS );

%           trigger #1 = start of eeg
%           trigger #2 = start of stimuli
%           trigger #3 = end of stimuli

        EEGwave = POS.data;        
%         for k = 2:length(POS.event)   % HJS removed as it was overwriting trigger #2 with #3. 
        for k = 2
            triggerLocation = POS.event(:,k).latency;
            triggers = zeros(1,length(POS.data));
            triggers(triggerLocation) = 1;
        end
        
        ffr=[EEGwave;triggers];
        ffr=ffr';
        
        if ismac
        save(['',OutputDir,'/',name,'.mat',''],'ffr')
        elseif ispc
        save(['',OutputDir,'\',name,'.mat',''],'ffr')
        end
        
         pwelch(ffr,[],[],[],16384)
         if ismac
         saveas(gcf,['',OutputDir,'/',name,'_fft','.fig',''])
         elseif ispc
         saveas(gcf,['',OutputDir,'\',name,'_fft','.fig',''])
         end
         
    end
end

close all 
%clear all