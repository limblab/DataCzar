function filenames = gimme_a_file_cmd(varargin)
% --- gimme_a_file_cmd ---
%
% Provides a list of filenames that are fit a desired set of inputs.
% 
% -----------------------------------------------------------------------
% Usage:
%   filenames = gimme_a_file_cmd(name/value pair)
%
% Inputs are given as a name/value pair, where the name will relate to the
% field you're wanting to search (ie monkey, task etc) and the value will
% be the corresponding search term. This should be a valid value for the
% corresponding search field. Use as many or as few as you want.
%
% -----------------------------------------------------------------------
%
% Baseline Settings:
%*   numResults            Maximum number of files to return. [default:20]
%*   justFileName          Return just the filenames. Otherwise it returns
%                              the values for every search term [default:T]
%*   connSessions          database connection object. (If you previously
%                              have connected to the database. In most 
%                              cases you won't use this.)
%
% Valid Search Fields:
%*   monkey_name           Name of the monkey. This must be a string.
%*   ccm_id                CCM ID. This is a string
%*   task_name             Name of the task. This must be a string. 
%*   task_description      Task description. If you're not sure about the
%                             exact name that was used, or want a general
%                             type of task instead of just one task.
%*   implant_location      Location of the implant (ie rightM1), can input 
%                             just a part of the implant location (ie M1)
%                             and it'll return everything that matches
%                             that.
%*   array_type            Array type (typically going to be Utah)
%*   rec_date              Date of the recording entered as a string. 
%                             A range of dates can be input using a cell 
%                             array of dates such as {'06/15/2018','06/18/2018'}
%*   behavior_quality      'Good','ok','bad'; this if for an individual
%                             session
%*   lab_num               Lab number
%*   duration              length of the recording in seconds. You can also
%                             input a range ie [600 900]. If you want a
%                             minimum length enter [600 NaN], if you want a
%                             maximum length enter [Nan 900].
%*   numChannels           number of recorded channels. You can also input
%                             a range in the same format as duration.
%*   hasTriggers           True/False
%*   hasChaoticLoad        True/False
%*   hasBumps              True/False
%*   numTrials             number of trials performed. You can also use an
%                             input range of the same format as duration
%*   numReward             number of successful trials. Can be a value range
%*   numAbort              number of aborted trials. Can be a value range
%*   numFail               number of failed trials. Can be a value range
%*   numIncomplete         number of incomplete trials. can be a range
%*   hasEMGs               whether it needs an EMG file
%*   EMGQuality            'good','ok','bad'; this automatically sets
%                              'hasEMGs' to TRUE
%    spikeQuality          'good','ok','bad'; 
%*   hasKin                has a file with kinematics (forces etc)
%*   kinQuality            'good','ok','bad'; this automatically sets
%                              'hasKin' to TRUE




%% Data input checking, formatting to sqlQuery
if mod(nargin,2)
    error('Inputs must be a name/value pair. See documentation for more info');
elseif nargin == 0
    error('You need to enter something to search for')
end

sqlQuery = parse_input_arrays(varargin{:});




%% connection to the database

% if we provide a connection to a server
connSessions = [varargin{find(strcmpi(varargin,'connSessions'))+1}];

if ~isa(connSessions,'database.jdbc.connection') % if we couldn't find any arguments named "dbConnection"
    connSessions = LLSessionsDB_connector; % connect to the database
end


%% send the sqlQuery, check for errors

filenames = fetch(connSessions,sqlQuery);

if isempty(filenames)
    warning('No Matching files were found. Try again with a new query!')
end


end



%% ------------------------------------------------------------------------
% SUBFUNCTIONS
%
% -------------------------------------------------------------------------



%% -----------------------------------------------------------------------
% Turns the varargin in into a series of structures for easy postgres use
function sqlQuery = parse_input_arrays(varargin)

justFileName = true;
numResults = 20;


% set up initial portions of query string
columns = {'sf.filename','d.rec_date as date','m.name as monkey_name'};
tables = {'general_info.monkeys as m';'general_info.arrays as a';...
    'recordings.days as d';'recordings.sessions as s';...
    'recordings.spike_files as sf'};
conds = {'m.ccm_id = a.ccm_id';'m.ccm_id = d.ccm_id';'d.day_key = s.day_key';...
    's.sessions_key = sf.sessions_key'};

for ii = 1:2:nargin
    switch lower(varargin{ii})
        case 'numresults'
            % total number of files to return
            if ~isinteger(varargin{ii+1})
                error('numResults must be an integer!')
            else
                numResults = varargin{ii+1};
            end
        %-    
        case 'justfilefame' % do we only want the filenames, or everything?
            justFileName = varargin{ii+1};
        %-    
        case 'monkey_name' % the monkey's name
            columns{end+1} = 'm.name';
            conds{end+1} = ['m.name = ''',varargin{ii+1},''''];
        %-    
        case 'ccm_id'
            columns{end+1} = 'm.ccm_id';
            conds{end+1} = ['m.ccm_id = ''',varargin{ii+1},''''];
        %-
        case 'task_name'
            columns{end+1} = 's.task_name';
            conds{end+1} = ['LOWER(s.task_name) = LOWER(''',...
                varargin{ii+1},''')'];

        %-    
        case 'task_description'
            columns{end+1} = 't.task_description';
            conds{end+1} = ['t.task_description LIKE ',...
                '''%', varargin{ii+1},'%'''];
            if ~any(strcmp(tables,'general_info.tasks as t'))
                tables{end+1} = 'general_info.tasks as t';
            end
        %-    
        case 'implant_location'
            columns{end+1} = 'a.implant_location';
            conds{end+1} = ['a.implant_location LIKE',...
                '''%', varargin{ii+1}, '%'''];
        %-    
        case 'array_type'
            columns{end+1} = 'a.array_type';
            conds{end+1} = ['LOWER(a.array_type) = LOWER(''',...
                varargin{ii+1},''')'];
        %-
        case 'rec_date'
            columns{end+1} = 'd.rec_date';
            % if it's a range look between those dates. otherwise look for
            % the exact date
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['d.rec_date = ''',varargin{ii+1}''''];
            elseif numel(varargin{ii+1}) == 2
                conds{end+1} = ['(d.rec_date > ''',varargin{ii+1}{1},''') AND ',...
                    '(d.rec_date < ''',varargin{ii+1}{2},''')'];
            else
                error('wrong number of entries in the rec_date value');
            end
        %-    
        case 'behavior_quality'
            columns{end+1} = 's.behavior_quality';
            % look if it's a valid value for quality
            if ~any(strcmpi(varargin{ii+1},{'good','ok','bad'}))
                error('invalid entry for behavior_quality')
            else
                conds{end+1} = ['s.behavior_quality > ''',varargin{ii+1},''''];
            end
        %-    
        case 'lab_num'
            columns{end+1} = 's.lab_num';
            % check to see if it's numeric
            if ~isnumeric(varargin{ii+1})
                error('invalid entry for lab_num')
            else
                conds{end+1} = ['s.lab_num = ',num2str(varargin{ii+1})];
            end
        %-    
        case 'duration'
            columns{end+1} = 's.duration';
            % need to handle this as a range
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.duration = ''',num2str(varargin{ii+1}),''''];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.duration < ''',num2str(varargin{ii+1}(2)),'''']
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.duration > ''',num2str(varargin{ii+1}(1)),'''']
                else
                    conds{end+1} = ['(s.duration < ''',num2str(varargin{ii+1}(2)),''') AND'...
                        '(s.duration > ''',num2str(varargin{ii+1}(1)),''')']
                end
            end
        %-    
        case 'numchannels'
            columns{end+1} = 's.numchannels';
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.numchannels = ',num2str(varargin{ii+1})];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.numchannels = ',num2str(varargin{ii+1}(2))];
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.numchannels = ',num2str(varargin{ii+1}(1))];
                else
                    conds{end+1} = ['(s.numchannels > ',num2str(varargin{ii+1}(1)),...
                        ') AND (s.numchannels < ',num2str(varargin{ii+1}(2)),')'];
                end
            end
        %-
        case 'hastriggers'
            columns{end+1} = 's.hastriggers';
            conds{end+1} = ['s.hastriggers = ', num2str(varargin{ii+1})];
        %-
        case 'haschaoticload'
            columns{end+1} = 's.haschaoticload';
            conds{end+1} = ['s.haschaoticload = ', num2str(varargin{ii+1})];
        %-
        case 'hasbumps'
            columns{end+1} = 's.hasbumps';
            conds{end+1} = ['s.s.hasbumps = ', num2str(varargin{ii+1})];
        %-
        case 'numtrials'
            columns{end+1} = 's.numtrials';
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.numtrials = ',num2str(varargin{ii+1})];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.numtrials < ',num2str(varargin{ii+1}(2))];
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.numtrials > ',num2str(varargin{ii+1}(1))];
                else
                    conds{end+1} = ['(s.numtrials > ',num2str(varargin{ii+1}(1)),...
                        ') AND (s.numtrials < ',num2str(varargin{ii+1}(2)),')'];
                end
            end
        %-
        case 'numreward'
            columns{end+1} = 's.numreward';
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.numreward = ',num2str(varargin{ii+1})];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.numreward < ',num2str(varargin{ii+1}(2))];
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.numreward > ',num2str(varargin{ii+1}(1))];
                else
                    conds{end+1} = ['(s.numreward > ',num2str(varargin{ii+1}(1)),...
                        ') AND (s.numreward < ',num2str(varargin{ii+1}(2)),')'];
                end
            end
        %-
        case 'numabort'
            columns{end+1} = 's.numabort';
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.numabort = ',num2str(varargin{ii+1})];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.numabort = ',num2str(varargin{ii+1}(2))];
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.numabort = ',num2str(varargin{ii+1}(1))];
                else
                    conds{end+1} = ['(s.numabort > ',num2str(varargin{ii+1}(1)),...
                        ') AND (s.numabort < ',num2str(varargin{ii+1}(2)),')'];
                end
            end
        %-
        case 'numfail'
            columns{end+1} = 's.numfail';
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.numfail = ',num2str(varargin{ii+1})];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.numfail = ',num2str(varargin{ii+1}(2))];
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.numfail = ',num2str(varargin{ii+1}(1))];
                else
                    conds{end+1} = ['(s.numfail > ',num2str(varargin{ii+1}(1)),...
                        ') AND (s.numfail < ',num2str(varargin{ii+1}(2)),')'];
                end
            end
        %-
        case 'numincomplete'
            columns{end+1} = 's.numincomplete';
            if numel(varargin{ii+1}) == 1
                conds{end+1} = ['s.numincomplete = ',num2str(varargin{ii+1})];
            else
                if isnan(varargin{ii+1}(1))
                    conds{end+1} = ['s.numincomplete = ',num2str(varargin{ii+1}(2))];
                elseif isnan(varargin{ii+1}(2))
                    conds{end+1} = ['s.numincomplete = ',num2str(varargin{ii+1}(1))];
                else
                    conds{end+1} = ['(s.numincomplete > ',num2str(varargin{ii+1}(1)),...
                        ') AND (s.numincomplete < ',num2str(varargin{ii+1}(2)),')'];
                end
            end
        %-
        case 'hasemgs'
            if ~any(strcmpi(tables,'recordings.emg_files as e')) && varargin{ii+1} % need to actually check that I'm saying I want EMGs!
                tables{end+1} = 'recordings.emg_files as e';
                columns{end+1} = 'e.filename as emg_filename';
                conds{end+1} = ['e.sessions_key = s.sessions_key'];
            end
        %-
        case 'emgquality'
            if ~any(strcmpi(varargin{ii+1},{'good','ok','bad'}))
                error('Invalid value entered for field ''emgQuality''');
            else
                if ~any(strcmpi(tables,'recordings.emg_files as e'))
                    tables{end+1} = 'recordings.emg_files as e';
                    columns{end+1} = 'e.filename as emg_filename';
                    conds{end+1} = ['e.sessions_key = s.sessions_key'];
                end
                conds{end+1} = ['e.emg_quality > ''', varargin{ii+1}, ''''];
            end
        %-
        case 'spikeQuality'
            if ~any(strcmpi(varargin{ii+1},{'good','ok','bad'}))
                error('Invalid value entered for field ''emgQuality''');
            else
                conds{end+1} = ['sf.spike_quality > ''', varargin{ii+1}, ''''];
            end
            
        case 'haskin'
            if ~any(strcmpi(tables,'recordings.kin_files as k')) && varargin{ii+1}
                tables{end+1} = 'recordings.kin_files as k';
                columns{end+1} = 'k.filename as kin_filename';
                conds{end+1} = ['k.sessions_key = s.sessions_key'];
            end
            
            
        case 'kinQuality'
            if ~any(strcmpi(varargin{ii+1},{'good','ok','bad'}))
                error('Invalid value entered for field ''kinQuality''');
            else
                if ~any(strcmpi(tables,'recordings.kin_files as k'))
                    tables{end+1} = 'recordings.kin_files as k';
                    columns{end+1} = 'k.filename as kin_filename';
                    conds{end+1} = ['k.sessions_key = s.sessions_key'];
                end
                conds{end+1} = ['k.kin_quality > ''', varargin{ii+1}, ''''];
            end
        %-
        case 'connSessions'
            
        %-        
        otherwise
            columns{end+1} = 'm.name';
            conds{end+1} = ['m.name = ''Jango'''];
            warndlg('You entered something wrong Chris, so I''m giving you Jango''s data.','hahaha');
            
    end % end of the name/value parsing switch/case
    
end

% -----------------------------
% now to assemble the sql query
%
% which columns do we want to see? everything we're working with or just
% the basics?
if justFileName
    sqlQuery = ['SELECT sf.filename, d.rec_date as date, m.name as monkey_name'];
    if any(strcmpi(tables,'recordings.kin_files as k'))
        sqlQuery = [sqlQuery, ', k.filename AS kin_filename'];
    end
    if any(strcmpi(tables,'recordings.emg_files as e'))
        sqlQuery = [sqlQuery, ', e.filename AS emg_filename'];
    end
else
    sqlQuery = ['SELECT ',strjoin(columns,', ')]
end

% add in the tables we want to use
sqlQuery = [sqlQuery, ' FROM ', strjoin(tables,', ')];
% add in the conditions
sqlQuery = [sqlQuery, ' WHERE (', strjoin(conds,') AND ('), ')'];
% and the number of results we're wanting to see
sqlQuery = [sqlQuery, ' LIMIT ', num2str(numResults), ';'];



end
