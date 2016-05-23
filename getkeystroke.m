function ch = getkeystroke(m) ;

% GETKEY - get a key 
%   CH = GETKEY waits for a keypress, returns the ASCII code. Accepts
%   all ascii characters, including backspace (8), space (32), enter (13),
%   etc. CH is a double.
%
%   CH = GETKEY('non-ascii') uses non-documented matlab 6.5 features to
%   return a string describing the key pressed so keys like ctrl, alt, tab
%   etc. can also be used. CH is a string.
%
%   Used here to determine which key has been pressed and than take
%   action accordingly.
%
% Cobbled together from a function found in the matlab users pages:
% 2005 Jos
% Feel free to (ab)use, modify or change this contribution

DECLAREGLOBALS

%retrieveguidata
set(gcbo,'Userdata',get(handles.QuotaQuest,'Currentkey')); 
    
% Set up the figure

    ch = get(gcbo,'Userdata');

    pd=handles.pd;

qualf='   ';

% now manage keystrokes so they do what you need done:
% if the Q key has already been pressed, identify which flag must be
% applied:
if(strcmp(handles.Qkey,'Y'))

%    hw2=waitbar(0,'Please wait');
    qualf='NON' ;  

     if(ch=='6')
        axes(handles.map);
        [x,y]=ginput(1);
        zoommapwindow 
        handles.Qkey='N';
%        close(hw2);
        return
     else
        kk=strmatch(ch,handles.qkeystrokes,'exact');
        if(~isempty(kk))
             qualf=handles.qflags{kk};
             qualf=qualf(1:3);
        end
        identifyflag;
     end 

else    

% If the Q key has not been pressed, check the key and take the required action.    
    if(ch=='q')
        handles;
        handles.Qkey='Y';
        %save this new value for Qkey, then go and get another keystroke

        %saveguidata

        return
    end
%    hw2=waitbar(0,'Please wait');

switch ch;
%deal with single keystroke commands:
    case 'escape'  %nicely exit the program, saving the current profile
        %retrieveguidata
        if(handles.changed=='Y')
            writenetcdf;
        end
        delete(handles.QuotaQuest);
%        close(hw2);
        return
    case 'f1'   %add QCA flag
        axes(handles.profile);
        qualf='QCA';
        addqualityflag(qualf,0,1);
%        close(hw2);
        return
    case 'f2'   %show QC (in list box)
        numh=pd.numhists;
        kk=1:numh;   %strmatch(DATA_QC_SOURCE,pd.Ident_Code);
qcstring= [pd.QC_code(kk,:) num2str(pd.QC_depth(kk),' \t%9.2f')];
        centering=1;
        deletionpoint= deleteQC('UserData',{centering qcstring 1});
        %close(hw2);
                return;
    case 'f3'   %delete QC (from list)
        numh=pd.numhists;
        kk= 1:numh;    %strmatch(DATA_QC_SOURCE,pd.Ident_Code);
        kkhist=kk;
qcstring= [pd.QC_code(kk,:) num2str(pd.QC_depth(kk),' \t%9.2f')];
        centering=1;
        deletionpoint= deleteQC('UserData',{centering qcstring 0});
            if(deletionpoint==-1);
%        close(hw2);
                return;
            end
       axes(handles.profile);
       deleteqcflag;
       printqflags;
       drawnow
