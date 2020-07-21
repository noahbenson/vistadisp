%% quadTriggerTest 
%
% Set up a stimulus to help estimate the HRF.
%
% The idea is to create a series of 2s stimuli with a variety of inter
% temporal intervals and then fit the HRF to the BOLD time series.
%
% See also
%   quad*.m

%% Load up the basic set of stimulus parameters

% We keep everything about the same, just modify the stimulus for
% different purposes.  In this case for getting an HRF estimate
load('HRFEstimate.mat','stimulus');
disp(stimulus);

%%
stimulus.seq = stimulus.seq(1:200);
stimulus.seqtiming = stimulus.seqtiming(1:200);
stimulus.fixSeq = stimulus.fixSeq(1:200);

%% Save it out

p = fileparts(which('8bars.mat'));
fname = fullfile(p,'TriggerTest.mat');
fprintf('Saving Trigger Test %s\n',fname);
save(fname,'stimulus');

%%
