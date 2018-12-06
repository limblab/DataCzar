function varargout = cerebus_record(varargin)
% CEREBUS_RECORD MATLAB code for cerebus_record.fig
%      CEREBUS_RECORD, by itself, creates a new CEREBUS_RECORD or raises the existing
%      singleton*.
%
%      H = CEREBUS_RECORD returns the handle to a new CEREBUS_RECORD or the handle to
%      the existing singleton*.
%
%      CEREBUS_RECORD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CEREBUS_RECORD.M with the given input arguments.
%
%      CEREBUS_RECORD('Property','Value',...) creates a new CEREBUS_RECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cerebus_record_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cerebus_record_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cerebus_record

% Last Modified by GUIDE v2.5 06-Dec-2018 13:18:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cerebus_record_OpeningFcn, ...
                   'gui_OutputFcn',  @cerebus_record_OutputFcn, ...
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


% --- Executes just before cerebus_record is made visible.
function cerebus_record_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cerebus_record (see VARARGIN)

% Choose default command line output for cerebus_record
handles.output = hObject;

% connect to the database
handles.connSessions = LLSessionsDB_connector;

% Fill the monkey_name menu
sqlQuery = 'SELECT m.name, m.ccm_id FROM general_info.monkeys as m WHERE m.retired IS NOT true';
try
    monkeyNames = fetch(handles.connSessions,sqlQuery);
catch ME % if there are errors getting names from the database
    warning('Unable to fetch monkey names from database.');
    error(ME)
end

if isempty(monkeyNames) % if there are some issues getting names from the database
    error('Unable to fetch monkey names from database.');
end
handles.nameMenu.String = strjoin(monkeyNames(:,1),'\n'); % update the menu values
handles.monkeys= monkeyNames;


% fill the task name menu
sqlQuery = 'SELECT t.task_name from general_info.tasks as t';
try
    taskNames = fetch(handles.connSessions,sqlQuery);
catch ME % if there are errors getting names from the database
    warning('Unable to fetch task names from database.');
    error(ME)
end

if isempty(taskNames) % if there are some issues getting names from the database
    error('No task names were received from database.');
end
handles.taskMenu.String = strjoin(taskNames,'\n');

% create structures that will be used to feed everything into the database
handles.session = struct('behavior_notes','','behavior_quality','',...
    'other_notes','','task_name','','lab_num',[],'duration',[],...
    'hastriggers',logical([])','haschaoticload',logical([]),'hasbumps',logical([]),...
    'numtrials',[],'numreward',[],'numabort',[],'numfail',[],'numincomplete',[],...
    'reward_size',[])'; % structure for everything that's going to be in the session table
handles.day = struct('ccm_id','','weight',[],'h2o_start',[],'h2o_end',[],...
    'treats','','behavior_note','','behavior_quality','','health_notes','',...
    'cleaned',logical([]),'other_notes','','experimenter',''); % structure for everything that's going to be in the day table
handles.spike_files = struct('array_serial','','filename','','file_hash','',...
    'setting_file','','is_sorted',logical([]),'num_chans',[],'num_units',[],...
    'rec_system','cerebus','connect_type','','spike_quality',''); % everything in the spike table
handles.emg_files = struct('filename','','file_hash','','rec_system','',...
    'sampling_rate',[],'emg_quality','','emg_notes','','muscle_list',''); % everything in the EMG table
handles.force_files = struct('filename','','file_hash','','rec_system','cerebus',...
    'sampling_rate',[],'force_notes',''); % everything in the force table
handles.kin_files = struct('filename','','file_hash','','sampling_rate',[],...
    'kin_quality','','kin_notes',''); % everything in the kin table

% keyboard;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cerebus_record wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cerebus_record_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in nameMenu.
function nameMenu_Callback(hObject, eventdata, handles)
% hObject    handle to nameMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nameMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nameMenu
contents = cellstr(get(hObject,'String'))
handles.monkeyName = contents{get(hObject,'Value')}; % which monkey did we chose?
handles.day.ccm_id = handles.monkeys{get(hObject,'Value'),2};

