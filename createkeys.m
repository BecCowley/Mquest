%createkeys - this creates an empty keys file for new databases:

    newkeysfile=netcdf([keysfile ],'noclobber');

    % create the dimensions
newkeysfile('N_Casts')=0;
if isempty(newkeysfile('N_Casts')), error('##Unable to create dimension N_Casts'),end
newkeysfile('String_1')=1;
if isempty(newkeysfile('String_1')), error('##Unable to create dimension String_1'),end
newkeysfile('String_2')=2;
if isempty(newkeysfile('String_2')), error('##Unable to create dimension String_2'),end
newkeysfile('String_4')=4;
if isempty(newkeysfile('String_4')), error('##Unable to create dimension String_4'),end
newkeysfile('String_10')=10;
if isempty(newkeysfile('String_10')), error('##Unable to create dimension String_10'),end


%create the variables:
newkeysfile{'obslat'}=ncfloat('N_Casts');
newkeysfile{'obslng'}=ncfloat('N_Casts');
newkeysfile{'c360long'}=ncfloat('N_Casts');
newkeysfile{'autoqc'}=nclong('N_Casts');

newkeysfile{'stn_num'}=ncchar('N_Casts','String_10');
newkeysfile{'callsign'}=ncchar('N_Casts','String_10');
newkeysfile{'obs_y'}=ncchar('N_Casts','String_4');
newkeysfile{'obs_t'}=ncchar('N_Casts','String_4');
newkeysfile{'obs_m'}=ncchar('N_Casts','String_2');
newkeysfile{'obs_d'}=ncchar('N_Casts','String_2');
newkeysfile{'data_t'}=ncchar('N_Casts','String_2');
newkeysfile{'d_flag'}=ncchar('N_Casts','String_1');
newkeysfile{'data_source'}=ncchar('N_Casts','String_10');

newkeysfile{'priority'}=nclong('N_Casts');
%add the attributes:
newkeysfile{'autoqc'}.conventions = ncchar('0=OK,1=fail aut1, 2=fail aut2, 3=fail aut1&2');
newkeysfile{'autoqc'}.FillValue_ = ncint(9);
newkeysfile{'d_flag'}.conventions = ncchar('D=yes, N=no');
newkeysfile{'d_flag'}.FillValue_ = ncchar('N');

close(newkeysfile);