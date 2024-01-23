% bulk fix of serial numbers based on a line of best fit to correct serial
% and batch date information:
%using investigator dataset, after running the first two cells of
%fix_batch_serial_info.m

ifix = find(serial >1000000 & batch<datenum('01-Jan-2023'));
p = polyfit(batch(ifix),serial(ifix),1);
x1 = min(batch):10:max(batch);
y1 = polyval(p,x1);
plot(x1,y1,'k');

% now fix the bad batch dates and bring them into line with the line of
% best fit
mdl = fitlm(batch(ifix),serial(ifix));

% % plot it
% figure(2);clf
% plot(mdl)
% 
% % ok, now correct anything with a residual > XX from the line
% plotResiduals(mdl)
% grid

% use > 30000 absolute cutoff
res = table2array(mdl.Residuals(:,'Raw'));
ibad = find(abs(res) > 30000);
plot(batch(ifix(ibad)),serial(ifix(ibad)),'k.','MarkerSize',12)

% now, the assumption is that the serial numbers are correct, so we are
% adjusting the batch dates
% have equation of y = mx + c
% where p has the slope (m) and intercept (c)
% rearrange for x:
%   x = (y-c)/m
newx = NaN*ones(size(ifix));
for a = 1:length(ibad)
    newx(ibad(a)) = (serial(ifix(ibad(a))) - p(2))/p(1);
end
% assign and plot
newb = batch;
newb(ifix(ibad)) = newx(ibad);
figure(3)
plot(newb,serial,'r.','MarkerSize',12)

%% recalculate the model with the updated data

ifix = find(serial >1000000 & newb<datenum('01-Jan-2023'));
p = polyfit(newb(ifix),serial(ifix),1);
y1 = polyval(p,x1);
plot(x1,y1,'r');

%% now fix the bad batch dates and bring them into line with the line of
% best fit
ibad = find(newb >=  datenum('01-Jan-2023') & ~isnan(serial));
newx = NaN*ones(size(ibad));
for a = 1:length(ibad)
    newx(a) = (serial(ibad(a)) - p(2))/p(1);
end
% assign and plot
newb(ibad) = newx;
figure(3)
plot(newb,serial,'g.','MarkerSize',12)

%% now back to fix_batch_serial_info to write back to files and check
batch = newb;