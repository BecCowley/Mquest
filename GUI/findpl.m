  for i=1:length(keysdata.stnnum)
       raw=0;
       filen=getfilename(num2str(keysdata.stnnum(i)),raw);
       if(ispc)
          filenam=[prefix '\' filen];
       else
          filenam=[prefix '/' filen];
       end
         ac = getnc(filenam,'Act_Code');
          kk=strmatch('PL',ac);
          if ~isempty(kk)
              ds=[keysdata.stnnum(i)]
          end
  end