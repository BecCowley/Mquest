% plotbuddies - a script to gather the buddy profiles and plot them with 
%       the current profile for comparison.
%
% This is an Mquest script that works only in the gui environment and
% requires the handles structure as well as the profiledata structure.

%retrieveguidata

holdb=0;  %this is the index of buddies from the same year...
ylimit=get(handles.profile,'Ylim');
xlimit=get(handles.profile,'Xlim');

%axes(handles.profile);
% gca
% handles.buddies{:}
cla

pd=handles.pd;

i=handles.currentprofile;
keysdata=handles.keys;
currentlat=keysdata.obslat(i);
currentlon=keysdata.obslon(i);
currentmonth=keysdata.month(i);
col=['gbyrb'];
handles.displaybuddy='Y';   

%saveguidata

singleyear=handles.singleyearbuddies;
singlemonth=handles.singlemonthbuddies;
restrict=handles.restrictbuddies;
buddyarea=handles.buddylim;
iyear=str2num(pd.year);
if(handles.buddy>3)
    bud=handles.buddies;
   
%first plot the buddies from other files:
   for jj=1:length(bud)
    findbud2=[];
    findbud1=[];
if(handles.stopbuds)
    drawnow
    break
end
        if(singleyear & singlemonth)
            %note - this has been changed so you independently select
            %single month and single year. Both together result in buddies
            %from only one month of one year; independently, they are more
            %general.
            findbud=find(bud{jj}.obslat>=currentlat-buddyarea & ...
                bud{jj}.obslat<=currentlat+buddyarea & ...
                bud{jj}.obslon>=currentlon-buddyarea & ...
                bud{jj}.obslon<=currentlon+buddyarea &...
                bud{jj}.year==iyear & bud{jj}.month==currentmonth);
        elseif (singleyear)                
            findbud=find(bud{jj}.obslat>=currentlat-buddyarea & ...
                bud{jj}.obslat<=currentlat+buddyarea & ...
                bud{jj}.obslon>=currentlon-buddyarea & ...
                bud{jj}.obslon<=currentlon+buddyarea &...
                bud{jj}.year==iyear);
        elseif(singlemonth)
            findbud=find(bud{jj}.obslat>=currentlat-buddyarea & ...
                bud{jj}.obslat<=currentlat+buddyarea & ...
                bud{jj}.obslon>=currentlon-buddyarea & ...
                bud{jj}.obslon<=currentlon+buddyarea &...
                bud{jj}.month==currentmonth);
        else
            findbud1=find(bud{jj}.obslat>=currentlat-buddyarea & ...
               bud{jj}.obslat<=currentlat+buddyarea & ...
               bud{jj}.obslon>=currentlon-buddyarea & ...
               bud{jj}.obslon<=currentlon+buddyarea &...
                bud{jj}.year~=iyear);
            findbud2=find(bud{jj}.obslat>=currentlat-buddyarea & ...
               bud{jj}.obslat<=currentlat+buddyarea & ...
               bud{jj}.obslon>=currentlon-buddyarea & ...
               bud{jj}.obslon<=currentlon+buddyarea &...
                bud{jj}.year==iyear);
            findbud=[findbud1' findbud2'];
        end
        if(restrict)
            if(length(findbud)> handles.nbds)
                [dist,phasea]=sw_dist(bud{jj}.obslat(findbud),bud{jj}.obslon(findbud));
                [d,ig]=sort(dist);
                findbud=findbud(ig(1:handles.nbds));
            end
        end
            
        if(length(findbud)>50)
            splitbuds=ceil(length(findbud)/50);
        else
            splitbuds=1;
        end

%    while(~(get(handles.stopbuddies,'Value')))
                
        for kk=1:splitbuds:length(findbud)
if(handles.stopbuds)
    drawnow
    break