%       close(hw2);
       return
       
    case 'f4'   %kill drop (replace with raw data)  ! must rewrite keys if date or position has changed...
        %check to see if date/time or lat/long has changed:
        rewritekeys=0;
        for jj=1:pd.numhists
            if(strcmp(pd.QC_code(jj,:),'TE') | strcmp(pd.QC_code(jj,:),'PE'))
                rewritekeys=1;
            end
        end
        %read the rawfile, not the edited file:
        rawfile=1;
        keysdata=handles.keys;
        ss=keysdata.stnnum(handles.currentprofile); 

        handles.menudepth=500.;
        handles.changed='Y';

        %saveguidata

        i=handles.currentprofile;
        readnetcdf
        pd=handles.profile_data;
        
        %now rewrite the keys elements that might have changed - do all just
        %to be sure.
                 
        t=pd.time;
        sh=strfind(t,':');
        if(~isempty(sh))
            t(sh)=[];
        end

        updatekeys('obs_y',keysdata.masterrecno(handles.currentprofile),...
                pd.year,keysdata.prefix);
        updatekeys('obs_m',keysdata.masterrecno(handles.currentprofile),...
                pd.month,keysdata.prefix);
        updatekeys('obs_d',keysdata.masterrecno(handles.currentprofile),...
                pd.day,keysdata.prefix);
        updatekeys('obs_t',keysdata.masterrecno(handles.currentprofile),...
                t,keysdata.prefix);
        updatekeys('obslat',keysdata.masterrecno(handles.currentprofile),...
                pd.latitude,keysdata.prefix);
       
           
 % no!       ????????????????????

%     c= mod(720-pd.longitude,360);
    c=pd.longitude;
    
       updatekeys('c360long',keysdata.masterrecno(handles.currentprofile),...
               c,keysdata.prefix);
       updatekeys('obslng',keysdata.masterrecno(handles.currentprofile),...
               c,keysdata.prefix);
  
        keysdata.year(handles.currentprofile)=str2num(pd.year);
        keysdata.month(handles.currentprofile)=str2num(pd.month);
        keysdata.day(handles.currentprofile)=str2num(pd.day);
        keysdata.time(handles.currentprofile)=str2num(t);
        keysdata.obslon(handles.currentprofile)=c;
        keysdata.obslat(handles.currentprofile)=pd.latitude;
        
        handles.keys=keysdata;
       
        handles.profile_data=pd;
        
        axes(handles.profile);
        cla
        re_plotprofile;
        addwaterfallinfo;
        setprofileinfo;
        setdepth_tempbox;
        
        rawfile=0;

        %saveguidata
        drawnow
        
        %close(hw2);
        return
    case 'f5'   %buddies +/-1
        axes(handles.profile);
        usebuddylimits=1;
        changebuddyselection;
        set(handles.buddyselection,'Value',1);
        st=get(handles.buddyselection,'String');
        set(handles.custombuddy,'String','1');
        drawnow
        %close(hw2);
        return
    case 'f6'   %buddies +/-2
        axes(handles.profile);
        usebuddylimits=2;
        changebuddyselection;
        set(handles.buddyselection,'Value',2);
        st=get(handles.buddyselection,'String');
        set(handles.custombuddy,'String','2');
        drawnow
        %close(hw2);
        return
    case 'f7'   %buddies 0.5 deg
            axes(handles.profile);
            budregion=get(handles.buddyselection,'String');
            handles.buddylim=0.5;
        if(handles.restrictbuddies)
%            handles.buddylim=0.5;
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
        %close(hw2);
        return
    case 'f8'   %buddies 1.0 deg
        axes(handles.profile);
        budregion=get(handles.buddyselection,'String');
        handles.buddylim=1.0;
        if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
        %close(hw2);
        return
        
    case 'f9'   %set region to show 10 buddies only (nbds can be easily reset)
        axes(handles.profile);
        handles.nbds=10;   %the number of buddies you want to see...
        if(handles.restrictbuddies)
            handles.restrictbuddies=0;
            set(handles.custombuddy,'String',num2str(handles.buddylim));
            budregion=get(handles.buddyselection,'String');
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            changebuddyselection
            drawnow
            %close(hw2);
            return
        else
            handles.restrictbuddies=1;
            budregion=get(handles.buddyselection,'String');
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
            changebuddyselection
            drawnow
            %close(hw2);
            return
        end
                
        %Originally:  buddies 2.0
