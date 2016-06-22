% plotnewprofile:  
%
%  plotnewprofile takes the new handles.currentprofile and redraws
%       the windows that require changes.

%retrieveguidata

if(strcmp(handles.changed,'y') | strcmp(handles.changed,'Y'))
    writenetcdf;
end
try
    pd=handles.pd;
end
keysdata=handles.keys;
handles.ss=keysdata.stnnum(handles.currentprofile); %keysdata.stnnum(i);   %
set(handles.profilenumber,'String',num2str(handles.currentprofile));
handles.menudepth=500.;

%saveguidata

plotprofile;

%setup profile information in static window
if(handles.updateall)
    setprofileinfo;
end
%setup depth/temp listbox

setdepth_tempbox;

%setup and plot waterfall
%axes(handles.waterfall);
setwaterfall;
drawnow

%update the position plots
clearmapposition;
if(handles.updateall)
    updatemap;
end