end
    clear filenam 
                filenam=bud{jj}.prefix;
                ss=bud{jj}.stnnum(findbud(kk));
                readbuddynetcdf
                isn=find(~isnan(btemp));
                if(handles.goodbuddy=='Y')
                    kkk=find(bqc(isn)<=2 | bqc(isn)==5);
                    if(bud{jj}.year(findbud(kk))==iyear)
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'mx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn(kkk)),bdepth(isn(kkk)),'m-');
                    else
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'rx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn(kkk)),bdepth(isn(kkk)),'r-'); 
                    end
                else
                    if(bud{jj}.year(findbud(kk))==iyear)
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'mx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn),bdepth(isn),'m-');
                    else
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'rx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn),bdepth(isn),'r-');
                    end
                end
                hold on
%end
        end

     axis ij
     grid on
%axis([-2 35 -1000 0])
%        xlimit=[-5 35];
%        ylimit=[-10 1000];
     set(handles.profile,'XLim',xlimit);
     set(handles.profile,'YLim',ylimit);

    end   %for jj=1:length(bud)
    
%now plot buddies from the same file:
%green is east, yellow is west
%or green is north, yellow is south (if lat < -35).

%handles.stopbuds=0;
%drawnow;

    keysdata=handles.keys;
%    blat=keysdata.obslat;
%    blon=keysdata.obslon;
%    ssb=keysdata.stnnum;

        if(singleyear & singlemonth)
            findbud=find(keysdata.obslat>=currentlat-buddyarea & ...
                keysdata.obslat<=currentlat+buddyarea & ...
                keysdata.obslon>=currentlon-buddyarea & ...
                keysdata.obslon<=currentlon+buddyarea &...
                keysdata.year==iyear & keysdata.month==currentmonth);
        elseif(singleyear)
            findbud=find(keysdata.obslat>=currentlat-buddyarea & ...
                keysdata.obslat<=currentlat+buddyarea & ...
                keysdata.obslon>=currentlon-buddyarea & ...
                keysdata.obslon<=currentlon+buddyarea &...
                keysdata.year==iyear);
        elseif(singlemonth)
            findbud=find(keysdata.obslat>=currentlat-buddyarea & ...
               keysdata.obslat<=currentlat+buddyarea & ...
               keysdata.obslon>=currentlon-buddyarea & ...
               keysdata.obslon<=currentlon+buddyarea &...
                keysdata.month==currentmonth);
        else
            findbud=find(keysdata.obslat>=currentlat-buddyarea & ...
               keysdata.obslat<=currentlat+buddyarea & ...
               keysdata.obslon>=currentlon-buddyarea & ...
               keysdata.obslon<=currentlon+buddyarea);
        end
        
        if(restrict)
            if(length(findbud)> handles.nbds)
                [dist,phasea]=sw_dist(keysdata.obslat(findbud),keysdata.obslon(findbud));
                [d,ig]=sort(dist);
                findbud=findbud(ig(1:handles.nbds));
            end
        end

        if(length(findbud)>50)
            splitbuds=ceil(length(findbud)/50);
        else
            splitbuds=1;
        end
        for kk=1:splitbuds:length(findbud)
if(handles.stopbuds)
    drawnow
    break
end
           clear filenam 
            filenam=keysdata.prefix;
            ss=keysdata.stnnum(findbud(kk));
            readbuddynetcdf
            isn=find(~isnan(btemp));
            if(handles.goodbuddy=='Y')
                kkk=find(bqc(isn)<=2 | bqc(isn)==5);
                if(currentlat<=-35.)
                    if(keysdata.obslat(kk)<currentlat);
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'yx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn(kkk)),bdepth(isn(kkk)),'y-');
                    else
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'gx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn(kkk)),bdepth(isn(kkk)),'g-');
                    end
                else
                    if(keysdata.obslon(kk)<currentlon);
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'yx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn(kkk)),bdepth(isn(kkk)),'y-');
                    else
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'gx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn(kkk)),bdepth(isn(kkk)),'g-');
                    end
                end
            else
                if(currentlat<=-35.)
                    if(keysdata.obslat(kk)<currentlat);
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'yx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn),bdepth(isn),'y-');
                    else
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'gx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn),bdepth(isn),'g-');
                    end
                else
                    if(keysdata.obslon(kk)<currentlon);
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'yx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn),bdepth(isn),'y-');
                    else
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'gx');
            set(wx,'MarkerSize',10)
    end
                        plot(btemp(isn),bdepth(isn),'g-');
                    end
                end
            end
                hold on
