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

% Last Modified by GUIDE v2.5 31-Oct-2018 16:16:26

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


% --- Executes on selection change in name_menu.
function name_menu_Callback(hObject, eventdata, handles)
% hObject    handle to name_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns name_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from name_menu


% --- Executes during object creation, after setting all properties.
function name_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in array_menu.
function array_menu_Callback(hObject, eventdata, handles)
% hObject    handle to array_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns array_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from array_menu


% --- Executes during object creation, after setting all properties.
function array_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weight_edit as text
%        str2double(get(hObject,'String')) returns contents of weight_edit as a double


% --- Executes during object creation, after setting all properties.
function weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function treats_edit_Callback(hObject, eventdata, handles)
% hObject    handle to treats_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of treats_edit as text
%        str2double(get(hObject,'String')) returns contents of treats_edit as a double


% --- Executes during object creation, after setting all properties.
function treats_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treats_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function h2ostart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to h2ostart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h2ostart_edit as text
%        str2double(get(hObject,'String')) returns contents of h2ostart_edit as a double


% --- Executes during object creation, after setting all properties.
function h2ostart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h2ostart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function experimenter_edit_Callback(hObject, eventdata, handles)
% hObject    handle to experimenter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of experimenter_edit as text
%        str2double(get(hObject,'String')) returns contents of experimenter_edit as a double


% --- Executes during object creation, after setting all properties.
function experimenter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimenter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
