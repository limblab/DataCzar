function add_task_cmd(taskName,taskDescription,altTaskName,connSessions)
% add_task_cmd(taskName,taskDescription)
%
% adds a new task to the SQL database so that you can record with it.
%
% Inputs:
%   - taskName          The name of the task (think isoWF, CO, RW). This
%                           should be a string
%   - taskDescription   A more in-depth description so that people who
%                           haven't worked with the task in the past can
%                           have an idea what's going on. This should be a
%                           string
%   - altTaskName       alternative task names (think IsoBox or WFIso) that
%                           have been used. This will hopefully be a thing
%                           of the past once we force everyone to use the
%                           same naming conventions, but for the time being
%                           it is what it is. This isn't a required field.
%                           This should be a cell array of strings, even if
%                           there's only one alternative name.
%
%
% KLB September 2018


if ~exist('taskName','var')
    error('Must enter a task name')
end
if ~ exist('taskDescription','var')
    taskDescription = 'NULL';
end

%% connect to to the database
if ~exist('connSessions')
    connSessions = LLSessionsDB_connector;
end


%% add things to the database
% SQL command etc to add it to the database
if exist('altTaskName','var') && ~isempty(altTaskName)
    sqlQuery = ['INSERT INTO general_info.tasks (task_name, task_description, alt_task_name) '...
        'VALUES (''',taskName,''', ''', taskDescription,''', ''{"',...
        strjoin(altTaskName,'", "'),'"}'');'];
else
    sqlQuery = ['INSERT INTO general_info.tasks (task_name,task_description) '...
            'VALUES (''',taskName,''', ''', taskDescription,''');'];
end
% send it over
curs = exec(connSessions,sqlQuery); % connect to the database
if ~isempty(curs.Message) % did it work?
    error(['Could not properly connect to database. Returns message: ',curs.Message])
end
fetch(curs); % Execute the statement
disp(['"',taskName,'" added to the database.']);




end