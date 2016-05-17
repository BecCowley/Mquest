%removepreviousflags
%eliminates duplicate versions of the flag you are adding to the profile...

badflag=qualflag(1:2);
jk=profiledata.numhists;
kkhist=1:profiledata.numhists;
ik2=0;
        for ik=1:jk
            ik2=ik2+1;
            if(strcmp(profiledata.QC_code(ik2,:),badflag))
               deletionpoint=ik2;
               deleteqcflag
               ik2=ik2-1;
           end
        end
