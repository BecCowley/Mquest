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

DECLAREGLOBALS
endpoint=-1;

%retrieveguidata

profiledata=handles.profile_data;
handles.changed='Y';
%     clo=datestr(clock,24);
%     update=[clo(1:2) clo(4:5) clo(7:10)];
%As of August, 2014, the format has been changed to yyyymmdd to agree with
%NOAA formats. Bec Cowley
update = datestr(now,'yyyymmdd');

%extra handling here!  (chopping, filtering, etc).

switch qualflag
    
    case 'CSA'
        
        if(strmatch('XC',handles.keys.datatype(handles.currentprofile,:)))
            kk=find(profiledata.depth<=1.9);
        else
            kk=find(profiledata.depth<=3.6);
        end
        profiledata.qc(kk)='5';
        nn=profiledata.numhists:profiledata.numhists+length(kk);
        for i=1:length(kk)
            histd=profiledata.depth(kk(i));
            actparm='TEMP';
            oldt=num2str(profiledata.temp(kk(i)));
            addhistories
        end
        profiledata.temp(kk)=99.99;
        
        if(strmatch('XC',handles.keys.datatype(handles.currentprofile,:)))
            kk=find(profiledata.depth<=2.9);
            profiledata.salqc(kk)='5';
            nn=profiledata.numhists:profiledata.numhists+length(kk);
            for i=1:length(kk)
                histd=profiledata.depth(kk(i));
                actparm='PSAL';
                oldt=num2str(profiledata.sal(kk(i)));
                addhistories
            end
            profiledata.sal(kk)=99.99;
        end
        
        
        handles.profile_data=profiledata;
        %saveguidata
        
        
        setdepth_tempbox;
        re_plotprofile;
        sortandsave;
        handles.Qkey='N';
        return
        
    case 'SPA'
        histindex=get(handles.depthdisplay,'Value');
        histdepth=profiledata.depth(histindex);
        oldt=num2str(profiledata.temp(get(handles.depthdisplay,'Value')));
        interpolatespikes;
        if(endpoint==-1)
            handles.Qkey='N';
            return
        end
        handles.profile_data=profiledata;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'IPA'
        histindex=get(handles.depthdisplay,'Value');
        histdepth=profiledata.depth(histindex);
        oldt=num2str(profiledata.temp(get(handles.depthdisplay,'Value')));
        interpolatespikes;
        if(endpoint==-1)
            handles.Qkey='N';
            return
        end
        handles.profile_data=profiledata;
        
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
            endpoint=min(endpoint,profiledata.ndep);
            if(endpoint==-1);
                handles.Qkey='N';
                return;
            end
        else
            ptemp=profiledata.qc;
            gg=strfind(ptemp,'5');
            if(isempty(gg))
                gg=0;
            end
            startpoint=gg(end)+1;
            endpoint=profiledata.ndep;
        end
        
        medianfilter;
        qualflag='HF';
        histd=profiledata.depth(startpoint);
        actparm='TEMP';
        oldt='99.99';
        severity=2;
        addhistories
        handles.profile_data=profiledata;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'WBR'
        
        %remove previous wb flags if present...
        removepreviousflags
        handles.profile_data=profiledata;
    case 'PLA'
        % premature launch flag - recorder started before probe entered
        % water. take current cursor position and move everything UP so it
        % corresponds to the first depth (0.67)
        histindex=get(handles.depthdisplay,'Value');
        histd=profiledata.depth(1);
        oldt=num2str(profiledata.depth(histindex));
        
        %        profiledata.depth(1:profiledata.ndep-histindex+1)=profiledata.depth(histindex:profiledata.ndep);
        profiledata.depth(profiledata.ndep-histindex+2:profiledata.ndep)=NaN;
        profiledata.temp(1:profiledata.ndep-histindex+1)=profiledata.temp(histindex:profiledata.ndep);
        profiledata.temp(profiledata.ndep-histindex+2:profiledata.ndep)=NaN;
        if isfield(profiledata,'sal')
            profiledata.sal(1:profiledata.ndep-histindex+1)=profiledata.sal(histindex:profiledata.ndep);
            profiledata.depthsal(1:profiledata.ndep-histindex+1)=profiledata.depthsal(histindex:profiledata.ndep);
            profiledata.sal(profiledata.ndep-histindex+2:profildata.ndep)=NaN;
            profiledata.depthsal(profiledata.ndep-histindex+2:profiledata.ndep)=NaN;
        end
        profiledata.depth_qc(1:profiledata.ndep-histindex+1)='2';
        %          profiledata.depth_qc(profiledata.ndep-histindex+2:profiledata.ndep)='';
        profiledata.qc(1:profiledata.ndep-histindex+1)=profiledata.qc(histindex:profiledata.ndep);
        %          profiledata.qc(profiledata.ndep-histindex+2:profiledata.ndep)='';
        
        profiledata.qc(profiledata.ndep-histindex+2:end)=' ';
        profiledata.depth_qc(profiledata.ndep-histindex+2:end)=' ';
        profiledata.ndep=profiledata.ndep-histindex+1;
        profiledata.deep_depth=profiledata.depth(profiledata.ndep);
        severity = 2;
        actparm='DEPH';
        %         severity=2;
        addhistories
        
        handles.profile_data=profiledata;
        
        setdepth_tempbox;
        sortandsave;
        re_plotprofile;
        handles.Qkey='N';
        return
        
    case 'PEA'
        %        changeposition - launch the gui to allow input of the new
        %        position:
        keysdata=handles.keys;
        if(keysdata.map180)
            [outputs]=changeposition('UserData',...
                [profiledata.latitude,keysdata.lon180(handles.currentprofile)]);
        else
            [outputs]=changeposition('UserData',...
                [profiledata.latitude,profiledata.longitude]);
        end
        
        handles.lastprofile=handles.currentprofile;
        histd=max(profiledata.depth(1),0.0);
        severity=5;
        profiledata.pos_qc=num2str(severity);
        difflat=abs(outputs.origlat-outputs.newlat);
        %        if(outputs.origlat~=outputs.newlat)
        if(difflat>0.002)
            profiledata.latitude=outputs.newlat;
            oldt=num2str(outputs.origlat);
            actparm=outputs.parmlat;
            addhistories
            %update the map - get rid of the old position...
            gg=plot(outputs.origlon,outputs.origlat,'kx');
            set(gg,'MarkerSize',14);
            set(gg,'LineWidth',2);
            %you must also change the keys file!!!
            keysdata.obslat(handles.currentprofile)=outputs.newlat;
            
            handles.profile_data=profiledata;
            handles.keys=keysdata;
            
            %saveguidata
            
            updatekeys('obslat',keysdata.masterrecno(handles.currentprofile),...
                outputs.newlat,keysdata.prefix);
        end
        difflon=abs(outputs.origlon-outputs.newlon);
        if(difflon>.002)
            %        if(outputs.origlon~=outputs.newlon)
            oldt=num2str(profiledata.longitude);
            if(keysdata.map180 & outputs.newlon<0)
                profiledata.longitude=360+outputs.newlon;
                keysdata.lon180(handles.currentprofile)=outputs.newlon;
            else
                profiledata.longitude=outputs.newlon;
            end
            actparm=outputs.parmlon;
            addhistories
            %update the map - get rid of the old position...
            gg=plot(outputs.origlon,outputs.origlat,'kx');
            
            set(gg,'MarkerSize',14);
            set(gg,'LineWidth',2);
            
            %            c= mod(720-outputs.newlon,360);
            %you must also change the keys file!!!
            keysdata.obslon(handles.currentprofile)=profiledata.longitude;
            
            handles.profile_data=profiledata;
            handles.keys=keysdata;
            
            %saveguidata
            
            updatekeys('obslng',keysdata.masterrecno(handles.currentprofile),...
                profiledata.longitude,keysdata.prefix);
            
            updatekeys('c360long',keysdata.masterrecno(handles.currentprofile),...
                profiledata.longitude,keysdata.prefix);
        end
        
        handles.profile_data=profiledata;
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
            [profiledata.year,profiledata.month,...
            profiledata.date,profiledata.time]);
        keysdata=handles.keys;
        handles.lastprofile=handles.currentprofile;
        histd=max(profiledata.depth(1),0.0);
        severity=5;
        profiledata.juld_qc=num2str(severity);
        olddate=(str2num(profiledata.year)*10000)+(str2num(profiledata.month)*100)...
            +str2num(profiledata.date);
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
            profiledata.time=outputs.newtime;
            oldt=outputs.origtime;
            actparm='TIME';
            addhistories
            %you must also change the keys file!!!
            
            keysdata.time(handles.currentprofile)=newtime;
            
            handles.profile_data=profiledata;
            handles.keys=keysdata;
            
            %saveguidata
            
            updatekeys('obs_t',keysdata.masterrecno(handles.currentprofile),...
                keytime,keysdata.prefix);
        end
        
        diffdate=abs(olddate-newdate);
        if(diffdate>=1)
            %        if(olddate~=newdate)
            profiledata.date=outputs.newdate;
            profiledata.month=outputs.newmonth;
            profiledata.year=outputs.newyear;
            
            oldt=num2str(olddate);
            actparm='DATE';
            addhistories
            %you must also change the keys file!!!
            
            if(~strcmp(outputs.newyear,outputs.origyear))
                keysdata.year(handles.currentprofile)=str2num(outputs.newyear);
                
                handles.profile_data=profiledata;
                handles.keys=keysdata;
                %saveguidata
                updatekeys('obs_y',keysdata.masterrecno(handles.currentprofile),...
                    outputs.newyear,keysdata.prefix);
            end
            
            if(~strcmp(outputs.newmonth,outputs.origmonth))
                
                keysdata.month(handles.currentprofile)=str2num(outputs.newmonth);
                handles.profile_data=profiledata;
                handles.keys=keysdata;
                
                %saveguidata
                
                
                updatekeys('obs_m',keysdata.masterrecno(handles.currentprofile),...
                    outputs.newmonth,keysdata.prefix);
            end
            
            if(~strcmp(outputs.newdate,outputs.origdate))
                keysdata.day(handles.currentprofile,:)=str2num(outputs.newdate);
                
                handles.profile_data=profiledata;
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
    histdepth=max(profiledata.depth(1),0.0);
    oldt=num2str(profiledata.temp(1));
