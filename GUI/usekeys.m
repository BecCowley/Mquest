%check which keys was pressed and deal with it...

%retrieveguidata

key=get(handles.figure1,'CurrentCharacter')
set (handles.keypressed,'String',key);
