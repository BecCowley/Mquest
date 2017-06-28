    if(qualf(3)=='A')
        cc=get(handles.acceptcodes,'String');
    else
        cc=get(handles.rejectcodes,'String');
    end
    cc2=strmatch(qualf(1:3),cc,'exact');
    if(isempty(cc2))
        erro=qualf;
        cc=cc;
%        errordlg('This flag is invalid!!!') ;
        handles.Qkey='N';
            
        %saveguidata

        return
    end
    if(qualf(3)=='A')
        placement=handles.acceptplace(cc2);
        severity=handles.acceptlevel(cc2);
    else
        placement=handles.rejectplace(cc2);
        severity=handles.rejectlevel(cc2);
    end  
    if(handles.Qkey=='Y')
        if exist('ch','var') == 1
            if(strmatch(ch,'2'))
                placement=0;
            end
        end
    end
    if(strmatch(qualf,'NON'))
        erro=qualf;
%        errordlg([ 'This flag is invalid!!!' erro]) 
        handles.Qkey='N';
            
        %saveguidata

        return
    end

    
%    handles.Qkey='N';
            
    %saveguidata
    axes(handles.profile)
    addqualityflag(qualf,placement,severity);