%        budregion=get(handles.buddyselection,'String');
%        usebuddylimits=strmatch('user select',budregion);
%        set(handles.buddyselection,'Value',usebuddylimits);
%        set(handles.custombuddy,'String',num2str(2.0));
%        changebuddyselection;
         drawnow
       %close(hw2);
       return
        
    case 'f10'  %set buddy window to 0.1 degrees
            axes(handles.profile);
            budregion=get(handles.buddyselection,'String');
            handles.buddylim=0.1;
        if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
%ignore tint!!! useless       
        %close(hw2);
        return
    
    case 'f11'  %display good buddies only
        handles.goodbuddy='Y';

        %saveguidata
        %close(hw2);
        return
    case 'f12'  %display all buddies
        handles.goodbuddy='N';
        %saveguidata
        %close(hw2);
        return
  
    case '1'    %reassign Q flags on date to fix '5' flag on data -
	              %deactivate after used...
%         axes(handles.profile)
%         assign_quality_flags
%         handles.changed='Y';
%         printqflags
%         drawnow
%         %close(hw2);
%         return
         
%        qualf='URA'
    case '2'    %switch MA for XB and vice versa - DTA code
%        convertdatatype;
    case '3'    %HBA
        qualf='HBA'
    case '4'    %buddies +/- 2.0 deg
        axes(handles.profile)
        budregion=get(handles.buddyselection,'String');
            handles.buddylim=2.0;
        if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
%ignore tint!!! useless        
        %close(hw2);
        return
        

    case '5'    %get rid of duplicate history records...
        kkhist=1:pd.numhists;
        for i=1:pd.numhists
            if(strmatch('PE',pd.QC_code(i,:)) |...
                    strmatch('TE',pd.QC_code(i,:)));
            else
          j=strmatch(pd.QC_code(i,:),pd.QC_code);
          gg=find(j~=i & pd.QC_depth(i)==pd.QC_depth(j));
            if(~isempty(gg))
                axes(handles.profile)
                deletionpoint=j(gg);
                deleteqcflag;
                drawnow
                %close(hw2);
                return
            end
            end
        end
%        drawnow
        %close(hw2);
        return
    case '6'    %get mapinput points and find profiles from coordinates!!
               
        keysdata=handles.keys;
        axes(handles.map);
        [x,y]=ginput(1);
        landpoint=find(keysdata.obslat>y-0.1 & keysdata.obslat<y+0.1 & ...
            keysdata.obslon>x-0.1 & keysdata.obslon<x+0.1)
        if(~isempty(landpoint))
            slandpoint=landpoint(1)
            handles.lastprofile=handles.currentprofile;
            handles.currentprofile=slandpoint;
            handles.profilefocus=500.; %this is the default...
            %saveguidata
            
            %check to see if is repeat and display alert if true:
            check_for_repeats
 
            plotnewprofile;
            updatemap;
 %check callsign and see if it has changed, then reset window if
        %necessary.
        
    callsignlist=get(handles.callsigns,'String');
    callsignselection=get(handles.callsigns,'Value');

    requiredcallsign=callsignlist(callsignselection,:);
    newcallsign=keysdata.callsign(handles.currentprofile,:);
    kk=strmatch(requiredcallsign,newcallsign);

    if(isempty(kk));
        kk2=strmatch(newcallsign,callsignlist);
        if(~isempty(kk2))
           set(handles.callsigns,'Value',kk2(1));
        end
    end
        end    
        drawnow
        %close(hw2);
        return
            

        
    case '7'    %set buddies for only one year
        handles.singleyearbuddies=1;
        set(handles.singleyear,'visible','on');
        %close(hw2);
        return
    case '8'    %set buddies for all years and all months
        handles.singleyearbuddies=0;
        handles.singlemonthbuddies=0;
        set(handles.singlemonth,'visible','off');
        set(handles.singleyear,'visible','off');
        %close(hw2);
        return             
    case '9'    %set buddies for only one month
        handles.singlemonthbuddies=1;
        set(handles.singlemonth,'Visible','on')
        %close(hw2);
        return

    case '0'    %redraw map window...
        
        plotmap
        drawnow
        %close(hw2);
        return
    
    
    case 'hyphen'    %redraw the waterfall window
        keysdata=handles.keys;
        hfp=handles.firstwaterprofile;
        hcp=handles.currentprofile;
        axes(handles.waterfall);
        cla;

        k=max(1,hcp-5);
        handles.firstwaterprofile=k;
    %saveguidata
        twater=handles.firstwaterprofile:min(length(keysdata.year),handles.firstwaterprofile+25);

        if(k+24>length(keysdata.stnnum));
            kk=length(keysdata.stnnum);
            twater=handles.firstwaterprofile:kk;
        else
            kk=k+25;
        end

        for wprof=1:length(twater)
            ss=keysdata.stnnum(twater(wprof));  
            plotwaterfall;
            drawnow
        end

        try
            wlim=(ceil(pd.depth(pd.ndep)/100)*100)+100;
            set(handles.waterfall,'Ylim',[0 wlim(1)]);
        catch
            set(handles.waterfall,'Ylim',[1 1000]);
        end
        %close(hw2);
        return
        
    case 'equal'    %reapply the last reject menu item selected
       cc=get(handles.rejectcodes,'String'); 
       cc1=get(handles.rejectcodes,'Value');
       qualf=cc{cc1}
        
    case 'backspace'  %plot all months buddies (for when working with single month)
        plotallbuddies
        return
        
