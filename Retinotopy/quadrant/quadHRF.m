%% retHRFEstimate contrast stimuli
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
load('8bars.mat','stimulus');
disp(stimulus)

%% Create the patterns

% Two contrasts that alternative at 16 FPS but at 2 Hz.

% A contrast stimulus has only 0, 128, 255 (uint8).  The uniform field
% is all 128s.
blank = uint8(128*ones(1080,1080));

% If there are 1080 pixels, there will be about 1080/48 blocks across
% the screen.
blockSize = 48;  
rep = ones(blockSize,blockSize);

% We will flicker 5 different contrasts
% One in the fovea and four in the different quadrants
%
rect = [1,1,255,255];  

% After the kron(), the effective size is blockSize*2
basicContrast1 = [0 255;255 0];
contrast1 = kron(basicContrast1,rep);
contrast1 = repmat(contrast1,ceil(1080/(blockSize*2)),ceil(1080/(blockSize*2)));
contrast1 = imcrop(contrast1,rect);
image(contrast1);

basicContrast2 = [255 0;0 255];
contrast2 = kron(basicContrast2,rep);
contrast2 = repmat(contrast2,ceil(540/(blockSize*2)),ceil(1080/(blockSize*2)));
contrast2 = imcrop(contrast2,rect);
image(contrast2);

%% 

img1 = blank; 
img2 = blank; 

% Central patch
pos = [540,540];
rows = (pos(1) - (256/2)):(pos(1) + (256/2) - 1);
cols = (pos(2) - (256/2)):(pos(2) + (256/2) - 1);
img1(rows,cols) = contrast1; 
img2(rows,cols) = contrast2;

pos = [256/2 + 100, 256/2 + 100];
rows = (pos(1) - (256/2)):(pos(1) + (256/2) - 1);
cols = (pos(2) - (256/2)):(pos(2) + (256/2) - 1);
img1(rows,cols) = contrast1; 
img2(rows,cols) = contrast2;

pos = [256/2 + 100, 1080 - (256/2 + 100)];
rows = (pos(1) - (256/2)):(pos(1) + (256/2) - 1);
cols = (pos(2) - (256/2)):(pos(2) + (256/2) - 1);
img1(rows,cols) = contrast1; 
img2(rows,cols) = contrast2;

pos = [1080 - (256/2 + 100),  256/2 + 100];
rows = (pos(1) - (256/2)):(pos(1) + (256/2) - 1);
cols = (pos(2) - (256/2)):(pos(2) + (256/2) - 1);
img1(rows,cols) = contrast1; 
img2(rows,cols) = contrast2;

pos = [1080 - (256/2 + 100), 1080 - (256/2 + 100)];
rows = (pos(1) - (256/2)):(pos(1) + (256/2) - 1);
cols = (pos(2) - (256/2)):(pos(2) + (256/2) - 1);
img1(rows,cols) = contrast1; 
img2(rows,cols) = contrast2;

image(img1);
image(img2);

images = uint8(zeros(1080,1080,3));
images(:,:,1) = img1;
images(:,:,2) = img2;
images(:,:,3) = blank;


%%
for ii=1:3
    image(images(:,:,ii)); pause(0.5);
end

%% Make the display temporal sequence
%
% 16 FPS
% 12 sec of blank at the start is 32*12 frames; (initBlank)
%
% 2 sec of stimulation means 32 frames for the stimulus
% Alternating at 2 Hz means present 4 frames of each contrast
%
% We will estimate the HRF from the BOLD response to randomly spaced 2
% sec pulses where the blank duration is randomly selected between 4
% and 20 sec.  The total will add up to 192 sec of stimuli and blank
%
% Total of 192 sec is 8*24

img1 = 1; img2 = 2; imgB = 3;
initBlank = ones(1,16*12)*imgB;   % 12 blank seconds

stim = repmat([ones(1,4)*img1, ones(1,4)*img2],1,4);  % 2 sec stimulus

% We will be in some number of blank frames
oneSecBlank = ones(1,16)*imgB;
twoSecBlank = ones(1,32)*imgB;

% The blanks are each a multiple of 2 sec.
blanks = randi(10,[500,1]);
blanks = blanks(blanks > 1);
sum(blanks*2)
histogram(blanks*2); xlabel('Sec')

%% Build up the 192 + 12 sec sequence

% Initialize RNG
rng(100);

seq = stim;
for ii=1:numel(blanks)
    seq = [seq,repmat(twoSecBlank,1,blanks(ii)),stim];
    duration = length(seq)/16;
    secLeft = 192 - duration;
    if secLeft < 12
        seq = [seq,repmat(oneSecBlank,1,secLeft)];
        break;
    end
end

% Add the initial blanks
seq = [initBlank, seq];

% Total length should be 192 + 12 = 204
length(seq)/16

%% Save it out

stimulus.images = images;
stimulus.seq = seq;
p = fileparts(which('8bars.mat'));
fname = fullfile(p,'HRFestimate');
fprintf('Saving HRF estimate stimulus %s\n',fname);
save(fname,'stimulus');

%%
