function varargout = add_task(varargin)
% ADD_TASK MATLAB code for add_task.fig
%      ADD_TASK, by itself, creates a new ADD_TASK or raises the existing
%      singleton*.
%
%      H = ADD_TASK returns the handle to a new ADD_TASK or the handle to
%      the existing singleton*.
%
%      ADD_TASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADD_TASK.M with the given input arguments.
%
%      ADD_TASK('Property','Value',...) creates a new ADD_TASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before add_task_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to add_task_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help add_task

% Last Modified by GUIDE v2.5 05-Oct-2018 11:38:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @add_task_OpeningFcn, ...
                   'gui_OutputFcn',  @add_task_OutputFcn, ...
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


% --- Executes just before add_task is made visible.
function add_task_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to add_task (see VARARGIN)

% Choose default command line output for add_task
handles.output = hObject;

if ~isfield(handles,'connSessions');
    handles.connSessions = LLSessionsDB_connector;
end
    

handles.taskInfo = struct('task_name','','task_description','');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes add_task wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = add_task_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_task_button.
function add_task_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_task_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.taskInfo,'alt_task_name')
    add_task_cmd(handles.taskInfo.task_name,handles.taskInfo.task_description,...
        handles.taskInfo.alt_task_name,handles.connSessions);
else
    add_task_cmd(handles.taskInfo.task_name,handles.taskInfo.task_description,...
        '',handles.connSessions);
end
closereq




function alt_task_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alt_task_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alt_task_name_edit as text
%        str2double(get(hObject,'String')) returns contents of alt_task_name_edit as a double
altList = get(hObject,'String');
% add a field for the alternative task names if anything was entered
if ~isempty(altList)
    handles.taskInfo.alt_task_name = strsplit(altList,'; ');
else
    if isfield(handles.taskInfo,'alt_task_name')
        rmfield(handles.taskInfo,'alt_task_name')
    end
end


guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function alt_task_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alt_task_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function task_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to task_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of task_name_edit as text
%        str2double(get(hObject,'String')) returns contents of task_name_edit as a double
handles.taskInfo.task_name = get(hObject,'String');

if ~isempty(handles.taskInfo.task_name) & ~isempty(handles.taskInfo.task_description)
    handles.add_task_button.Enable = 'on';
else
    handles.add_task_button.Enable = 'off';
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function task_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function task_description_edit_Callback(hObject, eventdata, handles)
% hObject    handle to task_description_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of task_description_edit as text
%        str2double(get(hObject,'String')) returns contents of task_description_edit as a double
handles.taskInfo.task_description = get(hObject,'String');

if ~isempty(handles.taskInfo.task_name) & ~isempty(handles.taskInfo.task_description)
    handles.add_task_button.Enable = 'on';
else
    handles.add_task_button.Enable = 'off';
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function task_description_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task_description_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
