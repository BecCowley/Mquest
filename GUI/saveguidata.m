
savehandles=handles;
if(strmatch('handles',handles))
    stopherefirst=1
end

try
    guidata(gcbo,handles);    
catch
    guidata(hObject,handles);
end
