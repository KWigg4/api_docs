library(shiny)

repo_url <- "https://github.com/KWigg4/api_docs.git"

if (dir.exists("images")) {
	addResourcePath("images", normalizePath("images"))
} else if (dir.exists("../images")) {
	addResourcePath("images", normalizePath("../images"))
}

# Helpers -----------------------------------------------------------------

section_card <- function(title, ...) {
	tags$section(
		class = "lesson-card",
		tags$h2(title),
		...
	)
}

step_item <- function(number, title, text) {
	tags$div(
		class = "step-item",
		tags$span(class = "step-number", number),
		tags$div(tags$strong(title), tags$p(text))
	)
}

term_card <- function(term, definition) {
	tags$div(
		class = "term-card",
		tags$strong(term),
		tags$p(definition)
	)
}

code_box <- function(code) {
	tags$pre(
		class = "code-box",
		HTML(htmltools::htmlEscape(code))
	)
}

copy_box <- function(id, label, value) {
	tags$div(
		class = "copy-box",
		tags$strong(label),
		tags$div(
			class = "copy-row",
			code_box(value),
			actionButton(id, "Copy", class = "copy-button", `data-copy` = value)
		)
	)
}

choice_feedback <- function(value, correct_value, correct_text, incorrect_text) {
	if (is.null(value) || length(value) == 0) return(NULL)
	
	if (identical(value, correct_value)) {
		tags$p(class = "feedback-correct", correct_text)
	} else {
		tags$p(class = "feedback-incorrect", incorrect_text)
	}
}

# CSS ---------------------------------------------------------------------

css <- "
:root {
  --navy: #0B3954;
  --teal: #087E8B;
  --gold: #D7A84B;
  --ink: #16313F;
  --muted: #5C6F7B;
  --background: #F5F8F9;
  --border: #D7E3E5;
  --danger: #B54747;
  --success: #2E6B54;
}

body {
  background: var(--background);
  color: var(--ink);
  font-family: Arial, sans-serif;
}

.container-fluid { padding: 0; }
.app-shell { max-width: 1180px; margin: 0 auto; padding: 24px; }

