function runCageRecording(monkey,emg,video)
% function runCageRecording
%
% runs a recording in the cage room - data through the cerebus, through the
% wireless EMG system, and tells the cameras when to record.
time_for_each_file = 900; % recording time of each file, in seconds
I = 0;
cbmex('open')
A = msgbox('Press ''ok'' to stop running');
ip_addr = 'http://192.168.42.2';

% parse inputs if we have them so we don't have to continuously update
% settings
if ~exist('monkey')
    monkey = 'Greyson';
end
if ~exist('video')
    video = false;
end
if ~exist('emg')
    emg = false;
end

% make sure that the "Toggle on/off" bits are set to "off"
if emg
    urlread(ip_addr,'post',{'__SL_P_UDI','C0'});
    urlread(ip_addr,'post',{'__SL_P_UDI','C1'});
end

todaysDate = datestr(today,'yyyymmdd');

if video
    serial_obj=serial('com2','baudrate',115200,'parity','none','databits',8,'stopbits',1);
    fopen(serial_obj);
end

while ishandle(A)
    I = I+1;
    try
       t = num2str(clock());
       if I<10
           inc = ['00',num2str(I)];
       elseif I<100
           inc = ['0',num2str(I)];
       else
           inc = num2str(I);
       end
       filename = ['C:\Users\Miller Lab\Documents\CageData\',monkey,'\',todaysDate,'\',todaysDate,'_',monkey,'_Cage_',inc];
       cbmex('fileconfig',filename, '', 0 ) ;
       drawnow;                        % wait till the app opens
       pause(1);
       drawnow;                        % wait some more to be sure. If app was closed, it does not always start recording otherwise
       %% ********** Files start**********%
       %%%%%%%%%%%%%%%%%%% Video %%%%%%%%%%%%%
%        cbmex('analogout', 4, 'sequence', [1,0,3000,21626,1,0], 'repeats', 1);
%        cbmex('analogout', 1, 'sequence', [150,0,100,21626,1,0], 'repeats', 8);
%        cbmex('analogout', 4, 'sequence', [1,0,3000,21626,1,0], 'repeats', 1);
%        cbmex('analogout', 1, 'sequence', [150,0,100,21626,1,0], 'repeats', 8);
       if video
           fwrite(serial_obj,'STR');
       end
       %%%%%%%%%%%%%%%%% EMG %%%%%%%%%%%%%%%%%
       if emg
           urlread(ip_addr,'post',{'__SL_P_UDI','S0'}); %turn on file streaming
       end
       cbmex('fileconfig',filename,'', 1 ) ;
       if emg
           urlread(ip_addr,'post',{'__SL_P_UDI','S1'}); % turn on streaming
       end
       %%
       drawnow;
       pauseCheck = tic;
       while ishandle(A) && (toc(pauseCheck)<time_for_each_file) % wait 1 second, then make sure that we haven't quit or that time is up
           pause(1)
       end
       %% ********* Files end ************%
       if emg
           urlread(ip_addr,'post',{'__SL_P_UDI','C1'}); % clear bit 1
       end
       cbmex('fileconfig',filename, '', 0 ) ;
       if emg
           urlread(ip_addr,'post',{'__SL_P_UDI','C0'}); % clear bit 0
       end
       if video
           fwrite(serial_obj,'END');
       end
       pause(3);
    catch
       error(['Error at time ' num2str(clock())])
    end
end
cbmex('fileconfig',filename, '', 0 ) ;
drawnow;

cbmex('close')
if video
    fclose(serial_obj);
end

end