function varargout = cerebus_EMG_video_record(varargin)
% CEREBUS_EMG_VIDEO_RECORD MATLAB code for cerebus_EMG_video_record.fig
%      CEREBUS_EMG_VIDEO_RECORD, by itself, creates a new CEREBUS_EMG_VIDEO_RECORD or raises the existing
%      singleton*.
%
%      H = CEREBUS_EMG_VIDEO_RECORD returns the handle to a new CEREBUS_EMG_VIDEO_RECORD or the handle to
%      the existing singleton*.
%
%      CEREBUS_EMG_VIDEO_RECORD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CEREBUS_EMG_VIDEO_RECORD.M with the given input arguments.
%
%      CEREBUS_EMG_VIDEO_RECORD('Property','Value',...) creates a new CEREBUS_EMG_VIDEO_RECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cerebus_EMG_video_record_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cerebus_EMG_video_record_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cerebus_EMG_video_record

% Last Modified by GUIDE v2.5 05-Sep-2018 16:14:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cerebus_EMG_video_record_OpeningFcn, ...
                   'gui_OutputFcn',  @cerebus_EMG_video_record_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cerebus_EMG_video_record is made visible.
function cerebus_EMG_video_record_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cerebus_EMG_video_record (see VARARGIN)

% Choose default command line output for cerebus_EMG_video_record
handles.output = hObject;

if ~isfield(handles,'connSessions');
% dialog box for user and password
    prompt = {'Username','Password'};
    title = 'username to connect to server';
    dims = [1 35];
    definput = {'',''};
    userPass = inputdlg(prompt,title,dims,definput);

    % connect to the postgres database, store the handle for the DB in the gui
    % handle
    serverSettings = struct('vendor','PostgreSQL','db','LLSessionsDB',...
        'url','vfsmmillerdb.fsm.northwestern.edu');
    handles.connSessions = database(serverSettings.db,userPass{1},userPass{2},...
        'Vendor',serverSettings.vendor,'Server',serverSettings.url);
end

% I have to do everything with the monkey names here, because the "handles"
% handle is the last thing to be created (after all of the other create_fcn),
% and I don't want to have multiple connections to the server hanging about.
%
% get the list of monkey names from the server
sqlquery = ['SELECT name, ccm_id FROM general_info.monkeys;']; % get the monkey names 
try
    curs = exec(handles.connSessions,sqlquery); % try to execute the SQL statement, otherwise throw a (mild) fit
    fetch(curs);
catch ME
    rethrow(ME);
end

% get the monkey names concatenated with the ccm_ID numbers
monkeyNames = cell(1+size(curs.Data,1),1);
monkeyNames{1} = 'Monkey Name'; % before selecting the monkey name
for ii = 1:length(monkeyNames)-1
    monkeyNames{ii+1} = strjoin(curs.Data(ii,:),', '); % join 'em
end


handles.MonkeyList.String = strjoin(monkeyNames,'\n');



% same thing for the tasks.
sqlquery = ['SELECT task_name FROM general_info.tasks;'];
try
    curs = exec(handles.connSessions,sqlquery); % try to execute the SQL statement, otherwise throw a (mild) fit
    fetch(curs);
catch ME
    rethrow(ME);
end

if ~strcmp(curs.Data{1},'No Data')
    taskNames = [sprintf('Task Names\n'), strjoin(curs.Data,'\n')];
else
    taskNames = 'Task Names';
    warning('Task Table doesn''t contain any data. You might want to fix that.')
    handles.TaskList.Enable = 'off';
end
handles.TaskList.String = taskNames;



% other settings to keep everything clean
handles.CurrentMonkey = 'Monkey Name';
handles.ValidMonkeySelected = false;
handles.CurrentArray = 'Array Name';
handles.ValidArraySelected = false;
handles.CurrentTask = 'Task Name';
handles.ValidTaskSelected = false;








% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cerebus_EMG_video_record wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cerebus_EMG_video_record_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in MonkeyList.
function MonkeyList_Callback(hObject, eventdata, handles)
% hObject    handle to MonkeyList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MonkeyList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MonkeyList
contents = cellstr(get(hObject,'String'));
handles.CurrentMonkey = contents{get(hObject,'Value')};

