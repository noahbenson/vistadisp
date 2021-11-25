function sesFileName = getSesFilename(params)
if isfield(params, 'sesFileName')
    sesFileName = params.sesFileName;
else
    if isfield(params, 'sub')
        subjid = params.sub;
    else
        subjid = input('Please enter subject ID: ', 's');
    end
    if isfield(params, 'ses')
        sesNum = params.ses;
    else
        sesNum = input('Please enter session number: ', 's');
    end
    if isfield(params, 'task')
        taskName = params.task;
    else
        taskName = input('Please enter task name: ', 's');
    end
    if isfield(params, 'run')
        runNum = params.run;
    else
        runNum = input('Please enter run number: ', 's');
    end
    runAsNum = str2double(runNum);
    sesAsNum = str2double(sesNum);
    sesFileName = sprintf('sub-%s_ses-%s_task-%s_run-%s', ...
                          subjid, sesNum, taskName, runNum);
end
if isfield(params, 'sesFileOverwrite') && params.sesFileOverwrite
    return;
end
while exist(sprintf('%s.edf', sesFileName), 'file')
    fprintf('\nFilename %s exists. Please re-enter subj ID and session number.\n', sesFileName)
    subjid = input('Please enter subjct initials: ', 's');
    sesNum = input('Please enter session number: ', 's');
    taskName = input('Please enter task name: ', 's');
    runNum = input('Please enter run number: ', 's');
    runAsNum = str2double(runNum);
    sesAsNum = str2double(sesNum);
    sesFileName = sprintf('sub-%s_ses-%s_task-%s_run-%s', ...
                          subjid, sesNum, taskName, runNum);
end
