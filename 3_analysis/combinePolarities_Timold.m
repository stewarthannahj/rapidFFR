function [add subtract] = combinePolarities(PosWaveIn, NegWaveIn, OutputDir, OutputFile, s_epoch, e_epoch)

% create output directory
mkdir(OutputDir);

% load files
Pos = load(PosWaveIn);
Neg = load(NegWaveIn);

% add polarities
add = (Pos + Neg)/2;

% subtract polarities
subtract = (Pos - Neg)/2;

% write txt and avg files
dlmwrite(['', OutputDir, '\', 'Add_', OutputFile, '.txt', ''],add);
bt_txt2avg(['', OutputDir, '\', 'Add_', OutputFile, '.txt', ''],16384,s_epoch,e_epoch);

dlmwrite(['', OutputDir, '\', 'Subtract_', OutputFile, '.txt', ''],subtract);
bt_txt2avg(['', OutputDir, '\', 'Subtract_', OutputFile, '.txt', ''],16384,s_epoch,e_epoch);
