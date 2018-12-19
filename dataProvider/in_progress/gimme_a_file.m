function varargout = gimme_a_file(varargin)
% GIMME_A_FILE MATLAB code for gimme_a_file.fig
%      GIMME_A_FILE, by itself, creates a new GIMME_A_FILE or raises the existing
%      singleton*.
%
%      H = GIMME_A_FILE returns the handle to a new GIMME_A_FILE or the handle to
%      the existing singleton*.
%
%      GIMME_A_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GIMME_A_FILE.M with the given input arguments.
%
%      GIMME_A_FILE('Property','Value',...) creates a new GIMME_A_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gimme_a_file_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gimme_a_file_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gimme_a_file

% Last Modified by GUIDE v2.5 05-Oct-2018 14:29:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gimme_a_file_OpeningFcn, ...
                   'gui_OutputFcn',  @gimme_a_file_OutputFcn, ...
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


% --- Executes just before gimme_a_file is made visible.
function gimme_a_file_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gimme_a_file (see VARARGIN)

% Choose default command line output for gimme_a_file
handles.output = hObject;


if ~isfield(handles,'connSessions')
    handles.connSessions = LLSessionsDB_connector;
end


handles.searchFields = {'Number of Results','Monkey Name','CCM ID','Task Name',...
    'Task Description','Implant Location','Array Type','Recording Date',...
    'Array Type','Recording Date','Behavior Quality','Lab Number',...
    'Recording Duration','Num. of Channels','Has Triggers','Has Chaotic Load',...
    'Has Bumps','Num. of Trials','Num. Rewards','Num. Aborts','Num. Failures',...
    'Num. Incomplete','Spike Quality','Has EMGs','EMG Quality','Has Kinematics',...
    'Kin. Quality'};

handles.psqlFields = {'numResults','monkey_name','ccm_id','task_name',...
    'task_description','implant_location','array_type','rec_date',...
    'behavior_quality','lab_num','duration','numChannels','hasTriggers',...
    'hasChaoticLoad','hasBumps','numTrials','numReward','numAbort',...
    'numIncomplete','hasEMGs','EMGQuality','spikeQuality','hasKin',...
    'kinQuality'};


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gimme_a_file wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gimme_a_file_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in search_term_menu.
function search_term_menu_Callback(hObject, eventdata, handles)
% hObject    handle to search_term_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns search_term_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from search_term_menu


% --- Executes during object creation, after setting all properties.
function search_term_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search_term_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_field_button.
function add_field_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_field_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in search_button.
function search_button_Callback(hObject, eventdata, handles)
% hObject    handle to search_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
