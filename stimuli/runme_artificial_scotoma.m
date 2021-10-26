%% ToolboxToolbox
%
% I just put vistadisp and Psychtoolbox on my path
%
% Remember:
%    CMD-0 brings the focus to the command window
%    sca   Clears the screen
%
% Scotoma quadrant is upper left (lesion is ventral right hemisphere)
%

% To check the screens situation:
% Screen('Screens')
%

% Path needs vistadisp, Psychtoolbox
%
% tbUse('vistadisp')

%% Let's see what we need.

% Initialize
params = retCreateDefaultGUIParams;

% Set for current
params.experiment  = 'experiment from file';
params.tr          = 2;  % second
params.fixation    = 'dot with grid';
params.calibration = 'CNI_Stanford_screen';   % Edit this if needed
params.triggerKey  = 't';   % CNI
params.trigger     = 'Scanner triggers computer'; % CNI typical

%{
% Standard
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix  = '8bars.mat';
%}

%{
% Standard bars but randomizing the positions
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8barsShuffled.mat';
%}

%{
% An artificial scotoma using standard sweep
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8barsUpperRightScotoma.mat';
%}

%{
% An artificial scotoma using standard sweep
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8barsShuffledUpperRightScotoma.mat';
%}

% {
% This the HH artificial scotoma
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = 'HRFestimate.mat';
%}

%{
% This the HH artificial scotoma
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8bars_AS_softEdge.mat';
%}

%% go!

% One example t
ret(params);

%%
%{
% This the artificial scotoma
params.loadMatrix = '8bars_AS_softEdge.mat';

% Another artificial scotoma
params.loadMatrix = '8barsUpperRightScotoma';

% Standard bars but randomizing the positions
params.loadMatrix = '8barsRandomizedPositions';

ret(params);
%}

%% Notes about editing the stimulus
%{
load(params.loadMatrix,'stimulus');
disp(stimulus)

% Looks like about 7 images per position????
seq = (500:520);
plot(seq,stimulus.seq(seq),'-.'); grid on
seq = 480:520;
for ii=1:numel(seq)
    imshow(stimulus.images(:,:,stimulus.seq(seq(ii))));
    disp(seq(ii))
    pause(0.5); 
end

% plot(stimulus.seqtiming(seq),stimulus.seq(seq),'-.');

%}
%% END