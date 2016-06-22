function  addbuddyfiles(varargin)
% ADDBUDDYFILES M-file for addbuddyfiles.fig
%
% Addbuddyfiles creates a gui for selection of new buddy files for use by
%   the current version of Mquest.  To add a buddy file, click on the "keys" 
%   file of the database you require. If you wish to change directory to
%   find another database, click on the directory name and you will see a new 
%   directory list of all the databases and directories in the new location.  
%
%    NOTE: the original database will always be used as a buddy.
%       
%
%      ADDBUDDYFILES, by itself, creates a new ADDBUDDYFILES or raises the existing
%      singleton*.
%
%      H = ADDBUDDYFILES returns the handle to a new ADDBUDDYFILES or the handle to
%      the existing singleton*.
%
%
%   addbuddyfiles creates the gui to allow you to specify which databases
%       should be used as buddies for the current versoin of Mquest.  This can
%        be changed at will but 
%
% Last Modified by GUIDE v2.5 04-Oct-2005 03:04:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addbuddyfiles_OpeningFcn, ...
                   'gui_OutputFcn',  @addbuddyfiles_OutputFcn, ...
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


% --- Executes just before addbuddyfiles is made visible.
function addbuddyfiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addbuddyfiles (see VARARGIN)

% Choose default command line output for addbuddyfiles
handles.output = hObject;

% Populate the listbox
    initial_dir = pwd;
load_listbox(initial_dir,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes addbuddyfiles wait for user response (see UIRESUME)
 uiwait(handles.buddyfiles);


% --- Outputs from this function are returned to the command line.
%function varargout = addbuddyfiles_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

    uiresume(handles.buddyfiles);
	index_selected = get(handles.listbox1,'Value');
	file_list = get(handles.listbox1,'String');	
	filename = file_list{index_selected};

	if  handles.is_dir(handles.sorted_index(index_selected))
		cd (filename);
		load_listbox(pwd,handles);
	else
	   [path,name,ext,ver] = fileparts(filename);
	   switch ext
	   case '.nc'
           dir_path=handles.userdata;
           if(ispc)
               newbuddy=[dir_path '\' name];
               handles.output=newbuddy;
           else
               newbuddy=[dir_path '/' name];
               handles.output=newbuddy;
           end
           guidata(gcbo,handles);
               close(handles.buddyfiles);
       otherwise          
          lasterr;
	      errordlg(lasterr,'File Type Error','modal') ;              
       end
    end
               
% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=[];
close(handles.buddyfiles);

% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path);
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(gcbo,handles);
set(handles.listbox1,'String',handles.file_names,...
	'Value',1);
set(handles.text1,'String',pwd);
handles.userdata=dir_path;
guidata(gcbo,handles);

