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

%%
% Path needs vistadisp and Psychtoolbox
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
% Bars shuffled bar positions
% params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8barsShuffled.mat';
%}

%{
% Standard Sweep
% params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix  = '8bars.mat';
%}

% {
% An artificial scotoma using standard sweep
% params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8barsUpperLeftScotoma.mat';
%}

%{
% An artificial scotoma using standard sweep
% params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8barsShuffledUpperLeftScotoma.mat';
%}

%{ 
% This a series of 2 sec pulses separated by random amounts ranging
% between 4 and 12 sec.
% params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = 'HRFestimate.mat';
%}

disp(params)

%% go!

ret(params);

%%


%%  Not used

%{
% This the HH artificial scotoma.  Not used at the CNI.
params.trigger = 'Computer triggers scanner'; % Only for debugging
params.loadMatrix = '8bars_AS_softEdge.mat';
%}

%% END