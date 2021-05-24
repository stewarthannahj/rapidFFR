function spectralNZfloor_DRR_nosampling(fileDirectory, listener, Active, Reference, Lcut_off, Hcut_off, technique, condition, draws, repeats, totalSweeps, s_trig_interval, prestim, F0, F1, F2, F3)
% with replacement
% NB: for normal technique, cuts of first and last F0 cycle of epoch

% technique = 'rapid' or 'normal'
% condition = 'random' or 'phaselocked'
% draws = number of draws, or trials picked per FFT calculation (e.g. 400; so half is pos, half is neg)
% repeats = number of times to compute FFT; 100 for phase-locked, 1000 for random
% totalSweeps = number of sweeps in the response (e.g. 1500)
% s_trig_interval = number of samples for 1 cycle

%% some starting values
order = 2;

%%
fileDirectory = [fileDirectory '\' listener];
% get a list of files
Files = dir(fullfile(fileDirectory, '*.bdf'));
nFiles = size(Files);

% create output directory
OutputDir = ['Output_' listener '_NZfloor'];
mkdir(OutputDir);

% construct the output data file name
outfile = ['', OutputDir,'\',listener,'_FFT_Nzfloor_', technique, '_', condition, '_', num2str(draws),'.csv', ''];
% write some headings and preliminary information to the output file
if ~exist(outfile)
    fout = fopen(outfile, 'at');
    fprintf(fout, 'file,listener,combine,condition,level,target,masker,repeats,repetition,sweeps,F0,H3,H4,H5,rms\n');
    fclose(fout);
end

for i=1:nFiles
    fileName = Files(i).name;
    [pathstr, name, ext] = fileparts(fileName);
    polarity = strtrim(regexp(name,'pos|neg','match'));
    level = char(strtrim(regexp(name,'60dB|70dB','match')));
    target = char(strtrim(regexp(name,'2010|402','match')));
    masker = char(strtrim(regexp(name,'quiet|UEN|Hi593|Hi838|Hi1185|Hi1676|Hi2370|Hi3352|Hi4740|Hi6703|Lo955','match')));
    
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
                [ALLNEG NEG] = eeg_store(ALLNEG, NEG, CURRENTSET);
                NEG = eeg_checkset( NEG );

                for l = 1:repeats
                    for j = 1:2
                        if j == 1
                            EEG = POS;
                            ALLEEG = ALLPOS;
                        elseif j == 2
                            EEG = NEG;
                            ALLEEG = ALLNEG;
                        end
                        
                        % epoch and save as new EEG data set
                        % create event channel (i.e. put in triggers)
                        startTrig = EEG.event(1,2).latency + round((prestim/1000)*EEG.srate) + (2*s_trig_interval); % don't look at first 2 nReps
                        endTrig = EEG.event(1,2).latency + round((prestim/1000)*EEG.srate) + ((totalSweeps-2)*s_trig_interval); % don't look at final nRep

                            if strcmp(condition,'random')
                                % create randomly placed triggers
                                r = round((endTrig-startTrig).*rand(1,draws)+startTrig);
                                r = sort(r);
                                TRIGdraws = draws;
                            elseif strcmp(condition,'phaselocked')
                                % create triggers
                                for n = 1:(draws-3)
                                    if n ==1
                                        beginLat = startTrig;
                                        endLat = beginLat + s_trig_interval-1;
                                    else
                                        if ~mod(n/132,1) % if it's a multiple of 132: shift back by one sample
                                            beginLat = endLat; % round(EEG.event(1,perm).latency);
                                            endLat = beginLat+s_trig_interval-1;
                                        else
                                            beginLat = endLat+1; % round(EEG.event(1,perm).latency);
                                            endLat = beginLat+s_trig_interval-1;
                                        end
                                    end
                                    if n == 1
                                        triggers = beginLat;
                                    else
                                        triggers = [triggers,beginLat];
                                    end
                                end
                                
                                if length(triggers) < draws
                                    TRIGdraws = length(triggers);
                                else
                                    TRIGdraws = draws;
                                end
                                r = triggers; % select random triggers by index
                            end
                            
                            for k = 1:length(r)
                                if k == 1
                                    EEG = rmfield(EEG, 'event'); % remove EEG.event field, will be replaced below
                                end
                                EEG.event(1,k) = struct('type',255,'latency',r(k),'urevent',k);
                            end
                            
                      
                        % save set
                        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                        EEG = eeg_checkset( EEG );

                        % sampling with replacement (selecting epochs - may overlap for 'random')
                        
                        % make sure there are enough possible epochs for
                        % the number of draws
                        if length(EEG.event) < TRIGdraws
                            TRIGdraws = length(EEG.event);
                        end
                        
                        epoch=zeros((TRIGdraws),s_trig_interval);
                        
                        for n = 1:(TRIGdraws)
                            startLat = round(EEG.event(1,n).latency);
                            epoch(n,:) = EEG.data(startLat:startLat+s_trig_interval-1);
                        end
                        
                        % reject artifacts (outside +/- 25 uV)
                        % create index of trials to be removed
                        countr = 1;
                        for n = 1:(TRIGdraws)
                            if (max(epoch(n,:))>25) || (min(epoch(n,:))< -25)
                                rm_index(countr) = n;
                                countr = countr+1;
                            end
                        end
                        % remove trials
                        if exist('rm_index')
                            epoch([rm_index],:) = [];
                        end
                                                
                        % average across draws
                        avg = mean(epoch,1);
                
                        if j == 1
                            posAVG = avg;
                        elseif j == 2
                            negAVG = avg;
                        end
                    end
                    
                    % add polarities
                    add = (posAVG + negAVG)/2;
                    
                    % subtract polarities
                    subtract = (posAVG - negAVG)/2;
                    
                    % save waveforms
                    dlmwrite(['', OutputDir,'\',listener,'_',target,'_',level,'_',masker,'_FFR_add.txt',''],add)
                    dlmwrite(['', OutputDir,'\',listener,'_',target,'_',level,'_',masker,'_FFR_sub.txt',''],subtract)
                    
                    % FFT
                    for k = 1:2
                        if k == 1
                            data = add;
                        elseif k == 2
                            data = subtract;
                        end
                        
                        L=length(data);
                        NFFT = 163*floor(L/163); % NFFT = 2^nextpow2(L); % Next power of 2 from length of y
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
                    for m = 1:2
                        if m == 1
                            fftFFR = addFFT;
                            combine = 'add';
                        elseif m == 2
                            fftFFR = subFFT;
                            combine = 'sub';
                        end
                        
                        % i. F0: F0_Lo-F0_Hi.
                        % find freqs nearest F0_Lo and F0_Hi.
%                         FreqInd = find(HzScale==F0,1);
                        % compute peak amplitude
                        Freq1 = fftFFR(F0+1);
                        
                        % ii. F1: F1_Lo-F1_Hi
                        % find freqs nearest F1_Lo and F1_Hi.
%                         FreqInd = find(HzScale==F1,1);
                        % compute peak amplitude
                        Freq2 = fftFFR(F1+1);
                        
                        % iii. HF: HF_Lo-HF_Hi
                        % find freqs nearest HF_Lo and HF_Hi.
%                         FreqInd = find(HzScale==F2,1);
                        % compute peak amplitude
                        Freq3 = fftFFR(F2+1);
                        
                        % iii. HF: HF_Lo-HF_Hi
                        % find freqs nearest HF_Lo and HF_Hi.
%                         FreqInd = find(HzScale==F3,1);
                        % compute peak amplitude
                        Freq4 = fftFFR(F3+1);
                                           
                        sigrms = rms(data);
                        
                        % print out relevant information
                        %                     fprintf(fout, 'file,listener,method,combine,condition,repeats,sweeps,Freq1,Freq2,Freq3,Freq4,Freq5\n'
                        fout = fopen(outfile, 'at');
                        fprintf(fout, '%s,%s,%s,%s,%s,%s,%s,%d,%d,%d,%d,%d,%d,%d,%d\n', ...
                            fileName,listener,char(combine),char(condition),char(level),char(target),char(masker),repeats,l,draws,Freq1,Freq2,Freq3,Freq4,sigrms);
                        fclose(fout);
                    end
                end
            end
        end
%     end
end

mm = robustcsvread(['',outfile,'']);
[rows columns] = size(mm);

% emailme(listener,char(condition),num2str(rows))

close all
clear all
fprintf('%s', 'Finished!')
