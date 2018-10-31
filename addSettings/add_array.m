function varargout = add_array(varargin)
% ADD_ARRAY MATLAB code for add_array.fig
%      ADD_ARRAY, by itself, creates a new ADD_ARRAY or raises the existing
%      singleton*.
%
%      H = ADD_ARRAY returns the handle to a new ADD_ARRAY or the handle to
%      the existing singleton*.
%
%      ADD_ARRAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADD_ARRAY.M with the given input arguments.
%
%      ADD_ARRAY('Property','Value',...) creates a new ADD_ARRAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before add_array_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to add_array_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help add_array

% Last Modified by GUIDE v2.5 04-Oct-2018 11:27:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @add_array_OpeningFcn, ...
                   'gui_OutputFcn',  @add_array_OutputFcn, ...
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


% --- Executes just before add_array is made visible.
function add_array_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to add_array (see VARARGIN)

% Choose default command line output for add_array
handles.output = hObject;

% if there's a handle already open we don't want to reconnect to the
% database
if ~isfield(handles,'connSessions');
    handles.connSessions = LLSessionsDB_connector;
end


% ------------------------------------------------------------------------
% I have to do everything with the monkey names here, because the "handles"
% handle is the last thing to be created (after all of the other create_fcn),
% and I don't want to have multiple connections to the server hanging about.
%
% get the list of monkey names from the server
sqlquery = ['SELECT name, ccm_id FROM general_info.monkeys ORDER BY name;']; % get the monkey names 
try
    curs = exec(handles.connSessions,sqlquery); % try to execute the SQL statement, otherwise throw a (mild) fit
    fetch(curs);
catch ME
    rethrow(ME);
end

% get the monkey names concatenated with the ccm_ID numbers
monkeyNames = cell(1+size(curs.Data,1),1);
monkeyNames{1} = ''; % before selecting the monkey name
handles.ccm_IDs = curs.Data(:,2);
for ii = 1:length(monkeyNames)-1
    monkeyNames{ii+1} = strjoin(curs.Data(ii,:),', '); % join 'em
end

handles.ccm_id_menu.String = strjoin(monkeyNames,'\n');


% ------------------------------------------------------------------------
% Here's everything for the array types
sqlquery = ['SELECT at.type FROM general_info.array_types as at;'];
try
    curs = exec(handles.connSessions,sqlquery); % try to execute the SQL statement, otherwise throw a (mild) fit
    fetch(curs);
catch ME
    rethrow(ME);
end

handles.array_type_menu.String = strjoin({'',curs.Data{:}},'\n');

% ------------------------------------------------------------------------
% creating the array_options structure for the purpose of entering into the
% function
% starting with only the required things, keeping it empty
handles.array_info = struct('serial',{},'ccm_id',{},'implant_date',{},...
    'implant_location',{},'map_file',{});
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes add_array wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = add_array_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_array_button.
function add_array_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_array_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_array_cmd(handles.array_info,handles.connSessions); % run the function
closereq % close everything



function electrode_length_edit_Callback(hObject, eventdata, handles)
% hObject    handle to electrode_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of electrode_length_edit as text
%        str2double(get(hObject,'String')) returns contents of electrode_length_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'electrode_length')
        handles.array_info = rmfield(handles.array_info,'electrode_length');
    end        
else
    handles.array_info(1).electrode_length = response;
end
guidata(hObject,handles);
    



% --- Executes during object creation, after setting all properties.
function electrode_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lead_length_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lead_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lead_length_edit as text
%        str2double(get(hObject,'String')) returns contents of lead_length_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'lead_length')
        handles.array_info = rmfield(handles.array_info,'lead_length');
    end        
else
    handles.array_info(1).lead_length = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function lead_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lead_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function removal_date_edit_Callback(hObject, eventdata, handles)
% hObject    handle to removal_date_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of removal_date_edit as text
%        str2double(get(hObject,'String')) returns contents of removal_date_edit as a double
response = datestr(get(hObject,'String'));
if isnan(response) % if it's not a date, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'removal_date')
        handles.array_info = rmfield(handles.array_info,'removal_date');
    end        
else
    handles.array_info(1).removal_date = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function removal_date_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to removal_date_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ccm_id_menu.
function ccm_id_menu_Callback(hObject, eventdata, handles)
% hObject    handle to ccm_id_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ccm_id_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ccm_id_menu
if get(hObject,'Value') == 1
    handles.array_info(1).ccm_id = '';
else
    handles.array_info(1).ccm_id = handles.ccm_IDs{get(hObject,'Value')-1}; % if it's blank it will still read as empty
end

% check to see whether everything has been entered properly
if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

% save it all
guidata(hObject,handles);





% --- Executes during object creation, after setting all properties.
function ccm_id_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ccm_id_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in array_type_menu.
function array_type_menu_Callback(hObject, eventdata, handles)
% hObject    handle to array_type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns array_type_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from array_type_menu
contents = cellstr(get(hObject,'String'));
handles.array_info(1).array_type = contents{get(hObject,'Value')}; % if it's blank it will still read as empty

