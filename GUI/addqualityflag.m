function addqualityflag(qualflag,depthsource,severity)

% function addqualityflag(qualflag,depthsource,severity)
%
% addqualityflag determines the action required for each flag and sets up
% the history section of the profile structure. It also arranges for the
% quality of the data to change, depending on the severity of the flag.
%
% inputs are:
%       qualflag = the 2 character flag being applied to the data (e.g.,
%                       QC, DU, etc.)
%       depthsource = where this flag will be placed.  this is a numeric
%                 code where 
%               `       0 = put at the surface of the profile,
%                       1 = put at the cursor depth,
%                       2 = put at the cursor depth (formerly at a depth from a menu),
%       severity = the quality to be assigned to the parameter data (0-5,9)
%
%   Updated June, 2016 to use new pd structure and matlab netcdf tools.

DECLAREGLOBALS
endpoint=-1;

%retrieveguidata

pd=handles.pd;
handles.changed='Y';
%     clo=datestr(clock,24);
%     update=[clo(1:2) clo(4:5) clo(7:10)];
%As of August, 2014, the format has been changed to yyyymmdd to agree with
%NOAA formats. Bec Cowley
% 2021-02-25, RC. update CSA Handling to flag 3 and not replace with 99.99 temperatures
update = datestr(now,'yyyymmdd');

%extra handling here!  (chopping, filtering, etc).

switch qualflag
    
    case 'CSA'

        if(strmatch('XC',handles.keys.datatype(handles.currentprofile,:)))
            kk=find(pd.depth<=1.9);
        else
            kk=find(pd.depth<=3.6);
        end
        pd.qc(kk)='3';
        nn=pd.numhists:pd.numhists+length(kk);
        for i=1:length(kk)
            histd=pd.depth(kk(i));
            actparm='TEMP';
            oldt=num2str(pd.temp(kk(i)));
            addhistories
        end
        
        if(strmatch('XC',handles.keys.datatype(handles.currentprofile,:)))
            kk=find(pd.depth<=2.9);
            pd.salqc(kk)='3';
            nn=pd.numhists:pd.numhists+length(kk);
            for i=1:length(kk)
                histd=pd.depth(kk(i));
                actparm='PSAL';
                oldt=num2str(pd.sal(kk(i)));
                addhistories
            end
        end
        
        
        handles.pd=pd;
        %saveguidata
        
        
        setdepth_tempbox;
        re_plotprofile;
        sortandsave;
        handles.Qkey='N';
        return
        
    case 'SPA'
        histindex=get(handles.depthdisplay,'Value');
        histdepth=pd.depth(histindex);
        oldt=num2str(pd.temp(get(handles.depthdisplay,'Value')));
        interpolatespikes;
        if(endpoint==-1)
            handles.Qkey='N';
            return
        end
        handles.pd=pd;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'IPA'
        histindex=get(handles.depthdisplay,'Value');
        histdepth=pd.depth(histindex);
        oldt=num2str(pd.temp(get(handles.depthdisplay,'Value')));
        interpolatespikes;
        if(endpoint==-1)
            handles.Qkey='N';
            return
        end
        handles.pd=pd;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'HFA'
        selectionstring=get(handles.depthdisplay,'String');
        qualflag='HF';
        
        %         save selstring.mat selectionstring
        if(depthsource==0)
            centering=1;
        else
            centering=get(handles.depthdisplay,'Value');
        end
        startpoint=centering;
        ch = get(gcbo,'Userdata') ;
        %if key is h alone, filter entire profile:
        if(handles.Qkey=='Y')
            endpoint=launchendindex('UserData',{centering selectionstring qualflag});
            endpoint=min(endpoint,pd.ndep);
            if(endpoint==-1);
                handles.Qkey='N';
                return;
            end
        else
            ptemp=pd.qc;
            gg=strfind(ptemp','5');
            if(isempty(gg))
                gg=0;
            end
            startpoint=gg(end)+1;
            endpoint=pd.ndep;
        end
        
        medianfilter;
        qualflag='HF';
        histd=pd.depth(startpoint);
        actparm='TEMP';
        oldt='99.99';
        severity=5;
        addhistories
        handles.pd=pd;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'WBR'
        
        %remove previous wb flags if present...
        removepreviousflags
        handles.pd=pd;
    case 'PLA'
        % premature launch flag - recorder started before probe entered
        % water. take current cursor position and move everything UP so it
        % corresponds to the first depth (0.67)
        histindex=get(handles.depthdisplay,'Value');
        histd=pd.depth(1);
        oldt=num2str(pd.depth(histindex));
        
        %        pd.depth(1:pd.ndep-histindex+1)=pd.depth(histindex:pd.ndep);
        pd.depth(pd.ndep-histindex+2:pd.ndep)=NaN;
        pd.temp(1:pd.ndep-histindex+1)=pd.temp(histindex:pd.ndep);
        pd.temp(pd.ndep-histindex+2:pd.ndep)=NaN;
        if isfield(pd,'sal')
            pd.sal(1:pd.ndep-histindex+1)=pd.sal(histindex:pd.ndep);
            pd.depthsal(1:pd.ndep-histindex+1)=pd.depthsal(histindex:pd.ndep);
            pd.sal(pd.ndep-histindex+2:profildata.ndep)=NaN;
            pd.depthsal(pd.ndep-histindex+2:pd.ndep)=NaN;
        end
        pd.depth_qc(1:pd.ndep-histindex+1)='2';
        %          pd.depth_qc(pd.ndep-histindex+2:pd.ndep)='';
        pd.qc(1:pd.ndep-histindex+1)=pd.qc(histindex:pd.ndep);
        %          pd.qc(pd.ndep-histindex+2:pd.ndep)='';
        
        pd.qc(pd.ndep-histindex+2:end)=' ';
        pd.depth_qc(pd.ndep-histindex+2:end)=' ';
        pd.ndep=pd.ndep-histindex+1;
        pd.deep_depth=pd.depth(pd.ndep);
        severity = 2;
        actparm='DEPH';
        %         severity=2;
        addhistories
        
        handles.pd=pd;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'PRA'
        % change the probe type, we will elect just to recalculate depths
        %get the old probe type and ask for a new one
        ii = strmatch('PEQ$', pd.surfcode);
        prt = pd.surfparm(ii,:);
        nprt = input('Enter new probe type as number from WMO 1770 probe type table: [default 52] ','s');
        if isempty(nprt)
            nprt = 52;
        else
            nprt = str2num(nprt);
        end
        pd.surfparm(ii,1:3) = num2str(nprt,'%03i');
        [~,dd] = change_probetype(str2num(prt), nprt,pd.temp,[],[],[],[],[]);
        % no change to temperatures in this situation, just have a new set of depths
        pd.depth = dd;
        tqc = str2num(pd.qc);
        ii = tqc<2; %downgrade any class 1 QC value to class 2
        pd.qc(ii) = '2';
        %update the Aux_ID values
        for iupdate = 1:pd.numhists
            [~,im] = min(abs(pd.QC_depth(iupdate) - dd));
            pd.QC_depth(iupdate) = dd(im);
        end
        %update Deep_depth
        pd.deep_depth = max(dd);
        histd = min(pd.depth);
        actparm='DEPH';
        oldt='99.99'; %original probe type is still present in raw file
        severity=2;
        addhistories
        handles.pd=pd;

        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        setprofileinfo;
        handles.Qkey='N';
        return

    case 'PEA'
        %        changeposition - launch the gui to allow input of the new
        %        position:
        keysdata=handles.keys;
        if(keysdata.map180)
            [outputs]=changeposition('UserData',...
                [pd.latitude,keysdata.lon180(handles.currentprofile)]);
        else
            [outputs]=changeposition('UserData',...
                [pd.latitude,pd.longitude]);
        end
        
        handles.lastprofile=handles.currentprofile;
        histd=max(pd.depth(1),0.0);
        pd.pos_qc=num2str(5);
        difflat=abs(outputs.origlat-outputs.newlat);
        %        if(outputs.origlat~=outputs.newlat)
        if(difflat>0.002)
            pd.latitude=outputs.newlat;
            oldt=num2str(outputs.origlat);
            actparm=outputs.parmlat;
            addhistories
            %update the map - get rid of the old position...
            gg=plot(outputs.origlon,outputs.origlat,'kx');
            set(gg,'MarkerSize',14);
            set(gg,'LineWidth',2);
            %you must also change the keys file!!!
            keysdata.obslat(handles.currentprofile)=outputs.newlat;
            
            handles.pd=pd;
            handles.keys=keysdata;
            
            %saveguidata
            
            updatekeys('obslat',keysdata.masterrecno(handles.currentprofile),...
                outputs.newlat,keysdata.prefix);
        end
        difflon=abs(outputs.origlon-outputs.newlon);
        if(difflon>.002)
            %        if(outputs.origlon~=outputs.newlon)
            oldt=num2str(pd.longitude);
            if(keysdata.map180 & outputs.newlon<0)
                pd.longitude=360+outputs.newlon;
                keysdata.lon180(handles.currentprofile)=outputs.newlon;
            else
                pd.longitude=outputs.newlon;
            end
            actparm=outputs.parmlon;
            addhistories
            %update the map - get rid of the old position...
            gg=plot(outputs.origlon,outputs.origlat,'kx');
            
            set(gg,'MarkerSize',14);
            set(gg,'LineWidth',2);
            
            %            c= mod(720-outputs.newlon,360);
            %you must also change the keys file!!!
            keysdata.obslon(handles.currentprofile)=pd.longitude;
            
            handles.pd=pd;
            handles.keys=keysdata;
            
            %saveguidata
            
            updatekeys('obslng',keysdata.masterrecno(handles.currentprofile),...
                pd.longitude,keysdata.prefix);
            
            updatekeys('c360long',keysdata.masterrecno(handles.currentprofile),...
                pd.longitude,keysdata.prefix);
        end
        
        handles.pd=pd;
        handles.keys=keysdata;
        
        %saveguidata
        
        plotmap
        %setup profile information in static window, update waterfall list
        addwaterfallinfo
        setprofileinfo
        plotnewprofile
        sortandsave;
        handles.Qkey='N';
        return
    case 'TEA'
        %        changetime - launch the gui to allow imput of the new date or time:
        [outputs]=changedatetime('UserData',...
            [pd.year,pd.month,...
            pd.day,pd.time]);
        keysdata=handles.keys;
        handles.lastprofile=handles.currentprofile;
        histd=max(pd.depth(1),0.0);
        pd.juld_qc=num2str(5);
        olddate=(str2num(pd.year)*10000)+(str2num(pd.month)*100)...
            +str2num(pd.day);
        newdate=(str2num(outputs.newyear)*10000)+(str2num(outputs.newmonth)*100)...
            +str2num(outputs.newdate);
        st=strfind(outputs.newtime,':');
        if(~isempty(st))
            nt=outputs.newtime;
            nt(st)=[];
            newtime=str2num(nt);
            keytime=nt;
        else
            newtime=str2num(outputs.newtime);
            keytime=outputs.newtime;
        end
        
        st=strfind(outputs.origtime,':');
        if(~isempty(st))
            nt=outputs.origtime;
            nt(st)=[];
            oldtime=str2num(nt);
        else
            oldtime=str2num(outputs.origtime);
        end
        if(isempty(oldtime))
            oldtime=0;
        end
        difftime=abs(oldtime-newtime);
        if(difftime>1)
            %        if(oldtime~=newtime)
            pd.time=outputs.newtime;
            oldt=outputs.origtime;
            actparm='TIME';
            addhistories
            %you must also change the keys file!!!
            % HHMM format for keys
            keysdata.time(handles.currentprofile)=str2num(keytime(1:4));
            
            handles.pd=pd;
            handles.keys=keysdata;
            
            %saveguidata
            
            updatekeys('obs_t',keysdata.masterrecno(handles.currentprofile),...
                keytime(1:4),keysdata.prefix);
        end
        
        diffdate=abs(olddate-newdate);
        if(diffdate>=1)
            %        if(olddate~=newdate)
            pd.day=outputs.newdate;
            pd.month=outputs.newmonth;
            pd.year=outputs.newyear;
            
            oldt=num2str(olddate);
            actparm='DATE';
            addhistories
            %you must also change the keys file!!!
            
            if(~strcmp(outputs.newyear,outputs.origyear))
                keysdata.year(handles.currentprofile)=str2num(outputs.newyear);
                
                handles.pd=pd;
                handles.keys=keysdata;
                %saveguidata
                updatekeys('obs_y',keysdata.masterrecno(handles.currentprofile),...
                    outputs.newyear,keysdata.prefix);
            end
            
            if(~strcmp(outputs.newmonth,outputs.origmonth))
                
                keysdata.month(handles.currentprofile)=str2num(outputs.newmonth);
                handles.pd=pd;
                handles.keys=keysdata;
                
                %saveguidata
                
                
                updatekeys('obs_m',keysdata.masterrecno(handles.currentprofile),...
                    outputs.newmonth,keysdata.prefix);
            end
            
            if(~strcmp(outputs.newdate,outputs.origdate))
                keysdata.day(handles.currentprofile,:)=str2num(outputs.newdate);
                
                handles.pd=pd;
                handles.keys=keysdata;
                %saveguidata
                
                
                updatekeys('obs_d',keysdata.masterrecno(handles.currentprofile),...
                    outputs.newdate,keysdata.prefix);
            end
            
        end
        
        %saveguidata
        
        
        %setup profile information in static window
        addwaterfallinfo
        plotnewprofile
        setprofileinfo;
        sortandsave;
        handles.Qkey='N';
        return
        
end

if(depthsource==0)     %put flag at surface
    histdepth=max(pd.depth(1),0.0);
    oldt=num2str(pd.temp(1));
end

if(depthsource==10)   %put flag at 10m (CTR)
    histdepth=max(pd.depth(1),10.0);
    oldt=num2str(pd.temp(1));
end
if(depthsource==3);   %put the flag at the end of the valid data
    histdepth=[];
    d=diff(pd.temp);
    try
        d=[0 d(1:end)'];
        jj=find(pd.temp>-2.4 & pd.temp < 31.9 & d'<=0.1);
    catch
        d=[0 d(1:end)];
        jj=find(pd.temp>-2.4 & pd.temp < 31.9 & d<=0.1);
    end
    % d(end+1)=d(end);
    try
%     if(~isempty(jj) & ~isnan(pd.temp(jj(end)+1)))
        histdepth=pd.depth(jj(end)+1);
        oldt=num2str(pd.temp(jj(end)+1));
%     else
    catch
        %no appropriate point found:
        handles.Qkey='N';
        return
    end
end

if(depthsource==2 | depthsource==1)   %put flag at cursor point
    histindex=get(handles.depthdisplay,'Value');
    histdepth=pd.depth(histindex);
    oldt=num2str(pd.temp(get(handles.depthdisplay,'Value')));
end

if(isempty(histdepth))
    handles.Qkey='N';
    return
end

histd=histdepth;

if(strmatch(qualflag(1:3),'PER'))
    actparm='LALO';
    pd.pos_qc=num2str(severity);
    addhistories
    
elseif(strmatch(qualflag(1:3),'TER'))
    pd.juld_qc=num2str(severity);
    actparm='DATI';
    addhistories;
    
else
    actparm='TEMP';
    addhistories
end


handles.pd=pd;

%saveguidata

%re_plotprofile

sortandsave;
printqflags


handles.Qkey='N';

