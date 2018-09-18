function xmlDOM = per_Monkey_Scan_Nev(monkeyName,directoryLocation,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% per_Monkey_Scan_Nev(monkeyName,directoryLocation, ...)
% 
% scans through the current directory for cerebus files (nev, nsx, etc)
% creates an xml DOM node for the monkey, and stores it into a file
% xmlFileName, then loads it into the xmlDOM to feed out.
%
% This function searches recursively through all sub directories
%
% Inputs:
%       monkeyName              : the name of the monkey, as a char array
%       directoryLocation       : directory to scan as a char array
%
% Optional Inputs:
%       xmlFileName             : save file, will attempt to load from this
%                                   file if there is no xmlDOM input and it
%                                   alread exists
%       xmlDOM                  : input xmlDOM (if calling recursively)
%
%
% ToDo:
%  EVERYTHING!!!!
%   - write recursive function that searches for sub directories, filenames
%                       etc
%   - add capability to append previously stored xml files
%


%% load all of the varargin
% see whether we need to create a new xml node, or just load in a previous
% one

makeNode = true; % flag to make a new node. default == true
xmlFile = ''; % to avoid errors when calling exist() later on
for ii = 1:numel(varargin)
    switch class(varargin{ii})
        case 'org.apache.xerces.dom.DocumentImpl' % it's a java thing
            docNode = varargin{ii};
            makeNode = false;
        case 'char'
            xmlFile = varargin{ii};
        otherwise
            error('Optional input %i is not valid',ii);
    end
end


%% create the xml DOM object
docNode = com.mathworks.xml.XMLUtils.createDocument('perMonkeyMetaData');
root = docNode.getDocumentElement;
root.setAttribute('version','0.1');
root.setAttribute('UpdateDate',datestr(now));
monkList = docNode.createElement('monkey'); % create the node for the experiment list
monkList.setAttribute('Name',monkeyName);
root.appendChild(monkList); % add the node to the document
dateList = monkList.createElement('dateList');
monkList.appendChild(dateList);


%% call the recursive subfunction
% function will dir() current folder, store any cerebus files into a
% struct, and then call itself with any subfolders.

% stores the date, which file types are available and where, and whether
% there is a sorted file available.
% nevList = struct; % this is because I don't want to make it 1x1 to start. Have to figure that out.
nevList = struct(...
    'BaseName',             '',...
    'Date',                 [],...
    'FileTypes',            struct('Type',[],'Location',[]),... % below, but if I do it now it makes this a 1x1 empty struct
    'Sorted',               false,...
    'Length',               0);

nevList = find_Nev_Files(nevList,directoryLocation);


%% load nevList structure into the xml DOM node
docNode = loadNevList(docNode,nevList);


%% create the xml DOM object as necessary
if makeNode == true
    if exist(xmlFile,'file') % is there a file to read from?
        docNode = xmlread(xmlFile); % load the object
    else % otherwise create one
        docNode = com.mathworks.xml.XMLUtils.createDocument('monkeyMetaData'); % new document
        monkeyList = docNode.createElement(sprintf('%sExperimentList',monkeyName)); % per monkey
        docNode.getDocumentElement.appendChild(monkeyList); % tack it on
        expList = monkeyList.createElement('experimentList'); % experiment section (vs array etc section)
        monkeyList.getDocumentElement.appendChild(expList); % tack it on
    end
end

%% take a look through the current folder
d = dir(directoryLocation);
d = d(3:end); % get rid of '.' and '..'

directoryList = d([d.isdir]); % store the directories for recursion
d = d(~[d.isdir]); % keep only files for dis part



% what's in the directory?
subDirs = dir(directoryLocation); % find the subdirectories
subDirs = subDirs(3:end); % get rid of . and ..
subDirs = subDirs([subDirs.isdir]);

localNevs = dir([directoryLocation,filesep,'*.nev']); % get the local nevs



for ii = 1:length(localNevs) % for each nev
    baseName = strsplit(localNevs(ii).name,'.nev'); % get rid of the file extension
    baseName = baseName{1}; % switch it back to a string
    baseNameCopy = baseName; % for looking for cds etc for sorted. There's probably a better way to do this...
    [baseName,sortFlag] = regexp(baseName,'_(s{1}(orted)?|[0-9]{2}(?![0-9]))','split','match'); % looking for sorted stuff, get rid of that for the baseName
    baseName = baseName{1}; % bring it back together
    baseExists = strcmp({nevList.BaseName},baseName); % find any matching filenames - this should only be one at a time, but we'll see if things break
    
    if any(baseExists)
        nevList(baseExists).FileTypes(end+1).Location = [directoryLocation,filesep,localNevs(ii).name]; % file loc'n
        nevList(baseExists).FileTypes(end).Type = '.nev'; % we already know this - we're looking through nevs :)
        
        if ~isempty(sortFlag) % look for sorted tags - defined above
            nevList(baseExists).Sorted = true;
        end
    else
        nevList(end+1).BaseName = baseName; % tack on a new entry
%         nevList(end).Date = localNevs(ii).date; % the storage date - that'll work for now, might change that later
        currNEV = openNEV([directoryLocation,filesep,localNevs(ii)],'noread','nosave','nomat'); % opening the file to save associated info.
        nevList(end).Date = currNEV.MetaTags.DateTime;
        nevList(end).Length = currNev.MetaTags.DataDurationSec;
        nevList(end).FileTypes.Type = '.nev'; % because it's a list of nevs
        nevList(end).FileTypes.Location = [directoryLocation,filesep,localNevs(ii).name]; % and the location
        
        nevList(end).Sorted = false;
        if ~isempty(sortFlag)
            nevList(end).Sorted = true; % someone sorted it, or so I think...
        end
%     end % the location of this end changes whether it looks for
%     associated files only when adding a totally new entry, or for every
%     nev. I'm going to go for only new entries for the moment


        matchingFiles = dir([directoryLocation,filesep,baseNameCopy,'*']); % find a matching list of different file types, making sure not r
        for jj = 1:length(matchingFiles)
            fileSplit = strsplit(matchingFiles(jj).name,'.'); % get filetypes, again
            addFile = ~(any(strcmp(fileSplit{end},{'nev','fig','png','jpg','bmp'}))||...
                        matchingFiles(jj).isdir);
            if addFile % other than nev and directories
                if strcmp(fileSplit{end},'mat') % treat mat files a little differently
                    if ~isempty(regexp([fileSplit{end-1}],'(BDF|bdf)', 'once')) % old BDFs
                        nevList(end).FileTypes(end+1) = struct('Type','BDF',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'(CDS|cds)', 'once')) % CDSs
                        nevList(end).FileTypes(end+1) = struct('Type','CDS',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'(D|d)(ecoder|ECODER)', 'once'))
                        nevList(end).FileTypes(end+1) = struct('Type','decoder',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'params', 'once'))
                        nevList(end).FileTypes(end+1) = struct('Type','FES Params',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    else
                        nevList(end).FileTypes(end+1) = struct('Type','mat',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    end
                
                elseif strcmp(fileSplit{end},'txt') % txt for FES stuff
                    if ~isempty(regexp([fileSplit{end-1}],'emgpreds','once'))
                        nevList(end).FileTypes(end+1) = struct('Type','FES Predictions',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'params','once'))
                        nevList(end).FileTypes(end+1) = struct('Type','FES Params',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'spikes','once'))
                        nevList(end).FileTypes(end+1) = struct('Type','FES Spikes',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'stim_out','once'))
                        nevList(end).FileTypes(end+1) = struct('Type','FES Stim Commands',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    elseif ~isempty(regexp([fileSplit{end-1}],'words','once'))
                        nevList(end).FileTypes(end+1) = struct('Type','FES Words',...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                    end
                    
                else
                nevList(end).FileTypes(end+1) = struct('Type',fileSplit{end},...
                                'Location',[directoryLocation,filesep,matchingFiles(jj).name]);
                end
            end

        end
    end  % the location of this end changes when to look for matching files. look above for more info.
    
end

% do it for all subdirectories -- make this shiz recursive! 
for ii = 1:length(subDirs)
    nevList = find_Nev_Files(nevList,[directoryLocation,filesep,subDirs(ii).name]);
end





end





%% docNode population
% loads all of the nevList values into the docNode DOM object
function docNode = loadNevList(docNode,nevList)

keyboard

% dateList = []; % make a list of all of the dates, to make it easier to compare with dates that we have
% 
% 
% for ii = 1:length(nevList)
%     







end