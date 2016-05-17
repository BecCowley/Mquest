% fixes the missing value flag in 'prof_Qparm' to 0 from 5
% also records the number and names of files requiring fixing so that
% archives can be replaced
% Operates on all databases in the current directory. Looks for the
% *_keys.nc files to operate on.
%Rebecca Cowley 22 Aug, 2012

clear
%% set up the output directory for the master list of files: 
%Ping,edit this path before running, and edit the 'filn' extension if
%needed
outp = '/home/UOT-data/quest/fixed_flags_masterlist.txt';

% get the list of keys files:
filn = dir('*_keys.nc');

%%
disp([num2str(length(filn)) ' databases found'])
pause(2)

%% now run through each file:
for a = 1:length(filn)
    %get the database prefix (without the _keys.nc extension)
    prefix=filn(a).name(1:length(filn(a).name)-8);
    p={prefix};
    m={'All'};
    y={'All'};
    q={'1'};
    aa={'1'};
    tw={'1'};
    sstyle={'None'};
    try
        [kd]=getkeys(p,m,y,q,aa,tw,sstyle);
    catch
        disp([filn(a).name ' not MQNC database'])
        pause(2)
        continue
    end        
    if ~isfield(kd,'stnnum') %not an MQNC database
        disp([filn(a).name ' not MQNC database'])
        pause(2)
        continue
    end
    pause(2)
    stn = kd.stnnum;
    %% Now run through each file in the database:
    stned = [];stnrw=[];
    %%
    for b = 1:length(stn)
        %edited file first
        raw=0;
        filen=getfilename(num2str(stn(b)),raw)
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        %open the netcdf file for writing
        nc=netcdf(filenam,'write');
        np = nc{'No_Prof'}(:);
        %for each profile:
        for c = 1:np
            %get the profparm and qc data
            nd = nc{'No_Depths'}(c);
            if nd == 0
                continue
            end
            pp = nc{'Profparm'}(c,:,1:nd,:,:);
            pq = nc{'ProfQP'}(c,:,1:nd,:,:,:);
            kk=find(pp > 99 & pp < 100);
            if ~isempty(kk)
                pqq = str2num(pq(kk));
                if ~isempty(pq);
                    %check that the conversion above has worked:
                    %find the missing values (chopped surface spikes usually)
                    %check that the corresponding qc flag is set at 5, if not, change
                    %it.
                    jj = find(pqq ~= 5);
                    if ~isempty(jj)
                        pqq(jj) = 5;
                        pq(kk) = num2str(pqq);
                        %write the new values to the netcdf file
                        nc{'ProfQP'}(c,:,1:nd,:,:,:) = pq;
                        %record the information:
                        fid = fopen([prefix '_missvalflag_ed.txt'],'a');
                        fprintf(fid,'%d\n',stn(b));
                        fclose(fid);
                        stned = [stned;stn(b)];
                        
                    end
                else
                    disp('Empty quality flags!')
                    return
                end
            end
        end
        
        %close the file
        close(nc)
        
        
        
        %check the raw version too (should not be any here)
        raw=1;
        filen=getfilename(num2str(stn(b)),raw)
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        
        nc=netcdf(filenam,'write');
        np = nc{'No_Prof'}(:);
        %for each profile:
        for c = 1:np
            %get the profparm and qc data
            nd = nc{'No_Depths'}(c);
            if nd == 0
                continue
            end
            pp = nc{'Profparm'}(c,:,1:nd,:,:);
            pq = nc{'ProfQP'}(c,:,1:nd,:,:,:);
            kk=find(pp > 99 & pp < 100);
            if ~isempty(kk)
                pqq = str2num(pq(kk));
                if ~isempty(pq);
                    %check that the conversion above has worked:
                    %find the missing values (chopped surface spikes usually)
                    %check that the corresponding qc flag is set at 5, if not, change
                    %it.
                    jj = find(pqq ~= 5);
                    if ~isempty(jj)
                        pqq(jj) = 5;
                        pq(kk) = num2str(pqq);
                        %write the new values to the netcdf file
                        nc{'ProfQP'}(c,:,1:nd,:,:,:) = pq;
                        %record the information:
                        fid = fopen([prefix '_missvalflag_raw.txt'],'a');
                        fprintf(fid,'%d\n',stn(b));
                        fclose(fid);
                        stnrw = [stnrw;stn(b)];
                    end
                else
                    disp('Empty raw quality flags!')
                    return
                end
            end
        end
        
        %close the file
        close(nc)
                
    end
    
    if ~isempty(stned)
        %output the file name to a master list
        fid = fopen(outp,'a');
        fprintf(fid,'%s\n',[pwd '/' prefix ', ed'] )
        fclose(fid)
    end
    if ~isempty(stnrw)
        %output the file name to a master list
        fid = fopen(outp,'a');
        fprintf(fid,'%s\n',[pwd '/' prefix ', raw'])
        fclose(fid)
    end
    
    
    
end