%macro get_redcap_report(report_id=, out=);

    /* Validate required parameters */
    %if %superq(report_id)= %then %do;
        %put ERROR: The REPORT_ID parameter is required.;
        %return;
    %end;

    %if %superq(out)= %then %do;
        %put ERROR: The OUT parameter is required.;
        %return;
    %end;

    /* Temporary files for the REDCap API request and response */
    filename req temp;
    filename response temp;

    /* Build the REDCap API request */
    data _null_;
        file req;

        put "token=%sysget(token_toy)"
            '&content=report'
            '&report_id=' "&report_id"
            '&format=csv'
            '&rawOrLabel=label';
    run;

    /* Submit the API request */
    proc http
        url="%sysget(redcap_uri)"
        method="POST"
        in=req
        out=response
        ct="application/x-www-form-urlencoded";
    run;

    /* Report the HTTP result */
    %put HTTP status code: &SYS_PROCHTTP_STATUS_CODE;
    %put HTTP status phrase: &SYS_PROCHTTP_STATUS_PHRASE;

    /* Stop if REDCap did not return a successful response */
    %if &SYS_PROCHTTP_STATUS_CODE ne 200 %then %do;

        %put ERROR: REDCap request failed. Import was not attempted.;

        /* Print the REDCap response to the SAS log */
        data _null_;
            infile response;
            input;
            put _infile_;
        run;

        filename req clear;
        filename response clear;

        %return;
    %end;

    /* Import the unchanged REDCap response */
    proc import
        datafile=response
        out=DataRaw.&out
        dbms=csv
        replace;
        getnames=yes;
        guessingrows=max;
    run;

    /* Clear temporary file references */
    filename req clear;
    filename response clear;

%mend get_redcap_report;
