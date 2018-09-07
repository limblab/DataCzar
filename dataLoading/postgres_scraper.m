function postgres_scraper(directory,params)
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
%
% Updated Aug 2018, KLB

%% credentials and connection settings
% since we probably don't want this available in a public proc
while ~exist('user','var')
    [credFile,credpath] = uigetfile('*.mat','Load credentials file');
    load([credpath,filesep,credFile]);
end


vendor = 'PostgreSQL';

%% Initiate connection with sessions server
db = 'LLSessionsDB';

if exist('url','var') % on the server
    connSessions = database(db,user,pass,'Vendor',vendor,'Server',url);
else % local host
    connSessions = database(db,user,pass,'Vendor',vendor);
end

%% start running through the current folder

% change this to however we're wanting to set the base directory
if exist('directory','var')
    baseDir = directory;
else
    baseDir = uigetdir('.');
end

addNevs(connSessions,connSettings,baseDir);


%% close everything
close(connSettings)
close(connSessions)
end




%% --------------------------------------------------------------------- %%
% subfunctions %
% ----------------------------------------------------------------------- %

%% directory exploration function
% looks through provided directory and subdirectories for nevs, nsx, etc
function exceptionList = addNevs(connSessions, connSettings, directory)

nevList = dir([directory,filesep,'**/*.nev']); % all nevs in this folder
fprintf('Found %i potential nev files\n',numel(nevList));


% list of valid values for monkeys, array names etc
% monkeys
selectquery = 'SELECT name FROM general_info.monkeys';
monkeys = select(connSessions,selectquery);
monkeys = monkeys.name; % move them from a table to a cell array, to make it easier

% counters to keep track of addition to the DB for summary stats
added = 0; failures = 0; prevAdded = 0;

for ii = 1:length(nevList) % for each nev    
    fprintf('Processing file %i of %i\n..............................\n',...
        ii,numel(nevList));
    
    currFullPath = [nevList(ii).folder,filesep,nevList(ii).name];
    baseName = strsplit(nevList(ii).name,'.nev'); % get rid of the file extension
    baseName = baseName{1}; % switch it back to a string
