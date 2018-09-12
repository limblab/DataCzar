function add_task_cmd(taskName,taskDescription)
% add_task_cmd(taskName,taskDescription)
%
% adds a new task to the SQL database so that you can record with it.
%
% Inputs:
%   - taskName          The name of the task (think isoWF, CO, RW)
%   - taskDescription   A more in-depth description so that people who
%                           haven't worked with the task in the past can
%                           have an idea what's going on
%
%
% KLB September 2018


if ~exist('taskName','var')
    error('Must enter a task name')
end
if ~ exist('taskDescription','var')
    taskDescription = 'NULL';
end



prompt = {'Username','Password'};
title = 'username to connect to server';
dims = [1 35];
definput = {'',''};
userPass = inputdlg(prompt,title,dims,definput);

% connect to the postgres database, store the handle for the DB in the gui
% handle
serverSettings = struct('vendor','PostgreSQL','db','LLSessionsDB',...
    'url','vfsmmillerdb.fsm.northwestern.edu');
connSessions = database(serverSettings.db,userPass{1},userPass{2},...
    'Vendor',serverSettings.vendor,'Server',serverSettings.url);


% SQL command etc to add it to the database
sqlQuery = ['INSERT INTO general_info.tasks (task_name,task_description) '...
            'VALUES (''',taskName,''', ''', taskDescription,''');'];
curs = exec(connSessions,sqlQuery); % connect to the database
if ~isempty(curs.Message) % did it work?
    error(['Could not properly connect to database. Returns message: ',curs.Message])
end
fetch(curs); % Execute the statement



end