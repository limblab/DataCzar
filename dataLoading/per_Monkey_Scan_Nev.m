function per_Monkey_Scan_Nev(monkeyName,directoryLocation,xmlFileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% per_Monkey_Scan_Nev(monkeyName,directoryLocation)
% 
% scans through a directory for cerebus files (nev, nsx, etc)
% creates an xml DOM node for the monkey, and stores it into a file
% xmlFileName
%
%   Inputs:
%       monkeyName              : the name of the monkey, as a char array
%       directoryLocation       : directory to scan as a char array
%       xmlFileName             : save file
%
%
% ToDo:
%  EVERYTHING!!!!
%   - write recursive function that searches for sub directories, filenames
%                       etc
%   - add capability to append previously stored xml files
%

%% create the xml DOM object
docNode = com.mathworks.xml.XMLUtils.createDocument('perMonkeyMetaData');
updateDate = docNode.createElement('UpdateInformation');
docNode.getDocumentElement.appendChild(updateDate);
monkList = docNode.createElement(monkeyName); % create the node for the experiment list
docNode.getDocumentElement.appendChild(monkList); % add the node to the document


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
    'Sorted',               false);

nevList = find_Nev_Files(nevList,directoryLocation);


%% load nevList structure into the xml DOM node




end



%% directory exploration function
% looks through provided directory for cerebus files, stores their location
% into a struct, repeats for subfunctions, then returns the new nevList
function nevList = find_Nev_Files(nevList,directoryLocation)

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
        
        if ~isempty(sortFlag) % look for sorted tags - a little restrictive, but I'm not sure what else to do at the moment
            nevList(baseExists).Sorted = true;
        end
    else
        nevList(end+1).BaseName = baseName; % tack on a new entry
        nevList(end).Date = localNevs(ii).date; % the storage date - that'll work for now, might change that later
        nevList(end).FileTypes.Type = '.nev'; % because it's a list of nevs
        nevList(end).FileTypes.Location = [directoryLocation,filesep,localNevs(ii).name]; % and the location
        
        if ~isempty(sortFlag)
            nevList(end).Sorted = true; % someone sorted it, or so I think...
        end
    end
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

    
end

% do it for all subdirectories -- make this shiz recursive! 
for ii = 1:length(subDirs)
    nevList = find_Nev_Files(nevList,[directoryLocation,filesep,subDirs(ii).name]);
end




end


