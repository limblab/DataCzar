function add_monkey_cmd(monkeyName, ccmID, usdaID, species)
% add_monkey_cmd(monkeyName, ccmID, udaID, species)
%
% text-based method to add a new monkey to the database. An alternative is
% to use a GUI based version I'm planning to make. HAHA!
%
% Aug 2018, KLB


%% Connection to the server
user = input('Username: ','s');
pass = input('Password: ','s');

vendor = 'PostgreSQL';
db = 'LLSessionsDB';
url = 'vfsmmillerdb.fsm.northwestern.edu';

connSessions = database(db,user,pass,'Vendor',vendor,'Server',url);


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
        usdaID = 'NULL';
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
sqlquery = ['INSERT INTO general_info.monkeys (name, ccm_id, usda_id, species) VALUES ('''...
    strjoin({monkeyName,ccmID,usdaID,species},''','''),''');'];
curs = exec(connSessions,sqlquery);
fetch(curs);


end