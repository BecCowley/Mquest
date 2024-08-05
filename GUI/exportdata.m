function varargout = exportdata(varargin)
% EXPORTDATA M-file for exportdata.fig
%      EXPORTDATA, by itself, creates a new EXPORTDATA or raises the existing
%      singleton*.
%
%      H = EXPORTDATA returns the handle to a new EXPORTDATA or the handle to
%      the existing singleton*.
%
%      EXPORTDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTDATA.M with the given input arguments.
%       
%       Example:
%        callsignstring=get(handles.callsigns,'String'); - a list of the
%                   callsigns in the database
%   or: callsignstring='FHZI';
%       centering=1;
%       
%       exportdata('UserData',{centering callsignstring});
%
%       it reads "selectuser.mat" to get all other variables...
%
%      EXPORTDATA('Property','Value',...) creates a new EXPORTDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before exportdata_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to exportdata_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help exportdata

% Last Modified by GUIDE v2.5 02-May-2006 08:56:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exportdata_OpeningFcn, ...
                   'gui_OutputFcn',  @exportdata_OutputFcn, ...
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


% --- Executes just before exportdata is made visible.
function exportdata_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to exportdata (see VARARGIN)

inputdata=get(hObject,'UserData');
callsignstring=inputdata(2);
set(handles.callsigns,'String',['All' callsignstring]);
centervalue=inputdata(1);
set(handles.callsigns,'Value',centervalue{1});
set(handles.callsigns,'ListboxTop',1);
set(handles.startdate,'String','00000000');
set(handles.enddate,'String','99999999');
handles.startdate='00000000';
handles.enddate='99999999';

load selectuser;
u=u ;
p=p ;
m={'All'} ;
y={'All'} ;
q=q ;
a=a; 
tw={1};
sstyle={'ship'};
handles.first=1;

[keysdata2]=getkeys(p,m,y,q,a,tw,sstyle);
handles.keys2=keysdata2;

% Choose default command line output for exportdata
handles.output = -1;

% default xctd extraction
handles.usexctd = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes exportdata wait for user response (see UIRESUME)
 uiwait(handles.exportdata);


% --- Outputs from this function are returned to the command line.
function varargout = exportdata_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in callsigns.
function callsigns_Callback(hObject, eventdata, handles)
% hObject    handle to callsigns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns callsigns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from callsigns

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

callslist=get(handles.callsigns,'String');
callsselected=get(handles.callsigns,'Value');
handles.selectedcallsign=callslist(callsselected);

try
    guidata(hObject, handles);
catch
    guidata(gcbo, handles);
end

% --- Executes during object creation, after setting all properties.
function callsigns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to callsigns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startdate_Callback(hObject, eventdata, handles)
% hObject    handle to startdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startdate as text
%        str2double(get(hObject,'String')) returns contents of startdate as a double

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.startdate=get(hObject,'String');
if(length(handles.startdate)<8)
    errordlg(['error = you must enter 8 characters for the start date'])
end
try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function startdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enddate_Callback(hObject, eventdata, handles)
% hObject    handle to enddate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enddate as text
%        str2double(get(hObject,'String')) returns contents of enddate as a double

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.enddate=get(hObject,'String');
if(length(handles.enddate)<8)
    errordlg(['error = you must enter 8 characters for the end date'])
end

try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end
handles.outputfilename;

% --- Executes during object creation, after setting all properties.
function enddate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enddate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xctds.
function xctds_Callback(hObject, eventdata, handles)
% hObject    handle to xctds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xctds
try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.usexctd=get(handles.xctds,'Value');

try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end


% --- Executes on selection change in exportformat.
function exportformat_Callback(hObject, eventdata, handles)
% hObject    handle to exportformat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns exportformat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exportformat


% --- Executes during object creation, after setting all properties.
function exportformat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportformat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outputfilename_Callback(hObject, eventdata, handles)
% hObject    handle to outputfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputfilename as text
%        str2double(get(hObject,'String')) returns contents of outputfilename as a double

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.outputfile=get(handles.outputfilename,'String');

try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function outputfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in beginexport.
function beginexport_Callback(hObject, eventdata, handles)
% hObject    handle to beginexport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%here is where the hard work is done...
%try to get all thevalues here and not in the individual callbacks:


try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

keysdata2=handles.keys2;
%setup date structure for the callsignsubset required:

callslist=get(handles.callsigns,'String');
callsselected=get(handles.callsigns,'Value');
selectedcallsign=callslist(callsselected);

subsetkeys=strmatch(selectedcallsign,keysdata2.callsign);
%subset for XBTS if no XCTD selected (note, removes CTDs too).
% try
if handles.usexctd == 0
    sk = strmatch('XB',keysdata2.datatype);
    subsetkeys = unique([subsetkeys;sk]);
end
% end
if(~isempty(subsetkeys))
    %create data structure:
    %for i=1:length(subsetkeys)
realdate=(keysdata2.year(subsetkeys)*10000)+(keysdata2.month(subsetkeys)*100)+...
    (keysdata2.day(subsetkeys));
else
    realdate=(keysdata2.year*10000)+(keysdata2.month*100)+(keysdata2.day);
    subsetkeys=1:length(keysdata2.year);
end
reversestartdate=reorderdate(handles.startdate);
   targetstart=str2num(reversestartdate);
   reverseenddate=reorderdate(handles.enddate);
   targetend=str2num(reverseenddate);
   exform=get(handles.exportformat,'Value');
   switch exform
       case 2
           separatecruise
           kk2 = [];
       case 3
           separatecruise_cruiseid
           kk2 = [];
       case 4 %output all data to datn format, seperated by cruiseID
           if ~isempty(strmatch('All',selectedcallsign))
%                extract_box_datn
               separatecruise_cruiseid
               kk2 = [];
           else
               kk2=find(realdate<=targetend & realdate>=targetstart);
           end
       otherwise
           kk2=find(realdate<=targetend & realdate>=targetstart);
   end
   if(~isempty(kk2))
       for i=1:length(kk2)
         ss=keysdata2.stnnum(subsetkeys(kk2(i)),:);
         [profiledata,pd] = readnetcdf(ss);
         
%          readnetcdfforexport
         switch exform
             case 1
%                 c='here MA'
                 disp(ss)
                 writeMA;
             case 4 %output selected data to datn format
%                  c='here REF'
                writeREF
             case 5
                 write2m2decdata;
         end
         if(handles.first)
             handles.first=0;
             try
                 guidata(gcbo,handles);
             catch
                 guidata(hObject,handles);
             end
         end
       end
   end
   
delete(handles.exportdata);
return


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end


delete(handles.exportdata);
return