if ~strcmp(handles.CurrentMonkey,'Monkey Name') % only do this if we don't select the 'Monkey Name' option
    monkeyID = strsplit(handles.CurrentMonkey, ', ');
    monkeyID = monkeyID{2}; % get the ccm_id number of the selected monkey

    % get the list of applicable arrays
    sqlQuery = ['SELECT serial, implant_location, removal_date, monkey_id FROM general_info.arrays ',...
        'WHERE (monkey_id = ''',monkeyID,''') AND (removal_date IS NULL);']; % SQL query for the arrays corresponding to the currently selected monkey
    try
        curs = exec(handles.connSessions,sqlQuery);
        fetch(curs);
    catch ME
        rethrow(ME)
    end
    
    if isempty(curs.Message) && ~strcmp(curs.Data{1},'No Data')
        handles.ArrayList.Enable = 'on'; % turn on the array list drop down menu
        arrayList = cell(size(curs.Data,1)+1,1);
        arrayList{1} = 'Array Name';
        for ii = 1:size(arrayList,1)-1
            arrayList{ii+1} = strjoin(curs.Data(ii,1:2),', '); % only want the serial number and location, no need for the monkey name (we already know that)
        end
        handles.ArrayList.String = strjoin(arrayList,'\n');

        handles.ValidMonkeySelected = true;
    else
        warning('Database doesn''t contain any arrays for this monkey')
        handles.ArrayList.Value = 1;
%         handles.ArrayList.String = 'Array Name';
        handles.ArrayList.Enable = 'off';
    end
    
else
    % keeping things clean in case we go back to 'monkey name'
    handles.ArrayList.Enable = 'off';
    handles.ArrayList.Value = 1;
    handles.ValidMonkeySelected = false;
end

% it's not science if you don't write it down
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function MonkeyList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MonkeyList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in TaskList.
function TaskList_Callback(hObject, eventdata, handles)
% hObject    handle to TaskList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TaskList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TaskList
% 
% save the selected array into the data handle
contents = cellstr(get(hObject,'String'));
selectedTask = contents{get(hObject,'Value')};
selectedTask = strsplit(selectedTask, ', ');

% make sure that things are clean if we reselect 'Array Name'
if ~strcmp(selectedTask,'Task Name')
    handles.selectedTask = selectedTask{1};
    handles.ValidTaskSelected = true;
else
    handles.selectedTask = 'Task Name';
    handles.ValidTaskSelected = false;
end


guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function TaskList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TaskList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ArrayList.
function ArrayList_Callback(hObject, eventdata, handles)
% hObject    handle to ArrayList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ArrayList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ArrayList



% --- Executes during object creation, after setting all properties.
function ArrayList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ArrayList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.Enable = 'off'; % turn it off until we select the monkey



function SettingsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettingsEdit as text
%        str2double(get(hObject,'String')) returns contents of SettingsEdit as a double


% --- Executes during object creation, after setting all properties.
function SettingsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettingsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadSettingsButton.
function LoadSettingsButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SaveSettingsButton.
function SaveSettingsButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in VideoCheck.
function VideoCheck_Callback(hObject, eventdata, handles)
% hObject    handle to VideoCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VideoCheck



function FolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FolderEdit as text
%        str2double(get(hObject,'String')) returns contents of FolderEdit as a double


% --- Executes during object creation, after setting all properties.
function FolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseButton.
function BrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function SettingsEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettingsEdit2 as text
%        str2double(get(hObject,'String')) returns contents of SettingsEdit2 as a double


% --- Executes during object creation, after setting all properties.
function SettingsEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettingsEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseButton2.
function BrowseButton2_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RecTimeCheck.
function RecTimeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RecTimeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RecTimeCheck
on = get(hObject,'Value');

if on
    handles.RecTimeEdit.Enable = 'on';
else
    handles.RecTimeEdit.Enable = 'off';
end

guidata(hObject,handles);



function RecTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RecTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RecTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of RecTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function RecTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RecTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StartRecButton.
function StartRecButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartRecButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in WirelessCheck.
function WirelessCheck_Callback(hObject, eventdata, handles)
% hObject    handle to WirelessCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WirelessCheck

