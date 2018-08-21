function el = prepEyelink(wPtr)

el = 0;

[result, dummy] = EyelinkInit();

if result
    el = EyelinkInitDefaults(wPtr);
    el.backgroundcolour = 128;
    el.foregroundcolour = 255;
    Eyelink('Command', 'file_sample_data = LEFT,RIGHT,GAZE,AREA');
else
    fprintf('Couldn''t initialize connection with eyetracker! Switch to dummy...\n');
    [dummy] = Eyelink('initializedummy');
    el = EyelinkInitDefaults(wPtr);
end

% status = Eyelink('isconnected');
% switch status
%     case -1
%         fprintf(1, 'Eyelink in dummymode.\n\n');
%     case  0
%         fprintf(1, 'Eyelink not connected.\n\n');
%     case  1
%         fprintf(1, 'Eyelink connected.\n\n');
% end
