function [buddykeysdata]=getbuddykeys(mmm,timewindow,u,qc,pref)

filen=[u{1} 'buddies.txt'];
try
    [buddyprefix]=textread(filen,'%s');
catch
        buddyprefix=[];
end
if(str2num(qc{1})==2)  
    buddyprefix{length(buddyprefix)+1}=pref;
end
buddykeysdata=[];
for jj=1:length(buddyprefix) 
    bkeysfile=[buddyprefix{jj} '_keys.nc'];
if(ispc)
    findslash=strfind(bkeysfile,'/');
    if(~isempty(findslash))
        bkeysfile(findslash)='\';
    end
else
    findslash=strfind(bkeysfile,'\');
    if(~isempty(findslash))
        bkeysfile(findslash)='/';
    end
end
    col=['g' 'b' 'y' 'r' 'g'];

    stationnumber=ncread(bkeysfile,'stn_num');

    month=ncread(bkeysfile,'obs_m')';
    year=ncread(bkeysfile,'obs_y')';
    day=ncread(bkeysfile,'obs_d')';
    time=ncread(bkeysfile,'obs_t')';
    latitude=ncread(bkeysfile,'obslat');
    longitude=ncread(bkeysfile,'c360long');
    autoqc=ncread(bkeysfile,'autoqc');
    callsign=ncread(bkeysfile,'callsign')';
    dsource=ncread(bkeysfile,'data_source')';
    priority=ncread(bkeysfile,'priority');
    stnnum=ncread(bkeysfile,'stn_num')';

 if(~isempty(strmatch('all',mmm{1})) | ~isempty(strmatch('All',mmm{1})))
    kk=1:length(month);   
 else
    mm=(findstr('janfebmaraprmayjunjulaugsepoctnovdec',mmm{1})+2)/3;
    if(isempty(mm))
        mm=(findstr('JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC',mmm{1})+2)/3;
        if(isempty(mm))
            mm=(findstr('JanFebMarAprMayJunJulAugSepOctNovDec',mmm{1})+2)/3;
        end
    end
    if(str2num(timewindow{1})==3)
%    if(strmatch(timewindow,'3','exact'))
        mv=mm-1:mm+1;
        mv(find(mv==0))=12;
        mv(find(mv==13))=1;
        k1=find(str2num(month(:,1:2))==mv(1) & str2num(day(:,1:2))>=15);
        k2=find(str2num(month(:,1:2))==mv(2));
        k3=find(str2num(month(:,1:2))==mv(3) & str2num(day(:,1:2))<=15);
        kk=[k1' k2' k3'];
    else
        kk=find(str2num(month(:,1:2))==mm);
    end
    if(isempty(kk))
        kk=1:length(month);
    end
    length(kk);

 end

number_of_buddy_profiles=length(kk)

buddykeysdata{jj}.time=str2num(time(kk,:));
buddykeysdata{jj}.day=str2num(day(kk,:));
buddykeysdata{jj}.month=str2num(month(kk,:));
buddykeysdata{jj}.year=str2num(year(kk,:));
buddykeysdata{jj}.obslat=latitude(kk);
buddykeysdata{jj}.obslon=longitude(kk);
buddykeysdata{jj}.callsign=callsign(kk,:);
buddykeysdata{jj}.stnnum=str2num(stnnum(kk,:));
buddykeysdata{jj}.priority=priority(kk,:);
buddykeysdata{jj}.datasource=dsource(kk,:);
buddykeysdata{jj}.prefix=buddyprefix{jj};

end


return

