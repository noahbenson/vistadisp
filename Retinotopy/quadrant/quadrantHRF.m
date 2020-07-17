%% retHRFEstimate contrast stimuli
%
% Set up a stimulus to help estimate the HRF.
%
% THe idea is:
%

%% Load up the basic set of stimulus parameters

% We keep everything about the same, just modify the stimulus for
% different purposes.  In this case for getting an HRF estimate
load('8bars.mat','stimulus');
disp(stimulus)

%% Different quadrants.  Two contrasts.

% a contrast stimulus has only 0, 128, 255 (uint8)
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

%% Make the display sequence
%
% 16 FPS
% 12 sec of blank at the start is 32*12; (initBlank)
% 2 sec of stimulation means 32 frames for the stimulus
% Rather than stim-long blank we will estimate the HRF from randomly
% spaced 2 sec pulses where the blank duration is randomly selected between
% 4 and 12 sec.  The total will add up to 192 sec of stimuli and blank
%
% 22 sec of blank is 16*22
% Total of 192 sec is 8*24
% Alternating at 2 Hz means alternate 4 frames of each contrast

img1 = 1; img2 = 2; imgB = 3;
initBlank = ones(1,16*12)*imgB;   

stim = repmat([ones(1,4)*img1, ones(1,4)*img2],1,4);
oneSecBlank = ones(1,16)*imgB;

% Here are many random intervals, all 4 sec or larger
blanks = randi(12,[500,1]);
blanks = blanks(blanks > 3);
sum(blanks)
histogram(blanks)

% Build up the 192 + 12 sec sequence
seq = stim;
for ii=1:numel(blanks)
    seq = [seq,repmat(oneSecBlank,1,blanks(ii)),stim];
    duration = length(seq)/16;
    secLeft = 192 - duration;
    if secLeft < 12
        seq = [seq,repmat(oneSecBlank,1,secLeft)];
        break;
    end
end
length(seq)/16 + 12
seq = [initBlank, seq];
length(seq)/16;

%% Save it out

stimulus.images = images;
stimulus.seq = seq;
p = fileparts(which('8bars.mat'));
fname = fullfile(p,'HRFestimate');
save(fname,'stimulus');

%% TODO:  Test the flipud switch
%  Build the stimulus sequence for 2 sec HRF responses
%  2 sec then nothing in that quadrant for 20 sec
%  UL: Stim (2)   Blank (22)  Stim(2)     Blank (22)
%  LR: Blank(6)   Stim (2)    Blank (22)
%  LR: Blank(12)  Stim (2)    Blank (22)
%  UR: Blank(18)  Stim (2)    Blank (22)
%

%{
%% Define the quadrant row/cols 

ulRows = 1:(1080/2); ulCols = 1:(1080/2);
urRows = ulRows;     urCols = ((1080/2)+1):1080;
llRows = ((1080/2)+1):1080; llCols = ulCols;
lrRows = llRows;  lrCols = urCols;

%% Create the quadrant contrast patterns

ulContrast1 = blank; ulContrast2 = blank;
ulContrast1(ulRows,ulCols) = contrast1;
ulContrast2(ulRows,ulCols) = contrast2;
image(ulContrast1); image(ulContrast2)

urContrast1 = blank; urContrast2 = blank;
urContrast1(urRows,urCols) = contrast1;
urContrast2(urRows,urCols) = contrast2;
image(urContrast1); image(urContrast2)

llContrast1 = blank; llContrast2 = blank;
llContrast1(llRows,llCols) = contrast1;
llContrast2(llRows,llCols) = contrast2;
image(llContrast1); image(llContrast2)

lrContrast1 = blank; lrContrast2 = blank;
lrContrast1(lrRows,urCols) = contrast1;
lrContrast2(lrRows,urCols) = contrast2;
image(lrContrast1); image(lrContrast2)

%% Put the 9 images into the stimulus.images
images = uint8(zeros(1080,1080,9));
images(:,:,1) = ulContrast1;
images(:,:,2) = ulContrast2;
images(:,:,3) = urContrast1;
images(:,:,4) = urContrast2;
images(:,:,5) = llContrast1;
images(:,:,6) = llContrast2;
images(:,:,7) = lrContrast1;
images(:,:,8) = lrContrast2;
images(:,:,9) = blank;
%}
