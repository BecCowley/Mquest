function Mquest(username)

% usage: Mquest('username')
%  This function is used to launch Mquest and initialize variables.
%  it sets up the preferences for the user (which can be iota or
%  ann or lisa or mership or argo or ....) and then asks you if
%  you wish to change any parameters.

CONFIG

user = readUserInfotxt;

% if(~ispc)
%     pathelements
% end
newuser=0;
%user has entered a username
getuser=find(strcmp(username,user.user));

if(isempty(getuser))
    newuser = 1;
    if nargin < 1
        %this is a new user
        username=input('Please enter a new username [default: ''newuser'']: ','s');
        if isempty(username)
            username = 'newuser';
        end
    end
    getuser = length(user.user) + 1;
end

%add the new user information to the structure
user.usernumber = getuser;
user.showauto = 0;
if newuser==1
    user.user{end+1}=username;
    user.prefix{end+1}='unknown';
    user.mm{end+1}='All';
    user.yy{end+1}='All';
    user.qc{end+1}='1';
    user.auto{end+1}='1';
    user.timewindow{end+1}='1';
    user.sstyle{end+1}='unknown';
    saveuserinfo(user);
end
%call to gui 'selectuser'
selectuser(user);
