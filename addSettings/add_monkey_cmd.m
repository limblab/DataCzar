function add_monkey_cmd(monkeyName, ccmID, usdaID, species)
% add_monkey_cmd(monkeyName, ccmID, udaID, species)
%
% text-based method to add a new monkey to the database. An alternative is
% to use a GUI based version I'm planning to make. HAHA!
%
% Aug 2018, KLB


%% Connection to the server
prompt = {'Username','Password'};
name = 'Enter yo'' credentials';
userPass = inputdlg(prompt,name);

vendor = 'PostgreSQL';
db = 'LLSessionsDB';
url = 'vfsmmillerdb.fsm.northwestern.edu';

connSessions = database(db,userPass{1},userPass{2},'Vendor',vendor,'Server',url);


%% check the input variables

if ~exist('monkeyName','var')
    error('You must input a monkey name');
end
if ~exist('ccmID','var')
    error('You must input a CCM ID number. That''s our primary key for the db!');
end
if ~exist('usdaID','var')
    usdaIDyn = input('Would you like to enter a USDA ID number? ','s');
    if any(strcmpi(usdaIDyn,{'y','yes'}))
        usdaID = input('What is the ID number? ','s');
    else
        usdaID = NaN;
    end
end
if ~exist('species','var')
    speciesYN = input('is this a Rhesus? ','s');
    if any(strcmpi(speciesYN,{'y','yes'}))
        species = 'Rhesus';
    else
        species = input('What is the species? ','s');
        while ~exist(species)
            species = input('You''ve gotta give me something, stubborn. ','s');
        end
    end
end




%% put it all into the server
if ~isnan(usdaID)
    sqlQuery = ['INSERT INTO general_info.monkeys (name, ccm_id, usda_id, species) VALUES ('''...
        strjoin({monkeyName,lower(ccmID),usdaID,species},''','''),''');'];
else
    sqlQuery = ['INSERT INTO general_info.monkeys (name, ccm_id, species) VALUES ('''...
        strjoin({monkeyName,lower(ccmID),species},''','''),''');'];
end

curs = exec(connSessions,sqlQuery); % connect to the database
if ~isempty(curs.Message) % did it work?
    error(['Could not properly connect to database. Returns message: ',curs.Message])
end
fetch(curs); % Execute the statement


end