%    case 'w'   
%         axes(handles.profile);
%         qualf='WSR'
%         addqualityflag(qualf,1,2)        
%     case 'e'    %not active
%        axes(handles.profile);
%         qualf='EF';
%         addqualityflag(qualf);
%     case 'r'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf)  ;      
    case 't'   %change date and/or time  
        axes(handles.profile);
        qualf='TEA';
        addqualityflag(qualf,0,1);  
        drawnow
        %close(hw2);
        return
%    case 'y'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
%    case 'u'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
%    case 'i'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
    case 'o'    %tor entire profile
        axes(handles.profile);
        qualf='TOR';
        addqualityflag(qualf,0,3);
        drawnow
        %close(hw2);
        return
    case 'p'    %change position (lat or long)
        axes(handles.profile);
        qualf='PEA';
        addqualityflag(qualf,0,2);
        drawnow
        %close(hw2);
        return
    case 'leftbracket'    %CTA at 0m and CTR at 10m
        axes(handles.profile);
        qualf='CTA';
        addqualityflag(qualf,0,2);
        qualf='CTR';
        addqualityflag(qualf,10,3);
        drawnow
        %close(hw2);
        return
%    case 'rightbracket'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
    case 'backslash'    %plot raw data along with edited data in profile window   
        keysdata=handles.keys;
        axes(handles.profile);
        cla;
        ss=keysdata.stnnum(handles.currentprofile);  %keysdata.stnnum(i);   %
        handles.displaybuddy='N';
        re_plotprofile;
         % now plot the raw data over top in yellow(?) 
        raw=1;
        filenam=handles.keys.prefix;
        readbuddynetcdf
        raw=0;
        isn=find(~isnan(btemp));
%        axes(handles.profile);
        if(length(isn)==1)
            wx=plot(btemp(isn),bdepth(isn),'rx');
                set(wx,'MarkerSize',10)
        end

        plot(btemp(isn),bdepth(isn),'r-');
        hold on
        
        %now plot the edited profile:
        isn=find(~isnan(pd.temp) & pd.temp<99.);
        plot(pd.temp(isn),pd.depth(isn),'w-');

        drawnow
        %close(hw2);
        return

        
