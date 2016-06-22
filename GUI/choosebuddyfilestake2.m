function varargout = choosebuddyfiles(varargin)
% CHOOSEBUDDYFILES Application M-file for choosebuddyfiles.fig
%   CHOOSEBUDDYFILES, by itself, creates a new CHOOSEBUDDYFILES or raises the existing
%   singleton*.
%
%   H = CHOOSEBUDDYFILES returns the handle to a new CHOOSEBUDDYFILES or the handle to
%   the existing singleton*.
%
%   CHOOSEBUDDYFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in CHOOSEBUDDYFILES.M with the given input arguments.
%
%   CHOOSEBUDDYFILES('Property','Value',...) creates a new CHOOSEBUDDYFILES or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before choosebuddyfiles_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to choosebuddyfiles_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2000-2002 The MathWorks, Inc.

% Edit the above text to modify the response to help choosebuddyfiles

% Last Modified by GUIDE v2.5 24-Aug-2004 10:31:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @choosebuddyfiles_OpeningFcn, ...
                   'gui_OutputFcn',     @choosebuddyfiles_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before choosebuddyfiles is made visible.
function choosebuddyfiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choosebuddyfiles (see VARARGIN)

% Choose default command line output for choosebuddyfiles
handles.output = 'error';

% Update handles structure
guidata(hObject, handles);

if nargin == 3,
    initial_dir = pwd;
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end


% Populate the listbox
load_listbox(initial_dir,handles)
% Return figure handle as first output argument
    
% UIWAIT makes choosebuddyfiles wait for user response (see UIRESUME)
 uiwait(handles.editbuddyfiles);


% --- Outputs from this function are returned to the command line.
function varargout = choosebuddyfiles_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output

% ------------------------------------------------------------
% Callback for list box - open .fig with guide, otherwise use open
% ------------------------------------------------------------
function varargout = listbox1_Callback(h, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

get(handles.editbuddyfiles,'SelectionType');
if strcmp(get(handles.editbuddyfiles,'SelectionType'),'open')
	index_selected = get(handles.listbox1,'Value');
	file_list = get(handles.listbox1,'String');	
	filename = file_list{index_selected};
	if  handles.is_dir(handles.sorted_index(index_selected))
		cd (filename)
		load_listbox(pwd,handles)
	else
	   [path,name,ext,ver] = fileparts(filename);
	   switch ext
	   case '.nc'
		   dir_path=handles.userdata;
           if(ispc)
               newbuddy=[dir_path '\' name]
               handles.output=newbuddy
               guidata(gcbo,handles)  
               uiresume
           else
               newbuddy=[dir_path '/' name];
               handles.output=newbuddy;
               guidata(gcbo,handles);            
               uiresume
           end
           close(handles.editbuddyfiles)
           return
	   otherwise 
			errordlg(lasterr,'File Type Error','modal')
            close(handles.editbuddyfiles)
            return
       end
	 end	
   end

% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(gcbo,handles)
set(handles.listbox1,'String',handles.file_names,...
	'Value',1)
set(handles.text1,'String',pwd)
handles.userdata=dir_path;
guidata(gcbo,handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function editbuddyfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbuddyfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Add the current directory to the path, as the pwd might change thru' the
% gui. Remove the directory from the path when gui is closed 
% (See editbuddyfiles_DeleteFcn)
setappdata(hObject, 'StartPath', pwd);
addpath(pwd);


% --- Executes during object deletion, before destroying properties.
function editbuddyfiles_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to editbuddyfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove the directory added to the path in the editbuddyfiles_CreateFcn.
if isappdata(hObject, 'StartPath')
    rmpath(getappdata(hObject, 'StartPath'));
end


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=[];
guidata(gcbo,handles);
close(handles.editbuddyfiles)
