%% define the objects
clc
try
    cbmex('open');
catch err
    disp('No cerebus system is running');
    throw(err);
end
serial_obj=serial('com1','baudrate',9600,'parity','none','databits',8,'stopbits',1);
fopen(serial_obj);


%% Define the desired length of the recording
recTime = 900; % time in seconds. if -1, just record until you hit a button on the keyboard


%% begin recording
path = ['E:\Data-lab1\17L2-Greyson\CerebusData\',datestr(now,'yyyymmdd')];
filename = [datestr(now,'yyyymmdd'),'_Greyson_'];
path_and_filename = strcat(path,filesep,filename);
cbmex('fileconfig',path_and_filename,'',1);
fwrite(serial_obj,'STR');

%% pause for a period of time
if recTime == -1
    input('hit enter to stop recording');
else 
    pause(recTime)
end

%% stop recording
cbmex('fileconfig',path_and_filename,'',0);
fwrite(serial_obj,'END');
cbmex('close');
fclose(serial_obj);