%    case 'a'    %not active
%        axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf)    ;    
%    case 's'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf)     ;   
    case 'd'    %DUR profile, save, and send to the next profile
        axes(handles.profile);
        qualf='DUR';
        addqualityflag(qualf,0,4);
        %retrieveguidata
        keysdata=handles.keys;
        handles.lastprofile=handles.currentprofile;
        if(handles.currentprofile>=length(keysdata.stnnum))
            handles.currentprofile=length(keysdata.stnnum);
        else
            handles.currentprofile=handles.currentprofile+1;
        end
            handles.profilefocus=500.; %this is the default...
            %saveguidata
            
       %check to see if this is a repeat profile and display warning if it is:
       check_for_repeats;
       plotnewprofile;
       updatemap;
       drawnow

%check callsign and see if it has changed, then reset window if necessary.
        
keysdata=handles.keys;
callsignlist=get(handles.callsigns,'String');
callsignselection=get(handles.callsigns,'Value');

requiredcallsign=callsignlist(callsignselection,:);
newcallsign=keysdata.callsign(handles.currentprofile,:);
kk=strmatch(requiredcallsign,newcallsign);

if(isempty(kk));
   kk2=strmatch(newcallsign,callsignlist);
   if(~isempty(kk2))
       set(handles.callsigns,'Value',kk2(1));
   end
end
       %close(hw2);
       return
        
    case 'f'    %add FSA, CSA and QCA all together and put in buddy mode
        axes(handles.profile);
        qualf='QCA';
        addqualityflag(qualf,0,1);
        qualf='CSA';
        addqualityflag(qualf,0,1);
        qualf='FSA';
        addqualityflag(qualf,0,2);
        %put into buddy mode
          plotbuddies

        drawnow
        %    close(hw2);
        return
%    case 'g'    %not active
%        axes(handles.profile);
%        qualf='QC'
%        addqualityflag(qualf)
    case 'h'    %HFA the entire profile from the current cursor point
        axes(handles.profile);
        qualf='HFA';
        addqualityflag(qualf,0,2);
        drawnow
        %close(hw2);
        return
    case 'j'    %add PSA, CSA and QCA all together and put in buddy mode
        axes(handles.profile);
        qualf='QCA';
        addqualityflag(qualf,0,1);
        qualf='CSA';
        addqualityflag(qualf,0,0);
        qualf='PSA';
        addqualityflag(qualf,0,2);
        %put into buddy mode
         plotbuddies
        drawnow
        % close(hw2);
        return

    case 'k'    %add ler at surface...
        axes(handles.profile);
        qualf='LER';
        addqualityflag(qualf,0,3);
        drawnow
        %close(hw2);
        return

%    case 'l'    %not active
%        axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
%    case ';'    %not active
%        axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);

    case 'z'    %add hbr and ngr automatically at the cursor point (also f10)
        %first, remove any HBR or NGR already present:
        axes(handles.profile);
        qualf='HBR';
        numh=pd.numhists;
        qcstring= [pd.QC_code(1:numh,:)];
        deletionpoint= strmatch(qualf(1:2),qcstring,'exact');
            if(~isempty(deletionpoint));
                kkhist=1:pd.numhists;
                deleteqcflag;
            end
        qualf='NGR';
        qcstring= [pd.QC_code(1:numh,:)];
        deletionpoint= strmatch(qualf(1:2),qcstring,'exact');
            if(~isempty(deletionpoint));
                kkhist=1:pd.numhists;
                deleteqcflag;
            end

        %now add the hbr and ngr at the appropriate place:
        qualf='HBR';    
        addqualityflag(qualf,2,3);
        qualf='NGR';
        addqualityflag(qualf,2,4);
        drawnow
        %close(hw2);
        return
        
    case 'x'    %NGR the entire profile...
        axes(handles.profile);
        qualf='NGR';
        addqualityflag(qualf,0,4);
        plotbuddies
        drawnow
        %close(hw2);
        return
    case 'c'    %add CSA and QCA, then put into buddy mode
        axes(handles.profile);
        qualf='QCA';
        addqualityflag(qualf,0,1);
        qualf='CSA';
        addqualityflag(qualf,0,0);
        %put into buddy mode
        plotbuddies
        drawnow
        %close(hw2);
        return
    case 'v'    %IPR entire profile
        axes(handles.profile);
        qualf='IPR';
        addqualityflag(qualf,0,3);
        drawnow
        %close(hw2);
        return
    case 'b'    %add WBR automatically at the bottom of the good data
        axes(handles.profile);
        qualf='WBR';
        addqualityflag(qualf,3,4);
        drawnow
        %close(hw2);
        return
