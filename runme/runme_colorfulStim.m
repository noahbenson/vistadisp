
% runme for the colorful stimulus
% 192 TRs

%% 

params = retCreateDefaultGUIParams;
params.fixation = 'dot with grid';
params.tr = 1;
params.skipSyncTests = 0;
params.calibration = 'CBI_Propixx';
params.prescanDuration = 0;
params.experiment  = 'Experiment From File';
params.doEyelink = true;
%% stim file

%% run it

for ii = 1:6
    params.loadMatrix = sprintf('ret_%d.mat', ii);
    ret(params);
end