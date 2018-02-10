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
expList = docNode.createElement(sprintf('%sExperimentList',monkeyName)); % create the node for the experiment list
docNode.getDocumentElement.appendChild(expList); % add the node to the document


%% call the recursive subfunction
% function will dir() current folder, store any cerebus files into a
% struct, and then call itself with any subfolders.

% stores the date, which file types are available and where, and whether
% there is a sorted file available.
nevList = struct(...
    'BaseName',             '',...
    'Date',                 [],...
    'FileTypes',            struct('Type','','Location',''),...
    'Sorted',               false);

nevList = find_Nev_Files(nevList,directoryLocation);




%% load nevList structure into the xml DOM node




end



%% directory exploration function
% looks through provided directory for cerebus files, stores their location
% into a struct, repeats for subfunctions, then returns the new nevList
function nevList = find_Nev_Files(nevList,directoryLocation)

% what's in the directory?
D = dir(directoryLocation);
D = D(3:end); % get rid of . and ..

for ii = 1:length
    fileSplit = strsplit(D(ii).name,'.');
    fileExt = fileSplit{end};
    if strcmp(fileExt,'nev')
        if any(strcmp(strsplit([fileSplit{1:end-1}],'_'),{'sorted','001'})
        
        nevList.BaseName = [fileSplit{1:end-1}];
        nevList.




end

