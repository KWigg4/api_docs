# REDCap API Training

This repository contains training materials and example code for securely extracting data from REDCap through the API using either R or SAS.

## Repository contents

- `Code/01_get_redcap_R.R` — R example using `REDCapR`
- `Code/01_get_redcap_sas.sas` — SAS example using `PROC HTTP`
- `shiny/app.R` — interactive REDCap API learning app
- `images/` — screenshots used in the presentation and learning app
- `Training/` — presentation and written training materials
- `DataRaw/` — destination for unchanged API extracts; real extracts should not be committed to Git

## Get the training materials

Git can be used whether you are completing the training in R or SAS.

### First time: clone the repository

1. Open a terminal.
   - R users may use the **Terminal** tab in RStudio.
   - SAS users may use **Windows Terminal**, **Command Prompt**, or **PowerShell**.
2. Navigate to the parent folder where you want the training folder to be created.
3. Run:

```bash
git clone https://github.com/KWigg4/api_docs.git
```

This creates a local folder named `api_docs` containing the training materials.

### Returning later: retrieve updates

Do not clone the repository again. Open a terminal in the existing `api_docs` folder and run:

```bash
git pull
```

- `git clone` gets the repository the first time.
- `git pull` retrieves the latest committed training materials after that.

## Training workflow

1. Request API access in REDCap.
2. Store the REDCap URI and API token securely.
3. Run either the R or SAS example.
4. Retrieve the REDCap report through the API.
5. Save the unchanged source extract to `DataRaw`.
6. Reuse or automate the extraction as needed.

## Security

Treat the REDCap API token like a password.

Never store a REDCap API token in:

- R or SAS source code
- the Git repository
- the project root
- `Code/`
- `DataRaw/`
- screenshots or training materials

Each person should use a token issued for that person's REDCap access.

## Store credentials securely

### Option 1: Windows User environment variables

Create the variables under **User variables**, not System variables.

- `redcap_uri` — REDCap API web address
- `token_xxx` — project-specific REDCap API token

Do not include quotation marks around the values in the Windows Environment Variables window.

After adding or changing the variables, completely close and reopen RStudio or SAS before testing them.

Safe R check:

```r
nchar(Sys.getenv("token_xxx"))
```

Safe SAS check:

```sas
%put Token length=%length(%sysget(token_xxx));
```

A nonzero length confirms that the program can access the token without printing the token itself.

### Option 2: Secure text file or user-level `.Renviron`

A protected `.txt` file may be stored in a secure location outside the project/root directory. Do not track the credential file with Git.

For R, open the user-level `.Renviron` file with:

```r
usethis::edit_r_environ()
```

Add the REDCap URI and project token:

```text
redcap_uri="https://redcap.ucdenver.edu/api/"
token_xxx="YOUR_PROJECT_TOKEN"
```

Restart R after updating `.Renviron`.

Retrieve the values when the program runs:

```r
raw0 <- REDCapR::redcap_report(
  redcap_uri = Sys.getenv("redcap_uri"),
  token = Sys.getenv("token_xxx"),
  report_id = 207931,
  raw_or_label = "label"
)$data
```

## Run the R example

Open:

```text
Code/01_get_redcap_R.R
```

The R example:

1. Reads `redcap_uri` and the project token using `Sys.getenv()`.
2. Retrieves the selected REDCap report with `REDCapR::redcap_report()`.
3. Writes an unchanged, dated CSV extract to `DataRaw`.

## Run the SAS example

Open:

```text
Code/01_get_redcap_sas.sas
```

The SAS example:

1. Reads `redcap_uri` and the project token using `%sysget()`.
2. Submits the request with `PROC HTTP`.
3. Requests the report in CSV format.
4. Imports the response and saves the unchanged dataset in `DataRaw`.

## Automation

Test the API extraction manually before scheduling it.

### R automation

The `taskscheduleR` package can create a Windows scheduled task for an R script.

```r
taskscheduleR::taskscheduler_create(
  taskname = "REDCap_API",
  rscript = "Code/01_get_redcap_R.R",
  schedule = "DAILY"
)
```

After creating the task, open **Windows Task Scheduler** and adjust the task properties as needed.

### SAS automation

SAS programs can be run in batch mode and launched through Windows Task Scheduler. The SAS executable path varies by installation.

Example batch command:

```bat
"C:\Program Files\SASHome\SASFoundation\9.4\sas.exe" ^
  -sysin "C:\path	o\Code_get_redcap_sas.sas" ^
  -log "C:\path	o\Logs
edcap_api.log"
```

Replace the example paths with the SAS executable, program, and log locations on the computer running the task.

### Windows password changes

A Windows password change may interrupt scheduled processing. If a scheduled task stops after a password change, open the task properties in Windows Task Scheduler, select **OK**, and re-enter the updated password when prompted.

## R helper packages

- [REDCapR: R utilities for interacting with REDCap](https://github.com/OuhscBbmc/REDCapR)
- [qualtRics documentation](https://docs.ropensci.org/qualtRics/)

## Run the learning app

From the repository root, run:

```r
shiny::runApp("shiny")
```

The app covers API terminology, obtaining a token, secure credential storage, R and SAS extraction workflows, reusable approaches, automation, and a short knowledge check.