end

if(depthsource==10)   %put flag at 10m (CTR)
    histdepth=max(profiledata.depth(1),10.0);
    oldt=num2str(profiledata.temp(1));
end
if(depthsource==3);   %put the flag at the end of the valid data
    histdepth=[];
    d=diff(profiledata.temp);
    try
        d=[0 d(1:end)'];
        jj=find(profiledata.temp>-2.4 & profiledata.temp < 31.9 & d'<=0.1);
    catch
        d=[0 d(1:end)];
        jj=find(profiledata.temp>-2.4 & profiledata.temp < 31.9 & d<=0.1);
    end
    % d(end+1)=d(end);
    
    if(~isempty(jj) & ~isnan(profiledata.temp(jj(end)+1)))
        histdepth=profiledata.depth(jj(end)+1);
        oldt=num2str(profiledata.temp(jj(end)+1));
    else
        %no appropriate point found:
        handles.Qkey='N';
        return
    end
end

if(depthsource==2 | depthsource==1)   %put flag at cursor point
    histindex=get(handles.depthdisplay,'Value');
    histdepth=profiledata.depth(histindex);
    oldt=num2str(profiledata.temp(get(handles.depthdisplay,'Value')));
end

if(isempty(histdepth))
    handles.Qkey='N';
    return
end

histd=histdepth;

if(strmatch(qualflag(1:3),'PER'))
    actparm='LALO';
    addhistories
    
elseif(strmatch(qualflag(1:3),'TER'))
    actparm='DATI';
    addhistories;
    
else
    actparm='TEMP';
    addhistories
end


handles.profile_data=profiledata;

%saveguidata

%re_plotprofile

sortandsave;
printqflags


handles.Qkey='N';

