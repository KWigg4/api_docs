
today <- lubridate::today()

# Export a report you created in REDCap
demo_raw <- REDCapR::redcap_report(
	redcap_uri = Sys.getenv("redcap_uri"),
	token      = Sys.getenv("token_toy"),
	report_id  = 207931, # if you're using a report
	raw_or_label = "label" # or raw
)$data 
# 11/02: nrow 100, ncol=14

# Saved as an RDS and a timestamped .csv: 
saveRDS(demo_raw, here::here("DataRaw/demo_raw_R.RDS"))
write.csv(
	demo_raw,
	here::here(paste0("DataRaw/demo_",today,".csv")),
	row.names = FALSE,
	na=""
)

# You can also just download an entire db or project. See the website for this package for more options! 

# get metadata for this specific report from REDCap (with some example filteres)
meta <- REDCapR::redcap_metadata_read(
	redcap_uri = Sys.getenv("redcap_uri"),
	token      = Sys.getenv("token_toy")
)$data |> 
	dplyr::filter(form_name == "demo") |> 
	dplyr::filter(!field_type=="descriptive") |> 
	dplyr::select(
		field_name, field_type, field_label
		, dplyr::starts_with(c("select","text_validation_type"))) 

write.csv(
	meta,
	here::here(paste0("DataRaw/demo_",today,".csv")),
	row.names = FALSE,
	na=""
)
