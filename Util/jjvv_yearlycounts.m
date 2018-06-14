%Can use this command in terminal to get a count of files in the directory
% find *.sbd -newermt "01 Jan 2015" ! -newerct "31 Dec 2015" -ls | wc

clear
datapath = '/home/UOT/programs/xbt2gts_programs/SBDmessages_processed/';

yr = '2017';
%%
% get the directory listing
d=dir([datapath '*sbd']);
b=1;

warning off
for a=1:length(d)
    if d(a).datenum < datenum(['01/01/' yr],'dd/mm/yyyy') | d(a).datenum > datenum(['31/12/' yr],'dd/mm/yyyy')
        continue
    end
    disp(num2str(a))
    dd=strfind(d(a).name,'_');
    if(~isempty(dd))
        sbd=d(a).name(1:dd-1);
        filename = [datapath d(a).name];
        [jjvv,y,mm,daya,lat,lon] = read_SBD_function(filename);
        if isempty(jjvv)
            continue
        end
        
        % now keep track of callsign:
        ii = strfind(jjvv,'=NNNN');
        jj = strfind(jjvv,' ');
        if jjvv(15) == yr(end) %limit to the year of interest
            call{b} = jjvv(jj(end)+1:ii-1);
            yy{b} = jjvv(15);
            year(b) = y;
            mon(b) = mm;
            day(b) = daya;
            lt(b) = lat;
            ln(b) = lon;
            b = b+1;
        end
    end
end


%% plot
figure(1);clf
plot(ln,lt,'x')
hold on
coast
%% extract the number for each callsign:
%discount transmitted test profiles
itest = find(lt < -20 & lt > -30 & ln > 129 & ln <134);
call(itest) = {'test'};
c = unique(call);

for a = 1:length(c)
    ii = cellfun(@isempty,strfind(call,c{a}));
    ii = sum(ii==0);
    disp([c{a} ' = ' num2str(ii) ' jjvv messages sent'])
end

disp(['Total = ' num2str(length(call))])
