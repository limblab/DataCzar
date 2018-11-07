function runCageRecording
% function runCageRecording
%
% runs a recording in the cage room - data through the cerebus, through the
% wireless EMG system, and tells the cameras when to record.
time_for_each_file = 900; % recording time of each file, in seconds
I = 0;
cbmex('open')
A = msgbox('Press ''ok'' to stop running');
ip_addr = 'http://192.168.42.93';

% make sure that the "Toggle on/off" bits are set to "off"
urlread(ip_addr,'post',{'__SL_P_UDI','C0'});
urlread(ip_addr,'post',{'__SL_P_UDI','C1'});
% make sure nothing's recording
cbmex('analogout', 4, 'sequence', [15,0,300,21626,60,0], 'repeats', 1);
while ishandle(A)
    I = I+1;
    try
       t = num2str(clock());
       if I < 10
           filename = ['E:\Data-lab1\Cage_Data\Greyson\20181107\20181107_Greyson_Cage_00', num2str(I)];
       elseif (I>=10) && (I<100)
           filename = ['E:\Data-lab1\Cage_Data\Greyson\20181107\20181107_Greyson_Cage_0', num2str(I)];
       else
           filename = ['E:\Data-lab1\Cage_Data\Greyson\20181107\20181107_Greyson_Cage_', num2str(I)];
       end
       cbmex('fileconfig',filename, '', 0 ) ;
       drawnow;                        % wait till the app opens
       pause(1);
       drawnow;                        % wait some more to be sure. If app was closed, it does not always start recording otherwise
       %% ********** Files start**********%
       urlread(ip_addr,'post',{'__SL_P_UDI','S0'}); %turn on file streaming
       cbmex('fileconfig',filename,'', 1 ) ;
       urlread(ip_addr,'post',{'__SL_P_UDI','S1'}); % turn on streaming
       %%%%%%%%%%%%%%%%%%% Video %%%%%%%%%%%%%%%%%%%%
       cbmex('analogout', 1, 'sequence', [15,0,300,21626,60,0], 'repeats', 1);
       %%
       drawnow;
       pauseCheck = tic;
       while ishandle(A) && (toc(pauseCheck)<time_for_each_file) % wait 1 second, then make sure that we haven't quit or that time is up
           
           pause(1)
       end
       %% ********* Files end ************%
       urlread(ip_addr,'post',{'__SL_P_UDI','C1'}); % clear bit 1
       cbmex('fileconfig',filename, '', 0 ) ;
       urlread(ip_addr,'post',{'__SL_P_UDI','C0'}); % clear bit 0
       %%%%%%%%%%%%%%%%%% Video %%%%%%%%%%%%%%%%%%%%
       cbmex('analogout', 4, 'sequence', [15,0,300,21626,60,0], 'repeats', 1);
    catch
       error(['Error at time ' num2str(clock())])
    end
end
cbmex('fileconfig',filename, '', 0 ) ;
drawnow;

cbmex('close')

end