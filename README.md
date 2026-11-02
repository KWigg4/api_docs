# REDCap API Training

Training materials for extracting REDCap data through the API using R and SAS.

## Get the training materials

Clone the repository:

git clone <repository-url>

If you already cloned the repository, retrieve the latest version:

git pull

## Training workflow

1. Request REDCap API access.
2. Store the API token securely.
3. Run the R or SAS example.
4. Retrieve data from REDCap.
5. Save the raw extract to DataRaw.

## Important

Never store API tokens in:
- R or SAS code
- Git
- GitHub
- shared project folders

Credentials should be stored separately from the training code.

## Examples

### R
Code/01_get_redcap.R

### SAS
Code/01_get_redcap_sas.sas