%    case 'n'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
%    case 'm'    %not active
%         axes(handles.profile);
%        qualf='QC';
%        addqualityflag(qualf);
%    case 'comma'    %not active
%         axes(handles.profile);
%        qualf='IPA';
%        addqualityflag(qualf,2,2);        
%    case 'period'    %not active

%    case 'scrolllock'  %(pause key) - not necessary in matlab
        
    case 'insert'    %now used to return map to original axes
        
%        axes(handles.map);
        keysdata=handles.keys;
        lat=keysdata.obslat;
        lon=keysdata.obslon;

        lla=range(lat);
        llo=range(lon);
        xlimit=[llo(1)-5 llo(2)+5];
        ylimit=[lla(1)-5 lla(2)+5];
        set(handles.map,'XLim',xlimit);
        set(handles.map,'YLim',ylimit);

        %close(hw2);
        return
        
%    case 'slash'     %not active
        
    case 'numpad1'    %set buddies for only one year
        handles.singleyearbuddies=1;
        set(handles.singleyear,'Visible','on');
        %close(hw2);
        return
    case 'numpad2'    %set buddies for all years
        handles.singleyearbuddies=0;
        handles.singlemonthbuddies=0;
        set(handles.singlemonth,'visible','off');
        set(handles.singleyear,'visible','off');
        %close(hw2);
        return        
    case 'numpad3'    %set buddies to +/- 0.25 deg
            axes(handles.profile);
            budregion=get(handles.buddyselection,'String');
            handles.buddylim=0.25;
        if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
        %close(hw2);
        return

%    case 'numpad4'    %not used - replaced by edit box       
        
    case 'numpad5'    %set buddies to +/- 1.5 deg
            axes(handles.profile);
            budregion=get(handles.buddyselection,'String');
            handles.buddylim=1.5;
        if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
        %close(hw2);
        return
 
    case 'numpad6'    %set buddies to +/- 4 deg
            axes(handles.profile);
            budregion=get(handles.buddyselection,'String');
            handles.buddylim=4.0;
         if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
        %close(hw2);
        return
        
%    case 'numpad7'    %not used....
         
%    case 'numpad8'     %not used....
        
    case 'numpad9'    %set buddies to +/- 3 deg
            axes(handles.profile);
            budregion=get(handles.buddyselection,'String');
            handles.buddylim=3.0;
        if(handles.restrictbuddies)
            usebuddylimits=strmatch('max buddies',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',[num2str(handles.nbds) ...
                ' buddies max (' num2str(handles.buddylim) ')'])
        else
            usebuddylimits=strmatch('user select',budregion);
            set(handles.buddyselection,'Value',usebuddylimits);
            set(handles.custombuddy,'String',num2str(handles.buddylim));
        end
        changebuddyselection;
        drawnow
        %close(hw2);
        return
        
%    case 'numpad0'    %remove all QC flags - keep inactive!!!!

%    case 'add'
        
    case 'multiply'     %set temp scale to show surface values that are offscale
        r1=pd.temp(find(pd.temp<99));
        r=range(r1);
        set(handles.profile,'Xlim',[r(1)-5. r(2)+5.])
        %saveguidata
        return
    case 'subtract'  %set window to show entire trace - 
        %               used to see bottom of deep traces
        axes(handles.profile);
        cla;
        focusdepth=(pd.depth(1)-pd.depth(pd.ndep))/2;
        handles.profilefocus=pd.depth(pd.ndep)/2;
        set(handles.profile,'YLim',[-10 pd.depth(pd.ndep)+100]);
        yy=get(handles.depthdisplay,'Value');
        r=range(pd.temp);
        set(handles.profile,'Xlim',[r(1)-5. r(2)+5.])
        %saveguidata
        zoomprofile;
        printqflags;
        drawnow
        %close(hw2);
        return
