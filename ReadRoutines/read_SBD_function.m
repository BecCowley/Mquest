% function jjvv = read_SBD_function(filename)
% extract SBD data - reads the SBD messages from the iridium devil
% transmitters and converts them to jjvv text messages.
% modified from extract_SBD_data.m which is used to create the GTS messages
% This version is for checking old SBD profiles.
% Bec Cowley, March, 2015

function [jjvv,yy,mm,day,lat,lon] = read_SBD_function(filename)

fid=fopen(filename);
gg=fread(fid);
fclose(fid);
Idata=[];
% Idata=Idata';
Idata=[Idata gg'];
ch=char(Idata(6:7));
textm=[];

if(isempty(strmatch('C2',ch)) & isempty(strmatch('C3',ch)));
    %this is not a profile message - return
    [jjvv,yy,mm,day,lat,lon] = deal([]);
return    
else
    
    seq=h2b(Idata(1:2),1);
    parcn=str2num(convhex2bin(num2str(Idata(3))));
    numparc=str2num(convhex2bin(num2str(Idata(4))));
    if(numparc>1)
        disp('At numparc > 1!') %diagnostic testing
        keyboard
%         seq2=seq;
%         parcn2=parcn;
%         while(parcn2<numparc && seq2==seq)
%             i=i+1;
%             lId=length(Idata);
%             if(~a{i,6})
%                 fid=fopen([datapath a{i,1}]);
%                 gg=fread(fid);
%                 Idata=[Idata gg'];
%                 fclose(fid);
%             end
%             parcn2=convhex2bin(num2str(Idata(lId+1)));
%             seq2=h2b(Idata(lId+2:lId+3),1);
%             if(seq2~=seq)
%                 Idata(lId+1:end)=[];
%                 i=i-1;
%                 break
%             else
%                 Idata(lId+1:lId+5)=[];
%             end
%         end
    end
    
    bina(1:8)='0';
    ddata=[];
    for j=6:length(Idata)
        %idd=hex2dec(num2str(Idata(j)));
        aa=dec2bin(Idata(j));
        %        aa=dec2bin(idd);
        bina(1:8)='0';
        bina(8-length(aa)+1:8)=aa;
        ddata=[ddata bina];
    end
    
    kk=length(Idata);
    
    ID=bin2dec(ddata(1:16));
    dd=date;
    thisyear=str2num(dd(end-3:end));
    Drop=bin2dec(ddata(17:24));
    yy=bin2dec(ddata(25:28));
    if(yy==mod(thisyear,16));
        yy=thisyear;
    else
        yy=thisyear-(mod(thisyear,16)-yy);
        if yy > thisyear
            %calculated date greater than 2016. ddata is from  2015 or earlier and this
            %year is 2016
            yy = 2000 + bin2dec(ddata(25:28));
        end
    end
%     ID=bin2dec(ddata(1:16));
%     dd=date;
%     thisyear=dd(end-3:end);
%     Drop=bin2dec(ddata(17:24));
%     yy=bin2dec(ddata(25:28));
%     yy = str2num([thisyear(1:2) num2str(yy)]);
    mm=bin2dec(ddata(29:32))+1;
    day=bin2dec(ddata(33:37));
    
    hh=bin2dec(ddata(38:42));
    minu=bin2dec(ddata(43:48));
    
    
    lon=bin2dec(ddata(49:68))/2900;
    lat=(bin2dec(ddata(69:88))/2900)-90.;
    
    gts=bin2dec(ddata(89));
    
    np=bin2dec([ddata(90:95) ddata(113:120)]);
    IfaceC=bin2dec(ddata(96:102));
    peq=bin2dec(ddata(103:112));
    
    calls=[char(bin2dec(ddata(121:128))) char(bin2dec(ddata(129:136)))...
        char(bin2dec(ddata(137:144))) char(bin2dec(ddata(145:152)))...
        char(bin2dec(ddata(153:160))) char(bin2dec(ddata(161:168)))...
        char(bin2dec(ddata(169:176))) char(bin2dec(ddata(177:184)))...
        char(bin2dec(ddata(185:192)))];
    dd=193;
    g=1;
    while (dd<length(ddata)-23)
        t(g)=bin2dec(ddata(dd:dd+12))/200-3;
        d(g)=bin2dec(ddata(dd+13:dd+23))/2;
        dd=dd+24;
        g=g+1;
    end
    
    %construct jjvv code:    
    
    %create tesac
    try
        buffer = xbt2jjvv(yy,mm,dd,hh,minu,lat,lon,day,t,peq,IfaceC,d,calls);
    catch
        buffer=[];
    end
    
    %output to file:
    if(~isempty(buffer))
       jjvv = ['ZCZC ' buffer 'NNNN'];
    else
     [jjvv,yy,mm,day,lat,lon] = deal([]);
    end
end
end
%%
    function buffer = xbt2jjvv(yy,mm,dd,hh,minu,lat,lon,day,t,peq,IfaceC,d,calls)
        % XBT_SBDtoJJVV - converts SBD message from devil system to JJVV and mails
        % it to Lisa, me and the GTS:
        
        buffer=[];
        
        buffer='JJVV ';
        
        %first check the QC of the profile - if bad, skip out and finish...
        
        Pdate=[yy mm day hh minu];
        ok=check_prof_qc(lat,lon,t,d,Pdate);
        
        if(~ok)
            buffer=[];
            return
        end
        
        y=num2str(yy);
        y2=str2num(y(end));
        
        strd=sprintf('%2.2d%2.2d%1.1d',day,mm,y2);
        buffer=[buffer strd ' '];
        
        strd=sprintf('%2.2d',hh,minu);
        buffer=[buffer strd '/ '];
        
        lonstr=sprintf('%6.6i',round(lon*1000));
        
        if lat<=0 & lon<=0;quadrant=5;end
        if lat<=0 & lon>=0;quadrant=3;end
        if lat>=0 & lon<=0;quadrant=7;end
        if lat>-0 & lon>=0;quadrant=1;end
        
        latstr=[num2str(quadrant) sprintf('%5.5i',abs(round(lat*1000)))];
        
        buffer=[buffer latstr ' ' lonstr ' 88888 '];
        
        syspty=sprintf('%3.3d%2.2d',peq,IfaceC);
        
        buffer=[buffer syspty ' '];
        
        %remove redundant depth data:
        
        for ii=1:length(t)
            tnum(ii)=round(t(ii)*10);
            if(tnum(ii)<0)
                tnum(ii)=500+abs(tnum(ii));
            end
            tarr(ii,:)=sprintf('%3.3d',tnum(ii));
            dnum(ii)=round(d(ii));
            darr(ii,:)=sprintf('%2.2d',rem(dnum(ii),100));
            d100(ii)=floor(dnum(ii)/100);
        end
        
        difftnum=diff(tnum);
        kk=find(difftnum==0);
        
        dd=diff(kk);
        ll=find(dd==1);
        
        if(~isempty(ll))
            tarr(kk(ll+1),:)=[];
            darr(kk(ll+1),:)=[];
            d100(kk(ll+1))=[];
        end
        
        d999=0;
        for k=1:length(d100)
            if(d100(k)~=d999)
                buffer=[buffer '999' sprintf('%2.2d',d100(k)) ' '];
                d999=d100(k);
            end
            buffer=[buffer darr(k,:) tarr(k,:) ' '];
        end
        
        buffer=[buffer deblank(calls) '=']
        
    end
%%
    function ok = check_prof_qc(lat,lon,t,d,Pdate)
%     same as original function, but taken out the too old test
ok=1;
%Test 1: impossible or too old date test:
%removed
% today=datestr(now,31);
%     %check for impossible bits:
%     if((Pdate(1)<str2num(today(1:4)) | (Pdate(1)==str2num(today(1:4))-1 & Pdate(2)~=12)) | Pdate(2)<1 | Pdate(2)>12 | Pdate(3)<1 | Pdate(3)>31 ...
%             | Pdate(4)<0 | Pdate(4)>24 | Pdate(5)<0 | Pdate(5)>59)
%         ok=0;
%         ['impossible date - Pdate=' num2str(Pdate)]
%         return
%     end
    
    %Test 2:  impossible location:
    calc_depths_SBD;
    if(max(depth_range_near_topo)==0)
        ok=0;
        ['position on land - lat=' num2str(lat) ', lon=' num2str(lon)]
        return
    end
    
    if(lat<-90 | lat > 90 | lon<0 | lon > 360)
        ok=0;
        ['position impossible - ' num2str(lat) ', lon=' num2str(lon)]
        return
    end
    
    
%     %Test 4: Spike test:
%     bdt = findspike(t,d,'t');
%     if ~isempty(bdt)
%         %remove the spike point from the profile:
%         t(bdt)=[];
%         d(bdt)=[];
%     end
    
%     
%     %Test 6: Global range test:
%     jj = find(t<=-2.5 | t>40.);
%     if ~isempty(jj)
%         % remove data from profile:
%         t(jj)=[];
%         d(jj)=[];
%     end
    
    %Test 3 - data integrity - moved to end
    if(length(t)<1 | length(d)<1)  %no data to send...
        ok=0;
        ['no data ']
        return
    end
    end