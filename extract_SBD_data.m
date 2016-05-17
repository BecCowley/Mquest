% extract SBD data - reads the SBD messages from the iridium devil
% transmitters and converts them to bathy messages for distribution to the
% GTS.
%
% modified to handle soloII sbd data - October 2012 : AY


cd /home/UOT/programs/Mquest
datapath='/home/UOT/programs/Mquest/SBDmessages/';
system('/home/UOT/programs/Mquest/newsbd.pl');
%load matfile for plotting:
load ([datapath 'sbddata.mat'])
%purge older data:
today=julian(clock);
kk=find(juldp<=today-30);
juldp(kk)=[];
latp(kk)=[];
lonp(kk)=[];
callsp(kk,:)=[];
newest(kk)=[];
newest(1:end)=0;
savemat=(['save ' datapath 'sbddata.mat juldp latp lonp callsp newest;']);
eval(savemat);


a=dirc([datapath '*sbd']);

[m,n]=size(a);
if(m>0)
    for i=1:m
        
        dd=strfind(a{i,1},'_');
        if(~isempty(dd))
            sbd=a{i,1}(1:dd-1);
        end

        if(a{i,6})
            
        else
            clear t
            clear d
            clear gg
            clear dd
            clear g
            Idata=[];
            Idata=Idata';
            filenam=a{i,1}
            fid=fopen([datapath a{i,1}]);
            gg=fread(fid);
            Idata=[Idata gg'];
            fclose(fid);
            ch=char(Idata(6:7));
            textm=[];

            if(isempty(strmatch('C2',ch)) & isempty(strmatch('C3',ch)));
                %this is not a profile message - treat as text and output
                %to the report:
                textm=char(Idata)
                fid=fopen('textmessage.txt','w');
                fprintf(fid,'%s',textm);
                fclose(fid);
                system(['cat textmessage.txt | mailx -s"Devil text msg" ' 'ann.thresher@csiro.au, marine_obs@bom.gov.au, craig.hanstein@csiro.au, alan.poole@csiro.au, rebecca.cowley@csiro.au']);

            else

                seq=h2b(Idata(1:2),1);
                parcn=str2num(convhex2bin(num2str(Idata(3))));
                numparc=str2num(convhex2bin(num2str(Idata(4))));
                if(numparc>1)
                    seq2=seq;
                    parcn2=parcn;
                    while(parcn2<numparc && seq2==seq)
                        i=i+1;
                        lId=length(Idata);
                        if(~a{i,6})
                            fid=fopen([datapath a{i,1}]);
                            gg=fread(fid);
                            Idata=[Idata gg'];
                            fclose(fid);
                        end
                        parcn2=convhex2bin(num2str(Idata(lId+1)));
                        seq2=h2b(Idata(lId+2:lId+3),1);
                        if(seq2~=seq)
                            Idata(lId+1:end)=[];
                            i=i-1;
                            break
                        else
                            Idata(lId+1:lId+5)=[];
                        end
                    end
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
                end

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

                %construct tesac and send to GTS if bit is set:
                file=[datapath deblank(calls) '_' num2str(Drop) '.jjvv']

                fid=fopen(file,'w');


                %create tesac
                try
                    XBT_SBDtoJJVV
                catch
                    buffer=[];
                end

                %output to file:
                if(~isempty(buffer))
                    count=fprintf(fid,'ZCZC\n');
                    count=fprintf(fid,'%s',buffer);
                    count=fprintf(fid,'\nNNNN');
                    fclose(fid);
                end

                if(gts & ok)
                    %send tesac:
                    %system(['cat ' file ' | mailx -s"GTS msg" ' 'ann.thresher@csiro.au,
                    %ljc@bom.gov.au, cmssdata@bom.gov.au']);
                    system(['cat ' file ' | mailx -s"GTS msg" ' 'ann.thresher@csiro.au, cmss@bom.gov.au, Sebastien.Mancini@utas.edu.au, l.krummel@bom.gov.au, rebecca.cowley@csiro.au']);

                    %save data to mat file for plotting: (only do this if it's valid data
                    % and not tests)
                    juldp(end+1)=julian([thisyear mm day hh minu 00]);
                    latp(end+1)=lat;
                    lonp(end+1)=lon;
                    callsp(end+1,:)=calls;
                    newest(end+1)=1;

                    savemat=(['save ' datapath 'sbddata.mat juldp latp lonp callsp newest;']);
                    eval(savemat)

                else
                    ['gts bit not set or too old - not sent to GTS, file= ' a{i,1}]
                    system(['cat ' file ' | mailx -s"bad GTS msg" ' 'ann.thresher@csiro.au, rebecca.cowley@csiro.au']);

                end
            end %if is not directory...

        end %is this a text message?
        % to next input file:
    end

    %copy all files to the ftp directory /home/ftp/pub/gronell/SBDdata and
    %chmod
     system(['cp /home/UOT/programs/Mquest/SBDmessages/*sbd /home/ftp/pub/gronell/SBDdata']);
     system(['chmod 664 /home/ftp/pub/gronell/SBDdata/*']);
% 
    %move all files to 'processed' directory:
    system(['mv /home/UOT/programs/Mquest/SBDmessages/*sbd /home/UOT/programs/Mquest/SBDmessages_processed']);

    %create plots:
    load ([datapath 'sbddata.mat']);
    unicalls=unique(callsp(:,:),'rows');
    [m,n]=size(unicalls);
    col=xtemperature(m+1);

    %add depth contours to make the points more obvious:
    figure
    axis([100 180 -70 0])
    v=axis
    gebco
    hold on
    if ~exist('hb')
        addpath /home/dunn/matlab
        xb = getnc('/home/netcdf-data/terrainbase','lon');
        yb = getnc('/home/netcdf-data/terrainbase','lat');
        ix = find(xb > v(1) & xb < v(2));
        ix = [1:length(xb)];
        iy = find(yb > v(3) & yb < v(4));

        hb = -1*getnc('/home/netcdf-data/terrainbase','height',[min(iy) min(ix)],[max(iy) max(ix)]);
        vx = xb(ix);
        vy = yb(iy);
    end

    contourf(vx,vy,hb,[0:100:2000]);
    caxis([0,2000]);

    for i=1:m
        ll=strmatch(unicalls(i,:),callsp,'exact');
        gg=find(newest(ll)==1);
        gt=find(newest(ll)==0);
        h=plot(lonp(ll(gt)),latp(ll(gt)),'color',col(i+1,:),'marker','x','LineStyle','none')
        set(h,'MarkerSize',10)
        hold on
        h=plot(lonp(ll(gg)),latp(ll(gg)),'gx')
        set(h,'MarkerSize',10)
    end
    title('latest SBD data received in GREEN')
    xlabel('longitude')
    ylabel('latitude')
%     print -djpeg latestSBDdata.jpg
try
    print -dtiff latestSBDdata.tif
catch
    save_fig('latestSBDdata.tif')
end
    system(['cat SBDletterheader.txt | mailx -s"SBDplots" -a"latestSBDdata.tif" ann.thresher@csiro.au alan.poole@csiro.au craig.hanstein@csiro.au marine_obs@bom.gov.au rebecca.cowley@csiro.au'])
end