%    case 'decimal'    %not used...
        
    case 'home'       %goto drop 1
        hw2=waitbar(0,'Please wait');
        handles.lastprofile=handles.currentprofile;
        handles.currentprofile=1;
        handles.profilefocus=500.; %this is the default...
        i=1;
        %saveguidata
        plotnewprofile;
        updatemap;
        drawnow
        close(hw2);
        return
    
    case 'delete'    %change display region to focus on current profile -
                     % the opposite is 'insert' to close(hw2);return window to original bounds
        
%        axes(handles.map);
        keysdata=handles.keys;
        if(keysdata.map180)
            lon=keysdata.lon180(handles.currentprofile);
        else
            lon=keysdata.obslon(handles.currentprofile);
        end
        lat=keysdata.obslat(handles.currentprofile);

        xlimit=[lon-2 lon+2];
        ylimit=[lat-2 lat+2];
        set(handles.map,'XLim',xlimit);
        set(handles.map,'YLim',ylimit);
        %close(hw2);
        return
        
%    case 'end'       %not used!!

    
    case 'pageup'    %display buddy profiles
       axes(handles.profile);
       plotbuddies;
       drawnow
       %close(hw2);
       return
    case 'pagedown'  %display only current profile
        keysdata=handles.keys;
        axes(handles.profile);
        cla;
         ss=keysdata.stnnum(handles.currentprofile);  %keysdata.stnnum(i);   %
        handles.displaybuddy='N';
        re_plotprofile;
        drawnow
        %close(hw2);
        return
        
    case 'uparrow'    %save current profile if necessary and displays the next profile
        hw2=waitbar(0,'Please wait');
        keysdata=handles.keys;
        handles.lastprofile=handles.currentprofile;
        if(handles.currentprofile>=length(keysdata.stnnum))
            handles.currentprofile=length(keysdata.stnnum);
        else
            handles.currentprofile=handles.currentprofile+1;
        end
            handles.profilefocus=500.; %this is the default...
            %saveguidata
            
            %check to see if is repeat and display alert if true:
             check_for_repeats
 
            plotnewprofile;
            updatemap;
            drawnow
 %check callsign and see if it has changed, then reset window if
        %necessary.
        
    keysdata=handles.keys;
    callsignlist=get(handles.callsigns,'String');
    callsignselection=get(handles.callsigns,'Value');

    requiredcallsign=callsignlist(callsignselection,:);
    newcallsign=keysdata.callsign(handles.currentprofile,:);
    kk=strmatch(requiredcallsign,newcallsign);

    if(isempty(kk));
        kk2=strmatch(newcallsign,callsignlist);
        if(~isempty(kk2))
           set(handles.callsigns,'Value',kk2(1));
        end
    end
    
            close(hw2);
            return
            
    case 'downarrow'  %save current profile if necessary and go back to 
                        %the previous
        hw2=waitbar(0,'Please wait');

        keysdata=handles.keys;
            handles.lastprofile=handles.currentprofile;
        if(handles.currentprofile<=1)
            handles.currentprofile=1;
        else
            handles.currentprofile=handles.currentprofile-1;
        end
            handles.profilefocus=500.; %this is the default...
            %saveguidata
    
  %check to see if this is a repeat and, if so, display alert
            check_for_repeats
                         
            plotnewprofile;
            updatemap;
        drawnow
                    
