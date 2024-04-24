%% Repair the woce_time and time fields in the edited files after a bug
% was introduced in March, 2024.
% This code uses the keys file 0bs_t and time variable and replaces the
% woce-time variable if it doesn't match.

% Bec Cowley, April, 2024

%% first run the bash script: Mquest/Util/update_time_type.sh
% NEED TO EDIT IT FIRST! Change the folder path for the files you are
% fixing
% run the script from the command line

%% Now continue
clear
prefix=input('enter the database prefix:','s');
orig = input('enter the path to original TURO files:','s');
stnnum = str2num(ncread([prefix '_keys.nc'],'stn_num')');
obst = ncread([prefix '_keys.nc'],'obs_t');

%% let's extract the date/time information from the original files
turof = dir([orig '/*.nc']);
[tlat, tlon, turot] = deal(NaN*ones(length(turof),1));
tcruid = "";
for a = 1:length(turof)
    filn = [turof(a).folder '/' turof(a).name];
    %let's get time from rawdata.time and check against woce_time/woce_date
    tiunits = ncreadatt(filn,'time','units');
    tt = ncread(filn,'time');
    [turot(a),~]=cdfdate2num(tiunits,'gregorian',tt);
    %get the lat/lon for confirmation too
    tlat(a) = ncread(filn, 'latitude');
    tlon(a) = ncread(filn, 'longitude');
    tcruid(a) = ncreadatt(filn, '/','Voyage');
end

%%
updkeys = 0;
for aa=1:length(stnnum)
    
    %need to fix both ed and raw files:
    filen=getfilename(num2str(stnnum(aa)),0);
    filenamed=[prefix '/' filen];
    % check for a TE flag in the ed file before we continue. Need to
    % handle this or re-qc
    qc = ncread(filenamed,'Act_Code')';
    nhists = ncread(filenamed, 'Num_Hists');
    qc = qc(1:nhists,:);
    for bb = 1:nhists
        if matches('TE',qc(bb,:))
            disp('This file has a TIME change QC code, not handled in this code.')
            disp('Suggest ''kill'' the QC for this profile and re-run this code, then re-qc')
            disp(filenamed)
%             return
        end
    end
    
    filen=getfilename(num2str(stnnum(aa)),1);
    filenamraw=[prefix '/' filen];
    
    % read all the times:
    obstt = obst(:,aa)';
    wt = sprintf('%06d',ncread(filenamraw,'woce_time'));
    wted = sprintf('%06d',ncread(filenamed,'woce_time'));
    % bug introduced causes the woce_time value to be wrong. The 'time'
    % value is correct, can calculate woce_time from time.
    % In pre-bug files, the 'time' is incorrect and we can update it,
    % need to grab the time from the keys file
    % which doesn't have seconds, but better than nothing
    tiunits = ncreadatt(filenamraw,'time','units');
    tt = double(ncread(filenamraw,'time'));
    [ti,~]=cdfdate2num(tiunits,'gregorian',tt);
    tii = datestr(ti,'HHMMSS');
    %location
    lat = ncread(filenamraw,'latitude');
    lon = ncread(filenamraw,'longitude');
    
    tiunits = ncreadatt(filenamed,'time','units');
    tt = double(ncread(filenamed,'time'));
    [tied,~]=cdfdate2num(tiunits,'gregorian',tt);
    tiied = datestr(tied,'HHMMSS');
    %location
    lated = ncread(filenamed,'latitude');
    loned = ncread(filenamed,'longitude');
    % cruiseid
    cruid = strtrim(ncread(filenamed, 'Cruise_ID'));
    
    % checking again for ed/raw differences
    if lat~=lated | lon ~= loned | ti ~= tied
        % if no PE in flags, stop
        ok = 0;
        for bb = 1:nhists
            if matches('PE',qc(bb,:))
                ok = 1;
            end
            if matches('TE',qc(bb,:))
                ok = 1;
            end
        end
        if ~ok
            disp('Different lat/lon/date/time in ed and raw files for:')
            disp(filenamed)
            return
        end
    end
%     if ~matches(wt, wted)
%         disp('Different woce_times in ed and raw files')
%         disp(filenamed)
%         disp(['raw: ' wt ', ed: ' wted ', keys: ' obstt])
% %         keyboard
%     end
    datet = datestr(ti,'yyyymmdd');

    % let's take the opportunity to fix the time variable for everything
    wd = ncread(filenamraw, 'woce_date');
    if ti ~= datenum([num2str(wd) wt],'yyyymmddHHMMSS')
        if ~matches(tii(1:4),wt(1:4))
            if matches(num2str(wd),datet)
                % we can proceed to updating the time field, dates
                % match
                disp(['fixing time variable for: ' filenamed])
                wdt = datenum([num2str(wd) wt],'yyyymmddHHMMSS');
                tim = wdt - datenum('1900-01-01 00:00:00');
                ncwrite(filenamraw, 'time', tim);
                ncwrite(filenamed, 'time', tim);
                %assign the new time
                ti = wdt;
            else
                disp('Dates dont match, not updating time field')
                return
            end
        end
    end
    if ~matches(obstt,wted(1:4)) & (matches('000000',tiied) | ~matches(wt,wted))
        % post-bug situation, need to update woce_time and time variables
        % from original TURO files.
        % find the closest date/time information (within 1.5 minutes)
        [c,ii] = min(abs(ti - turot));
        %lat/lon confirmation
        [cc,jj] = min(abs(lat - tlat));
        [cc,kk] = min(abs(lon - tlon));
        if jj ~= kk & kk ~= ii
            if jj ~= kk | c > 3/60/24 %lat/lon should be same index, time within 3 minutes
                %             disp('No match for this profile in the turo dataset')
                %             disp(filenamraw)
                disp(cruid')
                continue
            end
        else
%             disp(filenamed)

            if contains(turof(kk).name, 'test')
                % need to use the index for the time match, not the lat/lon
                % match
                ind = ii;
            else
                ind = kk;
            end
            newwt = datestr(turot(ind),'HHMMSS');
            % confirm we are using the correct index, sometimes the ti is
            % closer to the next ii. Confirm with the obst value:
            [c2,ij] = min(abs(datenum([datet obstt],'yyyymmddHHMM') - turot));
            if kk ~= ii
                if ii ~= ij & kk ~= ij
                    disp(['time match: ' newwt ', keys match: ' datestr(turot(ij),'HHMMSS') ', raw: ' wt ', ed: ' wted ', keys: ' obstt])
                    choice = input('Use keys match [return] or use time match [1]?:','s');
                    if isempty(choice)
                        newwt = obstt;
                        ind = ij;
                    end
                end
            end
            % write out the correct woce_time
            disp(['fixing: ' filenamed])
            ncwrite(filenamraw, 'woce_time', single(str2num(newwt)))
            ncwrite(filenamed, 'woce_time', single(str2num(newwt)))
            % and update the time variable
            tim = turot(ind) - datenum('1900-01-01 00:00:00');
            ncwrite(filenamraw, 'time', tim);
            ncwrite(filenamed, 'time', tim);
            % check the keys time is correct
            if ~matches(obstt, newwt(1:4))
                disp(['correct time: ' newwt ', raw: ' wt ', ed: ' wted ', keys: ' obstt])
                disp(['Updating obs_t in keys for ' filenamed])
                obst(:,aa) = newwt(1:4)';
                updkeys = 1;
                continue
            end
        end
    end
    
    
end

%% update the keys file
if updkeys
    disp('Updating obs_t in keys file')
    ncwrite([prefix '_keys.nc'],'obs_t', obst);
end    
