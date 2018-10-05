function connSessions = LLSessionsDB_connector
% connSessions = LLSessionsDB_connector()
%
% function to connect to LLSessionsDB. Not really meant to be used outside
% of a calling function, though I guess you could use it separately if you
% wanted to.

prompt = {'Username','Password'};
name = 'Enter yo'' credentials';
userPass = inputdlg(prompt,name);

vendor = 'PostgreSQL';
db = 'LLSessionsDB';
url = 'vfsmmillerdb.fsm.northwestern.edu';

connSessions = database(db,userPass{1},userPass{2},'Vendor',vendor,'Server',url);

% if the JDBC driver isn't installed, direct them on how to rectify that
% situation
if strcmp(connSessions.Message,'Unable to find JDBC driver.')
    h = errordlg('The postgres JDBC driver hasn''t been installed. See reference page.','JDBC missing','modal');
    uiwait(h);
    if ispc
        doc "PostgreSQL JDBC for Windows";
    else
        doc "PostgreSQL JDB for Linux";
    end
    error('Unable to find the JDBC driver')
end

% other errors, just let them know about it
if ~isempty(connSessions.message)
    error(['Could not connect to database. Returned with message: ',connSessions.message]');
end