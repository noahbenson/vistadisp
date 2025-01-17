function [response, timing, quitProg] = showScanStimulus(display,...
    stimulus, t0, timeFromT0, params) 
% [response, timing, quitProg] = showStimulus(display,stimulus, ...
%           [time0 = GetSecs], [timeFromT0 = true])
%
% Inputs
%   display:    vistaisp display structure 
%   stimulus:   vistadisp stimulus structure (e.g., see doRetinotopyScan.m)
%   t0:         time the scan started in seconds acc to PsychtoolBox 
%               GetSecs function. By default stimulus timing is relative to 
%               t0. If t0 does not exist it is created at the start of this
%               program.
%   timeFromT0: boolean. If true (default), then time each screen flip from
%               t0. If false, then time each screen flip from last screen
%               flip. The former is typically used for fMRI, where we want
%               to avoid accumulation of timing errors. The latter may be
%               more useful for ECoG/EEG where we care about the precise
%               temporal frequency of the stimulus.
% Outputs:
%   response:   struct containing fields 
%                   keyCode: keyboard response at each frame, if any; if 
%                           no response record a 0); 
%                   secs: time of each response in seconds ?? verify
%                   flip:   time of each screen flip measured by PTB
%   timing:     float indicating total time of experiment
%   quitProg:   Boolean to indicate if experiment ended by hitting quit key
%               
%   
% HISTORY:
% 2005.02.23 RFD: ported from showStimulus.
% 2005.06.15 SOD: modified for OSX. Use internal clock for timing rather
%                 than framesyncing because getting framerate does not
%                 always work. Using the internal clock will also allow
%                 some "catching up" if stimulus is delayed for whatever
%                 reason. Loading mex functions is slow, so this should be
%                 done before callling this program.
% 2011.09.15  JW: added optional input flag, timeFromT0 (default = true).
%                 true, we time each screen flip from initial time (t0). If
%                 false, we time each screen flip from the last screen
%                 flip. Ideally the results are the same.

% input checks
if nargin < 2,
    help(mfilename);
    return;
end;
if nargin < 3 || isempty(t0),
    t0 = GetSecs; % "time 0" to keep timing going
end;

if notDefined('timeFromT0'), timeFromT0 = true; end

% some more checks
if ~isfield(stimulus,'textures')
    % Generate textures for each image
    disp('WARNING: Creating textures before stimulus presentation.');
    disp(['         This should be done before calling ' mfilename ' for']);
    disp('         accurate timing.  See "makeTextures" for help.');
    stimulus = makeTextures(display,stimulus);
end;

% quit key
try
    quitProgKey = display.quitProgKey;
catch
    quitProgKey = KbName('q');
end;

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;
response.flip = [];

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));

% If we are doing eCOG, then start with black photodiode
if isfield(stimulus, 'trigSeq') 
    drawTrig(display,0);
end
% If we are making a movie, set that up.
if isfield(params, 'movie') && ~isempty(params.movie)
    makemov = true;
    fprintf("Creating movie...\n");
    moviePtr = Screen('CreateMovie', ...
                      display.windowPtr, params.movie, 1920, 1080, 10);
    movieRect = stimulus.destRect;
else
    makemov = false;
end
        
for frame = 1:nFrames
    
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    if stimulus.seq(frame)>0
        % put in an image
        imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        drawFixation(display,stimulus.fixSeq(frame));
        
        % If we are doing eCOG, then flash photodiode if requested
        if isfield(stimulus, 'trigSeq') 
            colIndex = drawTrig(display,stimulus.trigSeq(frame));
        end
        
    elseif stimulus.seq(frame)<0
        % put in a color table
        gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
        % The second argument is the color index.  This apparently changed
        % in recent times (07.14.2008). So, for now we set it to 1.  It may
        % be that this hsould be
        drawFixation(display,stimulus.fixSeq(frame));
        Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
    end;
    
    %--- timing
    waitTime = getWaitTime(stimulus, response, frame,  t0, timeFromT0);
    if nargin > 4
        if isfield(params, 'waitBuffer')
            waitBuffer = -abs(params.waitBuffer);
        else
            waitBuffer = -0.01;
        end
        if isfield(params, 'waitPause')
            waitPause = abs(params.waitPause);
        else
            waitPause = 0.01;
        end
    else
        waitBuffer = -0.01;
        waitPause = 0.01;
    end
        
    %--- get inputs (subject or experimentor)
    while(waitTime < waitBuffer),
        % Scan the keyboard for subject response
        [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(display.devices.keyInputExternal);
        if(ssKeyIsDown)
            %            kc = find(ssKeyCode);
            %            response.keyCode(frame) = kc(1);
            response.keyCode(frame) = 1; % binary response for now
            response.secs(frame)    = ssSecs - t0;
        end;
        % scan the keyboard for experimentor input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            end;
        end;
        
        % update waitTime.
        waitTime = getWaitTime(stimulus, response, frame,  t0, timeFromT0);       
    
        % if there is time release cpu
        if(waitTime < 2*waitBuffer),
            WaitSecs(waitPause);
        end;
        
        % timing
        waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0);
    end;
    
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;    
    
    %--- update screen
    flipTime = t0 + stimulus.seqtiming(frame);
    VBLTimestamp = Screen('Flip', display.windowPtr, flipTime);
    % If we are making a movie, add this frame to it.
    if makemov
        Screen('AddFrameToMovie', ...
               display.windowPtr, movieRect, 'frontBuffer', moviePtr);
    end
    %response.flip(end+1) = GetSecs;
    response.flip(frame) = VBLTimestamp;
    if isfield(stimulus, 'trigSeq'), response.LED(frame)  = colIndex; end
end;

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));
% Finalize the movie if need-be
if makemov
    fprintf("Finalizing movie...\n");
    Screen('FinalizeMovie', moviePtr);
    Screen('CloseMovie', moviePtr);
end
return;


function waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0)
% waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0)
%
% If timeFromT0 we wait until the current time minus the initial time is
% equal to the desired presentation time, and then flip the screen. 
% If timeFromT0 is false, then we wait until the current time minus the
% last screen flip time is equal to the desired difference in the
% presentation time of the current flip and the prior flip.

    if timeFromT0        
        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    else
        if frame > 1, 
            lastFlip = response.flip(frame-1);
            desiredWaitTime = stimulus.seqtiming(frame) - stimulus.seqtiming(frame-1);
        else 
            lastFlip = t0;
            desiredWaitTime = stimulus.seqtiming(frame);
        end
        % we add 10 ms of slop time, otherwise we might be a frame late. 
        % This should NOT cause us to be 10 ms early, because PTB waits
        % until the next screen flip. However, if the refresh rate of the
        % monitor is greater than 100 Hz, this might make you a frame
        % early. [So consider going to down to 5 ms? What is the minimum we
        % need to ensure that we are not a frame late?] 
        waitTime = (GetSecs-lastFlip)-desiredWaitTime + .010;
    end





























