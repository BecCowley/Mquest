%runconversion - 
%
%  function to copy old WNC format files to new MQNC file formats
%  the main change is in the types of some variables and one variable is
%  added.

prefix={input('Enter the database prefix:','s')}
mmm={'all'};
yy={'all'};
qc={'None'};
auto={'None'};
[keysdata]=getkeys(prefix,mmm,yy,qc,auto,'1','none');
[a,b,c]=textread('questAflags.txt','%3s %f %f');
h.acceptcode=a;
h.acceptlevel=b;
h.acceptplace=c;

% setup the reject menu:
clear a
clear b
clear c
[a,b,c]=textread('questRflags.txt','%3s %f %f');
h.rejectcode=a;
h.rejectlevel=b;
h.rejectplace=c;

%for i=1:length(keysdata.stnnum)
for i=2862:length(keysdata.stnnum)
    i=i
    ss=keysdata.stnnum(i);
    convertWNCtoMQNCfiles(prefix,ss,h);
end
