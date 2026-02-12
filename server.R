## Shiny Server component for dashboard

source("global.R")

function(input, output, session){
  
  ###
  ### DEFINE REACTIVE VALUES ###
  ###
  
  # Increase the maximum file size limit to 50 MB
  options(shiny.maxRequestSize = 50*1024^2)
  
  # Define a reactive variable to keep track of the current menu
  current_menu <- reactiveVal("NULL")
  
  # Define reactive values to store phenotypic file information
  uploaded_pheno_file_info <- reactiveValues(
    phenotypes = NULL,
    filename = NULL,
    deseq2_analysis_results = NULL,
    PHPS_results = NULL,
    MHPS_results = NULL
  )
  
  # Define reactive values to store histology data
  uploaded_histology_scores <- reactiveValues(
    steatosis = NA,
    ballooning = NA,
    inflammation = NA,
    fibrosis = NA,
    lesion_start = "Zone 3 / Perivenular",
    steatosis_type = "Macrovesicular",
    ballooned_hepatocytes = "Yes, clear cells, rounded, sometimes increased in size",
    lobular_inflammation = "Yes, large inflammatory cell foci",
    mallory_denk = "Yes",
    perisinusoidal_fibrosis = "F0",
    HHPS_results = NULL
  )
  
  # Define reactive values to store raw_counts file information
  uploaded_rawcounts_file_info <- reactiveValues(
    rawcounts = NULL,
    filename = NULL,
    filesize = NULL,
    deseq2_analysis_results = NULL,
    statistics = NULL,
    DHPS_results = NULL
  )
  
  # Define reactive values to store merged_degs file information
  merged_degs_file <- reactiveValues(
    merged_degs = NULL
  )
  
  # Define reactive values to store merged_paths file information
  merged_paths_file <- reactiveValues(
    merged_paths = NULL
  )
  
  # Reactive value to store validation message
  validation_message <- reactiveVal(character(0))
  validation_success <- reactiveVal(FALSE)
  
  
  
  # Reactive value to store PHPS, HHPS, DHPS, MHPS
  PHPS_reactive <- reactive({
    req(uploaded_pheno_file_info$phenotypes)
    
    compute_PHPS(
      input$model_name,
      uploaded_pheno_file_info$phenotypes
    )
  })
  
  HHPS_reactive <- reactive({
    req(uploaded_histology_scores$steatosis)
    
    HHPS(input$model_name, uploaded_histology_scores)
  })
  
  DHPS_reactive <- reactive({
    req(uploaded_rawcounts_file_info$DHPS_results)
    uploaded_rawcounts_file_info$DHPS_results
  })
  
  
  MHPS_reactive <- reactive({
    
    req(PHPS_reactive())
    
    compute_MHPS(
      model_name_ = input$model_name,
      PHPS = PHPS_reactive(),
      HHPS = if ("Histology" %in% input$var1) HHPS_reactive() else NULL,
      DHPS = if ("RNA-Seq" %in% input$var1) DHPS_reactive() else NULL
    )
  })
  
  
  
  reset_new_model_testing <- function(reason = NULL) {
    if (!is.null(reason)) {
      showNotification(paste0("🔄 Resetting analysis: ", reason), type = "message", duration = 3)
    }
    
    # Remove dynamic result tabs (ignore errors if not present)
    try(removeTab(inputId = "t4", target = "menu4_tab2"), silent = TRUE)
    try(removeTab(inputId = "t4", target = "menu4_tab3"), silent = TRUE)
    try(removeTab(inputId = "t4", target = "menu4_tab4"), silent = TRUE)
    try(removeTab(inputId = "t4", target = "menu4_tab_MHPSResults"), silent = TRUE)
    
    # Clear computed results (so nothing “old” leaks into plots/tables)
    uploaded_pheno_file_info$PHPS_results <- NULL
    uploaded_histology_scores$HHPS_results <- NULL
    uploaded_rawcounts_file_info$DHPS_results <- NULL
    uploaded_rawcounts_file_info$deseq2_analysis_results <- NULL
    uploaded_rawcounts_file_info$statistics <- NULL
    
    # Reset validation state & continue button label
    validation_message(character(0))
    validation_success(FALSE)
    updateActionButton(session, inputId = "continue_button", label = "Continue to Analysis")
    
    # Optionally jump back to the first tab in t4 (your "New data upload" tab)
    updateTabsetPanel(session, "t4", selected = "New data upload")
    
    last_layers(character(0))
  }
  
  
  analysis_signature <- reactive({
    list(
      species = input$species,
      # keep the raw string; you can also normalize empty->"New_Model" if you want
      model_name = trimws(ifelse(is.null(input$model_name), "", input$model_name)),
      layers = sort(ifelse(is.null(input$var1), character(0), input$var1))
    )
  })
  
  last_signature <- reactiveVal(NULL)
  
  observeEvent(analysis_signature(), {
    sig <- analysis_signature()
    prev <- last_signature()
    
    # On first run just store the signature and do nothing
    if (is.null(prev)) {
      last_signature(sig)
      return()
    }
    
    # Only reset if analysis had already produced something
    analysis_has_run <- !is.null(uploaded_pheno_file_info$PHPS_results) ||
      !is.null(uploaded_histology_scores$HHPS_results) ||
      !is.null(uploaded_rawcounts_file_info$DHPS_results)
    
    if (!analysis_has_run) {
      last_signature(sig)
      return()
    }
    
    changed <- !identical(prev$species, sig$species) ||
      !identical(prev$model_name, sig$model_name) ||
      !identical(prev$layers, sig$layers)
    
    if (changed) {
      # Build a readable reason
      reasons <- c()
      if (!identical(prev$species, sig$species)) reasons <- c(reasons, "species changed")
      if (!identical(prev$model_name, sig$model_name)) reasons <- c(reasons, "model name changed")
      if (!identical(prev$layers, sig$layers)) reasons <- c(reasons, "selected data layers changed")
      
      reset_new_model_testing(paste(reasons, collapse = ", "))
    }
    
    last_signature(sig)
  }, ignoreInit = TRUE)
  
  
  last_layers <- reactiveVal(character(0))
  
  observeEvent(input$var1, {
    # normalize NULL -> character(0), and sort for stable comparison
    layers_now <- sort(if (is.null(input$var1)) character(0) else as.character(input$var1))
    layers_prev <- last_layers()
    
    # first time: just store
    if (is.null(layers_prev)) {
      last_layers(layers_now)
      return()
    }
    
    # only reset if analysis has already been run
    analysis_has_run <- !is.null(uploaded_pheno_file_info$PHPS_results) ||
      !is.null(uploaded_histology_scores$HHPS_results) ||
      !is.null(uploaded_rawcounts_file_info$DHPS_results)
    
    if (!analysis_has_run) {
      last_layers(layers_now)
      return()
    }
    
    if (!identical(layers_prev, layers_now)) {
      reset_new_model_testing("selected data layers changed")
    }
    
    last_layers(layers_now)
  }, ignoreInit = TRUE)
  
  analysis_state <- reactiveValues(has_run = FALSE)
  
  
  ###
  ### Menu1 ###
  ### Nothing for this menu
  
  observeEvent(input$go_new_model,  { updateTabItems(session, "sidebar", "new_model") })
  observeEvent(input$go_dataset,    { updateTabItems(session, "sidebar", "data") })
  observeEvent(input$go_tutorial,   { updateTabItems(session, "sidebar", "tutorial") })
  
  
  ###
  ### Menu2 ###
  ###
  #Tab3 --- Summary Table  (Table S9)
  summary_models <- SUMMARY_MODELS
  output$data_summary_models <- renderDT({
    datatable(
      summary_models,
      options = list(
        pageLength = 41,         # Number of rows per page
        scrollX = TRUE,          # Enable horizontal scrolling
        autoWidth = TRUE,        # Automatically adjust column widths
        columnDefs = list(
          list(width = '100px', targets = "_all")  # Adjust width for all columns
        ),
        rowCallback = JS("function(row, data, index) {$('td', row).css('overflow', 'hidden');$('td', row).css('white-space', 'nowrap');$('td', row).css('text-overflow', 'ellipsis');}"
        )
      )
    )
  })
  
  # Download handlers
  output$download_summary_models <- downloadHandler(
    filename = function() {
      "summary_models.csv"
    },
    content = function(file) {
      write.csv(summary_models, file)
    }
  )
  
  #Menu2 Tab4 --- All Metadata
  my_data <- MY_DATA
  output$dataT <- renderDT({
    datatable(
      my_data,
      options = list(
        pageLength = 616,         # Number of rows per page
        scrollX = TRUE,           # Enable horizontal scrolling
        autoWidth = TRUE,         # Automatically adjust column widths
        columnDefs = list(
          list(width = '100px', targets = "_all")  # Adjust width for all columns
        ),
        rowCallback = JS("function(row, data, index) {$('td', row).css('overflow', 'hidden'); $('td', row).css('white-space', 'nowrap');$('td', row).css('text-overflow', 'ellipsis');}"
        )
      )
    )
  })
  
  # Download handlers
  output$download_all_metadata <- downloadHandler(
    filename = function() {
      "all_animal_metadata.csv"
    },
    content = function(file) {
      write.csv(my_data, file)
    }
  )
  
  
  
  
  
  ###
  ### Menu3 ###
  ###
  merged_degs = MERGED_DEGS
  genes_for_selection <- merged_degs[,1]
  genes_for_selection = sort(genes_for_selection)
  merged_degs_file$merged_degs <- merged_degs
  
  # Create the gene selection dropdown menu using selectizeInput with server = TRUE
  output$geneDropdown <- renderUI({
    selectizeInput("selectedGenes", "Selected Genes of Interest:", choices = NULL, multiple = TRUE)
  })
  
  # Update the choices of the selectizeInput with server-side processing
  updateSelectizeInput(session, "selectedGenes", choices = genes_for_selection, server = TRUE)
  
  # Generate the heatmap
  output$heatmapPlotGenes <- renderPlot({
    req(input$selectedGenes)
    heatmap <- create_heatmap(merged_degs_file$merged_degs, input$selectedGenes)
  })
  
  observeEvent(input$selectedGenes, {
    updateTabsetPanel(session, "t3", selected = "Gene Selection Heatmap")
  })
  
  
  merged_paths = MERGED_PATHS
  paths_for_selection <- merged_paths[,1]
  paths_for_selection = sort(paths_for_selection)
  merged_paths_file$merged_paths <- merged_paths
  
  # Create the pathway selection dropdown menu using selectizeInput with server = TRUE
  output$pathDropdown <- renderUI({
    selectizeInput("selectedPaths", "Selected Pathways of Interest:", choices = NULL, multiple = TRUE)
  })
  
  # Update the choices of the selectizeInput with server-side processing
  updateSelectizeInput(session, "selectedPaths", choices = paths_for_selection, server = TRUE)
  
  # Generate the heatmap
  output$heatmapPlotPaths <- renderPlot({
    req(input$selectedPaths)
    heatmap <- create_paths_heatmap(merged_paths_file$merged_paths, input$selectedPaths)
  })
  
  observeEvent(input$selectedPaths, {
    updateTabsetPanel(session, "t3", selected = "Pathway Selection Heatmap")
  })
  
  
  
  ###
  ### Menu4 ###
  ###
  # Reactive expression to determine the selected species and display the corresponding image - Mouse or Rat image - In the side menu when adding the new model
  output$species_image <- renderUI({
    if (input$species == "Rat") {
      tags$img(src = "rat_model-modified.png", style = "width: 70%; max-width: 200px; height: auto;")
    } else {
      tags$img(src = "mouse_model-modified.png", style = "width: 70%; max-width: 200px; height: auto;")
    }
  })
  
  # Render the dynamic content based on current menu
  output$dynamic_content <- renderUI({
    selected <- input$var1
    if (current_menu() == "Phenotypes") {
      tagList(
        uiOutput("phenotypes_content")
      )
    } else if (current_menu() == "Histology") {
      tagList(
        uiOutput("histology_content")
      )
    } else if (current_menu() == "RNA-Seq") {
      tagList(
        uiOutput("rna_seq_content")
      )
    }
  })
  
  # Phenotypes content
  output$phenotypes_content <- renderUI({
    if ("Phenotypes" %in% input$var1) {
      tagList(
        h2(style = "color: black; font-size: 1.5em; font-weight: bold;", "Phenotypic Information"),
        fileInput("pheno_upload", "Upload Phenotypic Data", accept = c(".csv", ".tsv")),
        if (!is.null(uploaded_pheno_file_info$filename)) {
          tags$div(style = "background-color: green; color: white; padding: 2px; border-radius: 5px; margin-top: -30px;",
                   tags$span(style = "font-size: 1.2em;", "✔️"), # Add tick symbol
                   tags$span(paste("Successfully uploaded:", uploaded_pheno_file_info$filename))
          )
        },
        tags$hr(),
        # Download example CSV
        tags$p(
          tags$b("Example phenotypic table:"),
          tags$br(),
          "Download the example and modify your model values. Add/Remove lines according to the number of animals in your dataset. Then upload your amended file."
        ),
        # Wrap download and load buttons in a flex container
        tags$div(
          style = "display: flex; gap: 10px; margin-bottom: 15px;",
          downloadButton("download_pheno_example", "Download Example CSV"),
          actionButton("load_pheno_example", "Load Example CSV", icon = icon("file-import"))
        ),
        
        tags$img(src = "pheno_example.png", style = "width: 100%; max-width: 600px; height: auto"),
        tags$hr(),
        tags$p(
          style = "text-align: justify;", 
          tags$b("Important Notes:"),
          tags$br(),
          tags$ul(
            tags$li(tags$code("SampleName")," and ", tags$code("DietGroup"), " columns need to be clearly specified."),
            tags$li("Ideally, all variables should be present."),
            tags$li("However, the tool works even if some variables are missing; in that case use NA values."))),
        tags$hr()
      )
    }
  })
  
  # Download handler for Phenotypic example CSV
  output$download_pheno_example <- downloadHandler(
    filename = function() {
      "phenotypic_example.csv"
    },
    content = function(file) {
      file.copy("file_sources/phenotypic_example.csv", file, overwrite = TRUE)
    }
  )
  
  observeEvent(input$load_pheno_example, {
    # Path to your example CSV in www folder
    example_path <- file.path("file_sources/phenotypic_example.csv")
    
    tryCatch({
      example_data <- read.csv(example_path, header = TRUE, check.names = FALSE)
      
      # Validate using the same function as uploads
      validation_message <- validate_pheno_file(example_data)
      
      if (is.null(validation_message)) {
        uploaded_pheno_file_info$phenotypes <- example_data
        uploaded_pheno_file_info$filename <- "pheno_example.csv"
        
        showNotification(
          "✅ Example file loaded successfully! ",
          type = "message",
          duration = 5
        )
      } else {
        showNotification(
          paste("❌ Error in example file:", validation_message),
          type = "error",
          duration = 10
        )
        uploaded_pheno_file_info$filename <- NULL
      }
      
    }, error = function(e) {
      showNotification(
        "❌ Error: Failed to load the example file.",
        type = "error",
        duration = 8
      )
      uploaded_pheno_file_info$filename <- NULL
    })
  })
  
  
  # Histology content
  output$histology_content <- renderUI({
    if ("Histology" %in% input$var1) {
      tagList(
        h2(style = "color: black; font-size: 1.5em; font-weight: bold;", "Histological Information"),
        tags$p(style = "text-align: justify;", "Use decimal points for a more precise description of you model's average histological scores"),
        fluidRow(
          column(3,numericInput("steatosis_score", "Steatosis:", value = uploaded_histology_scores$steatosis, min = 0, max = 3, step = 0.5, width = '100%'),
                 tags$p(HTML("0 = none<br>1 = mild (<33%)<br>2 = moderate (33-66%)<br>3 = severe (>66%)"), style = "font-size: 0.7em; color: gray; text-align: left; margin-top: -10px;")),
          column(3,numericInput("ballooning_score", "Ballooning:", value = uploaded_histology_scores$ballooning, min = 0, max = 2, step = 0.5, width = '100%'),
                 tags$p(HTML("0 = none<br>1 = few ballooned hepatocytes<br>2 = many ballooned hepatocytes"), style = "font-size: 0.7em; color: gray; text-align: left; margin-top: -10px;")),
          column(3,numericInput("inflammation_score", "Inflammation:", value = uploaded_histology_scores$inflammation, min = 0, max = 3, step = 0.5, width = '100%'),
                 tags$p(HTML("0 = none<br>1 = mild (1-2 foci/field)<br>2 = moderate (2-4 foci/field)<br>3 = severe (>4 foci/field)"), style = "font-size: 0.7em; color: gray; text-align: left; margin-top: -10px;")),
          column(3,numericInput("fibrosis_score", "Fibrosis:", value = uploaded_histology_scores$fibrosis, min = 0, max = 4, step = 0.5, width = '100%'),
                 tags$p(HTML("0 = none<br>1 = perisinusoidal mild<br>2 = perisinusoidal moderate<br>3 = bridging fibrosis<br>4 = cirrhosis"), style = "font-size: 0.7em; color: gray; text-align: left; margin-top: -10px;"))
          ),
        
        # Add questions with dropdown menus (modify options as needed)
        tags$p(tags$hr(), "Please select the best answers that characterise your model:"),
        div(style = "display: block; white-space: nowrap;",
            selectInput("lesion_start", "C1: Where do histological lesions start?",
                        choices = c("Zone 3 /Perivenular", "Periportal", "Anywhere"),
                        selected = uploaded_histology_scores$lesion_start,
                        width = "1000px")
        ),
        div(style = "display: block; white-space: nowrap;",
            selectInput("steatosis_type", "C2: Which is the predominant steatosis type?",
                        choices = c("Macrovesicular", "Mediovesicular (small droplet macrovesicular)", "Macro- and Mediovesicular", "Microvesicular"),
                        selected = uploaded_histology_scores$steatosis_type,
                        width = "1000px")
        ),
        div(style = "display: block; white-space: nowrap;",
            selectInput("ballooned_hepatocytes", "C3: Does the model develop ballooned hepatocytes?", 
                        choices = c("Yes, clear cell, rounded, sometimes increased in size",
                                    "Yes, clear cells but not round (vs normal hepatocyte)", 
                                    "Yes, round, but not clear", 
                                    "Yes, with granular cytoplasm", 
                                    "Yes, with microvesicle droplets", 
                                    "Never"),
                        selected = uploaded_histology_scores$ballooned_hepatocytes,
                        width = "1000px")
        ),
        div(style = "display: block; white-space: nowrap;",
            selectInput("lobular_inflammation", "C4: Does the model develop lobular inflammation?",
                        choices = c("Yes, large inflammatory cell foci", 
                                    "Yes, small to medium-size clusters", 
                                    "Yes, diffuse sinusoidal inflammation"),
                        selected = uploaded_histology_scores$lobular_inflammation,
                        width = "1000px")
        ),
        div(style = "display: block; white-space: nowrap;",
            selectInput("mallory_denk", "C5: Can occasional Mallory-Denk bodies be seen?",
                        choices = c("Yes", "No"),
                        selected = uploaded_histology_scores$mallory_denk,
                        width = "1000px")
        ),
        div(style = "display: block; white-space: nowrap;",
            selectInput("perisinusoidal_fibrosis", "C6: Does the model develop perisinusoidal fibrosis?",
                        choices = c("F0", "F1 (Periportal)", "F1 (Perisinusoidal)", "F2-4"),
                        selected = uploaded_histology_scores$perisinusoidal_fibrosis,
                        width = "1000px")
        ),
        tags$hr()
      )
    }
  })
  
  # RNA-Seq content
  output$rna_seq_content <- renderUI({
    if ("RNA-Seq" %in% input$var1) {
      tagList(
        h2(style = "color: black; font-size: 1.5em; font-weight: bold;", "RNA-Seq Data"),
        fileInput("rna_seq_upload", "Upload Raw Counts matrix", accept = c(".csv", ".tsv", ".txt")),
        if (!is.null(uploaded_rawcounts_file_info$filename)) {
          tags$div(style = "background-color: green; color: white; padding: 2px; border-radius: 5px; margin-top: -30px;",
                   tags$span(style = "font-size: 1.2em;", "✔️"), # Add tick symbol
                   tags$span(paste("Successfully uploaded:", uploaded_rawcounts_file_info$filename))
          )
        },
        tags$hr(),
        # Download example CSV
        tags$p(tags$b("Example raw counts table:"),
               tags$br(),"Download example to see how the uploaded raw counts file should look like"),
        # Wrap download and load buttons in a flex container
        tags$div(
          style = "display: flex; gap: 10px; margin-bottom: 15px;",
          downloadButton("download_rawcounts_example", "Download Example CSV"),
          actionButton("load_rawcounts_example", "Load Example CSV", icon = icon("file-import"))
        ),
        
        tags$img(src = "rawcounts_example.png", style = "width: 85%; max-width: 600px; height: auto"),
        tags$hr(),
        tags$p(
          style = "text-align: justify;",
          tags$b("Important Notes:"),
          tags$br(),
          tags$ul(
            tags$li("Ensure that the column names in your raw counts file match the ", tags$code("SampleNames"), " in your phenotypes file."),
            tags$li("It’s okay if some samples are missing; however, the provided sample names must exactly match those listed in the phenotypes file."))),
        tags$hr()
      )
    }
  })
  
  # Download handler for Raw Counts example CSV
  output$download_rawcounts_example <- downloadHandler(
    filename = function() {
      "rawcounts_example.csv"
    },
    content = function(file) {
      file.copy("file_sources/raw_counts_example.csv", file, overwrite = TRUE)
    }
  )
  
  observeEvent(input$load_rawcounts_example, {
    example_path <- file.path("file_sources/raw_counts_example.csv")
    
    tryCatch({
      example_data <- read.csv(example_path, header = TRUE, check.names = FALSE)
      
      if (is.null(uploaded_pheno_file_info$phenotypes)) {
        showNotification(
          "❌ Please load phenotypic example first (from the Tab 'Phenotypes')",
          type = "error",
          duration = 10
        )
        return()
      }
      
      # Validate using the same function as uploads
      validation_message <- validate_rawcounts_file(example_data, uploaded_pheno_file_info$phenotypes$SampleName)
      
      if (is.null(validation_message)) {
        uploaded_rawcounts_file_info$rawcounts <- example_data
        uploaded_rawcounts_file_info$filename <- "rawcounts_example.csv"
        
        showNotification(
          "✅ Example raw counts file loaded successfully! ",
          type = "message",
          duration = 5
        )
      } else {
        showNotification(
          paste("❌ Error in example file:", validation_message),
          type = "error",
          duration = 10
        )
        uploaded_rawcounts_file_info$filename <- NULL
      }
      
    }, error = function(e) {
      showNotification(
        "❌ Error: Failed to load the example file.",
        type = "error",
        duration = 8
      )
      uploaded_rawcounts_file_info$filename <- NULL
    })
  })
  
  # Handle Phenotypic file upload
  observeEvent(input$pheno_upload, {
    if (!is.null(input$pheno_upload)) {
      file_extension <- tools::file_ext(input$pheno_upload$name)
      if (file_extension %in% c("csv", "tsv")) {
        tryCatch({
          data <- read.csv(input$pheno_upload$datapath, header = TRUE, check.names = FALSE)
          validation_message <- validate_pheno_file(data)
          if (is.null(validation_message)) {
            uploaded_pheno_file_info$phenotypes <- data
            uploaded_pheno_file_info$filename <- input$pheno_upload$name
            showNotification(paste("✅ File successfully uploaded:", input$pheno_upload$name, ". It is assummed  the uploaded file has the structure of the provided example"), type = "message", duration = 5)
          } else {
            showNotification(paste("❌ Error:", validation_message), type = "error", duration = 15)
            uploaded_pheno_file_info$filename = NULL
          }
        }, error = function(e) {
          showNotification("❌ Error: Failed to read the file. Please upload a valid CSV or TSV file!", type = "error", duration = 8)
          uploaded_pheno_file_info$filename = NULL
        })
      } else {
        showNotification("❌ Error: Unsupported file type. Please upload a CSV or TSV file!", type = "error", duration = 7)
        uploaded_pheno_file_info$filename = NULL
      }
    }
  })
  
  # Handle RawCounts file upload
  observeEvent(input$rna_seq_upload, {
    if (!is.null(input$rna_seq_upload)) {
      file_extension <- tools::file_ext(input$rna_seq_upload$name)
      if (file_extension %in% c("csv", "tsv", "txt")) {
        tryCatch({
          data <- read.csv(input$rna_seq_upload$datapath)
          if (!is.null(uploaded_pheno_file_info$phenotypes)) {
            sample_names <- uploaded_pheno_file_info$phenotypes$SampleName
            validation_message <- validate_rawcounts_file(data, sample_names)
            if (is.null(validation_message)) {
              uploaded_rawcounts_file_info$rawcounts <- data
              uploaded_rawcounts_file_info$filename <- input$rna_seq_upload$name
              showNotification(paste("✅ File successfully uploaded:", input$rna_seq_upload$name), type = "message", duration = 5)
            } else {
              showNotification(paste("❌ Error:", validation_message), type = "error", duration = 5)
              uploaded_rawcounts_file_info$filename = NULL
            }
          } else {
            showNotification("❌ Error: Please upload the phenotypes file first. If not available, upload at least the first 2 columns of the phenotypic file to show CONTROL and TREATMENT samples", type = "error", duration = 10)
            uploaded_rawcounts_file_info$filename = NULL
          }
        }, error = function(e) {
          showNotification("❌ Error: Failed to read the file. Please upload a valid CSV, TSV or TXT file!", type = "error", duration = 5)
          uploaded_rawcounts_file_info$filename = NULL
        })
      } else {
        showNotification("❌ Error: Unsupported file type. Please upload a CSV, TSV or TXT file!", type = "error", duration = 5)
        uploaded_rawcounts_file_info$filename = NULL
      }
    }
  })
  
  # Next-menu content
  output$next_menu_content <- renderUI({
      tagList(
        if ("Phenotypes" %in% input$var1) actionButton("pheno_menu_button", "Phenotypes", icon = icon("file-medical")),
        if ("Histology" %in% input$var1) actionButton("histo_menu_button", "Histology", icon = icon("microscope")),
        if ("RNA-Seq" %in% input$var1) actionButton("ngs_menu_button", "RNA_Seq", icon = icon("dna")),
        if (length(input$var1) == 0) {
          tagList(
            tags$h3("New Model Testing", style = "margin-bottom: 20px; color: #2C3E50;"),
            tags$div(
              style = "text-align: center;",
              tags$img(src = "Pheno_Histo_NGS.png", style = "width: 90%; max-width: 600px; height: auto;")
              )
            )
        } else {
          NULL
        }
      )
  })
  
  # Server logic for pheno_menu_button
  observeEvent(input$pheno_menu_button, {
    current_menu("Phenotypes")
  })
  
  # Server logic for histo_menu_button
  observeEvent(input$histo_menu_button, {
    current_menu("Histology")
  })
  
  # Server logic for ngs_menu_button
  observeEvent(input$ngs_menu_button, {
    current_menu("RNA-Seq")
  })
  
  # Menu4:Tab1 - Observer to switch to the appropriate menu based on checkbox selection
  observe({
    selected <- input$var1
    if (!("Phenotypes" %in% selected) && ("Histology" %in% selected)) {
      current_menu("Histology")
    } else if (!("Phenotypes" %in% selected) && ("RNA-Seq" %in% selected)) {
      current_menu("RNA-Seq")
    }  else if (("Phenotypes" %in% selected) && !("RNA-Seq" %in% selected && "Histology" %in% selected)) {
      current_menu("Phenotypes")
    }  else if (("RNA-Seq" %in% selected) && !("Phenotypes" %in% selected && "Histology" %in% selected)) {
      current_menu("RNA-Seq")
    } else if (("Histology" %in% selected) && !("Phenotypes" %in% selected && "RNA-Seq" %in% selected)) {
      current_menu("Histology")
    }
  })
  
  # Observe changes in the numeric inputs and update the reactive values
  observe({
    uploaded_histology_scores$steatosis <- input$steatosis_score
    uploaded_histology_scores$ballooning <- input$ballooning_score
    uploaded_histology_scores$inflammation <- input$inflammation_score
    uploaded_histology_scores$fibrosis <- input$fibrosis_score
    uploaded_histology_scores$lesion_start <- input$lesion_start
    uploaded_histology_scores$steatosis_type <- input$steatosis_type
    uploaded_histology_scores$ballooned_hepatocytes <- input$ballooned_hepatocytes
    uploaded_histology_scores$lobular_inflammation <- input$lobular_inflammation
    uploaded_histology_scores$mallory_denk <- input$mallory_denk
    uploaded_histology_scores$perisinusoidal_fibrosis <- input$perisinusoidal_fibrosis
  })
  
  #  Menu4:Side bar - Update the current_menu_message text based on the current menu
  output$current_menu_message <- renderUI({
    if (current_menu() == "Phenotypes") {
      HTML("<div style='text-align: center; font-weight: bold; font-size: 14px; color: #1F4E79; background-color: #f0f0f0; padding: 8px; border: 3px solid #1F4E79;'>UPDATING PHENOTYPIC DATA</div>")
    } else if (current_menu() == "Histology") {
      HTML("<div style='text-align: center; font-weight: bold; font-size: 14px; color: #1F4E79; background-color: #f0f0f0; padding: 8px; border: 3px solid #1F4E79;'>UPDATING HISTOLOGICAL DATA</div>")
    } else if (current_menu() == "RNA-Seq") {
      HTML("<div style='text-align: center; font-weight: bold; font-size: 14px; color: #1F4E79; background-color: #f0f0f0; padding: 8px; border: 3px solid #1F4E79;'>UPDATING COUNTS MATRIX</div>")
    }
    else {
      HTML("<div style='text-align: center; font-weight: bold; font-size: 14px; color: #1F4E79; background-color: #f0f0f0; padding: 8px; border: 3px solid #1F4E79;'>NEW MODEL TESTING</div>")
    }
  })
  
  # Validation content
  output$validation_content <- renderUI({
    tagList(
      tags$br(),tags$br(),tags$br(),
      if (length(input$var1) > 1)
        tags$p(style = "font-weight: bold;", "Modify the other data layers or validate the uploaded data")
      else if (length(input$var1) == 1 )
        tags$p(style = "font-weight: bold;", "Validate the uploaded data or select more layers to upload"),
      
      if (length(input$var1) > 0)
        actionButton("check_button", "Validation", icon = icon("check")),
      uiOutput("validation_result"),
      uiOutput("continue_button")  # This will render the "Continue to Analysis" button
    )
  })
  
  # Server logic for validation_button
  observeEvent(input$check_button, {
    # If the button for Validation is pressed then -> Remove the "Tab2", "Tab3", "Tab4", and "Tab_MHPSResults" tabs if they were previously created so we re-run the analysis
    removeTab(inputId = "t4", target = "menu4_tab2")
    removeTab(inputId = "t4", target = "menu4_tab3")
    removeTab(inputId = "t4", target = "menu4_tab4")
    removeTab(inputId = "t4", target = "menu4_tab_MHPSResults")
    
    message <- validate_data(input$var1, uploaded_pheno_file_info, uploaded_histology_scores, uploaded_rawcounts_file_info)
    validation_message(message)
    validation_success(length(message) == 0)
  })
  
  # Render the validation message
  output$validation_result <- renderUI({
    messages <- validation_message()
    if (length(messages) > 0) {
      lapply(messages, function(msg) {
        tags$p(style = "color: red;", msg)
      })
    } else if (validation_success()) {
      tags$p(style = "color: green;", "Validation successful. All checks passed.")
    }
  })
  
  # Render the "Continue to Analysis" button
  output$continue_button <- renderUI({
    if (validation_success()) {
      actionButton("continue_button", "Continue to Analysis", icon = icon("arrow-right"))
    }
  })
  
  # Observer for the continue button
  observeEvent(input$continue_button, {
    #Do an extra validation because after validating some tabs may have changed
    message <- validate_data(input$var1, uploaded_pheno_file_info, uploaded_histology_scores, uploaded_rawcounts_file_info)
    validation_message(message)
    validation_success(length(message) == 0)
    
    if (validation_success()) {
      # Remove the "Tab2", "Tab3", "Tab4", and "Tab_MHPSResults" tabs if they were previously created so we re-run the analysis
      removeTab(inputId = "t4", target = "menu4_tab2")
      removeTab(inputId = "t4", target = "menu4_tab3")
      removeTab(inputId = "t4", target = "menu4_tab4")
      removeTab(inputId = "t4", target = "menu4_tab_MHPSResults")
      
      last_signature(analysis_signature())
      
      # Insert new tabPanel "Menu4_tab2" dynamically
      insertTab(
        inputId = "t4",
        tabPanel(
          title = "PHPS/HHPS Results", 
          icon = icon("chart-bar"),
          h2(
            style = "color: black; font-size: 1.5em; font-weight: bold;", 
            paste0(input$species, " Model: PHPS/HHPS Results")
          ),
          value = "menu4_tab2",
          fluidRow(
            column(
              width = 12,
              if ("Phenotypes" %in% input$var1)
                div(
                  h3("PHPS"),
                  downloadButton("download_PHPS_results", "PHPS Results"), tags$br(), tags$br(),
                  DTOutput("PHPS_results") # Output table for phenotype scores
                )
              ),
             column(
               width = 12,
               if ("Histology" %in% input$var1)
                div(
                  tags$br(),
                  h3("HHPS"),
                  downloadButton("download_HHPS_results", "HHPS Results"), tags$br(), tags$br(),
                  DTOutput("HHPS_results") # Output table for histology scores
                )
              )
          )
        ),
        target = "New data upload", # Insert after the "New data upload" tab
        position = "after"
      )
      
      # Render the PHPS results table
      output$PHPS_results <- renderDT({
        uploaded_pheno_file_info$PHPS_results <- compute_PHPS(input$model_name, uploaded_pheno_file_info$phenotypes)
        datatable(
          uploaded_pheno_file_info$PHPS_results,
          options = list(
            pageLength = 10,         # Number of rows per page
            lengthMenu = c(10, 25, 42),  # user can choose
            scrollX = TRUE,          # Enable horizontal scrolling
            autoWidth = TRUE,        # Automatically adjust column widths
            columnDefs = list(
              list(width = '100px', targets = "_all")  # Adjust width for all columns
            ),
            rowCallback = JS("function(row, data, index) {
        $('td', row).css('overflow', 'hidden');
        $('td', row).css('white-space', 'nowrap');
        $('td', row).css('text-overflow', 'ellipsis');
        $('td:eq(1)', row).css('font-weight', 'bold');
        $('td:eq(3)', row).css('font-weight', 'bold');
      }")
          )
        )
      })
      
      # Render the HHPS results table
      output$HHPS_results <- renderDT({
        uploaded_histology_scores$HHPS_results <- HHPS(input$model_name, uploaded_histology_scores)
        datatable(
          uploaded_histology_scores$HHPS_results,
          options = list(
            pageLength = 10,         # Number of rows per page
            lengthMenu = c(10, 25, 42),  # user can choose
            scrollX = TRUE,          # Enable horizontal scrolling
            autoWidth = TRUE,        # Automatically adjust column widths
            columnDefs = list(
              list(width = '100px', targets = "_all")  # Adjust width for all columns
            ),
            rowCallback = JS("function(row, data, index) {
        $('td', row).css('overflow', 'hidden');
        $('td', row).css('white-space', 'nowrap');
        $('td', row).css('text-overflow', 'ellipsis');
        $('td:eq(1)', row).css('font-weight', 'bold');
        $('td:eq(3)', row).css('font-weight', 'bold');
      }")
          )
        )
      })
      
      # Switch to the "Menu4_tab2" tab
      updateTabsetPanel(session, "t4", selected = "menu4_tab2")
      
      
      if ("RNA-Seq" %in% input$var1) {
        withProgress(message = "Running differential expression and DHPS analysis…", value = 0, {
          incProgress(0.2, detail = "Preparing count matrix")
          cts <- uploaded_rawcounts_file_info$rawcounts
          rownames(cts) <- cts[, 1]
          cts <- cts[, -1]
          
          codes <- uploaded_pheno_file_info$phenotypes
          columns_ <- codes[, 1]
          columns_ <- columns_[is.element(columns_, colnames(cts))]
          cts <- cts[, columns_]
          codes_temp <- codes[is.element(codes[, 1], columns_), ]
          
          CTRL <- which(codes_temp[, 2] == "CTRL")
          TREATMENT <- which(codes_temp[, 2] == "TREATMENT")
          
          # Perform DE analysis and update reactive value
          incProgress(0.1, detail = "Running DESeq2")
          uploaded_rawcounts_file_info$deseq2_analysis_results <- myDeseq2(cts, CTRL, TREATMENT, input$species)
          
          # Call myDeseq2Info to get statistics
          incProgress(0.1, detail = "Summarising differential expression")
          uploaded_rawcounts_file_info$statistics <- myDeseq2Info(uploaded_rawcounts_file_info$deseq2_analysis_results, cts, CTRL, TREATMENT)
          
          incProgress(0.4, detail = "Computing DHPS scores")
          # my_DHPS(input$species, input$model_name, uploaded_rawcounts_file_info$deseq2_analysis_results) ###
          uploaded_rawcounts_file_info$DHPS_results <- my_DHPS(input$species, input$model_name, uploaded_rawcounts_file_info$deseq2_analysis_results)
          incProgress(0.1, detail = "Finalising results")
          # Insert new tabPanel "Menu4_tab3" dynamically after Menu4_tab2
          insertTab(
            inputId = "t4",
            tabPanel(
              title = "DHPS Results", icon = icon("chart-bar"),
              h2(style = "color: black; font-size: 1.5em; font-weight: bold; margin-bottom: 10px;", paste0(input$species, " Model: DHPS Results")),
              value = "menu4_tab3",
              fluidRow(
                column(width = 8,
                       tags$hr(),
                       h3("DHPS"),
                       downloadButton("download_DHPS_results", "DHPS Results"),
                       tags$br(), tags$br(),
                       DTOutput("DHPS_results")
                ),
              
                column(width = 4,  # Adjust column width for better alignment
                       div(
                         style = "text-align: left; margin-bottom: 10px;",  # Left align and add some margin
                         tags$p("Download differential expression analysis results:"),
                         downloadButton("download_deseq2_results", "D.E.Results"), tags$br(), tags$br(),
                         renderPlotly({
                           my_rplotly(uploaded_rawcounts_file_info$deseq2_analysis_results, input$model_name)
                         })
                       ),
                       div(
                         style = "text-align: left; width: 100%;",  # Left align the print output and set width
                         tags$p("Summary Statistics:"),
                         renderPrint({
                           cat(uploaded_rawcounts_file_info$statistics)
                         })
                       )
                )
              )
            ),
            target = "menu4_tab2", # Insert after the "Menu4_tab2" tab
            position = "after"
          )
          
        })
      }
      
      # Insert new tabPanel "Menu4_MHPSResults" at the end
      insertTab(
        inputId = "t4",
        tabPanel(
          title = "MHPS Results", 
          icon = icon("chart-bar"),
          h2(
            style = "color: black; font-size: 1.5em; font-weight: bold;", 
            paste0(input$species, " Model: MHPS Results")
          ),
          div(
            h3("MHPS"),
            downloadButton("download_MHPS_results", "MHPS Results"),
            tags$br(), tags$br(),
            DTOutput("MHPS_results"), # Output table for Summary MHPS_results
            tags$br(), tags$br(),
            uiOutput("MHPS_summary_text"),
            tags$p(tags$b("A summary report is available to download:")),
            downloadButton("download_MHPS_report", "Download Report"),
            h4(
              "MHPS Final Ranking: Metabolic vs Fibrotic",
              style = "text-align: center; font-weight: bold; margin-bottom: 10px;"
            ),
            plotOutput("MHPS_scatter", height = "400px", width = "100%"),
            fluidRow(
              column(
                width = 6,
                h4("Metabolic MHPS", style = "text-align: center; font-weight: bold;"),
                plotOutput("MHPS_barplot_metabolic", height = "600px")
              ),
              column(
                width = 6,
                h4("Fibrotic MHPS", style = "text-align: center; font-weight: bold;"),
                plotOutput("MHPS_barplot_fibrotic", height = "600px")
              )
            )
            
            
          )
          ,
          value = "menu4_tab_MHPSResults",
        )
      )
      
      # Render the MHPS results table
      output$MHPS_results <- renderDT({
        
        datatable(
          MHPS_reactive(),
          rownames = FALSE,
          options = list(
            dom = 'lftip',
            pageLength = 10,
            lengthMenu = c(10, 25, 42),
            scrollX = TRUE,
            autoWidth = FALSE,
            columnDefs = list(
              list(width = '100px', targets = "_all")
            ),
            rowCallback = JS("
        function(row, data, index) {
          $('td', row).css('overflow', 'hidden');
          $('td', row).css('white-space', 'nowrap');
          $('td', row).css('text-overflow', 'ellipsis');
          $('td:eq(1)', row).css('font-weight', 'bold');
          $('td:eq(3)', row).css('font-weight', 'bold');
        }
      ")
          )
        )
      })
      
      
      # Change the label of the "Continue" button to "Re-analyse"
      updateActionButton(session, inputId = "continue_button", label = "Re-analyse")
    }
    
    analysis_state$has_run <- TRUE
  })
  
  # Download PHPS results
  output$download_PHPS_results <- downloadHandler(
    filename = function() {
      "PHPS_new_model.csv"
    },
    content = function(file) {
      write.csv(uploaded_pheno_file_info$PHPS_results, file)
    }
  )
  
  # Download HHPS results
  output$download_HHPS_results <- downloadHandler(
    filename = function() {
      "HHPS_new_model.csv"
    },
    content = function(file) {
      write.csv(uploaded_histology_scores$HHPS_results, file)
    }
  )
  
  
  
  output$DHPS_results <- renderDT({
    req(uploaded_rawcounts_file_info$DHPS_results)
    
    dhps_mat <- uploaded_rawcounts_file_info$DHPS_results
    
    # convert matrix -> data.frame with model names visible
    dhps_df <- as.data.frame(dhps_mat)
    
    datatable(
      dhps_df,
      rownames = TRUE,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 42),
        scrollX = TRUE,
        autoWidth = TRUE,
        columnDefs = list(list(width = '120px', targets = "_all")),
        rowCallback = JS("
        function(row, data, index) {
          $('td', row).css('overflow', 'hidden');
          $('td', row).css('white-space', 'nowrap');
          $('td', row).css('text-overflow', 'ellipsis');
          $('td:eq(1)', row).css('font-weight', 'bold');
          $('td:eq(3)', row).css('font-weight', 'bold');
        }
      ")
      )
    )
  })
  
  
  output$download_DHPS_results <- downloadHandler(
    filename = function() {
      paste0("DHPS_", input$model_name, ".csv")
    },
    content = function(file) {
      req(uploaded_rawcounts_file_info$DHPS_results)
      
      dhps_df <- as.data.frame(uploaded_rawcounts_file_info$DHPS_results)
      dhps_df$Model <- rownames(dhps_df)
      dhps_df <- dhps_df[, c("Model", "DHPS_Metabolic", "DHPS_Fibrotic")]
      
      write.csv(dhps_df, file, row.names = FALSE)
    }
  )
  
  
  
  
  # Download Dif Expression DESeq2 results
  output$download_deseq2_results <- downloadHandler(
    filename = function() {
      "Dif_expression_results.csv"
    },
    content = function(file) {
      write.csv(uploaded_rawcounts_file_info$deseq2_analysis_results, file)
    }
  )
  
  # Download MHPS results
  output$download_MHPS_results <- downloadHandler(
    filename = function() {
      paste0("MHPS_", input$model_name, ".csv")
    },
    content = function(file) {
      write.csv(MHPS_reactive(), file, row.names = FALSE)
    }
  )
  
  output$MHPS_summary_text <- renderUI({
    req(MHPS_reactive())
    
    generate_MHPS_summary(MHPS_reactive())
  })
  
  
  
  
  
  output$download_MHPS_report <- downloadHandler(
    filename = function() {
      "MHPS_test.html"
    },
    content = function(file) {
      
      req(MHPS_reactive())
      MHPS <- MHPS_reactive()
      
      # Create the plots as ggplot objects
      metabolic_plot <- plot_MHPS_contributions(
        MHPS = MHPS,
        available_layers = input$var1,
        arm = "Metabolic",
        new_model = ifelse(is.null(input$model_name) || trimws(input$model_name) == "", "New_Model", input$model_name)
      )
      
      fibrotic_plot <- plot_MHPS_contributions(
        MHPS = MHPS,
        available_layers = input$var1,
        arm = "Fibrotic",
        new_model = ifelse(is.null(input$model_name) || trimws(input$model_name) == "", "New_Model", input$model_name)
      )
      
      # Fallback if NULL
      if (is.null(metabolic_plot)) metabolic_plot <- plot_MHPS_contributions(MHPS, available_layers = input$var1, arm = "Metabolic", new_model = input$model_name)
      if (is.null(fibrotic_plot))  fibrotic_plot  <- plot_MHPS_contributions(MHPS, available_layers = input$var1, arm = "Fibrotic", new_model = input$model_name)
      
      tmp_rmd <- tempfile(fileext = ".Rmd")
      
      # ---- Resolve metadata ----
      model_name <- if (
        is.null(input$model_name) ||
        trimws(input$model_name) == ""
      ) {
        "New_Model"
      } else {
        input$model_name
      }
      report_date <- Sys.Date()
      
      layers_text <- c(
        if ("Phenotypes" %in% input$var1) "Phenotypes (PHPS) -",
        if ("Histology"  %in% input$var1) "Histology (HHPS) -",
        if ("RNA-Seq"    %in% input$var1) "Transcriptomics (DHPS)"
      )
      layers_text <- layers_text[layers_text != ""]
      
      writeLines(c(
        "---",
        "title: \"MHPS: New Model Testing Report\"",
        "output:",
        "  html_document:",
        "    theme: flatly",
        "    self_contained: true",
        "params:",
        "  MHPS: NULL",
        "  model_name: NULL",
        "  metabolic_plot: NULL",
        "  fibrotic_plot: NULL",
        "---",
        
        # ---- Setup ----
        "```{r setup, include=FALSE}",
        "knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)",
        "library(ggplot2)",
        "```",
        
        
        # ---- Model metadata block ----
        paste0("**Model:** ", model_name, "  "),
        paste0("**Report date:** ", report_date, "  "),
        "",
        "**Data layers contributing to MHPS:**",
        layers_text,
        "",
        "This MHPS report reflects the translational alignment of the selected preclinical model to human MASLD based exclusively on the data layers provided at the time of analysis. The final MHPS score and its components are therefore conditional on the availability of these inputs.",
        "",
        "",
        
        "## Report Overview",
        "This report summarizes the translational performance of the selected preclinical model using the MASLD Human Proximity Score (MHPS) framework.",
        "MHPS is a composite, human-centric metric designed to quantify how closely preclinical models recapitulate the molecular and phenotypic features of human metabolic dysfunction–associated steatotic liver disease (MASLD).",
        "",
        "The report integrates multiple orthogonal evidence layers to provide a concise yet comprehensive assessment of translational relevance. Specifically, it includes:",
        "",
        "- A narrative summary of the model’s translational alignment relative to human MASLD",
        "",
        "- The complete MHPS table, enabling comparison across all evaluated preclinical models",
        "",
        "- A metabolic–fibrotic density scatterplot illustrating the model’s position within the broader landscape of translational performance",
        "",
        "- A description of the methodological framework and data provenance underpinning the MHPS analysis",
        "",
        "",
        "Together, these elements support evidence-based model selection and facilitate transparent comparison between preclinical systems.",
        "<br><br><br>",
        
        # ---- Summary Text ----
        " ",
        "```{r mhps-summary}",
        "generate_MHPS_summary(params$MHPS)",
        "",
        "",
        "",
        "```",
        
        
        # ---- MHPS Table ----
        "## MHPS Table",
        "```{r mhps-table}",
        "knitr::kable(params$MHPS)",
        "```",
        
        # ---- Scatterplot ----
        "## Metabolic vs Fibrotic MHPS",
        "```{r mhps-scatter, fig.width=7, fig.height=5}",
        "plot_MHPS_scatter(params$MHPS, new_model = params$model_name)",
        "```",

        # ---- Metabolic Contribution Barplot ----
        "<h2 style='font-family: \"Helvetica, Arial, sans-serif\"; font-size:1.3em; font-weight:bold; color:black;'>Metabolic MHPS Contributions</h2>",
        "```{r mhps-bar-metabolic, fig.width=8, fig.height=6}",
        "print(params$metabolic_plot)",
        "```",
        
        # ---- Fibrotic Contribution Barplot ----
        "<h2 style='font-family: \"Helvetica, Arial, sans-serif\"; font-size:1.3em; font-weight:bold; color:black;'>Fibrotic MHPS Contributions</h2>",
        "```{r mhps-bar-fibrotic, fig.width=8, fig.height=6}",
        "print(params$fibrotic_plot)",
        "```",
        
        "",
        "",
        "## Methods",
        "The MASLD Human Proximity Score (MHPS) is a composite translational metric developed to systematically quantify the similarity between preclinical models and human MASLD across multiple disease-relevant dimensions.",
        "",
        "MHPS integrates three complementary components:",
        "",
        "- PHPS (Phenotypic Human Proximity Score): quantifies similarity between preclinical models and human disease phenotypes based on metabolic and clinical features.",
        "",
        "- HHPS (Histological Human Proximity Score): captures alignment of liver histopathological characteristics with human MASLD and MASH.",
        "",
        "- DHPS (Disease Human Proximity Score): assesses transcriptomic similarity between preclinical models and human MASLD patient liver profiles using Drug Set Enrichment Analysis (DSEA).",
        "",
        "",
        "",
        
        "## Data Provenance",
        "- Preclinical data were derived from a curated compendium of 598 animals, including 509 mice and 89 rats, spanning dietary, genetic, and pharmacological MASLD models.",
        "",
        "- Human reference data were sourced from well-characterised MASLD patient cohorts with matched transcriptomic and clinical metadata.",
        "",
        "- Transcriptomic data were processed using standardized RNA-seq workflows to ensure cross-study comparability.",
        "",
        "- MHPS computation was performed using the internally validated MHPS analysis framework described in Nature Metabolism (Vacca, Kamzolas, Mørch Harder et al., 2024).",
        "",
        "- This report is generated dynamically at download time to ensure full consistency with the data and model selection shown in the web interface.",
        "",
        "",
        ""
        
        
      ), tmp_rmd)
      
      rmarkdown::render(
        input = tmp_rmd,
        output_file = file,
        params = list(
          MHPS = MHPS,
          metabolic_plot = metabolic_plot,
          fibrotic_plot  = fibrotic_plot,
          model_name = ifelse(is.null(input$model_name) || trimws(input$model_name) == "", "New_Model", input$model_name)
        ),
        envir = new.env(parent = globalenv()),
        quiet = TRUE
      )
      
      
    }
  )
  

  

  #Plot MHPS Metabolic vs Fibrotic - scatterplot
  output$MHPS_scatter <- renderPlot({
    req(MHPS_reactive())  # Ensure MHPS data is available
    plot_MHPS_scatter(MHPS_reactive(), new_model = input$model_name)
  })
  
  
  
  
  output$MHPS_barplot_metabolic <- renderPlot({
    req(MHPS_reactive(), input$var1)
    
    plot_MHPS_contributions(
      MHPS = MHPS_reactive(),
      available_layers = input$var1,
      arm = "Metabolic",
      new_model = input$model_name
    )
  })
  
  output$MHPS_barplot_fibrotic <- renderPlot({
    req(MHPS_reactive(), input$var1)
    
    plot_MHPS_contributions(
      MHPS = MHPS_reactive(),
      available_layers = input$var1,
      arm = "Fibrotic",
      new_model = input$model_name
    )
  })
  
  
  

}
