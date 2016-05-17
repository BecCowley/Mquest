% Collate nutrients and T & S into casts are dump to ascii files
%
% Output: One file per cast, format:
%   Rec1:  CPN lat lon
%   Rec2:  Year month day
%   Rec2+(1:ndeps):  depth T S O2 Si P NO3
%
% JRD 11/10/01, 22/4/08
%edited to suit MQNC to ascii - Bec Cowley, 2012

%
%    *** HARD-CODED for number of properties (presently 6) ****
%
clear
dirn = '/home/UOT-data/quota/IO/ascii/';
dset = '/home/UOT-data/quota/IO/masterio';
%first load up the keys file:
p={dset};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
kd=getkeys(p,m,y,q,a,tw,sstyle);

reg = [30 120 -30 30];
vars = [1 2 ]; %temperature and salinity (if available)
% trng = [datenum([1850 1 1 0 0 0]) inf];

%subset the data by lat/lon ranges to make smaller files:
x = reg(1):5:reg(2);
y = reg(3):5:reg(4);
stnn = [];
for a = 1:length(x)-1
    for b = 1:length(y)-1
        rng = [x(a) x(a+1) y(b) y(b+1)];
        [la,lo,stn,tim,deep_d,dtyp,cruise,calls,v1,v2,v3,v4] = ...
            get_MQNC_data(kd,rng,vars,dset,[],[],[],[]);
        if isempty(la)
            continue
        end
        
        %keep track of station numbers to avoid duplicates in multiple
        %files
        [c, ia, ib] = intersect(stnn,stn);
        if ~isempty(c)
            %remove these profiles, already written to another file
            v1(ib,:) = [];
            v2(ib,:) = [];
            v3(ib,:) = [];
            v4(ib,:) = [];
            dtyp(ib,:) = [];
            stn(ib) = [];
            la(ib) = [];
            lo(ib) = [];
            tim(ib) = [];
            deep_d(ib) = [];
            cruise(ib,:) = [];
            calls(ib,:) = [];
        end
        stnn = [stnn;stn];
       
        dtim = datestr(tim(:));
        [ncast,junk] = size(v1);
        if ncast == 0
            continue
        end
        
        fid = fopen([dirn 'ts' num2str(rng(1)) '_' num2str(rng(2)) '_' num2str(rng(3)) '_' num2str(rng(4)) '.asc'],'w');
        for kk = 1:ncast
            igood = ~isnan(v1(kk,:));
            nt = sum(igood);
            tem = [v1(kk,igood); v2(kk,igood)]; 
            igood = ~isnan(v3(kk,:));
            ns = sum(igood);
            sal = [v3(kk,igood);v4(kk,igood)];
            fprintf(fid,'%d,%6.3f,%6.3f,%s,%s,%s,',stn(kk),la(kk),lo(kk),dtyp(kk,:),cruise(kk,:),calls(kk,:));
            fprintf(fid,'%s,%d, %s,',dtim(kk,:),nt,'TEMP');
            fprintf(fid,'%5.3f,%5.3f,',tem(:));
            fprintf(fid,'\n');
            if ns > 0 %if there is salinity data
                fprintf(fid,'%d,%6.3f,%6.3f,%s,%s,%s,',stn(kk),la(kk),lo(kk),dtyp(kk,:),cruise(kk,:),calls(kk,:));
                fprintf(fid,'%s,%d, %s,',dtim(kk,:),ns,'SALT');
                fprintf(fid,'%5.3f,%5.3f,',sal);
                fprintf(fid,'\n');
            end
        end
        fclose(fid);
    end
end

%% plot locations:
[c,ia,ib] = intersect(stnn,kd.stnnum);
figure(1);clf
plot(kd.obslon(ib),kd.obslat(ib),'.')
hold on
coast