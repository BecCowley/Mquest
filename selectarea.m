% selectarea.m - for matlab subsetting of the archive 2m data.

archive_dir='/home/UOT/archives/XBT/archive2m/'
a=dirc([archive_dir '*.datn']);

[m,n]=size(a);
clear latrange lonrange timerange

latrange=input('enter latitude range required - <cr>=all, or enter [## ##]  ')
if(isempty(latrange))
    latrange=[-90 90]
end
lonrange=input('enter longitude range required (west is negative) - <cr>=all, or enter [## ##]   ')
if(isempty(lonrange))
    lonrange=[-180:180]
end

timerange=input('enter the time limits required (yyyymmdd format) - <cr>=all, or enter [## ##]   ')
if(isempty(timerange))
    timerange=[0 30000000]
end

outfile=input('enter the output file name:','s')

fid2=fopen(outfile,'w');
inarea=0;

for i=1:m
    file=a{i,1}
    fid=fopen([archive_dir a{i,1}]);
        
    datl=fgetl(fid);
       
    while datl~=-1
        
        if(isempty(~strmatch(datl(1:4),'    ')))  %header line
            inarea=0;
            datex=str2num(datl(10:17));
            latx=str2num(datl(23:24)) + str2num(datl(25:26))/60;
            if strmatch(datl(27),'S')
                latx=-latx;
            end
            lonx=str2num(datl(28:30)) + str2num(datl(31:32))/60;
            if strmatch(datl(33),'W')
                lonx=-lonx;
            end
            
            if latx <=  max(latrange) & latx >= min(latrange) & ...
                    lonx <=  max(lonrange) & lonx >= min(lonrange) & ...
                    datex <= max(timerange) & datex >= min(timerange)
                
                inarea=1;
                
                fprintf(fid2,'%s\n',datl);
            end
            
        elseif inarea
            fprintf(fid2,'%s\n',datl);
        else
            
        end
            
        datl=fgetl(fid); 
        
    end

    fclose(fid);
    
end

fclose(fid2);

