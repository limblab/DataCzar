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

% Last Modified by GUIDE v2.5 05-Sep-2018 12:50:11

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
