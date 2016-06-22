try
    retrievehandlesfirst=handles;
end
try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

retrievehandles=handles;
if(strmatch('handles',handles))
    stophere=1
end
