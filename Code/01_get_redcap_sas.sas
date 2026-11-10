/**************************************************************************
* REDCap API Workflow in SAS
*
* Demonstrates:
*   1. Direct REDCap API extraction
*   2. Reusable extraction using a SAS macro

* DEPS: This depends on having redcap_uri and token_toy both as EnvVars
**************************************************************************/

/* Confirm that the API token is available (without directly printing it)
	- EXPECT: length = 32  */
%put Token length=%length(%sysget(token_toy));


/**************************************************************************
* VERSION 1: DIRECT API EXTRACTION
**************************************************************************/

/* Temp files for the API request and response */
FILENAME req temp;
FILENAME response temp;


/* Build the REDCap API request */
data _null_;
    file req;
    put "token=%sysget(token_toy)"
        '&content=report'
        '&report_id=207931'
        '&format=csv'
        '&rawOrLabel=label';
run;

/* submit the request to REDCap */
PROC HTTP
    URL="%sysget(redcap_uri)"
    METHOD="POST"
    IN=req
    OUT=response
    CT="application/x-www-form-urlencoded";
RUN;


/* determine project root */
%let root=%sysfunc(
    prxchange(s/\\Code\\.*$//i, 1, %sysget(SAS_EXECFILEPATH))
);

%PUT ROOT=&root;

/* assign DataRaw libname */
LIBNAME DataRaw "&root.\DataRaw";


/* Import the REDCap response */
PROC IMPORT
    DATAFILE=response
    OUT=DataRaw.demo_raw
    dbms=csv
    replace;
    GETNAMES=yes;
    GUESSINGROWS=max;
RUN;


/* review the imported dataset */
PROC CONTENTS DATA=DataRaw.demo_raw;
RUN;


/* clean up; rm tmp file references */
FILENAME req clear;
FILENAME response clear;


/**************************************************************************
* VERSION 2: REUSABLE MACRO
*
* Macro script: Code/macros/get_redcap_report.sas
**************************************************************************/

/* tell SAS where to find autocall macros */
OPTIONS SASAUTOS=(sasautos "&root.\Code\macros");

/* Run the extraction macro */
%get_redcap_report(
    report_id=207931,
    out=demo
);

/* Review output */
PROC CONTENTS DATA=DataRaw.demo; RUN;
