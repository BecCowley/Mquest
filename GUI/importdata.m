function varargout = importdata(varargin)
% IMPORTDATA M-file for importdata.fig
%      IMPORTDATA, by itself, creates a new IMPORTDATA or raises the existing
%      singleton*.
%
%      H = IMPORTDATA returns the handle to a new IMPORTDATA or the handle to
%      the existing singleton*.
%
%      IMPORTDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTDATA.M with the given input arguments.
%
%      IMPORTDATA('Property','Value',...) creates a new IMPORTDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before importdata_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to importdata_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help importdata

% Last Modified by GUIDE v2.5 24-May-2006 11:26:33

global waiting

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importdata_OpeningFcn, ...
                   'gui_OutputFcn',  @importdata_OutputFcn, ...
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


% --- Executes just before importdata is made visible.
function importdata_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to importdata (see VARARGIN)


inputdata=get(hObject,'UserData');
handles.currentdir=inputdata{2};
handles.currentprefix=inputdata{1};
handles.databaseprefix=inputdata{1};
handles.usecurrentdatabase=0;
%quotaquest=inputdata{3};
currdir=handles.currentdir;
a=dir(currdir);
handles.databasedir=currdir;

%grab the keys files and directories in this current directory
ii = 2;
directorylist(1)={'new'};
for i=1:size(a,1)
    %keys files
    isinput=strfind(a(i).name,'.MA');
    isdatabase=strfind(a(i).name,'keys.nc');
    if(~isempty(isdatabase)) 
        directorylist{ii} = a(i).name;
        isdir(ii) = 0;
        ii = ii+1;
    elseif ~isempty(isinput)
        %ma files
        directorylist{ii}=a(i).name;
        isdir(ii)=0;
        ii = ii+1;
    elseif a(i).isdir
        if(ispc)
            directorylist{ii}=[a(i).name '\'];
        else
            directorylist{ii}=[a(i).name '/'];
        end
        isdir(ii)=1;
        ii = ii+1;
    end
    suff{i} = a(i).name;
end

handles.isdir=isdir;
%set(handles.databaseprefix,'String',directorylist,'Value',1);
handles.suff=suff;
handles.inputdatadir=pwd;

inputfiles=directorylist;
inputfiles(1)={'   '};
handles.directorylength=length(directorylist);

set(handles.inputdata,'String',inputfiles,'Value',1);


% Choose default command line output for importdata
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes importdata wait for user response (see UIRESUME)
 uiwait(handles.importdata);


% --- Outputs from this function are returned to the command line.
function varargout = importdata_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



function inputdata_Callback(hObject, eventdata, handles)
% hObject    handle to inputdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputdata as text
%        str2double(get(hObject,'String')) returns contents of inputdata as a double

%Treat as for database selection - with directory listings!!!;

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end


if strcmp(get(handles.importdata,'SelectionType'),'open') % If double click
    index_selected = get(handles.inputdata,'Value');
    file_list = get(handles.inputdata,'String');
    filename =[ file_list{index_selected} ]; % Item selected in list box
    if  handles.isdir(index_selected) % If directory
        handles.inputdatadir=[handles.inputdatadir '/' filename];
    %cd (filename)
        input=1;
        listdir % Load list box with new directory
    end
end

try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function inputdata_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in inputformats.
function inputformats_Callback(hObject, eventdata, handles)
% hObject    handle to inputformats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns inputformats contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inputformats


try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end
suff=handles.suff;
dataforms=get(handles.inputformats,'Value');
    switch dataforms
        case 2        

            for i=1:length(suff)
                isinput=strfind(suff(i),'.MA');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
            
        case 1
 
            usethis=0;
            
        case 3 %MK21 data from the RAN
             usethis=0;
        case 4
            
            usethis=0;
            
        case 5
            
            usethis=0;
            
        case 6
            
            for i=1:length(suff)
                isinput=strfind(suff(i),'.txt');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
        case 7 %TSK data
            usethis=0;
        case 8
            for i=1:length(suff)
                isinput=strfind(suff(i),'.nc');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
        case 9 %Mk12 data
            for i=1:length(suff)
                isinput=strfind(suff(i),'.EDF');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
            
        case 10 %WOD csv data
            for i=1:length(suff)
                isinput=strfind(suff(i),'.csv');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
            
    end

kkin=find(usethis==1);

holdlist=get(handles.inputdata,'String');
clear inputfiles

inputfiles=holdlist(1:handles.directorylength);
i=handles.directorylength;
for j=1:length(kkin)
    i=i+1;
    inputfiles(i)=suff(kkin(j));
end

if(~isempty(inputfiles))
    set(handles.inputdata,'String',inputfiles,'Value',1);
end
try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end
          

% --- Executes during object creation, after setting all properties.
function inputformats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputformats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in startimport.
function startimport_Callback(hObject, eventdata, handles)
% hObject    handle to startimport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%depending on the format chosen, get the input data file name, the output
%file name, and the gtspp_uniq_id, read the input data and place within the
%database.  If the database chosen is "new", create the keys file, then
%proceed...

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

%waiting=1;

    index_selected = get(handles.inputdata,'Value');
    file_list = get(handles.inputdata,'String');
    filename = file_list{index_selected}; % Item selected in list box
    if(ispc)
        inputdata=[handles.inputdatadir '\' filename];
    else
        inputdata=[handles.inputdatadir '/' filename];
    end
    clear findex_selected
    clear file_list
    clear filename
%    index_selected =(handles.databaseprefix,'Value');
%    file_list = get(handles.databaseprefix,'String');
if(iscell(handles.databaseprefix))
    filename = handles.databaseprefix{1}; % Item selected in list box
else
    filename = handles.databaseprefix;
end
    if(ispc)    
        slash=strfind(filename,'\');
    else
        slash=strfind(filename,'/');
    end
    if(isempty(slash));slash=length(filename)+1;end
    origdir=pwd;
    newdir=handles.databasedir;
    findrelativepath
    if(ispc)
        outputdata=[relpath '\' filename(1:slash-1)];
    else
        outputdata=[relpath '/' filename(1:slash-1)];
    end
    
    dataforms=get(handles.inputformats,'Value');
%    load uniqueid.mat
%while waiting    
    switch dataforms
        case 2        

            inputMA(inputdata,outputdata)
            
        case 1

            inputDEVIL(inputdata,outputdata)
 
        case 4
            
            inputMK21(inputdata,outputdata,0)
            
        case 5
            
            inputSCRIPPSdata(inputdata,outputdata)
            
        case 6
            
            inputRTQC(inputdata,outputdata)
            
        case 7
            inputTSK(inputdata,outputdata)
        case 8
% disabled until it can be properly tested. Bec, 13 September, 2012
            inputMQNC(inputdata,outputdata)
        case 3
            inputMK21(inputdata,outputdata,1)
            
        case 9
            inputMK12(inputdata,outputdata)
        case 10
            inputWODcsv(inputdata,outputdata)
    end
%end       

%close the gui:
waiting=0;
uiresume
delete(handles.importdata);

% now this is the tricky part - close Mquest and restart it!!!

%delete(QuotaQuest);
QuotaQuest;


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

uiresume
close(handles.importdata);
%delete(handles.importdata);
QuotaQuest

return

