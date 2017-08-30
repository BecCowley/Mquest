function profiledata = calc_depths(probetype,profiledata)
% Generate the set of depths
% based on z = at + 10exp-3 * bt^2, where t is
% in 0.1s increments. a=6.691, b=-2.25;
pt = str2num(probetype);
switch pt
    case {1,31,41,51}
        %Sippican deep blue, t7
        a=6.691;
        b=-.00225;
    otherwise
        %not coded for other types
        disp('This probe type is not coded for a change of depth calculation')
        keyboard
        return            
end
% Generate the set of depths
% based on z = at + 10exp-3 * bt^2, where t is
% in 0.1s increments. a=6.691, b=-2.25;

[m,n]=size(profiledata.Depthpress);

for aa = 1:n
    t=0.1:0.1:400; %to 1800m ish
    
    z = (a.*t) + (b*t.^2);
    if profiledata.Depthpress(1,aa) == 0
        z = [0 z];
    end
    profiledata.Depthpress(:,aa) = z(1:size(profiledata.Depthpress(:,aa),1));
end
