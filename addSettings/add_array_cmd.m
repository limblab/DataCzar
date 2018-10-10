function add_array_cmd(arrayInfo,connSessions)
%% add_array_cmd(array_info)
%
% function to add a new array to the database. This is the method to add it
% via the matlab command line.
% 
%
%
% arrayInfo should be a structure with the following fields:
%   - serial                serial number of the array
%   - array_type            utah etc. If this throws an error ask Kevin to
%                                       add a new array type.
%   - monkey_id             CCM ID for the monkey. This needs to be a
%                                       monkey that has already been added 
%                                       to the database, so make sure to
%                                       take care of that first.
%   - electrode_length      length of the electrodes in mm; stored as a
%                                       float. [default:'NULL']
%   - lead_length           length of the leads in cm, stored as an int. 
%                                       [default:'NULL']
%   - implant_date          date of implantation
%   - removal_date          date of removal [default:'NULL']
%   - map_file              location of map_file on the server
%                                       [default:'NULL']
%   - implant_location      descriptive implant location ie rightM1, leftS1
%   - loc_ML                stereotaxic Medial/Lateral coordinates of array
%                                       [default:'NULL']
%   - loc_AP                stereotaxic anterior/posterior coordinates of
%                                       array [default:'NULL']
%   - crani_Medial          stereotaxic coordinates of medial edge of crani
%                                       [default:'NULL']
%   - crani_Lateral         stereotaxic coords of lateral edge of crani
%                                       [default:'NULL']
%   - crani_Anterior        stereotaxic coords of anterior edge of crani
%                                       [default:'NULL']
%   - crani_Posterior       stereotaxic coords of posterior edge of crani
%                                       [default:'NULL']
%
%
% if the field doesn't say [default:'NULL'] in the descriptor, it can't be
% empty. This function will throw an error if it isn't provided.
%
% KLB September 2018


%% check the incoming settings
% fields  that can't be empty
arrayInfoReqd = {'serial','array_type','ccm_id','implant_date','implant_location'};
% fields that can be empty
arrayInfoNULL = {'electrode_length','lead_length','removal_date','map_file',...
                        'loc_ML','loc_AP','crani_Medial',...
                        'crani_Lateral','crani_Anterior','crani_Posterior'};



for ii = 1:numel(arrayInfoReqd)
    if ~isfield(arrayInfo,arrayInfoReqd{ii})
        error(['Input structure must contain field ',arrayInfoReqd{ii}]);
    end
end


%% connect to the database

if ~exist('connSessions','var')
    connSessions = LLSessionsDB_connector;
end


%% put it all into the server

% need to put a fairly loose structure into a defined sql query
% needs to be format INSERT INTO general_info.monkeys ('fields') VALUES ('values')
fields = fieldnames(arrayInfo); % get all the fields
sqlQuery = ['INSERT INTO general_info.arrays (', strjoin(fields,', '), ') VALUES (']; % define the columns we're going to be inserting
for ii = 1:numel(fields) % for each column/field
    if isnumeric(arrayInfo.(fields{ii})) % format changes if it's a number or not -- need single quotes if it's not a number
        sqlQuery = [sqlQuery, num2str(arrayInfo.(fields{ii}))];
    else
        sqlQuery = [sqlQuery, '''', num2str(arrayInfo.(fields{ii})), ''''];
    end
    
    % structure between elements in the values list
    if ii<numel(fields) % add the necessary commas for everything except the end of the group
        sqlQuery = [sqlQuery, ', ']; % add comma if it's still in the middle of the list
    else
        sqlQuery = [sqlQuery, ');']; % finish the query off otherwise.
    end
end
        

curs = exec(connSessions,sqlQuery); % connect to the database
if ~isempty(curs.Message) % did it work?
    error(['Could not properly connect to database. Returns message: ',curs.Message])
end
fetch(curs); % Execute the statement

disp(['Array ',array_info.serial,' added to the database']);






end