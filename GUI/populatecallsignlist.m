%populatecallsignlist
%take callsigns from getkeys and set up callsign selection box


try
    ucall=unique(keysdata.callsign,'rows');
catch
    [keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
    ucall=unique(keysdata.callsign,'rows');
end
set(handles.callsigns,'String',ucall);

%saveguidata
