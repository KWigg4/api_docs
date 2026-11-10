%macro get_redcap_report(report_id=, out=);

    /* Temporary files for the REDCap API request and response */
    filename in temp;
    filename outcsv temp;

    /* Build the API request */
    data _null_;
        file in;
        put "token=%sysget(token_toy)";
        put "&content=report";
        put "&format=csv";
        put "&type=flat";
        put "&report_id=&report_id";
        put "&rawOrLabel=raw";
        put "&rawOrLabelHeaders=raw";
        put "&exportCheckboxLabel=false";
        put "&returnFormat=json";
    run;

    /* Submit request to REDCap */
    proc http
        url="%sysget(redcap_uri)"
        method="POST"
        in=in
        out=outcsv;
        headers
            "Content-Type"="application/x-www-form-urlencoded";
    run;

    /* Import unchanged REDCap response */
    proc import
        datafile=outcsv
        out=DataRaw.&out
        dbms=csv
        replace;
        guessingrows=max;
        getnames=yes;
    run;

    filename in clear;
    filename outcsv clear;

%mend get_redcap_report;
