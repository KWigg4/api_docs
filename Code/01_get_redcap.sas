%put Length=%length(%sysget(token_corhwi_inst));

filename req temp;
filename response temp;

data _null_;
    file req;
    put "token=%sysget(token_corhwi_inst)"
        "&content=report"
        "&report_id=202139"
        "&format=json"
        "&rawOrLabel=label";
run;

proc http
    url="%sysget(redcap_uri)"
    method="POST"
    in=req
    out=response
    ct="application/x-www-form-urlencoded";
run;

* Get root dir for Code file ; 
%let root=%sysfunc(
  prxchange(s/\\Code\\.*$//i,1,%sysget(SAS_EXECFILEPATH))
);
%put ROOT=&root;
libname DataRaw "&root.\DataRaw";



libname DataRaw "C:\Users\wigginki\The University of Colorado Denver\Colorado Rural Health Workforce Initiative - Task One\Surveys\DataRaw"
json fileref=response;

data admin0;
    set redcap.admin;
run;

/* Determine project root */
%let root=%sysfunc(prxchange(s/\\Code\\.*$//i,1,%sysget(SAS_EXECFILEPATH)));
%put ROOT=&root;

proc options option=sasautos;
run;


/* Libraries */
libname DataRaw "&root.\DataRaw";

/* Tell SAS where macros live */
options sasautos=(sasautos "&root.\Code\macros");

%redcap_report(report_id=202139,out=admin0);
proc contents data=_rcjson._all_;
run;
proc datasets lib=_rcjson memtype=data;
quit;
