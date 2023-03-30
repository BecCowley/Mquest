% Find specific codes in the database

clear
nms = dir('*keys.nc');
%%
for bb = 5%1:length(nms);
    prefix=nms(bb).name(1:end-8);
    stnnum = str2num(ncread(nms(bb).name,'stn_num')');
    disp(prefix)
    
    %%
    for aa=1:length(stnnum)
        
        raw= 0;
        filen=getfilename(num2str(stnnum(aa)),raw);
        filenam=[prefix '/' filen];
        if ~exist(filenam,'file')
            continue
        end
        dt = ncread(filenam,'Data_Type')';
        if isempty(strmatch('XB',dt))
            continue
        end
        qc=ncread(filenam,'Act_Code');
        kk=strmatch('PS',qc');
        if isempty(kk)
            continue
        end
        depth=squeeze(ncread(filenam,'Depthpress'));
        temp = squeeze(ncread(filenam,'Profparm'));
        depqc=ncread(filenam,'Aux_ID');
        ndeps = ncread(filenam,'No_Depths');
        flags = squeeze(ncread(filenam,'ProfQP'));
        flags = str2num(flags(1:ndeps));
        
        %we want rejects /accepts
%         qcd = depqc(kk);
% %         %what flag is at these depths?
%         ii = find(abs(depth-qcd(1)) < 0.5);
%         if ~isempty(ii)
%             %             if any(flags(ii) > 2 & flags(ii) <5)%rejects
%             if any(flags(ii) < 3)%accepts
                disp(stnnum(aa))
                disp(qc(:,1:15)')
                
                %plot them for a quick check
                figure(1);clf
                plot(temp,depth,'k-')
                axis ij
                pause
%             end
%         else
%             disp('mismatch in auxid and depths')
%             disp(stnnum(aa))
%             
%             keyboard
%         end
                end
end
