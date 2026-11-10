app_files <- c(
	".Rprofile",
	"app.R",
	"renv.lock",
	"Code/01_get_redcap_R.R",
	"Code/01_get_redcap_sas.sas",
	"Code/02_schedule.R",
	"images/img_api_request_token.png",
	"images/img_env_variables.png"
)

rsconnect::deployApp(
	appDir = ".",
	appFiles = app_files,
	account = "kimberlytwiggins",
	server = "connect.posit.cloud",
	appName = "redcap-api-training"
)

