%% retStimulusEdit - Explanation and methods for editing the stimulus
%
% The purpose is to clarify the entries of the 'stimulus' struct that
% contains the images and sequence for a standard scan.
%
% Then we modify the parameters to achieve two goals.  
%
%  First we want to shuffle the order of bar positions rather than
%  sweep.
%
%  Second, we want to blank out certain regions of the screen so that
%  no contrast appears there (artificial scotoma).
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


%% Timing

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

% If each position has 8 contrast patterns
nImages = size(stimulus.images,3);
for ii=1:nImages
    image(stimulus.images(:,:,ii)); pause(0.1);
    if ~mod(ii,8)
        disp(ii)
    end
end

% The last image is blank
image(stimulus.images(:,:,end))

%% Time at a position

% Frame the values in 8bars.mat, we have 2 sec TR, so 32 frames at one
% position.  Let's have a look.  

% The total stimulus sequence
nFrames = numel(stimulus.seq);

% The start boundaries for each position should align with each TR.
starts = 1:32:nFrames;

% Pull out a sequence with one frame prior to this position and one
% frame after
s = 5;
thisSeq = (starts(s)-1):starts(s+1);
plot(stimulus.seq(thisSeq),'-o');

% Look at the images to see that we are right
nImages = numel(thisSeq);
imgSeq = stimulus.images(:,:,stimulus.seq(thisSeq));
for ii=1:nImages
    image(imgSeq(:,:,ii)); pause(0.2);
end

%% Suppose we want to randomize the timing of the positions

% Then we we can randomly exchange pairs of the 8 blocks images.
% There are
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
    pause(0.2);
end

%% Now exchange blocks of 8

images2 = stimulus.images;

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
    pause(0.2);
end

stimulus.images = images2;

% Everything is the same except the bar positions have been randomized
p = fileparts(which('8bars.mat'));
fname = fullfile(p,'8barsRandomizedPositions');
save(fname,'stimulus');

%% Now, let's block out the upper right quadrant

load('8bars.mat','stimulus');

% Select the upper right rows and cols
rows = 1:(1080/2);
cols = (1080/2):1080;
uniform = 128*ones(numel(rows),numel(cols));

images2 = stimulus.images;
for ii=1:size(stimulus.images,3)
    images2(rows,cols,ii) = uniform;
end

% Everything is the same but the positions are randomized
for ii=1:size(images2,3)
    image(images2(:,:,ii)); 
    pause(0.1);
end

%% Everything is the same except the bar positions have been randomized

stimulus.images = images2;

p = fileparts(which('8bars.mat'));
fname = fullfile(p,'8barsUpperRightScotoma');
save(fname,'stimulus');

%%

