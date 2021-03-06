function knownFailures = postgres_scraper(directory,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% postgres_scraper
%
% scans through a dirctory for cerebus files (nev, nsx etc) and adds them
% to the LLSessionsDB postgres database. The idea behind this is that it
% runs at a fixed interval checking for new recordings and adding them to
% the db so that it's all easy to keep track.
%
% Currently this doesn't have any outputs, though I suspect in
% the future we might want to have some sort of error response if it
% crashes or something. Maybe just an email to whoever's in charge? Dunno
%
% -------------------------------------------------------------------------
% Allows name/value pairs of optional arguments 
%
%   Field               Explanation
%
%   quiet               Boolean [default T] - allows the program to run
%                           quietly in the background and skips anything t
%                           that is giving it trouble; instead just stores
%                           any question in a local log file. This
%                           overrides fileCheck (set to T) and altTaskName
%                           (set to T)
%   fileCheck           Boolean [default T] - checks to see if files have
%                           been previously added based on filename rather
%                           than the sha256 hash. Not as solid, but much
%                           faster.
%   altTaskName         Boolean [default T] - checks alternative task
%                           names to account for different conventions used
%                           for filenames. This may make things match a
%                           little more easily, which might not always be a
%                           good thing
%
% 
%

%% varargin parsin
options.quiet = true;
options.fileCheck = true;
options.altTaskName = true;

% look through the varargin
for ii = 1:2:nargin-1
    switch lower(varargin{ii})
        case 'filecheck'
            options.fileCheck = varargin{ii+1};
        case 'alttaskname'
            options.altTaskName = varargin{ii+1};
        case 'quiet'
            options.quiet = varargin{ii+1};
        otherwise
            warning(['Invalid input: ',varargin(ii)]);
    end
end

% if quiet is true...
if options.quiet
    options.fileCheck = true;
    options.altTaskName = true;
end


%% connect to the database, get credentials etc

connSessions = LLSessionsDB_connector;

%% start running through the current folder

% change this to however we're wanting to set the base directory
if exist('directory','var')
    baseDir = directory;
else
    baseDir = uigetdir('.');
end

knownFailures = addNevs(connSessions,baseDir,options);

save([basedir,filesep,'scraped_data_',datestr(today,'yyyy.mm.dd'),'.mat'],'knownFailures');


%% close everything
close(connSessions)
end




%% --------------------------------------------------------------------- %%
% subfunctions %
% ----------------------------------------------------------------------- %

%% directory exploration function
% looks through provided directory and subdirectories for nevs, nsx, etc
function knownFailures = addNevs(connSessions, directory,options)

if verLessThan('matlab','R2017b')
    nevList = struct('name',{},'date',{},'bytes',{},'isdir',{},'datenum',{},'folder',{});
    nevList = findNevsRecursive(directory,nevList);
else
    nevList = dir([directory,filesep,'**/*.nev']); % all nevs in this folder
end
fprintf('Found %i potential nev files\n',numel(nevList));


% list of valid values for monkeys, array names etc
% monkeys
sqlQuery = 'SELECT name, ccm_id FROM general_info.monkeys';
monkeys = fetch(connSessions,sqlQuery);

% counters to keep track of addition to the DB for summary stats
added = 0; prevAdded = 0;
knownFailures = struct('FileName','','Description','');

for ii = 1:length(nevList) % for each nev    
    fprintf('\n..............................\nProcessing file %i of %i\n',...
        ii,numel(nevList));
    
    
    currFullPath = [nevList(ii).folder,filesep,nevList(ii).name];
    baseName = strsplit(nevList(ii).name,'.nev'); % get rid of the file extension
    baseName = baseName{1}; % switch it back to a string
    sortFlag = (numel(regexpi(baseName,'_(s{1}(orted)?|[0-9]{2}(?![0-9]))','match')) > 0); % looking for sorted stuff

    
    % check to see whether the file has already been added to the dB. We
    % can either do that by checking the file hash, or check the filename.
    % I prefer the former when we have time, but that definitely takes
    % longer.
    if ~options.fileCheck
        shaHash = get_256_hash(currFullPath);
        % has this file already been logged?
        sqlQuery = ['select * from recordings.spike_files where file_hash = ''',shaHash,'''']; % look for the same hash
        matchingFiles = fetch(connSessions,sqlQuery);

        % I think some PCs don't have certutil....
        if isempty(shaHash)
            if ~options.quiet
                warning(['Could not calculate shaHash; skipping file ',basename]);
            end
            knownFailures(end+1) = struct('FileName',currFullPath,'Description','Could not caluculate shaHash');
            continue;
        end
        
    else % if we want to just check the file name 
        sqlQuery = ['select * from recordings.spike_files where filename = ''',nevList(ii).name,''';'];
        matchingFiles = fetch(connSessions,sqlQuery);
    end
    
    
    
    if numel(matchingFiles) == 0 % if there aren't any others like this file
        
        % if we didn't create the shaHash previously due to using the
        % filename
        if options.fileCheck
            shaHash = get_256_hash(currFullPath);
            if isempty(shaHash)
                if ~options.quiet
                    warning(['Could not calculate shaHash; skipping file ',basename]);
                end
                knownFailures(end+1) = struct('FileName',currFullPath,'Description','Could not caluculate shaHash');
                continue;
            end
        end
        
        
    % find the monkey name in the filename
        monkeyName = cellfun(@(x) any(regexpi(baseName,x)),monkeys(:,1)); % try to find a monkey name in the filename
        if sum(monkeyName) ~= 1 % could we resolve the monkey name?
            if ~options.quiet
                warning(['Could not resolve a valid monkey name in file ',baseName,',. Has this monkey and array been added to the array database?'])
            end
            knownFailures(end+1) = struct('FileName',currFullPath,'Description',...
                'Could not resolve a valid monkey name');
            continue
        else
            ccmID = monkeys{monkeyName,2}; % get the ccmID number
            monkeyName = monkeys{monkeyName,1}; % set it as the found name
        end
        
        
        % find the task name in the filename
        baseNameSplit = strrep(baseName,'_','|');
        baseNameSplit = ['''(',baseNameSplit,')'''];
        sqlQuery = ['SELECT t.task_name from general_info.tasks as t ',...
            'WHERE t.task_name ~* ',baseNameSplit];
        taskName = fetch(connSessions,sqlQuery);
        if isempty(taskName)
            sqlQuery = ['SELECT t.task_name FROM general_info.tasks AS t WHERE ',...
                baseNameSplit,' ~* any(t.alt_task_name)'];
            taskName = fetch(connSessions,sqlQuery);
        end 
            
        if numel(taskName) ~= 1
            if ~options.quiet
                taskYN = input(['Unable to guess task for file: ',baseName,'. Do you know the task?'],'s');
                if any(strcmpi(taskYN,{'y','yes','yeah','ok','true'}))
                    taskName = input('Taskname: ','s');
                else
                    warning('Could not resolve task name. Skipping this file for now');
                    knownFailures(end+1) = struct('FileName',currFullPath,...
                        'Description','Could not resolve valid task name');
                    continue
                end
            else
                knownFailures(end+1) = struct('FileName',currFullPath,...
                    'Description','Could not resolve valid task name');
                continue
            end
        else
            taskName = taskName{:}; % to switch it from a cell to a string
        end
        
        % try to open the file to start getting information
        try
            nev = openNEV(currFullPath,'noread','nosave','nomat');
        catch
            if ~options.quiet
                warning(['Could not read ',currFullPath])
            end
            knownFailures(end+1) = struct('FileName',currFullPath,...
                'Description','Could not read file');
            continue
        end
        
        recDate = datestr(datenum(nev.MetaTags.DateTime),'yyyy-mm-dd'); % date it was recorded
        recTime = datestr(datenum(nev.MetaTags.DateTime),'HH:MM:SS'); % when it was recorded
        duration = nev.MetaTags.DataDurationSec; % length of the file
        numChans = length(unique(nev.Data.Spikes.Electrode)); % how many electrodes have data?
        numUnits = sum((nev.Data.Spikes.Unit~=0)&(nev.Data.Spikes.Unit~=255)); % how many sorted units -- ie, not 0 or 255 (invalid)
        
        
        % open related nsX files, look for EMG, force and kin?
        hasEMG = false;
        hasForce = false;
        forceFile = {};
        EMGFile = {}; %
        forceSample = []; % sampling rate of the file found
        EMGSample = []; % sampling rate of the file found
        EMGHash = {};
        EMGNames = {};
        forceHash = {};
        for jj = 1:6
            nsxName = [nevList(ii).folder,filesep,baseName,'.ns',num2str(jj)];
            if exist(nsxName,'file')
                nsx = openNSx(nsxName,'noread');
                % if there are any recordings labelled as EMG, enter them
                if any(regexpi([nsx.ElectrodesInfo.Label],'EMG'))
                    hasEMG = true; % do we have any EMGs?
                    EMGFile{end+1} = [baseName,'.ns',num2str(jj)]; % just in case it shows up in multiple files etc
                    EMGSample(end+1) = nsx.MetaTags.SamplingFreq; % tack on the appropriate sampling rate
                    EMGHash{end+1} = get_256_hash(nsxName);
                    % so that we have the emg names 
                    EMGNames{end+1} = regexpi([nsx.ElectrodesInfo.Label],'(?<=emg_)\w*','match');
                end
                
                
                if any(regexpi([nsx.ElectrodesInfo.Label],'force'))
                    hasForce = true;
                    forceFile{end+1} = [baseName,'.ns',num2str(jj)]; % if we have files with different
                    forceSample(end+1) = nsx.MetaTags.SamplingFreq; % tack on the appropriate sampling rate
                    forceHash{end+1} = get_256_hash(nsxName);
                end
                
            end
        end
        
        
        % do we know what array this is?
        % look to see whether this recording occurred while any of the
        % arrays were implanted for this monkey
        sqlQuery = ['SELECT a.serial FROM general_info.arrays as a ',...
            'WHERE (a.ccm_id = ''',ccmID,''' AND a.implant_date <=''',recDate,''') AND ',...
            '(removal_date >= ''',recDate,''' OR removal_date IS NULL)'];
        arrayEntry = fetch(connSessions,sqlQuery);
        
        implantID = NaN;
        if numel(arrayEntry) == 1
            implantID = arrayEntry{:};
        else
            if ~options.quiet
                arrayYN = input('Would you like to enter the array for this recording? ','s');
                if any(strcmpi(arrayYN,{'y','yes','yeah','true'}))
                    implantID = input('array SN: ','s');
                else
                    warning('Could not resolve which array this is.');
                    knownProblems(end+1) = struct('FileName',currFullPath,...
                        'Description','Could not resolve array serial number');
                end
            else
                knownProblems(end+1) = struct('FileName',currFullPath,...
                        'Description','Could not resolve array serial number');  
            end
        end






% ---- Insert everything into the dB -----

    %
    % First, see if the recording date exists.
    day_key = [ccmID, '_', recDate];
    sqlQuery = ['SELECT day_key FROM recordings.days WHERE day_key = ''', day_key, ''';'];
    day = fetch(connSessions,sqlQuery);

    % create it if not
    if isempty(day)
        sqlQuery = ['INSERT INTO recordings.days (rec_date, ccm_id, day_key) VALUES (''',...
            strjoin({recDate, ccmID, day_key},''', '''),''');'];
        exec(connSessions,sqlQuery);
%         fetch(curs);

        if ~options.quiet
            fprintf(['\nCreating new entry into days table for ',recDate,'\n']);
        end
    end


    % 
    % Create a new sessions entry if needed
    sessions_key = [day_key,'_',recTime];
    sqlQuery = ['SELECT sessions_key FROM recordings.sessions WHERE sessions_key = ''',...
        sessions_key,''';'];
    session = fetch(connSessions,sqlQuery);
    % create the table if necessary
    if isempty(session)
        if ~isnan(taskName)
            sqlQuery = ['INSERT INTO recordings.sessions (day_key, rec_time, sessions_key, ',...
                'task_name, duration) VALUES (''',...
                strjoin({day_key,recTime,sessions_key,taskName,[num2str(duration),' seconds']},''', '''),''');'];
%             fetch(connSessions,sqlQuery);
            exec(connSessions,sqlQuery);
%             fetch(curs);

            if ~options.quiet
                fprintf(['\nCreating new entry into sessions table for ',sessions_key,'\n'])
            end
        else
            sqlQuery = ['INSERT INTO recordings.sessions (day_key, rec_time, sessions_key,',...
                'duration) VALUES (''',...
                strjoin({day_key,recTime,sessions_key,[num2str(duration),' seconds']},''', '''),''');'];
%             fetch(connSessions,sqlQuery);
            exec(connSessions,sqlQuery);
%             fetch(curs);

            if ~options.quiet
                fprintf(['\nCreating new entry into sessions table for ',sessions_key,'\n'])
            end
        end
    end

    %
    % Create a new entry into the spike_files table
    if ~isnan(implantID) % if we have an implant name
        sqlQuery = ['INSERT INTO recordings.spike_files (sessions_key, array_serial, '...
            'filename, file_hash, setting_file, rec_system, is_sorted, '...
            'num_chans, num_units) VALUES (''',...
            strjoin({sessions_key, implantID, nevList(ii).name, shaHash, [baseName,'.ccf'],...
            'Cerebus', num2str(sortFlag)},''', '''),''', ',...
            num2str(numChans),', ' num2str(numUnits),');'];
        curs = exec(connSessions,sqlQuery);
    else % if not -- this will be a bit of trouble, but there it is.
        sqlQuery = ['INSERT INTO recordings.spike_files (sessions_key, '...
            'filename, file_hash, setting_file, rec_system, is_sorted, '...
            'num_chans, num_units) VALUES (''',...
            strjoin({sessions_key, nevList(ii).name, shaHash, [baseName,'.ccf'],...
            'Cerebus', num2str(sortFlag)},''', '''),''', ',...
            num2str(numChans),', ' num2str(numUnits),');'];
        curs = exec(connSessions,sqlQuery);

    end

    
    %
    % Create a new entry into the EMG database if necessary
    if hasEMG
        for jj = 1:numel(EMGFile)
            % has it been added to the EMG table previously?
            sqlQuery = ['SELECT file_hash FROM recordings.emg_files where file_hash = ''',...
                EMGHash{jj},''';'];
            if isempty(fetch(connSessions,sqlQuery))
                sqlQuery = ['INSERT INTO recordings.emg_files (sessions_key, filename, ',...
                    'file_hash, rec_system, sampling_rate, muscle_list) VALUES (''',...
                    strjoin({sessions_key, EMGFile{jj}, EMGHash{jj}, 'Cerebus'},''', '''),...
                    ''', ', num2str(EMGSample(jj)),', ''{"', strjoin(EMGNames{jj},'", "'),'"}'');'];
                curs = exec(connSessions,sqlQuery);
            end
        end
    end
    
    if hasForce
        for jj = 1:numel(forceFile)
            % has it been added to the EMG table previously?
            sqlQuery = ['SELECT file_hash FROM recordings.force_files where file_hash = ''',...
                forceHash{jj},''';'];
            if isempty(fetch(connSessions,sqlQuery))
                sqlQuery = ['INSERT INTO recordings.force_files (sessions_key, filename, ',...
                    'file_hash, rec_system, sampling_rate) VALUES (''',...
                    strjoin({sessions_key, forceFile{jj}, forceHash{jj}, 'Cerebus'},''', '''),...
                        ''', ',num2str(forceSample(jj)), ');'];
                curs = exec(connSessions,sqlQuery);
            end
        end
    end
    


    added = added + 1;
        
% --- if the file has already been added to the database ---
    else
        if ~options.quiet
            warning(['File ',nevList(ii).name,' not added. It''s already in the database!'])
        end
        prevAdded = prevAdded + 1;
        continue
    end
        
end    

fprintf('\n\n-----------------------------------------------------------------\n')
fprintf('%i files added to database\n %i skipped (previously added)\n %i failures (monkey name unresolved or failed to open .nev)',...
    added, prevAdded, numel(knownFailures));
fprintf('\n-----------------------------------------------------------------\n\n')


end


%% -- function get_256_hash --
% calculates the sha256 hash on a file for the purpose of identification.
% Since we have to do this in a few places, we might as well have it in a
% separate function
%
function shaHash = get_256_hash(fullFilePath)

    if ispc
        [~,shaHash] = dos(['CertUtil -hashfile "',fullFilePath,'" SHA256']); % get the SHA256 hash from windows
        shaHash = regexpi(shaHash,'([a-f_0-9]{2} ){31}[a-f_0-9]{2}','match'); % pull out the actual hash from the reply
        shaHash = strsplit(shaHash{:},' '); % get rid of the spaces
        shaHash = [shaHash{:}];
    elseif isunix
        [~,shaHash] = unix(['sha256sum ',fullFilePath]);
        shaHash = regexpi(shaHash, '[a-f_0-9]{32}','match');
    end
    
end



%% -- function findNevsRecursive
% 
% finds all of the nevs in the current and subdirectories -- this is for
% every version of matlab pre 2017, because apparently it couldn't do that
% before.
function nevList = findNevsRecursive(directory,nevList)
    
    newerList = dir([directory,filesep,'*.nev']);
    if ~isempty(newerList)
        [newerList.folder] = deal(directory);
        nevList = [nevList;newerList];
    end

    dirList = dir(directory); % find all files in here
    dirList = dirList(3:end); % get rid of . and ..
    dirList = dirList([dirList.isdir]); % only keep the directories
    for ii = 1:length(dirList) % for each directory
        if ~any(regexp(dirList(ii).name,'\.*')) % we're gonna ignore anything with a dot on the beginning - linux conventions 
            nevList = [findNevsRecursive([directory,filesep,dirList(ii).name],nevList)]; % rerun it for all sub directories
        end
    end
    
end