%% quadShuffleBar - Explanation and methods for editing the 8bars stimulus
%
% This script comments on the entries of the 'stimulus' struct that
% contains the images and sequence for a standard scan.
%
% Then we modify the parameters to shuffle the order of bar positions
% rather than sweep.
%
% See quadScotoma for applying a scotoma to these stimuil
%
% Parameter definitions of the stimulus struct
%
% images:  These are uint8 images that will be displayed
% cmap:    The colormap
% seq:     The order the images are displayed in
% seqtiming:  The moment in time they are displayed
% fixSeq:     THe fixation sequence
% srcRect:    Screen param
% destRect:   Screen param
% textures:   Not sure
%
% See also 
%    displayParams, makeRetinotopyStimulusFromFile, retLoadStimulus,
%    doRetinotopyScan 
%    retHRFEstimates


%% load('8bars_AS_softEdge.mat','stimulus');

load('8bars.mat','stimulus');
disp(stimulus)


%% These parameters document the timing of the display

% Start the first frame at time 0
stimulus.seqtiming(1)

% The time between frames
timeStep = stimulus.seqtiming(2) - stimulus.seqtiming(1);  % Frame length?

% Number of frames per sec
framesPerSec = 1/timeStep;

% All the frames plus the time at the end for the last frame to finish
totalDuration = stimulus.seqtiming(end) + timeStep % Start last stimulus and then wait one timeStep

% If we have 12 sec for magnetization to stabilize, then the stimulus
% is presented for this much time
stimulusDuration = totalDuration - 12   % This many seconds of warm up

%% Time at a position

% In the quadrantanopia experiments we use a 2 sec TR, so 32 frames.
% All of these frames represent a stimulus at one position.

% The total stimulus sequence
nFrames = numel(stimulus.seq);

% The start boundaries for each position should align with each TR.
starts = 1:32:nFrames;

% Pull out a sequence with one frame prior to this position and one
% frame after
s = 20;     % Many of these starts are the blank frames.
thisSeq = (starts(s)-1):starts(s+1);
plot(stimulus.seq(thisSeq),'-o');

%% Visualize 

% Look at the images to see that we are right.  First one is offset,
% then 32 frames at one position, then the next position.
nImages = numel(thisSeq);
imgSeq = stimulus.images(:,:,stimulus.seq(thisSeq));
image(imgSeq(:,:,1)); pause(0.3);
for ii=2:nImages
    image(imgSeq(:,:,ii)); pause(0.1);
end
image(imgSeq(:,:,end));

%% Shuffle (randomize) the timing of the bar positions

% We can randomly exchange pairs of the 8 blocks images.
% There are this many positions.
nPositions = 384/8;

% The sequence of images at a position start at these blocks
s = 2;
pStarts = 1:8:384;
thisSeq = pStarts(s):(pStarts(s+1)-1);

cla
nImages = 8;
imgSeq = stimulus.images(:,:,thisSeq);
for ii=1:nImages
    image(imgSeq(:,:,ii)); 
    pause(0.1);
end

%% Now exchange blocks of 8

rng(100);

% We will do the exchange in this temp variable, images2.
images2 = stimulus.images;

% We do 50 exchanges on 47 bar positions
for ii=1:50
    thisPair = randi(47,[1,2]);
    seq1 = pStarts(thisPair(1)):(pStarts(thisPair(1)+1)-1);
    seq2 = pStarts(thisPair(2)):(pStarts(thisPair(2)+1)-1);
    
    % Swap
    tmp = images2(:,:,seq1);
    images2(:,:,seq1) = images2(:,:,seq2);
    images2(:,:,seq2) = tmp;
end

%%  Looks good for randomly positioning instead of sweeping

% Everything is the same but the positions are randomized
for ii=1:size(images2,3)
    image(images2(:,:,ii)); 
    pause(0.1);
end

stimulus.images = images2;

%%  Everything is the same except the bar positions have been randomized

p = fileparts(which('8bars.mat'));
fname = fullfile(p,'8barsShuffled');
fprintf('Saving %s\n',fname);
save(fname,'stimulus');

%% Check that it loads and runs

load(fname,'stimulus')
% Everything is the same but the positions are randomized
for ii=1:length(stimulus.seq)
    image(stimulus.images(:,:,stimulus.seq(ii))); 
    pause(0.05);
end

%% END
