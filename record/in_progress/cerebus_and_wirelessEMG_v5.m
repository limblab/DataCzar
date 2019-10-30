function cerebus_and_wirelessEMG_v5
clc
% File and path name
path = ['E:\Data-lab1\17L2-Greyson\CerebusData\',datestr(now,'yyyymmdd')];
filename = [datestr(now,'yyyymmdd'),'_Greyson_Kluver_'];
global path_and_filename
path_and_filename = strcat(path,filesep,filename);
global ip_addr
ip_addr = 'http://192.168.42.93';
dt = datestr(now,'HH-MM-SS-FFF');
sync_file_name = [path_and_filename, '_sync',dt, '.txt'];
global sync_file
sync_file = fopen(sync_file_name,'w');
recTime = -1;
%%
urlread(ip_addr,'post',{'__SL_P_UDI','C0'});
urlread(ip_addr,'post',{'__SL_P_UDI','C1'});
try
    cbmex('open');
catch err
    disp('No cerebus system is running');
    throw(err);
end
%%
% Start recording
urlread(ip_addr,'post',{'__SL_P_UDI','S0'});
tic
cbmex('fileconfig',path_and_filename,'',1);
t = toc;
tcbmex = cbmex('time');
fprintf(sync_file,'%f\t%f\n',tcbmex,t);
tic
urlread(ip_addr,'post',{'__SL_P_UDI','S1'});
t = toc;
tcbmex = cbmex('time');
fprintf(sync_file,'%f\t%f\n',tcbmex,t);
%%
if recTime == -1
    input('hit enter to stop recording');
else 
    pause(recTime)
end
%%
tic
urlread(ip_addr,'post',{'__SL_P_UDI','C1'});
t = toc;
tcbmex = cbmex('time');
fprintf(sync_file,'%f\t%f\n',tcbmex,t);
cbmex('fileconfig',path_and_filename,'',0);
urlread(ip_addr,'post',{'__SL_P_UDI','C0'});
cbmex('close');
fclose(sync_file);
end