.hero {
  background: linear-gradient(115deg, var(--navy), #125B70);
  color: white;
  padding: 34px max(24px, 6vw);
}
.hero h1 { margin: 0 0 8px; font-size: 34px; font-weight: 700; }
.hero p { margin: 0; color: #D9EDF0; font-size: 17px; }

.nav-pills { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 22px; }
.nav-pills > li { float: none; }
.nav-pills > li > a {
  color: var(--navy);
  background: white;
  border: 1px solid var(--border);
  border-radius: 999px;
  font-weight: 600;
}
.nav-pills > li.active > a,
.nav-pills > li.active > a:hover,
.nav-pills > li.active > a:focus { color: white; background: var(--teal); }

.lesson-card {
  background: white;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 18px;
  box-shadow: 0 3px 12px rgba(11,57,84,.06);
}
.lesson-card h2 { color: var(--navy); font-size: 25px; margin: 0 0 18px; }
.lesson-card h3 { color: var(--navy); font-size: 19px; margin-top: 18px; }

.overview-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin: 20px 0; }
.overview-card { background: #EEF6F7; border: 1px solid #C2DADE; border-radius: 10px; padding: 16px; }
.overview-card strong { color: var(--navy); display: block; margin-bottom: 6px; }
.overview-card p { color: var(--muted); margin: 0; }

.two-column, .terms-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.terms-grid { gap: 14px; }
.term-card { background: #EEF6F7; border: 1px solid #C9DFE1; border-radius: 9px; padding: 15px; }
.term-card:nth-child(even) { background: #F8F3E8; border-color: #E5D8B9; }
.term-card strong { color: var(--teal); display: block; margin-bottom: 5px; }
.term-card p { margin: 0; }

.step-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  background: white;
  border: 1px solid var(--border);
  border-radius: 9px;
  padding: 14px;
  margin: 10px 0;
}
.step-item p { color: var(--muted); margin: 5px 0 0; }
.step-number {
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--teal);
  color: white;
  font-weight: 700;
}

.callout { background: #FBF7ED; border-left: 5px solid var(--gold); border-radius: 6px; padding: 14px 16px; margin: 17px 0; }
.security-callout { background: #FBEFEF; border-left-color: var(--danger); }
.success-callout { background: #ECF6F1; border-left-color: var(--success); }

.code-box {
  display: block;
  width: 100%;
  box-sizing: border-box;
  background: #142A35;
  color: #F4FBFC;
  border: 0;
  border-radius: 7px;
  padding: 13px 16px;
  margin: 8px 0;
  overflow-x: auto;
  white-space: pre;
  text-align: left !important;
  font-family: Consolas, 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.5;
}

.copy-box { margin-top: 16px; }
.copy-row { display: flex; align-items: stretch; gap: 8px; }
.copy-row .code-box { flex: 1; }
.copy-button { background: var(--teal); color: white; border: 0; border-radius: 7px; min-width: 74px; }
.training-image { display: block; max-width: 100%; margin: 18px auto 8px; border: 1px solid var(--border); border-radius: 9px; }
.code-file { background: #F2F6F7; border: 1px solid var(--border); border-radius: 9px; padding: 17px; min-width: 0; }
.code-file h3 { margin-top: 0; }
.file-path { display: inline-block; background: #E2EEF0; color: var(--navy); border-radius: 5px; padding: 5px 8px; margin-bottom: 8px; font-family: monospace; font-weight: 600; }

.feedback-correct { color: var(--success); font-weight: 700; }
.feedback-incorrect { color: var(--danger); font-weight: 700; }
.small-note { color: var(--muted); font-size: 13px; }

@media(max-width: 850px) {
  .overview-grid, .terms-grid, .two-column { grid-template-columns: 1fr; }
  .copy-row { flex-direction: column; }
  .hero h1 { font-size: 28px; }
}
"

# UI ----------------------------------------------------------------------

ui <- fluidPage(
	tags$head(
		tags$title("REDCap API Learning Lab"),
		tags$style(HTML(css))
	),
	
	tags$header(
		class = "hero",
		tags$h1("REDCap API Learning Lab"),
		tags$p("Learn how to request API access, store credentials securely, retrieve data with R or SAS, and save unchanged extracts to DataRaw.")
	),
	
	tags$main(
		class = "app-shell",
		uiOutput("progress_ui"),
		
		tabsetPanel(
			type = "pills",
			id = "lesson_tab",
			
			# Start Here --------------------------------------------------------
			tabPanel(
				"Start Here",
				section_card(
					"Overview",
					tags$p("This learning lab follows the complete workflow from REDCap API access through secure data extraction."),
					
					tags$div(
						class = "overview-grid",
						tags$div(class = "overview-card", tags$strong("1. Enable API access"), tags$p("Request a project-specific REDCap API token.")),
						tags$div(class = "overview-card", tags$strong("2. Store the token securely"), tags$p("Keep credentials outside the code and project directory.")),
						tags$div(class = "overview-card", tags$strong("3. Call REDCap"), tags$p("Use the R or SAS example to retrieve the report.")),
						tags$div(class = "overview-card", tags$strong("4. Reuse and automate"), tags$p("Save unchanged extracts to DataRaw and support repeatable runs."))
					),
					
					tags$div(class = "callout", tags$strong("Design principle: "), "Credentials stay separate from the code and extracted data."),
					tags$h3("Get the training files"),
					tags$p("Git works for both R and SAS users."),
					step_item(1, "Open a terminal", "R users can use the RStudio Terminal. SAS users can use Windows Terminal, Command Prompt, or PowerShell."),
					step_item(2, "Choose a parent folder", "Navigate to the location where you want Git to create the api_docs training folder."),
					step_item(3, "Clone the repository once", "Paste the command below into the terminal and press Enter."),
					copy_box("copy_clone", "Clone command", paste("git clone", repo_url)),
					step_item(4, "Choose your training path", "R users will open Code/01_get_redcap_R.R. SAS users will open Code/01_get_redcap_sas.sas."),
					
					tags$h3("Returning later?"),
					tags$p("Open a terminal in your existing api_docs folder and retrieve the latest committed materials:"),
					copy_box("copy_pull", "Update command", "git pull"),
					tags$div(class = "callout", tags$strong("Remember: "), tags$code("git clone"), " gets the repository once; ", tags$code("git pull"), " updates the copy you already have.")
				)
			),
			
			# Key Terms ---------------------------------------------------------
			tabPanel(
				"Key Terms",
				section_card(
					"Key terms",
					tags$div(
						class = "terms-grid",
						term_card("API", "A structured way for one system to request data from another system."),
						term_card("API token", "A unique secret used to authorize access to a particular REDCap project."),
						term_card("Endpoint or URI", "The REDCap web address that receives the API request."),
						term_card("Request", "The call sent to REDCap, including the token and requested export settings."),
						term_card("Response", "The data returned by REDCap after the request is processed."),
						term_card("Environment variable", "A value stored outside the program and retrieved when the program runs."),
						term_card("DataRaw", "The protected project location for unchanged source data retrieved from REDCap."),
						term_card("Automation", "A scheduled process that runs the extraction without requiring manual steps.")
					)
				)
			),
			
			# Step 1 ------------------------------------------------------------
			tabPanel(
				"1. Get Token",
				section_card(
					"Request API access in REDCap",
					step_item(1, 'Open "API and API Playground"', "Use the left sidebar within the correct REDCap project."),
					step_item(2, "Obtain the project token", 'Select "Obtain API token" for the project.'),
					step_item(3, "Store the token securely", "Do not paste the token into the training code."),
					
					tags$img(src = "images/img_api_request_token.png", class = "training-image", alt = "REDCap API token request screen"),
					
					tags$div(
						class = "callout security-callout",
						tags$strong("Token handling rules"),
						tags$ul(
							tags$li("Do not share the token with other people."),
							tags$li("Do not include the token in screenshots."),
							tags$li("Do not place the token in R or SAS code."),
							tags$li("Do not commit the token to Git."),
							tags$li("When the project is completely finished, the token can be deleted and generated again later if needed.")
						)
					)
				)
			),
			
			# Step 2 ------------------------------------------------------------
			tabPanel(
				"2. Store Securely",
				section_card(
					"Store tokens securely",
					tags$p("The REDCap URI and API token should be stored outside the R or SAS program and outside the project directory."),
					
					tags$div(
						class = "code-file",
						tags$h3("Option 1: Windows User environment variables"),
						tags$p("Create the REDCap URI and project-specific token under Windows User variables."),
						tags$ul(
							tags$li(tags$code("redcap_uri"), " → REDCap API web address"),
							tags$li(tags$code("token_xxx"), " → project-specific REDCap token")
						),
						tags$img(src = "images/img_env_variables.png", class = "training-image", alt = "Windows User Environment Variables setup"),
						tags$div(class = "callout", tags$strong("After adding or changing the variables: "), "completely close and reopen RStudio or SAS before testing them."),
						tags$h4("Check that the token is available"),
						tags$p("R:"), code_box('nchar(Sys.getenv("token_xxx"))'),
						tags$p("SAS:"), code_box("%put Token length=%length(%sysget(token_xxx));")
					),
					
					tags$div(style = "height: 20px;"),
					
					tags$div(
						class = "code-file",
						tags$h3("Option 2: Secure text file or .Renviron"),
						tags$p("Store a protected .txt file in a secure location outside the project/root directory, such as C:/, and do not track it with Git."),
						tags$h4("For R: use a user-level .Renviron file"),
						step_item(1, "Open .Renviron", "Run this command in the R console."),
						code_box("usethis::edit_r_environ()"),
						step_item(2, "Add the REDCap URI and token", "Store the values in the user-level .Renviron file, not in the project directory."),
						code_box(paste('redcap_uri="https://redcap.ucdenver.edu/api/"', 'token_xxx="YOUR_PROJECT_TOKEN"', sep = "\n")),
						tags$div(class = "callout security-callout", tags$strong("Important: "), "Always restart R after updating .Renviron."),
						step_item(3, "Call the stored values", "The R program retrieves the URI and token when it runs."),
						code_box(paste("raw0 <- REDCapR::redcap_report(", '  redcap_uri = Sys.getenv("redcap_uri"),', '  token = Sys.getenv("token_xxx"),', "  ...", ")", sep = "\n")),
						tags$h4("R helper packages for API calls"),
						tags$ul(
							tags$li(tags$strong("REDCapR package: "), tags$a("R utilities for interacting with REDCap", href = "https://github.com/OuhscBbmc/REDCapR", target = "_blank")),
							tags$li(tags$strong("qualtRics package: "), tags$a("Introduction to qualtRics", href = "https://docs.ropensci.org/qualtRics/", target = "_blank"))
						)
					)
				)
			),
			
			# Step 3 ------------------------------------------------------------
			tabPanel(
				"3. Call REDCap",
				section_card(
					"Call REDCap",
					tags$p("Choose the example that matches the software you use. The complete runnable programs are stored in the Code folder."),
					
					tags$div(
						class = "two-column",
						tags$div(
							class = "code-file",
							tags$h3("R"),
							tags$div(class = "file-path", "Code/01_get_redcap_R.R"),
							step_item(1, "Retrieve credentials", "Read redcap_uri and token_toy using Sys.getenv()."),
							step_item(2, "Request the report", "Use REDCapR::redcap_report() to retrieve the REDCap report."),
							step_item(3, "Save the raw extract", "Write the retrieved data to a dated CSV file in DataRaw."),
							tags$h4("Safe credential pattern"),
							code_box(paste('redcap_uri <- Sys.getenv("redcap_uri")', 'token <- Sys.getenv("token_toy")', sep = "\n"))
						),
						
						tags$div(
							class = "code-file",
							tags$h3("SAS"),
							tags$div(class = "file-path", "Code/01_get_redcap_sas.sas"),
							step_item(1, "Retrieve credentials", "Read redcap_uri and token_toy using %sysget()."),
							step_item(2, "Submit the API request", "Use PROC HTTP to send the request to REDCap."),
							step_item(3, "Save the raw extract", "Import the response and save the dataset in DataRaw."),
							tags$h4("Safe credential pattern"),
							code_box(paste('url="%sysget(redcap_uri)"', '"token=%sysget(token_toy)"', sep = "\n"))
						)
					),
					
					tags$div(class = "callout success-callout", tags$strong("Expected result: "), "The toy REDCap report produces 100 records and 14 variables. The source extract is saved in DataRaw."),
					tags$div(class = "callout", tags$strong("Preserve the raw data: "), "Do not clean, recode, deduplicate, or otherwise change the source extract while writing it to DataRaw.")
				)
			),
			
			# Reuse -------------------------------------------------------------
			tabPanel(
				"Reuse",
				section_card(
					"Reusable approaches",
					tags$p("After the basic extraction works, the same pattern can be wrapped for reuse across reports and projects."),
					
					tags$div(
						class = "two-column",
						tags$div(
							class = "code-file",
							tags$h3("R function"),
							tags$ul(
								tags$li("Store repeated API logic in a function."),
								tags$li("Pass the report ID as an argument."),
								tags$li("Pass the desired output filename or dataset name."),
								tags$li("Use project-relative output paths.")
							)
						),
						tags$div(
							class = "code-file",
							tags$h3("SAS macro and SASAUTOS"),
							tags$ul(
								tags$li("Store the extraction macro in Code/macros."),
								tags$li("Add the macro folder to SASAUTOS."),
								tags$li("Pass the report ID and output name to the macro."),
								tags$li("Reuse the same secure connection pattern.")
							)
						)
					),
					
					tags$div(class = "callout", "Reusable approaches reduce duplicated setup and make it easier to support multiple reports.")
				)
			),
			
			# Automation --------------------------------------------------------
			tabPanel(
				"Automation",
				section_card(
					"Automation with Windows Task Scheduler",
					tags$p("After testing the API extraction manually, the same program can be scheduled to run automatically."),
					
					tabsetPanel(
						type = "tabs",
						
						tabPanel(
							"R",
							tags$h3("R automation with taskscheduleR"),
							tags$p("The taskscheduleR package can create the initial Windows scheduled task directly from R."),
							step_item(1, "Create the scheduled task", "Use taskscheduleR::taskscheduler_create() to schedule the R script."),
							code_box(paste(
								"taskscheduleR::taskscheduler_create(",
								'  taskname = "REDCap_API",',
								'  rscript = "Code/01_get_redcap_R.R",',
								'  schedule = "DAILY"',
								")",
								sep = "\n"
							)),
							step_item(2, "Review Windows Task Scheduler", "Open the created task and adjust its properties as needed."),
							step_item(3, "Run the extraction", "The scheduled R program retrieves the stored credentials and writes the REDCap extract to DataRaw.")
						),
						
						tabPanel(
							"SAS",
							tags$h3("SAS automation"),
							tags$p("A SAS program can be run in batch mode and launched by Windows Task Scheduler."),
							step_item(1, "Create a batch command", "Use the SAS executable to run the .sas program in batch mode."),
							code_box(paste(
								'"C:\\Program Files\\SASHome\\SASFoundation\\9.4\\sas.exe" ^',
								'  -sysin "C:\\path\\to\\Code\\01_get_redcap_sas.sas" ^',
								'  -log "C:\\path\\to\\Logs\\redcap_api.log"',
								sep = "\n"
							)),
							tags$p(class = "small-note", "The SAS executable location varies by installation. Replace the example paths with the paths on your computer."),
							step_item(2, "Create the scheduled task", "Configure Windows Task Scheduler to run the batch command on the desired schedule."),
							step_item(3, "Run the extraction", "The scheduled SAS program retrieves the stored credentials and writes the REDCap extract to DataRaw.")
						)
					),
					
					tags$div(class = "callout", tags$strong("Project-relative paths: "), "Use project-relative paths so scheduled programs can reliably locate DataRaw and other project folders."),
					tags$div(class = "callout security-callout", tags$strong("Windows password changes: "), "A password change may interrupt scheduled processing. Open the task properties and re-enter the updated password when prompted.")
				)
			),
			
			# Knowledge Check ---------------------------------------------------
			tabPanel(
				"Knowledge Check",
				section_card(
					"Check your understanding",
					radioButtons(
						"q1", "1. Where should the API token be stored for this training?",
						choices = c("Inside the R or SAS program" = "a", "In a User environment variable or protected credential file" = "b", "Inside DataRaw" = "c", "In the Git repository" = "d"),
						selected = character(0)
					),
					uiOutput("q1_feedback"),
					
					radioButtons(
						"q2", "2. Why should credentials remain outside the code?",
						choices = c("So the program runs faster" = "a", "So secrets are not stored in scripts or committed to Git" = "b", "Because REDCap changes the token every time the program runs" = "c", "Because environment variables are required for every API" = "d"),
						selected = character(0)
					),
					uiOutput("q2_feedback"),
					
					radioButtons(
						"q3", "3. What is the purpose of DataRaw?",
						choices = c("Store unchanged source extracts" = "a", "Store project credentials" = "b", "Replace the REDCap project" = "c", "Store only final reports" = "d"),
						selected = character(0)
					),
					uiOutput("q3_feedback"),
					
					radioButtons(
						"q4", "4. What does git pull do in this training?",
						choices = c("Runs the REDCap API request" = "a", "Retrieves the latest committed training materials" = "b", "Stores the API token" = "c", "Creates the DataRaw folder" = "d"),
						selected = character(0)
					),
					uiOutput("q4_feedback")
				)
			)
		)
	)
)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {
		output$q1_feedback <- renderUI(
		choice_feedback(
			input$q1
			, "b"
			, "Correct. Store the token in a User environment variable or another protected credential file.", "Not quite. The token should remain outside the project code and outside Git."))
	output$q2_feedback <- renderUI(choice_feedback(input$q2, "b", "Correct. Credentials should not be stored in scripts or committed to Git.", "Not quite. The goal is to separate credentials from the code and repository."))
	output$q3_feedback <- renderUI(choice_feedback(input$q3, "a", "Correct. DataRaw preserves the unchanged source extract returned through the API.", "Not quite. DataRaw is used for unchanged source data, not credentials or final outputs."))
	output$q4_feedback <- renderUI(choice_feedback(input$q4, "b", "Correct. git pull retrieves the latest committed training materials from the remote repository.", "Not quite. git pull updates the local clone from the remote training repository."))
}

shinyApp(ui = ui, server = server)
