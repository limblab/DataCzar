function runCageRecording
time_for_each_file = 60;
I = 0;
cbmex('open')
A = msgbox('Press ''ok'' to stop running');
ip_addr = 'http://192.168.42.93';

%urlread(ip_addr,'post',{'__SL_P_UDI','C0'});
%urlread(ip_addr,'post',{'__SL_P_UDI','C1'});
cbmex('analogout', 4, 'sequence', [15,0,300,21626,60,0], 'repeats', 1);
while ishandle(A)
    I = I+1;
    try
       t = num2str(clock());
       filename = ['E:\Data-lab1\TestData\PiVideoTest\20181016_VideoSyncTest', num2str(I)];
       cbmex('fileconfig',filename, '', 0 ) ;
       drawnow;                        % wait till the app opens
       pause(1);
       drawnow;                        % wait some more to be sure. If app was closed, it does not always start recording otherwise
       %% ********** Files start**********%
       %urlread(ip_addr,'post',{'__SL_P_UDI','S0'});
       cbmex('fileconfig',filename,'', 1 ) ;
       %urlread(ip_addr,'post',{'__SL_P_UDI','S1'});
       %%%%%%%%%%%%%%%%%%% Video %%%%%%%%%%%%%%%%%%%%
       cbmex('analogout', 1, 'sequence', [15,0,300,21626,60,0], 'repeats', 1);
       %%
       drawnow;
       pauseCheck = tic;
       while ishandle(A) && (toc(pauseCheck)<time_for_each_file) % wait 1 second, then make sure that we haven't quit or that time is up
           pause(1)
       end
       %% ********* Files end ************%
       %urlread(ip_addr,'post',{'__SL_P_UDI','C1'});
       cbmex('fileconfig',filename, '', 0 ) ;
       %urlread(ip_addr,'post',{'__SL_P_UDI','C0'});
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