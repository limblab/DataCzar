function varargout = add_monkey(varargin)
% ADD_MONKEY MATLAB code for add_monkey.fig
%      ADD_MONKEY, by itself, creates a new ADD_MONKEY or raises the existing
%      singleton*.
%
%      H = ADD_MONKEY returns the handle to a new ADD_MONKEY or the handle to
%      the existing singleton*.
%
%      ADD_MONKEY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADD_MONKEY.M with the given input arguments.
%
%      ADD_MONKEY('Property','Value',...) creates a new ADD_MONKEY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before add_monkey_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to add_monkey_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help add_monkey

% Last Modified by GUIDE v2.5 03-Oct-2018 18:30:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @add_monkey_OpeningFcn, ...
                   'gui_OutputFcn',  @add_monkey_OutputFcn, ...
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


% --- Executes just before add_monkey is made visible.
function add_monkey_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to add_monkey (see VARARGIN)

% Choose default command line output for add_monkey
handles.output = hObject;

% Connect to the database if needed
if ~isfield(handles,'connSessions');
% dialog box for user and password
    prompt = {'Username','Password'};
    title = 'username to connect to server';
    userPass = inputdlg(prompt,title);

    % connect to the postgres database, store the handle for the DB in the gui
    % handle
    serverSettings = struct('vendor','PostgreSQL','db','LLSessionsDB',...
        'url','vfsmmillerdb.fsm.northwestern.edu');
    handles.connSessions = database(serverSettings.db,userPass{1},userPass{2},...
        'Vendor',serverSettings.vendor,'Server',serverSettings.url);

    % to let the user know if we can't find the JDBC driver
    if strcmp(handles.connSessions.Message,'Unable to find JDBC driver.')
        h = errordlg('The postgres JDBC driver hasn''t been installed. See reference page.','JDBC missing','modal');
        uiwait(h);
        doc JDBC;
        error('Could not find JDBC driver')
    end
end


handles.monkeyInfo = struct('name','','ccm_id','','usda_id','','species','Rhesus');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes add_monkey wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = add_monkey_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function MonkeyEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MonkeyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MonkeyEdit as text
%        str2double(get(hObject,'String')) returns contents of MonkeyEdit as a double
handles.monkeyInfo.name = get(hObject,'String');

if ~isempty(handles.monkeyInfo.name) && ~isempty(handles.monkeyInfo.ccm_id)
    set(handles.dbButton,'Enable','on');
else
    set(handles.dbButton,'Enable','off');
end

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function MonkeyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MonkeyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CCMEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CCMEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CCMEdit as text
%        str2double(get(hObject,'String')) returns contents of CCMEdit as a double
ccm_id = get(hObject,'String');

% take a look to see whether it's a valid CCM ID
if any(regexpi(ccm_id,'\d{1,2}[a-l]{1}\d+'))
    handles.monkeyInfo.ccm_id = ccm_id;
else
    set(hObject,'String','');
end

if ~isempty(handles.monkeyInfo.name) && ~isempty(handles.monkeyInfo.ccm_id)
    set(handles.dbButton,'Enable','on');
else
    set(handles.dbButton,'Enable','off');
end

guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function CCMEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCMEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function USDAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to USDAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of USDAEdit as text
%        str2double(get(hObject,'String')) returns contents of USDAEdit as a double
handles.monkeyInfo.usda_id = get(hObject,'String');

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function USDAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to USDAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpeciesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SpeciesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpeciesEdit as text
%        str2double(get(hObject,'String')) returns contents of SpeciesEdit as a double
handles.monkeyInfo.species = get(hObject,'String');

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function SpeciesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpeciesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dbButton.
function dbButton_Callback(hObject, eventdata, handles)
% hObject    handle to dbButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

add_monkey_cmd(handles.monkeyInfo.name, handles.monkeyInfo.ccm_id,...
    handles.monkeyInfo.species, handles.monkeyInfo.usda_id,...
    handles.connSessions);

closereq
