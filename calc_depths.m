% Generate the set of depths
% based on z = at + 10exp-3 * bt^2, where t is
% in 0.1s increments. a=6.691, b=-2.25;

a=6.691;
b=-.00225;
t=0.1:0.1:300;  %to 1800m ish

z = (a.*t) + (b*t.^2);
%zpeq = [1,2,31,32,41,42,51,52,201,202,211,212,221,222];

