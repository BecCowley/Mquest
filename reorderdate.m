%quick script to reverse the order of a character array of dates:
function output=reorderdate(input);

if(length(input)<8)
    return
end
output(1:4)=input(5:8);
output(5:6)=input(3:4);
output(7:8)=input(1:2);
return

