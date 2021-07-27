function spectralNZfloor_rapid_chunk_matInput(fileDirectory, OutputDir,outFileName, FFRtech, condition, draws, repeats, totalSweeps, chunks,s_epoch, e_epoch, prestim, F0, F1, F2, F3, F4,replacement)
% with replacement
% NB: rapid FFR only

% FFRtech = 'rapid' or 'standard' (rapid - removes first 2 and last nReps. Different startLat for each.       %%% HJS
% condition = 'random' or 'phaselocked'
% draws = number of draws, or trials picked per FFT calculation (e.g. 400; so half is pos, half is neg)
% repeats = number of times to compute FFT for bootstrapping; 100 for phase-locked, 1000 for random
% totalSweeps = number of sweeps in the response (e.g. 7500)
% chunk = number of chunks needed to analyze (e.g. total is 7500 nReps, but
% you want to analyze 1500 nReps at a time, staring with 1-1500, then
% 1501-3000 etc.)

%% some starting values
Fs = 16384;

%%
% get a list of files
Files = dir(fullfile(fileDirectory, '*.mat'));
nFiles = size(Files);

% create output directory
mkdir(OutputDir);

% construct the output data file name

if ismac
    outfile = ['', OutputDir,'/',outFileName,'.csv', ''];
elseif isunix
    outfile = ['', OutputDir,'/',outFileName,'.csv', ''];
elseif ispc
    outfile = ['', OutputDir,'\',outFileName,'.csv', ''];
end

% write some headings and preliminary information to the output file
if ~exist(outfile)
    fout = fopen(outfile, 'at');
    fprintf(fout, 'file,listener,combine,condition,repeats,repetition,sweeps,chunk,Freq1,Freq2,Freq3,Freq4,Freq5,rms,#epochsRemovedDueToArtifacts,epochsRemovedPercent\n');
    fclose(fout);
end

for i=1:nFiles(1)
    fileName = Files(i).name;
    [pathstr, name, ext] = fileparts(fileName);
    polarity = strtrim(regexp(name,'pos|neg','match'));
    listener = name(1:3);
    
    %     if strcmp(technique, method)
    if strcmp(polarity,'pos')
        POS = load(fullfile(fileDirectory,fileName));
        
        % find matching file with negative polarity
        NegFile = regexprep(fileName, 'pos', 'neg');
        if exist(fullfile(fileDirectory,NegFile))
            NEG = load(fullfile(fileDirectory,NegFile));
            
            % convert epoch start and end times to seconds
            s_epoch_s = s_epoch/1000;
            e_epoch_s = e_epoch/1000;
            % determine trigger interval
            s_trig_interval = round(((e_epoch-s_epoch)/1000)*Fs);
            
            for m = 1:chunks % analyze chunks of the EEG signal one by one (shifting by certain number of sweeps)
                endSweep = m*(totalSweeps/chunks); % determine end point for triggers
                startSweep = round(endSweep-(totalSweeps/chunks)+1); % determine start point for triggers
                for l = 1:repeats
                    for jj = 1:2 % loop through positive and negative polarities
                        if jj == 1
                            EEG.data = POS.ffr;
                        elseif jj == 2
                            EEG.data = NEG.ffr;
                        end
                        
                        % epoch and save as new EEG data set
                        % create event channel (i.e. put in triggers)
                        if strcmp(FFRtech,'rapid')    %%% HJS
                            startTrig = (startSweep+2)*s_trig_interval; % don't look at first 2 nReps       
                            if m > 2 && m == chunks
                                endTrig = (endSweep-4)*s_trig_interval; %%% HJS - in final chunk don't look at final 4 nRep else it calculates one extra trig_interval 
                            else
                                endTrig = (endSweep-2)*s_trig_interval; % don't look at final 2 nRep
                            end
                            
                            if strcmp(condition,'random')
                                % create randomly placed triggers
                                r = round((endTrig-startTrig).*rand(1,draws)+startTrig);        
                                for k = 1:draws
                                    while r(k) > endTrig-s_trig_interval                        %%% HJS if r(k) is too large to allow a full 128 trig interval at the end of EEG.event, it keeps recalculates r(k) until it allows a 128 trig interval
% % %                                         old = r(k)
                                        r(:,k) = round((endTrig-startTrig)*rand(1)+startTrig);     
% % %                                         new = r(k)
                                    end
                                end
                                r = sort(r);
                            elseif strcmp(condition,'phaselocked')
                                % create triggers for rapid FFR     %%% HJS
                                if strcmp(FFRtech, 'rapid')       %%% HJS
                                    if m > 2 && m == chunks
                                        triggers = [startTrig:s_trig_interval:endTrig-s_trig_interval];
                                    else
                                        triggers = [startTrig:s_trig_interval:endTrig]; 
                                    end
                                    if length(triggers) < draws
                                        draws = length(triggers);
                                    end
                                    % select random trials
                                    % indeces of random set of triggers
                                    index = randperm(length(triggers));
                                    index = index(1:draws);
                                    r = triggers(index); % select random triggers by index
                                end     %%% HJS
                            end
                            
                            for kk = 1:length(r)
                                EEG.event(1,kk) = struct('type',255,'latency',r(kk),'urevent',kk);
                            end
                            
                        elseif strcmp(FFRtech,'standard')   %%% HJS
                            startTrig = (startSweep+1)*s_trig_interval;   % don't look at first nRep %%% HJS
                            endTrig = (endSweep-1)*s_trig_interval; % don't look at last nRep %%% HJS 
                            
                            if strcmp(condition,'random')   %%% HJS
                                % create randomly placed triggers
                                r = round((endTrig-startTrig).*rand(1,draws)+startTrig);    %%% HJS
                                r = sort(r);    %%% HJS
                                
                            elseif strcmp(condition, 'phaselocked') %%% HJS
                                triggers = [startTrig:(s_trig_interval/chunks):endTrig]; %%% HJS
                                if length(triggers) < draws     %%% HJS
                                    draws = length(triggers);   %%% HJS
                                end                             %%% HJS
                                % select random trials
                                % indeces of random set of triggers
                                index = randperm(length(triggers)); %%% HJS
                                index = index(1:draws);             %%% HJS
                                r = triggers(index); % select random triggers by index  %%% HJS
                            end     %%% HJS
                            
                            for k = 1:length(r) %%% HJS
                                EEG.event(1,k) = struct('type',255,'latency',r(k),'urevent',k); %%% HJS
                            end     %%% HJS
                        end         %%% HJS
                        
                        
                        % sampling with replacement (selecting epochs - may overlap for 'random')
                        
                        % make sure there are enough possible epochs for
                        % the number of draws
                        if length(EEG.event) < draws
                            draws = length(EEG.event);
                        end

                        clear epoch %%% HJS
                        epoch=zeros((draws),round(e_epoch_s*Fs));
                        
                        for n = 1:(draws) %
                            if strcmp(replacement,'with') % with replacement
                                perm = randperm(draws);
                                perm = perm(1); 
                            else % without replacement
                                perm = n;
                            end
                            startLat = round(EEG.event(1,perm).latency);
                            % make sure the EEG data file is long enough
                            %                             (startLat+round(e_epoch_s*Fs)-1) <
                            if strcmp(FFRtech, 'standard')    %%% HJS
                                if EEG.event(1,perm).type == 255    %%% HJS
                                    startLat = startLat + round(s_epoch_s*Fs);   %%% HJS EEG.srate -> Fs
                                    epoch(n,:) = EEG.data(startLat:startLat+round(e_epoch_s*Fs)-1); %%% HJS
                                end     %%% HJS
                            elseif strcmp(FFRtech, 'rapid')        %%% HJS
                                    epoch(n,:) = EEG.data(startLat:startLat+round(e_epoch_s*Fs)-1); %%% HJS
                            end         %%% HJS
                        end
                                                
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
                            clear rm_index %%% HJS else it was writing each permutations rm_index onto each other and not deleting larger values
                        end
                        
                         epochsRemoved = countr-1;
                         epochsRemoved_percent = epochsRemoved/totalSweeps; % or is it draws? I think totalSweeps
                        
                        % average across draws
                        avg = mean(epoch,1);

                        if jj == 1
                            posAVG = avg;
                        elseif jj == 2
                            negAVG = avg;
                        end
                    end
                    
                    % add polarities
                    add = (posAVG + negAVG)/2;
                    
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
                        f = Fs/2*linspace(0,1,NFFT/2+1);
                        fftFFR = 2*abs(Y(1:NFFT/2+1));
                        HzScale = [0:(Fs/2)/(length(fftFFR)-1):round(Fs/2)]'; % frequency 'axis'
                        
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

                        % print out relevant information
                        % fprintf(fout, 'file,listener,method,combine,condition,repeats,sweeps,Freq1,Freq2,Freq3,Freq4,Freq5,#epochsRemovedDueToArtifacts,epochsRemovedPercent\n'
                        fout = fopen(outfile, 'at');
                        fprintf(fout, '%s,%s,%s,%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n', ...
                            fileName,listener,char(combine),char(condition),repeats,l,draws,m,Freq1,Freq2,Freq3,Freq4,Freq5,sigrms,epochsRemoved,epochsRemoved_percent);
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
