%eliminate duplicate history records...

kkhist=1:pd.numhists;
for i=1:pd.numhists
    
    j=strmatch(pd.QC_code(i,:),pd.QC_code);
    if(j~=i & pd.QC_depth(i)==pd.QC_depth(j))
        deletionpoint=i;
        deleteqcflag;
    end

end
