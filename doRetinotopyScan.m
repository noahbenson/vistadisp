function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 11.09.15 JW added a check for modality. If modality is ECoG, then call
%           ShowScanStimulus with the argument timeFromT0 == false. See
%           ShowScanStimulus for details. 

% defaults
if ~exist('params', 'var'), error('No parameters specified!'); end

% make/load stimulus
fprintf('\n\nLoading Stimulus...\n');
stimulus = retLoadStimulus(params);

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);%clear
    
% Get the session / subject.
sesFileName = getSesFilename(params);

try

    % check for OpenGL
    AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    if isfield(params, 'skipSyncTest')
        Screen('Preference','SkipSyncTests', params.skipSyncTests);
    else
        Screen('Preference','SkipSyncTests', 1);
    end
    
    % Open the screen
    params.display                = openScreen(params.display);
    params.display.devices        = params.devices;
    
    % to allow blending
    Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Make a nice screen if requested (this code copied and pasted from
    % inside the pressKey2Begin function).
    if isfield(params, 'instructions')
        instructs = params.instructions;
        display = params.display;
        Screen('FillRect', display.windowPtr, display.backColorRgb);
        drawFixation(display);
        if iscell(instructs)
            % multi-line input: present each line separately
            nLines = length(instructs);
            vRange = min(.4, .04 * nLines/2);  % vertical axis range of message
            vLoc = 0.5 + linspace(-vRange, vRange, nLines); % vertical location of each line
            textSize = 20;
            oldTextSize = Screen('TextSize', display.windowPtr, textSize);
            charWidth = textSize/4.5; % character width
            for n = 1:nLines
                loc(1) = display.rect(3)/2 - charWidth*length(instructs{n});
		        loc(2) = display.rect(4) * vLoc(n);
		        Screen('DrawText', display.windowPtr, instructs{n}, loc(1), loc(2), display.textColorRgb);
            end
            drawFixation(display);
            Screen('Flip',display.windowPtr);
            Screen('TextSize', display.windowPtr, oldTextSize);
        else
            % single line: present in the middle of the screen
            dispStringInCenter(display, instructs, 0.55);
        end
    end

    % Create stimuli.
    % Store the images in textures
    fprintf('\nCreating Textures...\n');
    t0 = tic();
    stimulus = createTextures(params.display,stimulus);
    t1 = toc(t0);
    fprintf("(%f seconds elapsed.)\n", t1);
    % If necessary, flip the screen LR or UD  to account for mirrors
    % We now do a single screen flip before the experiment starts (instead
    % of flipping each image). This ensures that everything, including
    % fixation, stimulus, countdown text, etc, all get flipped.
    retScreenReverse(params, stimulus);
    % If we are doing ECoG, then add photodiode flash to every other frame
    % of stimulus. This can be used later for syncing stimulus to electrode
    % outputs.
    stimulus = retECOGtrigger(params, stimulus);

    %% Initialize EyeLink if requested
    if params.doEyelink
        fprintf('\n[%s]: Setting up Eyelink..\n',mfilename)
        if isfield(params, 'eyelinkIP')
            eyelinkAddr = params.eyelinkIP;
        else
            eyelinkAddr = '192.168.1.5';
        end
        Eyelink('SetAddress',eyelinkAddr);
        el = EyelinkInitDefaults(params.display.windowPtr);
        EyelinkUpdateDefaults(el);
        %
        % %     Initialize the eyetracker
        Eyelink('Initialize', 'PsychEyelinkDispatchCallback');
        % %     Set up 5 point calibration
        s = Eyelink('command', 'calibration_type=HV5');
        %
        % %     Calibrate the eye tracker
        EyelinkDoTrackerSetup(el);
        %
        % %     Throw an error if calibration failed
        if s~=0
            error('link_sample_data error, status: ', s)
        end
   
        el = prepEyelink(params.display.windowPtr);
        
        ELfileName = sprintf('%s.edf', sesFileName);
        
        edfFileStatus = Eyelink('OpenFile', ELfileName);
        
        if edfFileStatus ~= 0, fprintf('Cannot open .edf file. Exiting ...');
            try
                Eyelink('CloseFile');
                Eyelink('Shutdown');
            end
            return; 
        else
            fprintf('\n[%s]: Succesfully openend Eyelink file..\n',mfilename)
        end
        
        cal = EyelinkDoTrackerSetup(el);
        
    end
    
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        retResetColorMap(params);
        
        % wait for go signal
        fprintf('\n\n------------------------------------------------\n');
        fprintf('The stimulus program is now ready and will begin\n');
        fprintf('when it detects a ''%s'' character.\n', params.triggerKey);
        onlyWaitKb = false;
        if isfield(params, 'beginPrompt')
            prompt = params.beginPrompt;
        else
            prompt = {'When the experiment begins,';
                      'this message will disappear.'};
        end
        pressKey2Begin(params.display, onlyWaitKb, ...
                       [], prompt, params.triggerKey);

        % If we are doing eCOG, then signal to photodiode that expt is
        % starting by giving a patterned flash
        retECOGdiode(params);
        
        % countdown + get start time (time0)
        [time0] = countDown(params.display,params.countdown,params.startScan, params.trigger);
        time0   = time0 + params.startScan; % we know we should be behind by that amount
        
        
        % go
        if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
            timeFromT0 = false;
        else timeFromT0 = true;
        end
        
        if params.doEyelink
            Eyelink('StartRecording');
        end
      
        [response, timing, quitProg] = showScanStimulus(params.display,stimulus,time0, timeFromT0, params); %#ok<ASGLU>
        
        if params.doEyelink
            Eyelink('StopRecording');
            Eyelink('ReceiveFile', ELfileName, fileparts(vistadispRootPath) ,1);
            Eyelink('CloseFile');
            Eyelink('Shutdown');
        end
        
        % reset priority
        Priority(0);
        
        % get performance
        [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        fprintf('[%s]: percent correct: %.1f %%, reaction time: %.1f secs\n',mfilename,pc,rc);
        
        % save
        if params.savestimparams,
            filename = fullfile(fileparts(vistadispRootPath), ...
                sprintf('%s_%s.mat', sesFileName, datestr(now,30)));
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.\n',mfilename,filename);
        end
        
        % don't keep going if quit signal is given
        if quitProg, break; end
        
    end
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);

catch ME
    % clean up if error occurred
    Screen('CloseAll'); setGamma(0); Priority(0); ShowCursor;
    warning(ME.identifier, ME.message);
end

return;