% get the arrays available for that monkey
sqlQuery = ['SELECT a.serial FROM general_info.arrays AS a WHERE a.ccm_id = ''',...
    handles.monkeys{get(hObject,'Value'),2},''' AND a.removal_date IS NULL'];
arrays = fetch(handles.connSessions,sqlQuery);
if isempty(arrays)
    handles.arrayMenu.Enable = 'off';
    handles.arrayText.Enable = 'off';
else
    handles.arrayMenu.Enable = 'on';
    handles.arrayText.Enable = 'on';
end    
handles.arrayMenu.String = arrays;

guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function nameMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nameMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in arrayMenu.
function arrayMenu_Callback(hObject, eventdata, handles)
% hObject    handle to arrayMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns arrayMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from arrayMenu
contents = cellstr(get(hObject,'String'));
handles.spike_files.array_serial = contents{get(hObject,'Value')};
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function arrayMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arrayMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function weightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to weightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weightEdit as text
%        str2double(get(hObject,'String')) returns contents of weightEdit as a double
handles.day.weight = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function weightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function treatsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to treatsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of treatsEdit as text
%        str2double(get(hObject,'String')) returns contents of treatsEdit as a double
handles.day.treats = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function treatsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treatsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function h2ostartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to h2ostartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h2ostartEdit as text
%        str2double(get(hObject,'String')) returns contents of h2ostartEdit as a double
handles.day.h2o_start = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function h2ostartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h2ostartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function experimenterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to experimenterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of experimenterEdit as text
%        str2double(get(hObject,'String')) returns contents of experimenterEdit as a double
handles.day.experimenter = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function experimenterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimenterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in taskMenu.
function taskMenu_Callback(hObject, eventdata, handles)
% hObject    handle to taskMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns taskMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from taskMenu
contents = cellstr(get(hObject,'String'));
handles.session.task_name = contents{get(hObject,'Value')};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function taskMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to taskMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rewardEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rewardEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewardEdit as text
%        str2double(get(hObject,'Strng')) returns contents of rewardEdit as a double
handles.day.treats = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rewardEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewardEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function labEdit_Callback(hObject, eventdata, handles)
% hObject    handle to labEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labEdit as text
%        str2double(get(hObject,'String')) returns contents of labEdit as a double
handles.session.lab_num = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function labEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ccfEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ccfEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ccfEdit as text
%        str2double(get(hObject,'String')) returns contents of ccfEdit as a double
ccfFile = get(hObject,'String');
if ~exist(ccfFile,'file')
    handles.ccfEdit.String = '';
    handles.spike_files.setting_file = '';
else
    handles.spike_files.setting_file = ccfFile;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ccfEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ccfEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ccfButton.
function ccfButton_Callback(hObject, eventdata, handles)
% hObject    handle to ccfButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ccfFile,ccfPath,~] = uigetfile('*.ccf','cerebus configuration file');
if ~isempty(ccfFile)
    handles.ccfEdit.String = [ccfPath,ccfFile];
    handles.spike_files.setting_file = ccfFile;
end
guidata(hObject,handles);


% --- Executes on button press in timeCheckBox.
function timeCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to timeCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeCheckBox
if get(oBject,'Value')
    handles.timeEdit.Enable = 'on';
else
    handles.timeEdit.Enable = 'off';
end
guidata(hObject,handles);


function timeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to timeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeEdit as text
%        str2double(get(hObject,'String')) returns contents of timeEdit as a double
if ~isempty(hObject.String)
    handles.recTime = str2double(get(hObject,'String'));
else
    handles.recTime = [];
end
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function timeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recordButton.
function recordButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in dayButton.
function dayButton_Callback(hObject, eventdata, handles)
% hObject    handle to dayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function connectorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to connectorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of connectorEdit as text
%        str2double(get(hObject,'String')) returns contents of connectorEdit as a double


% --- Executes during object creation, after setting all properties.
function connectorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to connectorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- function to enable the recording button
function enableRecording
% handles   handle for all of the GUI's data
handles = guidata(gcbo);

keyboard
