%Can use this command in terminal to get a count of files in the directory
% find *.sbd -newermt "01 Jan 2015" ! -newerct "31 Dec 2015" -ls | wc

clear
datapath = '/home/UOT/programs/Mquest/SBDmessages_processed/';

yr = '2015';
%%
% get the directory listing
d=dirc([datapath '*sbd'],'f');
b=1;

[m,n]=size(d);
if(m>0)
    for a=1:m
        disp([num2str(a) ' of ' num2str(m)])
        dd=strfind(d{a,1},'_');
        if(~isempty(dd))
            sbd=d{a,1}(1:dd-1);
            filename = [datapath d{a,1}];
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
