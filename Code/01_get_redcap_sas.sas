%put Token length=%length(%sysget(token_toy));

filename req temp;
filename response temp;

data _null_;
    file req;
    put "token=%sysget(token_toy)"
        '&content=report'
        '&report_id=207931'
        '&format=csv'
        '&rawOrLabel=label';
run;

proc http
    url="%sysget(redcap_uri)"
    method="POST"
    in=req
    out=response
    ct="application/x-www-form-urlencoded";
run;

/* Determine project root */
%let root=%sysfunc(prxchange(s/\\Code\\.*$//i,1,%sysget(SAS_EXECFILEPATH)));
%put ROOT=&root;

libname DataRaw "&root.\DataRaw";

/* Read REDCap response */
proc import
    datafile=response
    out=DataRaw.demo_raw
    dbms=csv
    replace;
    getnames=yes;
    guessingrows=max;
run;


proc options option=sasautos;
run;

* MACRO VERSION * 
/* Libraries */
libname DataRaw "&root.\DataRaw";

/* Tell SAS where macros live */
options sasautos=(sasautos "&root.\Code\macros");

%redcap_report(report_id=202139,out=admin0);
proc contents data=_rcjson._all_; run;
proc datasets lib=_rcjson memtype=data; quit;