%end
        end  %plotting - kk=1:splitbuds:length(findbud)
 %   end %while(~(get(handles.stopbuddies))
%handles.stopbuds=0;
%drawnow;

    axis ij
     grid on
%axis([-2 35 -1000 0])
%        xlimit=[-5 35];
%        ylimit=[-10 1000];
     set(handles.profile,'XLim',xlimit);
     set(handles.profile,'YLim',ylimit);

% now plot the original profile!!

%    i=handles.currentprofile;
%    ss=keysdata.stnnum(i);
%    clear filenam;
%    filenam=keysdata.prefix;
%    readbuddynetcdf;
btemp=pd.temp;
bdepth=pd.depth;
isn=find(~isnan(btemp)& btemp<99);
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'wx');
        set(wx,'MarkerSize',10)
    end
    h=plot(btemp(isn),bdepth(isn),'w-');
    set(h,'LineWidth',1.3);
else
    
    
%plot buddies from the same ship:
%    blat=keysdata.obslat;
%    blon=keysdata.obslon;
         
    for kk=max(1,i-buddyarea):min(length(keysdata.stnnum),i+buddyarea)   
     if(singleyear & keysdata.year(kk)~=str2num(pd.year))
            
     else

    ss=keysdata.stnnum(kk);
    clear filenam 
    filenam=keysdata.prefix;
       readbuddynetcdf;
       isn=find(~isnan(btemp));
        if(handles.goodbuddy=='Y')
            kkk=find(bqc(isn)<=2 | bqc(isn)==5);
            if(currentlat<=-35.)
                if(keysdata.obslat(kk)<currentlat);
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'yx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn(kkk)),bdepth(isn(kkk)),'y-');
                else
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'gx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn(kkk)),bdepth(isn(kkk)),'g-');
                end
            else
                if(keysdata.obslon(kk)<currentlon);
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'yx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn(kkk)),bdepth(isn(kkk)),'y-');
                else
    if(length(kkk)==1)
        wx=plot(btemp(isn(kkk)),bdepth(isn(kkk)),'gx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn(kkk)),bdepth(isn(kkk)),'g-');
                end
            end
        else
            if(currentlat<=-35.)
                if(keysdata.obslat(kk)<currentlat);
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'yx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn),bdepth(isn),'y-');
                else
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'gx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn),bdepth(isn),'g-') ;
                end
            else
                if(keysdata.obslon(kk)<currentlon);
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'yx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn),bdepth(isn),'y-');
                else
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'gx');
            set(wx,'MarkerSize',10)
    end
                    plot(btemp(isn),bdepth(isn),'g-');
                end
            end
        end
     end
%    end   %while (~(get(handles.stopbuddies,'Value')))
     end

% now plot the original profile!!
    btemp=pd.temp;
    bdepth=pd.depth;
    isn=find(~isnan(btemp)& btemp<99);
    if(length(isn)==1)
        wx=plot(btemp(isn),bdepth(isn),'wx');
        set(wx,'MarkerSize',10)
    end
    h=plot(btemp(isn),bdepth(isn),'w-');
    set(h,'LineWidth',1.3);
    
%    i=handles.currentprofile;
%    ss=keysdata.stnnum(i);
%    clear filenam
%    filenam=keysdata.prefix;
%    readbuddynetcdf;
%    isn=find(~isnan(btemp));
%    if(length(isn)==1)
%        wx=plot(btemp(isn),bdepth(isn),'wx');
%            set(wx,'MarkerSize',10)
%    end
%    h=plot(btemp(isn),bdepth(isn),'w-');
%    set(h,'LineWidth',1.3);
end

handles.stopbuds=0;

%add QC flags to plot and plot colored line of profile quality:
 
% handles.restrictbuddies=0;
 
printqflags

