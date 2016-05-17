%addhistories - this script adds a QC flag to the history section of the
%   profiledata structure.  
%
%   variables required:
%
%   profiledata - this is described in detail in readnetcdf.m
%   qualflag    - the quality flag to be added to the history (char*2)
%   histd       - the depth at which this flag applies
%   actparm     - the parameter affected by this flag (TEMP, PSAL, LATI,
%                    LALO, TIME)
%   update      - the current date (the date the record was
%                    updated)(char*8)
%   oldt        - the old value of the parameter at the depth "histd"
%   severity    - the quality level of the data after the flag is applied:
%                   0 = not QC'd
%                   1 = good data
%                   2 = good data with unconfirmed features
%                   3 = bad data that could potentially be corrected
%                   4 = bad data 

global DATA_QC_SOURCE

    profiledata.numhists=profiledata.numhists+1;
    numh=profiledata.numhists;
    profiledata.QC_code(numh,1:2)=qualflag(1:2);
    profiledata.QC_depth(numh)=histd;
    profiledata.Act_Parm(numh,1:4)=actparm;
    profiledata.PRC_Date(numh,1:8)=update;
    profiledata.PRC_Code(numh,1:4)='CSCB';
    profiledata.Version(numh,1:4)=' 1.0';
    
    profiledata.Previous_Val(numh,1:length(oldt))=oldt;
    profiledata.Ident_Code(numh,1:2)=DATA_QC_SOURCE;   %'CS';  
    profiledata.Flag_severity(numh)=severity;
    handles.profile_data=profiledata;