%     baseNameCopy = baseName; % for looking for cds etc for sorted. There's probably a better way to do this...
%     [baseName,sortFlag] = regexpi(baseName,'_(s{1}(orted)?|[0-9]{2}(?![0-9]))','split','match'); % looking for sorted stuff, get rid of that for the baseName
%     baseName = baseName{1}; % bring it back together    
    
    monkeyName = cellfun(@(x) any(regexpi(baseName,x)),monkeys); % try to find a monkey name in the filename
    if sum(monkeyName) ~= 1 % could we resolve the monkey name?
        warning('Could not resolve a valid monkey name in the filename. Has this monkey and array been added to the array database?')
        failures = failures + 1;
        continue
    else
        monkeyName = monkeys{monkeyName}; % if so, set it as the found name
    end
     
    if ispc
        [~,shaHash] = dos(['CertUtil -hashfile "',currFullPath,'" sha256']); % get the SHA256 hash from windows
        shaHash = regexpi(shaHash,'([a-f_0-9]{2} ){31}[a-f_0-9]{2}','match'); % pull out the actual hash from the reply
        shaHash = strsplit(shaHash{:},' '); % get rid of the spaces
        shaHash = [shaHash{:}];
    elseif isunix
        [~,shaHash] = unix(['sha256sum ',currFullPath]);
        shaHash = regexpi(shaHash, '[a-f_0-9]{32}','match');
    end
        

    % has this file already been logged?
    selectquery = ['select * from sessions where sha256 = ''',shaHash,'''']; % look for the same hash
    matchingFiles = select(connSessions,selectquery);
    
    
    if numel(matchingFiles) == 0 % if there aren't any others like this file
        try
            nev = openNEV(currFullPath,'noread','nosave','nomat');
        catch
            warning(['Could not read ',currFullPath])
            failures = failures + 1;
            continue
        end
        
        recDate = datestr(datenum(nev.MetaTags.DateTime),'yyyy-mm-dd');
        recTime = datestr(datenum(nev.MetaTags.DateTime),'HH:MM:SS');
        sourceFile = currFullPath;
        % and we need to get rid of any apostraphes in the filename to
        % sanitize the input and allow it to be stored
        sourceFile = strsplit(sourceFile,'''');
        sourceFile = strjoin(sourceFile,'_');
        duration = nev.MetaTags.DataDurationSec;
        
        % open related ns3 files, look for EMG and force
        ns3Name = [nevList(ii).folder,filesep,baseName,'.ns3']; % look for 2kHz recordings
        hasEMG = false; hasForce = false; % setting the defaults
        if exist(ns3Name,'file')
            ns3 = openNSx(ns3Name,'noread');
            hasEMG = any(regexpi([ns3.ElectrodesInfo.Label],'EMG')); % do we have any EMGs?
            hasForce = any(regexpi([ns3.ElectrodesInfo.Label],'force'));
        end
        
        
        % do we know what array this is?
        % look to see whether this recording occurred while any of the
        % arrays were implanted for this monkey
        selectquery = ['SELECT implantid FROM arrays ',...
            'WHERE (monkeyname = ''',monkeyName,''' AND implantdate <=''',recDate,''') AND ',...
            '(implantrem >= ''',recDate,''' OR implantrem IS NULL)'];
        arrayEntry = select(connSettings,selectquery);
        
        implantID = NaN;
        if numel(arrayEntry) == 1
            implantID = arrayEntry.implantid{:};
        else
            warning('Could not resolve which array this is. You''ll need to resolve this manually!');
        end
        
        
        
        if ~isnan(implantID)
            % this next bit is pretty messy. Put into an external script in
            % the future? who knows...
            insertRec = ['INSERT INTO sessions (',...
                'monkey, date, time, implantID, ',....
                'sourcefile, duration, ',...
                'hasEMG, hasForce, sha256) VALUES (''',...
                monkeyName,''', ''',recDate,''', ''',recTime,''', ''',implantID,''', ''',...
                currFullPath,''', ''',num2str(duration),''', ''',...
                num2str(hasEMG),''', ''',num2str(hasForce),''', ''',shaHash,''')'];
        else
                        % this next bit is pretty messy. Put into an external script in
            % the future? who knows...
            insertRec = ['INSERT INTO sessions (',...
                'monkey, date, time, ',....
                'sourcefile, duration, ',...
                'hasEMG, hasForce, sha256) VALUES (''',...
                monkeyName,''', ''',recDate,''', ''',recTime,''', ''',...
                currFullPath,''', ''',num2str(duration),''', ''',...
                num2str(hasEMG),''', ''',num2str(hasForce),''', ''',shaHash,''')'];
        end
        
        exec(connSessions,insertRec);
        added = added + 1;
        
    else
        warning(['File ',nevList(ii).name,' not added. It''s already in the database!'])
        prevAdded = prevAdded + 1;
        continue
    end
        
    
    
    
%     if any(baseExists)
%         nevList(baseExists).FileTypes(end+1).Location = [directoryLocation,filesep,localNevs(ii).name]; % file loc'n
%         nevList(baseExists).FileTypes(end).Type = '.nev'; % we already know this - we're looking through nevs :)
%         
%         if ~isempty(sortFlag) % look for sorted tags - defined above
%             nevList(baseExists).Sorted = true;
%         end
%     else
%         nevList(end+1).BaseName = baseName; % tack on a new entry
% %         nevList(end).Date = localNevs(ii).date; % the storage date - that'll work for now, might change that later
%         currNEV = openNEV([directoryLocation,filesep,localNevs(ii)],'noread','nosave','nomat'); % opening the file to save associated info.
%         nevList(end).Date = currNEV.MetaTags.DateTime;
%         nevList(end).Length = currNev.MetaTags.DataDurationSec;
%         nevList(end).FileTypes.Type = '.nev'; % because it's a list of nevs
%         nevList(end).FileTypes.Location = [directoryLocation,filesep,localNevs(ii).name]; % and the location
%         
%         nevList(end).Sorted = false;
%         if ~isempty(sortFlag)
%             nevList(end).Sorted = true; % someone sorted it, or so I think...
%         end
% %     end % the location of this end changes whether it looks for
% %     associated files only when adding a totally new entry, or for every
% %     nev. I'm going to go for only new entries for the moment
% 
% 
%         matchingFiles = dir([directoryLocation,filesep,baseNameCopy,'*']); % find a matching list of different file types, making sure not r
%         for jj = 1:length(matchingFiles)
%             fileSplit = strsplit(matchingFiles(jj).name,'.'); % get filetypes, again
%             addFile = ~(any(strcmp(fileSplit{end},{'nev','fig','png','jpg','bmp'}))||...
%                         matchingFiles(jj).isdir);
%             if addFile % other than nev and directories
%                 if strcmp(fileSplit{end},'mat') % treat mat files a little differently
%                     if ~isempty(regexp([fileSplit{end-1}],'(BDF|bdf)', 'once')) % old BDFs
%                         nevList(end).FileTypes(end+1) = struct('Type','BDF',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'(CDS|cds)', 'once')) % CDSs
%                         nevList(end).FileTypes(end+1) = struct('Type','CDS',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'(D|d)(ecoder|ECODER)', 'once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','decoder',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'params', 'once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','FES Params',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     else
%                         nevList(end).FileTypes(end+1) = struct('Type','mat',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     end
%                 
%                 elseif strcmp(fileSplit{end},'txt') % txt for FES stuff
%                     if ~isempty(regexp([fileSplit{end-1}],'emgpreds','once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','FES Predictions',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'params','once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','FES Params',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'spikes','once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','FES Spikes',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'stim_out','once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','FES Stim Commands',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     elseif ~isempty(regexp([fileSplit{end-1}],'words','once'))
%                         nevList(end).FileTypes(end+1) = struct('Type','FES Words',...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                     end
%                     
%                 else
%                 nevList(end).FileTypes(end+1) = struct('Type',fileSplit{end},...
%                                 'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
%                 end
%             end
% 
%         end
%     end  % the location of this end changes when to look for matching files. look above for more info.
    
end

fprintf('\n\n-----------------------------------------------------------------\n')
fprintf('%i files added to database\n %i skipped (previously added)\n %i failures (monkey name unresolved or failed to open .nev)',...
    added, prevAdded, failures);
fprintf('\n-----------------------------------------------------------------\n\n')

end
