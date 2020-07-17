%% quadScotoma - 
% 
% Start with 8bars (sweep) or with the shuffled version and apply a
% scotoma to the upper right quadrant.
%
% We apply a hard scotoma.  Maybe I should have blurred it.
%
% See also
%


%% load('8bars_AS_softEdge.mat','stimulus');

load('8bars.mat','stimulus');
disp(stimulus)

%% Now, let's block out the upper right quadrant

% Select the upper right rows and cols
rows = 1:(1080/2);
cols = (1080/2):1080;
uniform = 128*ones(numel(rows),numel(cols));

images2 = stimulus.images;
for ii=1:size(stimulus.images,3)
    images2(rows,cols,ii) = uniform;
end

%% Show the scotoma

for ii=1:size(images2,3)
    image(images2(:,:,ii)); 
    pause(0.1);
end

%% Write it out.  Sweep and Upper Right Scotoma

stimulus.images = images2;
p = fileparts(which('8bars.mat'));
fname = fullfile(p,'8barsUpperRightScotoma');
fprintf('Saved in storedImageMatrices %s\n',fname);

save(fname,'stimulus');

%% load('8bars_AS_softEdge.mat','stimulus');

% Now apply a scotoma to the shuffled bars, not the sweep.
load('8barsShuffled.mat','stimulus');
disp(stimulus)

%%  Create the scotoma

images2 = stimulus.images;
for ii=1:size(stimulus.images,3)
    images2(rows,cols,ii) = uniform;
end

% Everything is the same but the positions are randomized
for ii=1:size(images2,3)
    image(images2(:,:,ii)); 
    pause(0.1);
end

%%  Save it

stimulus.images = images2;
p = fileparts(which('8bars.mat'));
fname = fullfile(p,'8barsShuffledUpperRightScotoma.mat');
fprintf('Saved in storedImageMatrices %s\n',fname);

save(fname,'stimulus');

%% END

