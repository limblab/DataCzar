%% This script is for the synchronization of Cerebus and the Raspberry Pi camera
%
% yellow coax cable == output 1, blue coax cable == output 4
clc
try
    cbmex('open');
catch err
    disp('No cerebus system is running');
    throw(err);
end
%serial_obj=serial('com1','baudrate',9600,'parity','none','databits',8,'stopbits',1);
%fopen(serial_obj);


%% Define the desired length of the recording
recTime = 180; % time in seconds. if -1, just record until you hit a button on the keyboard
% This corresponds to the blue coax cable in Kevin's cabling scheme.
cbmex('analogout', 4, 'sequence', [15,0,6000,21626,60,0], 'repeats', 1);

%% begin recording
% path = ['E:\Data-lab1\17L2-Greyson\CerebusData\',datestr(now,'yyyymmdd')];
path = 'C:\Users\Miller Lab\Documents\TestData\20181116_NewAntennaLayout';
% filename = [datestr(now,'yyyymmdd'),'_Greyson_Freereaching_'];
filename = 'Still_in_cage_';
path_and_filename = strcat(path,filesep,filename);
% Start video recording
% This corresponds to the yellow coax cable
cbmex('analogout', 1, 'sequence', [15,0,6000,21626,60,0], 'repeats', 1);
% Start .nev file recording
cbmex('fileconfig',path_and_filename,'',1);
%fwrite(serial_obj,'STR');
%% pause for a period of time
if recTime == -1
    input('hit enter to stop recording');
else 
    pause(recTime)
end

%% stop recording
cbmex('analogout', 4, 'sequence', [15,0,6000,21626,60,0], 'repeats', 1); % blue coax cable
cbmex('fileconfig',path_and_filename,'',0);
%fwrite(serial_obj,'END');
cbmex('close');
%fclose(serial_obj);