%check callsign and see if it has changed, then reset window if
        %necessary.
        
    keysdata=handles.keys;
    callsignlist=get(handles.callsigns,'String');
    callsignselection=get(handles.callsigns,'Value');

    requiredcallsign=callsignlist(callsignselection,:);
    newcallsign=keysdata.callsign(handles.currentprofile,:);
    kk=strmatch(requiredcallsign,newcallsign);

    if(isempty(kk));
      kk2=strmatch(newcallsign,callsignlist)
      if(~isempty(kk2))
        set(handles.callsigns,'Value',kk2(1));
      end
    end
            close(hw2);
            return
            
    case 'leftarrow'   %reset zoom
        
        axes(handles.profile);
%         cla
        handles.profilefocus=500.; %this is the default...
%        handles.displaybuddy='N';
        %saveguidata
        set(handles.profile,'YLim',[-30 1000]);
        set(handles.profile,'XLim',[-5 35]);
        
        if(handles.displaybuddy=='Y')
usebuddylimits=get(handles.buddyselection,'Value');
%             budtype=get(handles.buddyselection,'Value');
%             budregion=get(handles.buddyselection,'String');
%            if(handles.restrictbuddies)
%                usebuddylimits=strmatch('max buddies',budregion);
%                set(handles.buddyselection,'Value',usebuddylimits);
%                set(handles.custombuddy,'String',[num2str(handles.nbds) ...
%                    ' buddies max (' num2str(handles.buddylim) ')'])
%            else
%                usebuddylimits=strmatch('user select',budregion);
%                set(handles.buddyselection,'Value',usebuddylimits);
%                set(handles.custombuddy,'String',num2str(handles.buddylim));
%            end
            changebuddyselection;
            printqflags
        
        else
            re_plotprofile;
            printqflags;
        end
         drawnow
       %close(hw2);
       return
        
    case 'rightarrow'   %zoom on the profile at the cursor - +/-100m
        
        axes(handles.profile);
%         cla;
        focusdepth=handles.menudepth;
        handles.profilefocus=100.;
        set(handles.profile,'YLim',[focusdepth-100 focusdepth+100]);
        yy=get(handles.depthdisplay,'Value');
        set(handles.profile,'Xlim',[pd.temp(yy)-10. pd.temp(yy)+10.])
        %saveguidata
        
        if(handles.displaybuddy=='Y')
%             budregion=get(handles.buddyselection,'String');
usebuddylimits=get(handles.buddyselection,'Value');
%            if(handles.restrictbuddies)
%                usebuddylimits=strmatch('max buddies',budregion);
%                 set(handles.buddyselection,'Value',usebuddylimits);
%                 set(handles.custombuddy,'String',[num2str(handles.nbds) ...
%                     ' buddies max (' num2str(handles.buddylim) ')'])
%             else
%                 usebuddylimits=strmatch('user select',budregion);
%                 set(handles.buddyselection,'Value',usebuddylimits);
%                 set(handles.custombuddy,'String',num2str(handles.buddylim));
%             end
            changebuddyselection;
            printqflags
        
        else
        
            zoomprofile;
            printqflags;
        end
        drawnow

       %close(hw2);
       return
       
end
        
%now add the flags if they haven't already been added:
    if(qualf(3)=='A')
        cc=get(handles.acceptcodes,'String');
    else
        cc=get(handles.rejectcodes,'String');
    end
    cc2=strmatch(qualf,cc,'exact');
    if(isempty(cc2))
        erro=qualf;
        cc=cc;
%        errordlg([ 'This flag is invalid!!!' erro]) 
        drawnow
        %close(hw2);
        return
    end
    if(strmatch(qualf,'NON'))
        erro=qualf;
%        errordlg([ 'This flag is invalid!!!' erro]) 
        drawnow
        %close(hw2);
        return
    end

    if(qualf(3)=='A')
        placement=handles.acceptplace(cc2);
        severity=handles.acceptlevel(cc2);
    else
        placement=handles.rejectplace(cc2);
        severity=handles.rejectlevel(cc2);
    end       
    axes(handles.profile);
    addqualityflag(qualf,placement,severity);
    handles.Qkey='N';
    drawnow
    %saveguidata
  
        
      
end     
    %close(hw2)     
        
