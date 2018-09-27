function log_scraper(logFileName,monkeyID)
%% --- log_scraper ---
%
% A function to pull the data from a spreadsheet keeping the
% daily log of a monkey, and use it to update the days and sessions
% information for the postgres server.
%
%
% Inputs:
%   logFileName         filename for the log
%   monkeyID            ccm ID number of the monkey
%
%
% updated September 2018 by KevinHP

%% check the validity of the inputs
if ~exist(logFileName, 'file')
    error('The input file doesn''t exist. Check what you entered and try again!')
end

if ~any(regexpi(monkeyID,'[0-9]+[A-L]{1}[0-9]{1}'))
    error('That isn''t a valid monkey ID')
end

%% connect to the server, make sure we have the associated monkey
prompt = {'Username','Password'};
userPass = inputdlg(prompt,'ENTER CREDENTIALS HERE PLEASE');


vendor = 'PostgreSQL';
db = 'LLSessionsDB';
url = 'vfsmmillerdb.fsm.northwestern.edu';
connSessions = database(db,userPass{1},userPass{2},'Vendor',vendor,'Server',url);

%% load the file
% find out the name of the sheets
[status,sheets] = xlsfinfo(logFileName);


sheetsStruct = struct;
for jj = 1:size(raw,2)
    for kk = 1:size(raw,1)-1
        sheetsStruct(kk).(strrep(raw{1,jj},' ','_')) = raw{kk+1,jj};
    end
end


for jj = 1:length(sheetsStruct)
    sqlQuery = ['Select rec_date from recordings.days where (rec_date = ''',...
        sheetsStruct(jj).rec_date,''') AND (monkey_id = ''12A1'');'];
    day = fetch(connSessions,sqlQuery);
    
    
    




