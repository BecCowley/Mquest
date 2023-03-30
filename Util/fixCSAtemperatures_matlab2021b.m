%% restore incorrect CSA flagged temperatures
% Old CSA flag replaces temperatures with 99.99
% Restore these temperatures and replace the flag 5 with flag 3
%Bec Cowley, May 2022

clear
prefix=input('enter the database prefix:','s')
stn = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
for bb = 1:length(stn)
    stnn = stn(bb);
    for cc = 1:2
        raw=cc-1;
        filen=getfilename(num2str(stnn),raw);
        filenam=[prefix '/' filen];

        %find the CSA flags in the Act_Code field
        actc = ncread(filenam,'Act_Code');
        ii = find(contains(string(actc'),'CS'));
        if isempty(ii)
            continue
        end

        %if the version of the CSA is already 2.0, skip
        vers = ncread(filenam, 'Version');
        ij = find(contains(string(vers(:,ii)'),' 2.0'));
        if length(ij) == length(ii)
            continue
        end
        disp(stnn)
        %now replace the CSA fields in the file:
        %need to update these fields: Version to 2.0, 
        % Profparm to replace 99.99 with the values in Previous_Val field
        % ProfQP flag from 5 to 3
        prev = ncread(filenam, 'Previous_Val');
        temp = ncread(filenam,'Profparm');
        flag = ncread(filenam,'ProfQP');

        % if CSA is applied twice or more, there will be 99.99 values in
        % previous value field. Let's ignore these.
        ibad = str2num(prev(:,ii)') == 99.99;
        if any(ibad)
            ii = ii(~ibad);
        end
 
        
        %find the matching depths in the depth array
        deps = ncread(filenam,'Depthpress');
        auxid = ncread(filenam,'Aux_ID');
        [~,irep,~] = intersect(deps, auxid(ii));

        %restore the temps
        temp(:,:,irep) = str2num(prev(:,ii)');

        %update the version info for just CSA flags
        vers(:,ii) = repmat(' 2.0',length(ii),1)';

        %flag changes from 5 to 3
        flag(:,:,:,irep) = '3';

        %and now write it out
        ncwrite(filenam, 'Profparm', temp)
        ncwrite(filenam, 'Version', vers)
        ncwrite(filenam, 'ProfQP', flag)

    end
end
