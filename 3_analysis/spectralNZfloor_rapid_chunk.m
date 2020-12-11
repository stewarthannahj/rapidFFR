function spectralNZfloor_rapid_chunk(fileDirectory, listener, Active, Reference, Lcut_off, Hcut_off, technique, condition, draws, repeats, totalSweeps, chunks,s_epoch, e_epoch, prestim, F0, F1, F2, F3, F4,outout,replacement)
% with replacement
% NB: for normal technique, cuts of first and last F0 cycle of epoch

% technique = 'rapid' or 'normal'
% condition = 'random' or 'phaselocked'
% draws = number of draws, or trials picked per FFT calculation (e.g. 400; so half is pos, half is neg)
% repeats = number of times to compute FFT; 100 for phase-locked, 1000 for random
% totalSweeps = number of sweeps in the response (e.g. 7500)
% chunk = number of chunks needed to analyze (e.g. total is 7500 nReps, but
% you want to analyze 1500 nReps at a time, staring with 1-1500, then
% 1501-3000 etc.)

%% some starting values
order = 2;
cut_trig = 0.002; % cut off first 2 ms of each epoch for normal technique to get rid of trigger artefact

%%
fileDirectory = [fileDirectory '\' listener];
% get a list of files
Files = dir(fullfile(fileDirectory, '*.bdf'));
nFiles = size(Files);

% create output directory
OutputDir = ['Output_' outout '_NZfloor'];
mkdir(OutputDir);

% construct the output data file name
outfile = ['', OutputDir,'\',listener,'_FFT_Nzfloor_', technique, '_', condition,'.csv', ''];
% write some headings and preliminary information to the output file
if ~exist(outfile)
    fout = fopen(outfile, 'at');
    fprintf(fout, 'file,listener,combine,condition,repeats,repetition,sweeps,chunk,Freq1,Freq2,Freq3,Freq4,Freq5,rms\n');
    fclose(fout);
end

for i=1:nFiles(1)
    fileName = Files(i).name;
    [pathstr, name, ext] = fileparts(fileName);
    polarity = strtrim(regexp(name,'pos|neg','match'));
    %     method = char(strtrim(regexp(name,'rapid|normal','match')));
    
    %     if strcmp(technique, method)
    if strcmp(polarity,'pos')
        
        % specify required channels
        if strcmp(Active, 'EXG1')
            Act = 33;
        elseif strcmp(Active, 'EXG2')
            Act = 34;
        elseif strcmp(Active, 'EXG3')
            Act = 35;
        elseif strcmp(Active, 'A32')
            Act = 32;
        elseif strcmp(Active, 'A26')
            Act = 26;
        elseif strcmp(Active, 'A5')
            Act = 5;
        elseif strcmp(Active, 'A13')
            Act = 13;
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
        
        % start eeglab
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        
        % load bdf file, extract only active and reference channel, and save as EEG data set
        POS = pop_biosig_TS((fullfile(fileDirectory,fileName)), 'channels', [Act Ref],'ref',Ref,'blockepoch','off');
        [ALLPOS POS] = eeg_store(ALLEEG, POS, CURRENTSET);
        POS = eeg_checkset( POS );
        
        NegFile = regexprep(fileName, 'pos', 'neg');
        if exist(fullfile(fileDirectory,NegFile))
            % load bdf file, extract only active and reference channel, and save as EEG data set
            NEG = pop_biosig_TS((fullfile(fileDirectory,NegFile)), 'channels', [Act Ref],'ref',Ref,'blockepoch','off');
            [ALLNEG NEG] = eeg_store(ALLEEG, NEG, CURRENTSET);
            NEG = eeg_checkset( NEG );
            
            % re-code channels (only 2 channels remain)
            Act = 1;
            Ref = 2;
            
            % re-reference the data to EXG2 (34) and save as new EEG data set
            POS = pop_reref( POS, Ref);
            [ALLPOS POS] = eeg_store(ALLEEG, POS, CURRENTSET);
            POS = eeg_checkset( POS );
            
            NEG = pop_reref( NEG, Ref);
            [ALLNEG NEG] = eeg_store(ALLEEG, NEG, CURRENTSET);
            NEG = eeg_checkset( NEG );
            
            % filter based on filtfilt (so effectively zero phase shift)
            % and save as new EEG data set
            % save figure of frequency response filter
            fprintf('%s', 'Filtering...')
            [POS.data b a] = butter_filtfilt(POS.data, Lcut_off, Hcut_off, order);
            [ALLPOS POS] = eeg_store(ALLPOS, POS, CURRENTSET);
            POS = eeg_checkset( POS );
            
            [NEG.data b a] = butter_filtfilt(NEG.data, Lcut_off, Hcut_off, order);
            [ALLPOS NEG] = eeg_store(ALLPOS, NEG, CURRENTSET);
            NEG = eeg_checkset( NEG );
            
            % convert epoch start and end times to seconds
            s_epoch_s = s_epoch/1000;
            e_epoch_s = e_epoch/1000;
            % determine trigger interval
            s_trig_interval = round(((e_epoch-s_epoch)/1000)*POS.srate);
            
            for m = 1:chunks % analyze chunks of the EEG signal one by one (shifting by certain number of sweeps)
                endSweep = m*(totalSweeps/chunks); % determine end point for triggers
                startSweep = endSweep-(totalSweeps/chunks)+1; % determine start point for triggers
                for l = 1:repeats
                    for jj = 1:2 % loop through positive and negative polarities
                        if jj == 1
                            EEG = POS;
                            ALLEEG = ALLPOS;
                        elseif jj == 2
                            EEG = NEG;
                            ALLEEG = ALLNEG;
                        end
                        
                        % epoch and save as new EEG data set
                        % create event channel (i.e. put in triggers)
                        if strcmp(technique,'rapid')
                            startTrig = EEG.event(1,2).latency + round((prestim/1000)*EEG.srate) + ((startSweep+2)*s_trig_interval); % don't look at first 2 nReps
                            endTrig = EEG.event(1,2).latency + round((prestim/1000)*EEG.srate) + ((endSweep-2)*s_trig_interval); % don't look at final nRep
                        end
                        
                        if strcmp(condition,'random')
                            % create randomly placed triggers
                            r = round((endTrig-startTrig).*rand(1,draws)+startTrig);
                            r = sort(r);
                        elseif strcmp(condition,'phaselocked')
                            % create triggers for rapid FFR
                            if strcmp(technique,'rapid')
                                triggers = [startTrig:s_trig_interval:endTrig];
                                
                                if length(triggers) < draws
                                    draws = length(triggers);
                                end
                                % select random trials
                                % indeces of random set of triggers
                                index = randperm(length(triggers));
                                index = index(1:draws);
                                r = triggers(index); % select random triggers by index
                            end
                        end
                        
                        % replace trigger field
                        if strcmp(technique,'rapid')
                            for kk = 1:length(r)
                                if kk == 1
                                    EEG = rmfield(EEG, 'event'); % remove EEG.event field, will be replaced below
                                end
                                EEG.event(1,kk) = struct('type',255,'latency',r(kk),'urevent',kk);
                            end
                        end
                        
                        %                         elseif strcmp(method,'normal')
                        %                             if strcmp(condition,'random')
                        %                                 startTrig = EEG.event(2).latency;
                        %                                 endTrig = EEG.event(totalSweeps+1).latency;
                        %                                 EEG = rmfield(EEG, 'event'); % remove EEG.event field, will be replaced below
                        %
                        %                                 % create randomly placed triggers
                        %                                 r = round((endTrig-startTrig).*rand(1,draws)+startTrig);
                        %                                 r = sort(r);
                        %                                 for k = 1:length(r)
                        %                                     EEG.event(1,k) = struct('type',255,'latency',r(k),'urevent',k);
                        %                                 end
                        %                             end
                        %                         end
                        
                        % save set
                        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                        EEG = eeg_checkset( EEG );
                        
                        % sampling with replacement (selecting epochs - may overlap for 'random')
                        
                        % make sure there are enough possible epochs for
                        % the number of draws
                        if length(EEG.event) < draws
                            draws = length(EEG.event);
                        end
                        
                        %                         if strcmp(method,'normal')
                        %                             epoch=zeros((draws),round(e_epoch_s*EEG.srate)-round(cut_trig*EEG.srate));
                        %                         else
                        epoch=zeros((draws),round((e_epoch_s-s_epoch_s)*EEG.srate));
                        %                         end
                        
                        for n = 1:(draws) %
                            if strcmp(replacement,'with') % with replacement
                                perm = randperm(draws);
                                perm = perm(1);
                            else % without replacement
                                perm = n; 
                            end
                            startLat = round(EEG.event(1,perm).latency);
                            if strcmp(technique,'standard')
%                                 startLat = startLat + round(cut_trig*EEG.srate);
%                                 epoch(n,:) = EEG.data(startLat:startLat+round(e_epoch_s*EEG.srate)-round(cut_trig*EEG.srate)-1);
                                if EEG.event(1,perm).type == 255
                                    startLat = startLat + round(s_epoch_s*EEG.srate);
                                    epoch(n,:) = EEG.data(startLat:startLat+round((e_epoch_s-s_epoch_s)*EEG.srate)-1);
                                end
                            else
                                epoch(n,:) = EEG.data(startLat:startLat+round((e_epoch_s-s_epoch_s)*EEG.srate)-1);
                            end
                        end
                        
%                         if strcmp(method,'standard')
%                             if strcmp(condition,'phaselocked')
%                                 % baseline correction
%                                 for n = 1:(draws)
%                                     epoch(n,:) = [(epoch(n,1:(round((e_baseline/1000)*EEG.srate)-1))) epoch(n,(round((e_baseline/1000)*EEG.srate)):length(epoch(n,:)))-mean(epoch(n,1:(round((e_baseline/1000)*EEG.srate))))];
%                                 end
%                             end
%                         end
                        
                        % reject artifacts (outside +/- 25 uV)
                        % create index of trials to be removed
                        countr = 1;
                        for nn = 1:(draws)
                            if (max(epoch(nn,:))>25) || (min(epoch(nn,:))< -25)
                                rm_index(countr) = nn;
                                countr = countr+1;
                            end
                        end
                        % remove trials
                        if exist('rm_index')
                            epoch([rm_index],:) = [];
                        end
                        
                        % average across draws
                        avg = mean(epoch,1);
                        
                        %                         if strcmp(method,'normal')
                        %                             if strcmp(condition,'phaselocked')
                        %                                 % read in csv file with stim-response lags (delays)
                        %                                 delayfile = ['',csvFile ,''];
                        %                                 delays = robustcsvread(delayfile);
                        %                                 % find the lag time
                        %                                     neural_lag = str2num(cell2mat(delays(2,6)));
                        %                                     START = round(((neural_lag+e_baseline)/1000)*EEG.srate)+F0; % Freq 1 here refers to the number of samples of one F0 cycle
                        %                                     STOP = START + (numCycles*F0)-1;
                        %                                     avg = avg(START:STOP);
                        %                             end
                        %                         end
                        %
                        if jj == 1
                            posAVG = avg;
                        elseif jj == 2
                            negAVG = avg;
                        end
                    end
                    
                    % add polarities
                    add = (posAVG + negAVG)/2;
                    
                    % remove trigger artefact
                    if strcmp(technique,'standard')
                        % find trigger (most negative going peak) within
                        % 200 samples after trigger
                        if s_epoch < 1 % if averaging window includes trigger
                            trigInd = find(negAVG == min(negAVG(1+round(abs(s_epoch_s*EEG.srate)):200+round(abs(s_epoch_s*EEG.srate)))));
                            % isolate the trigger (5 samples on either side seems reasonable)
                            artefact = [zeros(1,trigInd-6),negAVG(trigInd-5:trigInd+5),zeros(1,length(negAVG)-(trigInd+5))];
                            % subtract the trigger from the added polarity FFR
                            add = add - artefact;
                            plot(add)
                            hold on
                            plot(artefact,'color','red');
                        end
                    end
                    
                    % subtract polarities
                    subtract = (posAVG - negAVG)/2;
                    
                    % rms
                    addRMS = rms(add');
                    subRMS = rms(subtract');
                    
                    % FFT
                    for k = 1:2
                        if k == 1
                            data = add;
                        elseif k == 2
                            data = subtract;
                        end
                        
                        L=length(data);
                        NFFT = 2^nextpow2(L); % Next power of 2 from length of y
                        Y = fft(data,NFFT)/L;
                        f = EEG.srate/2*linspace(0,1,NFFT/2+1);
                        fftFFR = 2*abs(Y(1:NFFT/2+1));
                        HzScale = [0:(EEG.srate/2)/(length(fftFFR)-1):round(EEG.srate/2)]'; % frequency 'axis'
                        
                        if k == 1
                            addFFT = fftFFR;
                        elseif k == 2
                            subFFT = fftFFR;
                            % remove ALLEEG, EEG, POS, NEG
                            clear ALLEEG EEG
                        end
                    end
                    % Compute peak magnitudes over F0, F1 and HF ranges
                    for mm = 1:2
                        if mm == 1
                            fftFFR = addFFT;
                            combine = 'add';
                            sigrms=addRMS;
                        elseif mm == 2
                            fftFFR = subFFT;
                            combine = 'sub';
                            sigrms=subRMS;
                        end
                        
                        % i. F0: F0_Lo-F0_Hi.
                        % find freqs nearest F0_Lo and F0_Hi.
                        FreqInd = find(HzScale==F0,1);
                        % compute peak amplitude
                        Freq1 = fftFFR(FreqInd);
                        
                        % ii. F1: F1_Lo-F1_Hi
                        % find freqs nearest F1_Lo and F1_Hi.
                        FreqInd = find(HzScale==F1,1);
                        % compute peak amplitude
                        Freq2 = fftFFR(FreqInd);
                        
                        % iii. HF: HF_Lo-HF_Hi
                        % find freqs nearest HF_Lo and HF_Hi.
                        FreqInd = find(HzScale==F2,1);
                        % compute peak amplitude
                        Freq3 = fftFFR(FreqInd);
                        
                        % iii. HF: HF_Lo-HF_Hi
                        % find freqs nearest HF_Lo and HF_Hi.
                        FreqInd = find(HzScale==F3,1);
                        % compute peak amplitude
                        Freq4 = fftFFR(FreqInd);
                        
                        % iii. HF: HF_Lo-HF_Hi
                        % find freqs nearest HF_Lo and HF_Hi.
                        FreqInd = find(HzScale==F4,1);
                        % compute peak amplitude
                        Freq5 = fftFFR(FreqInd);
                        
                        %                         % iii. HF: HF_Lo-HF_Hi
                        %                         % find freqs nearest HF_Lo and HF_Hi.
                        %                         FreqInd = find(HzScale==F5,1);
                        %                         % compute peak amplitude
                        %                         Freq6 = fftFFR(FreqInd);
                        %
                        %                         % iii. HF: HF_Lo-HF_Hi
                        %                         % find freqs nearest HF_Lo and HF_Hi.
                        %                         FreqInd = find(HzScale==F6,1);
                        %                         % compute peak amplitude
                        %                         Freq7 = fftFFR(FreqInd);
                        %
                        
                        % print out relevant information
                        %                     fprintf(fout, 'file,listener,method,combine,condition,repeats,sweeps,Freq1,Freq2,Freq3,Freq4,Freq5\n'
                        fout = fopen(outfile, 'at');
                        fprintf(fout, '%s,%s,%s,%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n', ...
                            fileName,listener,char(combine),char(condition),repeats,l,draws,m,Freq1,Freq2,Freq3,Freq4,Freq5,sigrms);
                        fclose(fout);
                    end
                end
            end
        end
    end
end

%emailme

close all
clear all
fprintf('%s', 'Finished!')
