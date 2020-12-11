function whatF0(fileDirectory,OutputDir)
% The first task is to determine the actual F0 of the recorded wave
% The second task is to resample the wave so that the F0 is actually 128 Hz
%
% function x = getTrimmedFFR(fileName, nSamples, F0x)
% (see top of function for information)

% NB nCycles is hard coded:
% For 1 min recordings, it's 7503 (and later 7500)
% For 9 min recordigs, it's 67500 (and later 67497)

% create output directory
mkdir(OutputDir);

% get a list of files
Files = dir(fullfile(fileDirectory, '*.mat'));
nFiles = size(Files);

% construct the output data file name
if ismac
outfile = ['', OutputDir,'/unadjusted_F0.csv', ''];
elseif ispc
outfile = ['', OutputDir,'\unadjusted_F0.csv', ''];
end
    
% write some headings and preliminary information to the output file
if ~exist(outfile)
    fout = fopen(outfile, 'at');
    fprintf(fout, 'file,F0\n');
    fclose(fout);
end

%%
for i=1:nFiles(1)
    % reset some starting values
    F0=128;
    prestim=128; % ms
    SampFreq=16384;
    periodInSamples = SampFreq/F0;
    % extract 67500 cycles (15 sets of 4500 cycles each)
    % 67500 x 128 = 8,640,000 samples
    nCycles = 7503; % 67500;
    nSamples = nCycles * periodInSamples;
    
    if ismac
    fileName = Files(i).name;    % HJS added (3:end) for use on Mac
    elseif ispc
    fileName = Files(i).name;    % original for use on PC
    end
    [pathstr, name, ext] = fileparts(fileName);
    ffr = getTrimmedFFR(fullfile(fileDirectory,fileName), nSamples,prestim); 
      
    % do the largest FFT which is a whole number of cycles
    % making this 600 leads to 512 cycles analyzed
    maxCycles=nCycles;
    % it could be that there is no real point in ensuring this FFT is
    % calculated over a power of 2. I understand there is not much of a penalty
    % for lengths that are not powers of 2, but it should definitely include a
    % whole number of cycles.
    NFFT = 2^(nextpow2(maxCycles*periodInSamples)-1);
    [f, dB, V, phz] = myFFT(ffr(1:NFFT), 'SampFreq', SampFreq, 'Plots', 0);
    % Now select out the part of the spectrum around 128 Hz: see readOuts() for
    % further documentation
    vv128 = readOuts(128, f, dB, 5);
    % find the peak in this region, and extract the frequency value
    F0x = vv128(max(vv128(:,3))==vv128(:,3),2);
    
    % save away unadjusted F0
    fout = fopen(outfile, 'at');
    fprintf(fout, '%s,%5.4f\n', ...
        fileName,F0x);
    fclose(fout);
    
    % plot the spectrum to verify the extracted frequency value is correct
    % (and not just noise)
    figure
    plot(f,dB)
    title(['',fileName,''])
    saveas(gcf,['',OutputDir,'\',name,'.fig',''])
    
    % % In theory, you could get a more accurate estimate by measuring a higher
    % % harmonic and dividing through. Here is for the 7th harmonic
    % vv896 = readOuts(896, f, dB, 20);
    % vv896(max(vv896(:,3))==vv896(:,3),2)/7
    % % Which turns out exactly the same. Maybe there is some basic property of
    % % the FFT I am not considering. However you get it, this is your magic
    % % number! I think the crucial thing is to ensure this same number arises
    % % out of every recording. It might be safer to only look for the F0
    
    % Once you know the actual F0, the rest is easy! Here getTrimmedFFR() is
    % being used to resample the wave, and extract the appropriate
    % section. The position of the trigger is recalculated, and fewer samples
    % are taken to account for the fact that the new sampling frequency is
    % slightly higher.
    nCycles = 7500; % 67497; % I figured this out directly rather than writing an equation
    nSamples = nCycles * periodInSamples;
    ffr = getTrimmedFFR(fullfile(fileDirectory,fileName), nSamples,prestim, F0x);
    % This should now have F0=128. Let's check.
    maxCycles=nCycles;
    NFFT = 2^(nextpow2(maxCycles*periodInSamples)-1);
    [f, dB, V, phz] = myFFT(ffr(1:NFFT), 'SampFreq', SampFreq, 'Plots', 0);
    vv128 = readOuts(128, f, dB, 5);
    F0x2 = vv128(max(vv128(:,3))==vv128(:,3),2);
    
    if F0x2 == 128
%         error('F0 has not been changed to 128 Hz')
            % save trimmed and resampled ffr with the correct F0 (i.e. 128 Hz)
    save(['',OutputDir,'\',name,'.mat',''],'ffr')
    end  

end
clear
close all