% check to see whether everything has been entered properly
if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

% save it all
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function array_type_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function serial_edit_Callback(hObject, eventdata, handles)
% hObject    handle to serial_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of serial_edit as text
%        str2double(get(hObject,'String')) returns contents of serial_edit as a double
handles.array_info(1).serial = get(hObject,'String');

% check to see whether everything has been entered properly
if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

% save it all
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function serial_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to serial_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function implant_date_edit_Callback(hObject, eventdata, handles)
% hObject    handle to implant_date_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of implant_date_edit as text
%        str2double(get(hObject,'String')) returns contents of implant_date_edit as a double
handles.array_info(1).implant_date = datestr(get(hObject,'String'));

% check to see whether everything has been entered properly
if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

% save it all
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function implant_date_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to implant_date_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function implant_location_edit_Callback(hObject, eventdata, handles)
% hObject    handle to implant_location_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of implant_location_edit as text
%        str2double(get(hObject,'String')) returns contents of implant_location_edit as a double
handles.array_info(1).implant_location = get(hObject,'String');

% check to see whether everything has been entered properly
if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

% save it all
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function implant_location_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to implant_location_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function map_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to map_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of map_file_edit as text
%        str2double(get(hObject,'String')) returns contents of map_file_edit as a double
response = get(hObject,'String');
if exist(response,'file')
    handles.array_info(1).map_file = response;
else
    handles.array_info(1).map_file = {};
end

% check to see whether everything has been entered properly
if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

% save it all
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function map_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to map_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in map_file_button.
function map_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to map_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[respFile,respPath,~] = uigetfile(['*.cmp'],'Select the associated map file');

if respFile == 0
    fullPath = '';
else
    fullPath = [respPath,respFile];
end

handles.map_file_edit.String = fullPath;
handles.array_info(1).map_file = fullPath;

if reqd_options(handles)
    handles.add_array_button.Enable = 'on';
else
    handles.add_array_button.Enable = 'off';
end

guidata(hObject,handles)
    




function crani_anterior_edit_Callback(hObject, eventdata, handles)
% hObject    handle to crani_anterior_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crani_anterior_edit as text
%        str2double(get(hObject,'String')) returns contents of crani_anterior_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'crani_anterior')
        handles.array_info = rmfield(handles.array_info,'crani_anterior');
    end        
else
    handles.array_info(1).crani_anterior = response;
end
guidata(hObject,handles);






% --- Executes during object creation, after setting all properties.
function crani_anterior_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crani_anterior_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function crani_posterior_edit_Callback(hObject, eventdata, handles)
% hObject    handle to crani_posterior_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crani_posterior_edit as text
%        str2double(get(hObject,'String')) returns contents of crani_posterior_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'crani_posterior')
        handles.array_info = rmfield(handles.array_info,'crani_posterior');
    end        
else
    handles.array_info(1).crani_posterior = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function crani_posterior_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crani_posterior_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function crani_medial_edit_Callback(hObject, eventdata, handles)
% hObject    handle to crani_medial_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crani_medial_edit as text
%        str2double(get(hObject,'String')) returns contents of crani_medial_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'crani_medial')
        handles.array_info = rmfield(handles.array_info,'crani_medial');
    end        
else
    handles.array_info(1).crani_medial = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function crani_medial_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crani_medial_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function crani_lateral_edit_Callback(hObject, eventdata, handles)
% hObject    handle to crani_lateral_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of crani_lateral_edit as text
%        str2double(get(hObject,'String')) returns contents of crani_lateral_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'crani_lateral')
        handles.array_info = rmfield(handles.array_info,'crani_lateral');
    end        
else
    handles.array_info(1).crani_lateral = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function crani_lateral_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to crani_lateral_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function loc_AP_edit_Callback(hObject, eventdata, handles)
% hObject    handle to loc_AP_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loc_AP_edit as text
%        str2double(get(hObject,'String')) returns contents of loc_AP_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'loc_AP')
        handles.array_info = rmfield(handles.array_info,'loc_AP');
    end        
else
    handles.array_info(1).loc_AP = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function loc_AP_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loc_AP_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function loc_ML_edit_Callback(hObject, eventdata, handles)
% hObject    handle to loc_ML_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loc_ML_edit as text
%        str2double(get(hObject,'String')) returns contents of loc_ML_edit as a double
response = str2double(get(hObject,'String'));
if isnan(response) % if it's not a number, reject. Otherwise, save it.
    set(hObject,'String','');
    if isfield(handles.array_info,'loc_ML')
        handles.array_info = rmfield(handles.array_info,'loc_ML');
    end        
else
    handles.array_info(1).loc_ML = response;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function loc_ML_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loc_ML_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Check to make sure all of the required fields are filled out
function properFilled = reqd_options(handles)
    properFilled = ~any(structfun(@(x) isempty(x),handles.array_info)); % if none of them are empty, we assume it's all good.


