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









end

