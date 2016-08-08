function [out1,out2] = range(a)

% RANGE   If matrix A has minimum value L and maximum value U,
%         then RANGE(A) is [L,U]. NaN's are ignored.
%         RANGE can also be used with a multiple assignment,
%                [L,U] = RANGE(A).

index=find(~isnan(a));
minv=min(a(index));
maxv=max(a(index));
if nargout==2
  out1=minv;
  out2=maxv;
else
  out1=[minv,maxv];
end
