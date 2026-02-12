## Shiny UI component for the Dashboard

source("global.R")

dashboardPage(
  
  ####
  dashboardHeader(
    title = tags$a(
      href = "https://www.nature.com/articles/s42255-024-01043-6",
      target = "_blank",
      title = "Open Nature Metabolism paper: By Vacca, Kamzolas, Mørch Harder et al. (2024)",
      style = "color: inherit; text-decoration: none;",
      tags$span(
        icon("layer-group"),
        tags$strong(" MHPS Explorer"),
        tags$small(
          "  MASLD Human Proximity Score",
          style = "font-size: 12px; color: #b8c7ce;"
        )
      )
    )
    ,
    titleWidth = 650,
    tags$li(class = "dropdown", 
            tags$a(href = "https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-12808", 
                   icon("database"), 
                   "Raw NGS Data", 
                   target = "_blank",
                   title = "Access raw RNA-Seq data")),
    tags$li(class = "dropdown", 
            tags$a(href = "https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-12817", 
                   icon("database"), 
                   "Raw MA Data", 
                   target = "_blank",
                   title = "Access raw Microarray data")),
    tags$li(class = "dropdown", 
            tags$a(href = "https://www.ebi.ac.uk/biostudies/studies/S-BSST1361",
                   icon("chart-line"), 
                   "Processed Data", 
                   target = "_blank",
                   title = "Access all processed data described in our original publication")),
    tags$li(class = "dropdown", 
            tags$a(href = "https://github.com/kamzolas/MHPS", 
                   icon("github"), 
                   "Source Code", 
                   target = "_blank",
                   title = "View source code on our GitHub")),
    tags$li(class = "dropdown",
            tags$div(class = "btn-group",
                     tags$button(type = "button", 
                                 class = "btn btn-default dropdown-toggle", 
                                 `data-toggle` = "dropdown",
                                 icon("envelope"), 
                                 " Contact ", 
                                 tags$span(class = "caret")),
                     tags$ul(class = "dropdown-menu dropdown-menu-right",  # Ensure the menu aligns to the right
                             tags$li(
                               tags$a(href = "mailto:ik352@cam.ac.uk", 
                                      icon("user"), 
                                      "Ioannis Kamzolas",
                                      title = "Email Ioannis Kamzolas for questions, comments and suggestions")
                             ),
                             tags$li(
                               tags$a(href = "https://www.tvplab-cambridge.com/", 
                                      icon("vial"), 
                                      "TVPLab", 
                                      target = "_blank")
                             ),
                             tags$li(
                               tags$a(href = "https://www.ebi.ac.uk/research/petsalaki/", 
                                      icon("network-wired"), 
                                      "Petsalaki Group", 
                                      target = "_blank")
                             )
                     )
            )
    )
  ),
  
  
  
  
  ####
  dashboardSidebar(
    sidebarMenu(id = "sidebar",
                menuItem("Home", tabName = "home", icon = icon("home")),
                menuItem("LITMUS Dataset", tabName = "data", icon = icon("database")),
                menuItem("Selected Hits Testing", tabName = "hits_of_interest", icon = icon("th")),
                menuItem("New Model Testing", tabName = "new_model", icon=icon("chart-line")),
                menuItem("Tutorial", tabName = "tutorial", icon=icon("question-circle")),
                
                # Conditional Panels for conditional appearance
                conditionalPanel("input.sidebar == 'data'",
                                 tags$hr(),
                                 tags$p("- Main results of original analysis"),
                                 tags$p("- Download all metadata")),
                conditionalPanel("input.sidebar == 'hits_of_interest'",
                                 tags$hr(),
                                 uiOutput("geneDropdown"), # Placeholder for gene selection dropdown
                                 uiOutput("pathDropdown") # Placeholder for KEGG pathways selection dropdown
                ),
                conditionalPanel("input.sidebar == 'new_model'",
                                 tags$hr(),
                                 tags$div(style = "text-align: center;",
                                          uiOutput("species_image")),  # Dynamic image based on species selection
                                 textInput("model_name", "Enter Model's Name", placeholder = "Optional"),
                                 radioButtons("species", "Select Species", choices = c("Mouse", "Rat")),
                                 uiOutput("current_menu_message"), ### Here let's add the summary of what has been uploaded: e.g., Successfully uploaded: Phenotypes, RNA-Seq,
                                 checkboxGroupInput(inputId = "var1" , label ="New model's available data" , choices = c1, selected = NULL), tags$hr()
                )
    )
  ),
  
  
  
  
  
  ####
  dashboardBody(
    # Altmetric donut script
    tags$script(src = "https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"),
    
    #Add this so the slidebar stays stable when rolling the page body
    tags$head(
      tags$style(HTML("
      .mhps-overview-wrap { position: relative; }
      
      /* Large laptops */
      @media (max-width: 1199px) {
        .mhps-metrics-panel {
        width: 170px;
        padding: 7px;
      }

      .mhps-metrics-grid {
        gap: 6px;
      }

      .mhps-metric {
      padding: 6px;
      }
    }

    /* Small laptops / tablets */
    @media (max-width: 991px) {
    .mhps-metrics-panel {
    width: 150px;
    padding: 6px;
    border-radius: 9px;
    }
    
    .mhps-metrics-grid {
    gap: 5px;
    }
    
    .mhps-donut-row {
    padding-top: 6px;
    }
    }

    /* Phones: already stacked, just keep it tidy */
    @media (max-width: 767px) {
    .mhps-metrics-panel {
    position: static;
    width: 100%;
    max-width: 360px;
    margin: 0 auto 14px auto;
    }
    }

    /* Extra-tight layout for half-window / small laptop panes */
    @media (max-width: 700px) {
    .mhps-metrics-panel {
    width: 125px;
    padding: 5px;
    border-radius: 8px;
    }
    
    .mhps-metrics-header { margin-bottom: 5px; }

    .mhps-live {
    font-size: 10px;
    gap: 6px;
    }
    
    .mhps-live-dot {
    width: 7px;
    height: 7px;
    box-shadow: 0 0 0 2px rgba(46,204,113,0.18);
    }
    
    .mhps-metrics-sub { font-size: 9.5px; }
    
    .mhps-metrics-grid {
    gap: 4px;
    margin-top: 5px;
    margin-bottom: 5px;
    }
    
    .mhps-metric {
    border-radius: 7px;
    padding: 5px 5px 4px 5px;
    }
    
    .mhps-metric .label {
    font-size: 9.5px;
    }
    
    .mhps-metric .value {
    font-size: 14px;
    margin-top: 3px;
    }
    
    .mhps-donut-row {
    padding-top: 5px;
    margin-top: 4px;
    }
    
    .mhps-donut-label,
    .mhps-metrics-link {
    font-size: 10px;
    }

    /* Slightly shrink the donut itself */
    .mhps-metrics-panel .altmetric-embed svg {
    width: 42px !important;
    height: 42px !important;
    }
    }

    .mhps-metrics-panel {
    position: absolute;
    top: 10px;
    right: 12px;
    width: 200px;                 /* ↓ from 290px */
    background: rgba(255,255,255,0.96);
    border: 1px solid #e6e6e6;
    border-radius: 10px;          /* ↓ from 14px */
    padding: 8px 8px 7px 8px;     /* ↓ from 12px */
    box-shadow: 0 5px 14px rgba(0,0,0,0.10);
    z-index: 10;
    backdrop-filter: blur(6px);
    }

    .mhps-metrics-header {
    margin-bottom: 6px;           /* ↓ from 8px */
    }


    .mhps-live {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      font-weight: 700;
      font-size: 12px;
      letter-spacing: 0.2px;
      color: #1b1f23;
    }

    .mhps-live-dot {
      width: 9px;
      height: 9px;
      border-radius: 50%;
      background: #2ecc71;
      box-shadow: 0 0 0 3px rgba(46,204,113,0.18);
      display: inline-block;
    }

    .mhps-metrics-sub {
      font-size: 11px;
      color: #667;
      margin-top: 2px;
    }

    .mhps-metrics-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 7px;                     /* ↓ from 10px */
    margin-top: 6px;              /* ↓ from 8px */
    margin-bottom: 6px;
    }

    .mhps-metric {
    border: 1px solid #ededed;
    border-radius: 9px;           /* ↓ from 12px */
    padding: 7px 7px 6px 7px;     /* ↓ from 10px */
    background: #fff;
    }


    .mhps-metric .label {
      font-size: 11px;
      color: #667;
      margin: 0;
      line-height: 1.1;
    }

    .mhps-metric .value {
      font-size: 18px;
      font-weight: 800;
      color: #111;
      margin: 4px 0 0 0;
      line-height: 1.0;
    }

    .mhps-donut-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-top: 1px solid #eee;
    padding-top: 7px;             /* ↓ from 10px */
    margin-top: 5px;              /* ↓ from 6px */
    }

    .mhps-donut-label {
      font-size: 12px;
      color: #667;
      margin: 0;
    }

    .mhps-metrics-link {
      font-size: 12px;
      text-decoration: none;
      color: #1F4E79;
      font-weight: 600;
    }
    .mhps-metrics-link:hover { text-decoration: underline; }

    @media (max-width: 900px) {
      .mhps-metrics-panel {
        position: static;
        width: auto;
        margin: 0 auto 12px auto;
      }
    }
      
    /* Fix the sidebar to be fully flush with header */
    .main-sidebar {
      position: fixed !important;
      top: 0;               /* flush with the top */
      bottom: 0;
      overflow-y: auto;     /* scroll inside sidebar if too long */
      width: 230px;         /* adjust to your sidebar width */
      padding-top: 50px;    /* leave space for the fixed header */
    }

    /* Remove extra margin/padding inside sidebar menu */
    .sidebar-menu > li {
      margin-top: 0;
      padding-top: 0;
    }

    /* Adjust the main content so it doesn't go under sidebar */
    .content-wrapper, .right-side {
      margin-left: 230px;   /* same as sidebar width */
      min-height: 100vh;
    }

    /* Fix the header */
    .main-header {
      position: fixed;
      width: 100%;
      z-index: 1000;
    }

    /* Push the body down so content isn't hidden under the fixed header */
    .content-wrapper {
      padding-top: 50px;    /* same as header height */
    }
                      "))
    ),
    
    fluidRow(
      tabItems(
        ## First menu item -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        tabItem(tabName = "home", 
                tabBox(id="t1", width = 12, 
                       tabPanel(
                         "About",
                         icon = icon("flask"),
                         fluidRow(
                           column(
                             width = 12,
                             
                             # --- MINI HERO STRIP
                             tags$div(
                               style = "background: linear-gradient(90deg, #1F4E79 0%, #3498DB 100%); color: white; padding: 14px 18px; border-radius: 8px; margin-bottom: 16px; "
                               ,
                               tags$div(
                                 style = "display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:12px;",
                                 tags$div(
                                   tags$div(style="font-size:18px; font-weight:700; line-height:1.2;",
                                            HTML("MASLD Human Proximity Score")),
                                   tags$div(style="font-size:13.5px; opacity:0.9; margin-top:4px;",
                                            "Benchmark rodent MASLD models against human disease using integrated phenotypes, histology, and transcriptomics.")
                                 ),
                                 tags$div(
                                   style="display:flex; flex-wrap:wrap; gap:8px;",
                                   tags$span(style="background-color: rgba(255,255,255,0.15); padding:5px 10px; border-radius:999px; font-size:12.5px;",
                                             HTML("598 animals")),
                                   tags$span(style="background-color: rgba(255,255,255,0.15); padding:5px 10px; border-radius:999px; font-size:12.5px;",
                                             HTML("41 models")),
                                   tags$span(style="background-color: rgba(255,255,255,0.15); padding:5px 10px; border-radius:999px; font-size:12.5px;",
                                             HTML("PHPS • HHPS • DHPS → MHPS"))
                                 )
                               )
                             ),
                             
                             
                             tags$div(
                               class = "mhps-overview-wrap",
                               
                               # ---- TOP-RIGHT METRICS PANEL ----
                               tags$div(
                                 class = "mhps-metrics-panel",
                                 
                                 tags$div(
                                   class = "mhps-metrics-header",
                                   tags$div(
                                     tags$div(
                                       class = "mhps-live",
                                       tags$span(class = "mhps-live-dot"),
                                       "LIVE:"
                                     ),
                                     tags$div(
                                       class = "mhps-metrics-sub",
                                       "Paper impact snapshot"
                                     )
                                   ),
                                   tags$a(
                                     href = "https://www.nature.com/articles/s42255-024-01043-6",
                                     target = "_blank",
                                     title = "Open Nature Metabolism paper: By Vacca, Kamzolas, Mørch Harder et al. (2024)",
                                     class = "mhps-metrics-link",
                                     "Open paper →"
                                   )
                                 ),
                                 tags$div(
                                   class = "mhps-metrics-grid",
                                   
                                   tags$div(
                                     class = "mhps-metric",
                                     tags$p(class = "label", "Accesses"),
                                     tags$p(class = "value", "48K+")
                                   ),
                                   
                                   tags$div(
                                     class = "mhps-metric",
                                     tags$p(class = "label", "Citations"),
                                     tags$p(class = "value", "150+")
                                   ),
                                   
                                   tags$div(
                                     class = "mhps-metric",
                                     tags$p(class = "label", "X (Tweets)"),
                                     tags$p(class = "value", "150+")
                                   ),
                                   
                                   tags$div(
                                     class = "mhps-metric",
                                     tags$p(class = "label", "Altmetric"),
                                     # This is intentionally a placeholder label; the donut below is the “live” element
                                     tags$p(class = "value", "Live")
                                   )
                                 ),
                                 
                                 tags$div(
                                   class = "mhps-donut-row",
                                   tags$p(class = "mhps-donut-label", "Altmetric donut"),
                                   tags$div(
                                     class = "altmetric-embed",
                                     `data-badge-type` = "donut",
                                     `data-doi` = "10.1038/s42255-024-01043-6",
                                     `data-badge-popover` = "left",
                                     `data-hide-no-mentions` = "true"
                                   )
                                 )
                               )),
                             
                             
                             # --- Top figure + attribution
                             tags$div(
                               style = "text-align: center; margin-bottom: 10px;",
                               
                               tags$img(
                                 src = "Overview.png",
                                 style = "max-width: 58%; height: auto;"
                               ),
                               tags$p(
                                 style = "font-size: 12px; color: #666; text-align: center; margin-top: 6px;",
                                 HTML("Adapted from Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024).")
                               )
                             )
                             ,
                             
                             # --- HERO / PURPOSE
                             tags$div(
                               style = "padding: 14px 16px; background-color: #F8F9FA; border-left: 4px solid #3498DB; border-radius: 6px; margin: 12px 0 16px 0; font-size: 14px; color: #2C3E50; box-shadow: 0 1px 2px rgba(0,0,0,0.05);",
                               tags$div(
                                 style = "font-size: 18px; font-weight: bold; margin-bottom: 6px;",
                                 "MHPS: MASLD Human Proximity Score"
                               ),
                               tags$p(
                                 style = "margin: 0 0 8px 0;",
                                 HTML("<b>MHPS</b> benchmarks rodent MASLD models against human disease by integrating phenotypes (<b>PHPS</b>), histology (<b>HHPS</b>), and liver transcriptomics (<b>DHPS</b>).")
                               ),
                               
                               # --- MHPS FORMULA MINI-LINE
                               tags$div(
                                 style = "font-size: 13px; color: #566573; margin-top: 6px;",
                                 HTML("<b>MHPS = mean(PHPS, HHPS, DHPS)</b> • Outputs reported for <b>metabolic relevance</b> and <b>MASH–fibrosis induction potential</b>.")
                               ),
                               
                               tags$div(
                                 style = "display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px;",
                                 actionButton(
                                   inputId = "go_new_model",
                                   label = "Start: New Model Testing",
                                   icon = icon("chart-line"),
                                   style = "background-color:#3498DB; color:white; border:none;"
                                 ),
                                 actionButton(
                                   inputId = "go_dataset",
                                   label = "Explore: LITMUS Dataset",
                                   icon = icon("database"),
                                   style = "background-color:#ECF0F1; color:#2C3E50; border:1px solid #BDC3C7;"
                                 ),
                                 actionButton(
                                   inputId = "go_tutorial",
                                   label = "Open Tutorial",
                                   icon = icon("question-circle"),
                                   style = "background-color:#ECF0F1; color:#2C3E50; border:1px solid #BDC3C7;"
                                 )
                               ),
                               tags$p(
                                 style = "margin: 10px 0 0 0; font-size: 12.5px; color: #566573;",
                                 HTML("&#128083; <b>Tip:</b> The blue header buttons link to external data/code repositories and remain available throughout the tool.")
                               )
                             ),
                             
                             # --- QUICK STATS CARDS
                             fluidRow(
                               column(
                                 width = 4,
                                 tags$div(
                                   style = "padding: 12px; background-color: #ECF0F1; border-radius: 8px; height: 100%; border: 1px solid #E5E7E9; box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                   tags$div(style = "font-weight: bold; color: #2C3E50; font-size: 14px;",
                                            icon("users"), " Cohort"),
                                   tags$div(style = "font-size: 22px; font-weight: bold; margin-top: 6px;", "598 animals"),
                                   tags$div(style = "color: #566573; font-size: 13px; margin-top: 2px;", "509 mice • 89 rats"),
                                   tags$div(style = "color: #566573; font-size: 13px; margin-top: 6px;", "336 treated • 262 controls")
                                 )
                               ),
                               column(
                                 width = 4,
                                 tags$div(
                                   style = "padding: 12px; background-color: #ECF0F1; border-radius: 8px; height: 100%; border: 1px solid #E5E7E9; box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                   tags$div(style = "font-weight: bold; color: #2C3E50; font-size: 14px;",
                                            icon("layer-group"), " Models"),
                                   tags$div(style = "font-size: 22px; font-weight: bold; margin-top: 6px;", "41 models"),
                                   tags$div(
                                     style = "color: #566573; font-size: 13px; margin-top: 6px;",
                                     HTML("Includes CCl<sub>4</sub>-treated mice models (two time points) as positive controls for MASLD-independent fibrosis.")
                                   )
                                 )
                               ),
                               column(
                                 width = 4,
                                 tags$div(
                                   style = "padding: 12px; background-color: #ECF0F1; border-radius: 8px; height: 100%; border: 1px solid #E5E7E9; box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                   tags$div(style = "font-weight: bold; color: #2C3E50; font-size: 14px;",
                                            icon("sliders-h"), " Evidence layers"),
                                   tags$div(
                                     style = "margin-top: 8px; font-size: 13.5px; color: #2C3E50;",
                                     tags$div(style="display:flex; align-items:center; margin-bottom:6px;",
                                              tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                              HTML("<b>PHPS</b> (phenotypes)")
                                     ),
                                     tags$div(style="display:flex; align-items:center; margin-bottom:6px;",
                                              tags$span(style="height:10px;width:10px;background-color:#27AE60;border-radius:50%;display:inline-block;margin-right:8px;"),
                                              HTML("<b>HHPS</b> (histology)")
                                     ),
                                     tags$div(style="display:flex; align-items:center;",
                                              tags$span(style="height:10px;width:10px;background-color:#8E44AD;border-radius:50%;display:inline-block;margin-right:8px;"),
                                              HTML("<b>DHPS</b> (transcriptomics)")
                                     )
                                   )
                                 )
                               )
                             ),
                             
                             tags$br(),
                             
                             # --- WHAT YOU CAN DO
                             tags$h3("What you can do in this tool", style = "color:#2C3E50; margin-bottom: 10px;"),
                             
                             fluidRow(
                               column(
                                 width = 4,
                                 tags$div(
                                   style = "padding: 12px; border: 1px solid #E5E7E9; border-radius: 8px; background-color: #FFFFFF; height: 100%; box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                   tags$div(style="font-weight:bold; color:#2C3E50; font-size:14px; margin-bottom:6px;",
                                            icon("database"), " Explore the LITMUS reference dataset"),
                                   tags$div(style="color:#2C3E50; font-size:13.5px;",
                                            HTML("Browse study designs, metadata, and MHPS rankings across models. Detailed descriptors (species, background, diet, timepoint, room temperature, and more) are available in the <b>LITMUS Dataset</b> menu."))
                                 )
                               ),
                               column(
                                 width = 4,
                                 tags$div(
                                   style = "padding: 12px; border: 1px solid #E5E7E9; border-radius: 8px; background-color: #FFFFFF; height: 100%; box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                   tags$div(style="font-weight:bold; color:#2C3E50; font-size:14px; margin-bottom:6px;",
                                            icon("th"), " Test specific genes/pathways"),
                                   tags$div(style="color:#2C3E50; font-size:13.5px;",
                                            HTML("Interactively explore differential gene expression and KEGG pathway enrichment across the rodent dataset. Select genes/pathways in the sidebar to generate dynamic heatmaps from the <b>Selected Hits Testing</b> menu."))
                                 )
                               ),
                               column(
                                 width = 4,
                                 tags$div(
                                   style = "padding: 12px; border: 1px solid #E5E7E9; border-radius: 8px; background-color: #FFFFFF; height: 100%; box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                   tags$div(style="font-weight:bold; color:#2C3E50; font-size:14px; margin-bottom:6px;",
                                            icon("upload"), " Benchmark a new model"),
                                   tags$div(style="color:#2C3E50; font-size:13.5px;",
                                            HTML("Upload data layers (phenotypes, histology, RNA-seq) and obtain <b>PHPS</b>, <b>HHPS</b>, <b>DHPS</b>, and integrated <b>MHPS</b> outputs to assess metabolic relevance and MASH–fibrosis induction potential from the <b>New Model Testing</b> menu."))
                                 )
                               )
                             ),
                             
                             tags$br(),
                             
                             # --- NAVIGATION CLARITY
                             tags$div(
                               style = "padding: 10px 12px; background-color: #F8F9FA; border-left: 4px solid #2ECC71; border-radius: 6px; margin-bottom: 15px; font-size: 13.5px; color: #2C3E50;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                               tags$div(style="font-weight:bold; margin-bottom:4px;", "Navigation guide"),
                               tags$div(
                                 HTML(
                                   "<b>Sidebar menus (top-left)</b> open the main sections of the tool.<br/>
                                   <b>Home tabs (PHPS/HHPS/DHPS)</b> explain the scoring frameworks.<br/>
                                   <b>Header buttons (blue)</b> link to external datasets and the analysis source code."
                                 )
                               )
                             ),
                             
                             # --- CITATION + LICENSE
                             tags$hr(),
                             tags$h4("Reference & figure attribution", style = "color:#2C3E50;"),
                             tags$p(style = "color:#2C3E50;", HTML("Vacca, Kamzolas, Mørch Harder <i>et al.</i> ")),
                             tags$p(
                               style = "color:#2C3E50; margin-top:-8px;",
                               HTML(
                                 "<i>An unbiased ranking of murine dietary models based on their proximity to human metabolic dysfunction-associated steatotic liver disease (MASLD).</i><br/>
                                 <b>Nature Metabolism</b> (2024). Open Access (CC BY 4.0)."
                               )
                             ),
                             tags$p(
                               style = "color:#566573; font-size: 13px;",
                               HTML("Some figures and visual elements in this tool are adapted from the original publication under the Creative Commons Attribution 4.0 International License.")
                             )
                           )
                         )
                       ),
                       
                       
                       
                       
                       
                       tabPanel("PHPS", icon = icon("sitemap"),
                                fluidRow(
                                  column(
                                    width = 12,
                                    
                                    # How-to box
                                    tags$div(
                                      style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 6px;margin-bottom: 15px;font-size: 14px;color: #2C3E50;",
                                      HTML("&#128083; <b>How to read:</b> PHPS quantifies how closely model phenotypes align with human MASLD metabolic features. Use this tab to understand the scoring criteria and interpretation.")
                                    ),
                                    
                                    fluidRow(
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                          tags$h3("Phenotype Human Proximity Score (PHPS)", style="margin-top:0; color:#2C3E50;"),
                                          tags$p("PHPS comprises a 7-point scoring system ranking models against human phenotypic outcomes based on:"),
                                          tags$div(style="margin-top: 10px; color:#2C3E50;",
                                                   tags$div(style="display:flex; align-items:center; margin-bottom:8px;",
                                                            tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                                            tags$span("Body weight")
                                                   ),
                                                   tags$div(style="display:flex; align-items:center; margin-bottom:8px;",
                                                            tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                                            tags$span("Triglycerides and cholesterol")
                                                   ),
                                                   tags$div(style="display:flex; align-items:center; margin-bottom:8px;",
                                                            tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                                            tags$span("Liver-to-body weight ratio")
                                                   ),
                                                   tags$div(style="display:flex; align-items:center;",
                                                            tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                                            tags$span("AST/ALT levels")
                                                   )
                                          ),
                                          tags$p(style="margin-top:12px;",
                                                 "Models closely mimicking human systemic metabolic disease and MASH features are prioritised, while those with lower resemblance are penalised."
                                          ),
                                          tags$p(style="margin-bottom:0;", "The figure summarises the full PHPS scoring system.")
                                        )
                                      ),
                                      
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);text-align:center;",
                                          tags$img(src="PHPS.png", style="width: 100%; max-width: 600px; height: auto;"),
                                          tags$p(
                                            style="font-size:12px; color:#666; text-align:center; margin-top:6px; margin-bottom:0;",
                                            HTML("Adapted from Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024).")
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                       ),
                       
                       
                       tabPanel("HHPS", icon = icon("sitemap"),
                                fluidRow(
                                  column(
                                    width = 12,
                                    
                                    tags$div(
                                      style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #27AE60;border-radius: 6px;margin-bottom: 15px;font-size: 14px;color: #2C3E50;",
                                      HTML("&#128083; <b>How to read:</b> HHPS captures how well histopathology features in a model match human MASLD/MASH, enabling dual ranking for metabolic relevance vs MASH–fibrosis induction.")
                                    ),
                                    
                                    fluidRow(
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                          tags$h3("Histology Human Proximity Score (HHPS)", style="margin-top:0; color:#2C3E50;"),
                                          tags$p("HHPS assesses whether histological patterns mimic human MASLD/MASH pathology and ranks models based on:"),
                                          tags$div(style="margin-top: 10px; color:#2C3E50;",
                                                   tags$div(style="display:flex; align-items:center; margin-bottom:8px;",
                                                            tags$span(style="height:10px;width:10px;background-color:#27AE60;border-radius:50%;display:inline-block;margin-right:8px;"),
                                                            tags$span("Metabolic relevance")
                                                   ),
                                                   tags$div(style="display:flex; align-items:center;",
                                                            tags$span(style="height:10px;width:10px;background-color:#27AE60;border-radius:50%;display:inline-block;margin-right:8px;"),
                                                            tags$span("Ability to induce MASH–fibrosis")
                                                   )
                                          ),
                                          tags$p(style="margin-top:12px;",
                                                 "HHPS includes qualitative measures of human MASLD features expected in murine models to mimic histologically human MASH."
                                          ),
                                          tags$p(style="margin-bottom:0;", "The figure summarises the HHPS scoring system.")
                                        )
                                      ),
                                      
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);text-align:center;",
                                          tags$img(src="HHPS.png", style="width: 100%; max-width: 600px; height: auto;"),
                                          tags$p(
                                            style="font-size:12px; color:#666; text-align:center; margin-top:6px; margin-bottom:0;",
                                            HTML("Adapted from Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024).")
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                       )
                       ,
                       
                       
                       
                       tabPanel("DHPS", icon = icon("sitemap"),
                                fluidRow(
                                  column(
                                    width = 12,
                                    
                                    # How-to / key points box
                                    tags$div(
                                      style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #8E44AD;border-radius: 6px;margin-bottom: 15px;font-size: 14px;color: #2C3E50;",
                                      HTML("&#128083; <b>How to read:</b> DHPS quantifies how closely a model’s liver transcriptomic changes match human MASLD/MASH signatures using DSEA. This tab explains the reference construction and how enrichment scores are converted into DHPS.")
                                    ),
                                    
                                    # Key points cards
                                    fluidRow(
                                      column(
                                        width = 4,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 8px;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                          tags$div(style="font-weight:bold; color:#2C3E50; font-size:14px;", icon("bullseye"), " What DHPS measures"),
                                          tags$p(style="margin:8px 0 0 0; color:#2C3E50; font-size:13.5px;",
                                                 "Transcriptomic proximity to human MASLD/MASH (genes and KEGG pathways).")
                                        )
                                      ),
                                      column(
                                        width = 4,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 8px;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                          tags$div(style="font-weight:bold; color:#2C3E50; font-size:14px;", icon("layer-group"), " Human reference"),
                                          tags$p(style="margin:8px 0 0 0; color:#2C3E50; font-size:13.5px;",
                                                 "Built from reproducible transcriptional and pathway changes across 3 human MASLD datasets.")
                                        )
                                      ),
                                      column(
                                        width = 4,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 8px;height: 100%;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                          tags$div(style="font-weight:bold; color:#2C3E50; font-size:14px;", icon("balance-scale"), " Interpretation"),
                                          tags$p(style="margin:8px 0 0 0; color:#2C3E50; font-size:13.5px;",
                                                 "Higher enrichment indicates closer alignment to expected human disease signatures.")
                                        )
                                      )
                                    ),
                                    
                                    tags$br(),
                                    
                                    # Main content split into two clean sections
                                    fluidRow(
                                      column(
                                        width = 12,
                                        tags$div(
                                          style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;box-shadow: 0 1px 2px rgba(0,0,0,0.04);",
                                          tags$h3("DSEA Human Proximity Score (DHPS)", style="margin-top:0; color:#2C3E50;"),
                                          tags$p("DHPS ranks preclinical models against human RNA-Seq outcomes. It provides an Enrichment Score (ES) that reflects the proximity of a given model to a standard human reference dataset."),
                                          tags$hr(style="margin: 12px 0;"),
                                          
                                          tags$h4("Human reference construction", style="color:#2C3E50; margin-top:0;"),
                                          tags$p("The human reference was constructed by focusing on reproducible transcriptional and pathway changes in human MASH across three human MASLD datasets."),
                                          tags$p("The method was applied to differentially expressed genes and differentially regulated KEGG pathways, after removing pathways not relevant to the liver and/or with redundant genes leading to spurious enrichment."),
                                          tags$hr(style="margin: 12px 0;"),
                                          
                                          tags$h4("Dual ranking logic: metabolic vs fibrotic relevance", style="color:#2C3E50; margin-top:0;"),
                                          tags$p("To support both metabolic relevance and progressive MASH–fibrosis ranking, human NGS hits (genes and pathways) were divided into three groups:"),
                                          tags$div(style="margin-top: 8px; color:#2C3E50;",
                                                   tags$div(style="display:flex; align-items:flex-start; margin-bottom:8px;",
                                                            tags$span(style="height:10px;width:10px;background-color:#8E44AD;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                                            tags$span("A) All comparisons: hits homogeneously modulated at all disease stages (Mild vs Control, Moderate vs Mild, Severe vs Mild)")
                                                   ),
                                                   tags$div(style="display:flex; align-items:flex-start; margin-bottom:8px;",
                                                            tags$span(style="height:10px;width:10px;background-color:#8E44AD;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                                            tags$span("B) Mild vs Control: hits defining early disease stages (Mild vs Control, but not Moderate/Severe vs Mild)")
                                                   ),
                                                   tags$div(style="display:flex; align-items:flex-start;",
                                                            tags$span(style="height:10px;width:10px;background-color:#8E44AD;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                                            tags$span("C) Moderate/Severe vs Mild: hits defining progressive MASH (but not Mild vs Control)")
                                                   )
                                          ),
                                          tags$p(style="margin-top: 10px;",
                                                 "Hits from groups A & B (metabolic) or A & C (fibrotic) were used as reference signatures for the two ranking arms."),
                                          tags$hr(style="margin: 12px 0;"),
                                          
                                          tags$h4("From enrichment to DHPS", style="color:#2C3E50; margin-top:0;"),
                                          tags$p("The reference dataset (genes/KEGG) was used to rank murine models based on proximity to expected outcomes (how closely their transcriptome changes resemble human MASLD)."),
                                          tags$p("The outcome is an Enrichment Score (ES) with an associated p-value, indicating how enriched the human disease signature is in a given model. A closer model to the expected phenotype yields a higher ES."),
                                          tags$p("To avoid bias in interpreting DSEA results, non-statistically significant hits have their ES set to zero, while ES from downregulated hits is multiplied by −1."),
                                          tags$p("Enrichment scores from the two DSEA components are converted into a normalized ES and averaged to generate the final DHPS.")
                                        )
                                      )
                                    ),
                                    
                                    tags$br(),
                                    
                                    # Figure card
                                    fluidRow(
                                      column(
                                        width = 12,
                                        tags$div(
                                          style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;box-shadow: 0 1px 2px rgba(0,0,0,0.04);text-align:center;",
                                          tags$img(src="DHPS.png", style="width: 100%; max-width: 800px; height: auto;"),
                                          tags$p(
                                            style="font-size:12px; color:#666; text-align:center; margin-top:6px; margin-bottom:0;",
                                            HTML("Adapted from Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024).")
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                       )
                       
                       
                )
                
        ),
        
        ## Second menu item -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        tabItem(
          tabName = "data",
          tabBox(
            id = "t2",
            width = 12,
            
            tabPanel(
              "Models Characterization",
              icon = icon("chart-line"),
              
              fluidRow(
                column(
                  width = 12,
                  
                  # How-to box
                  tags$div(
                    style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 6px;margin-bottom: 15px;font-size: 14px;color: #2C3E50;",
                    HTML("&#128083; <b>How to read:</b> This panel summarizes phenotypic and histological changes across MASLD models relative to matched controls. Use the color gradients and bar lengths to interpret direction and magnitude of change.")
                  ),
                  
                  fluidRow(
                    # LEFT: explanation card
                    column(
                      width = 6,
                      tags$div(
                        style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;box-shadow: 0 1px 2px rgba(0,0,0,0.04);height: 100%;",
                        tags$h3("Phenotypic and Histologic Characterization of the Models", style = "margin-top:0; color:#2C3E50;"),
                        
                        tags$p("Phenotypic changes observed in the MASLD models compared to their matched controls were profiled as log2 fold changes (log2FC) across measures of:"),
                        
                        tags$div(
                          style="margin-top: 10px; color:#2C3E50;",
                          tags$div(style="display:flex; align-items:center; margin-bottom:6px;",
                                   tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                   tags$span("Body weight (BW)")
                          ),
                          tags$div(style="display:flex; align-items:center; margin-bottom:6px;",
                                   tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                   tags$span("Blood triglycerides (TGs) and cholesterol")
                          ),
                          tags$div(style="display:flex; align-items:center; margin-bottom:6px;",
                                   tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                   tags$span("Percentage liver weight to body weight (LW/BW%)")
                          ),
                          tags$div(style="display:flex; align-items:center;",
                                   tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                   tags$span("ALT/AST levels")
                          )
                        ),
                        
                        tags$hr(style="margin: 12px 0;"),
                        
                        tags$p("The red/blue color gradient indicates the level of increase/decrease of each measure relative to controls, while an asterisk indicates a significant change at p<0.05 (two-sided Mann-Whitney U test)."),
                        tags$p("The two panels of horizontal bars summarize histological profiles, where total length reflects Activity Score (CRN NAS) and fibrosis."),
                        tags$p("NAS components (steatosis, ballooning, and inflammation) are represented by stacked bar segments. Models are grouped by macro-categories (left annotations).")
                      )
                    ),
                    
                    # RIGHT: figure card
                    column(
                      width = 6,
                      tags$div(
                        style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;box-shadow: 0 1px 2px rgba(0,0,0,0.04);text-align:center;height: 100%;",
                        tags$img(src="Models characterisation.png", style = "width: 100%; max-width: 700px; height: auto;"),
                        tags$p(
                          style = "font-size: 12px; color: #666; text-align: center; margin-top: 6px; margin-bottom: 0;",
                          HTML("Adapted from Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024).")
                        )
                      )
                    )
                  )
                )
              )
            ),
            
            tabPanel(
              "Models Ranking",
              icon = icon("network-wired"),
              
              fluidRow(
                column(
                  width = 12,
                  
                  # How-to box
                  tags$div(
                    style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 6px;margin-bottom: 15px;font-size: 14px;color: #2C3E50;",
                    HTML("&#128083; <b>How to read:</b> MHPS integrates PHPS, HHPS, and DHPS to rank models by metabolic relevance and MASH–fibrosis induction. Bar length reflects total MHPS; stacked segments show evidence-layer contributions.")
                  ),
                  
                  fluidRow(
                    # LEFT: explanation card
                    column(
                      width = 5,
                      tags$div(
                        style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;box-shadow: 0 1px 2px rgba(0,0,0,0.04);height: 100%;",
                        tags$h3("MHPS - Metabolic Relevance & Progressive MASLD", style="margin-top:0; color:#2C3E50;"),
                        
                        tags$p("The comparison of MASLD models incorporates the three sub-scores (PHPS, HHPS, DHPS). The average of these normalized scores (MHPS) ranks murine models (high to low) based on:"),
                        
                        tags$div(
                          style="margin-top: 10px; color:#2C3E50;",
                          tags$div(style="display:flex; align-items:center; margin-bottom:6px;",
                                   tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                   tags$span("Metabolic relevance")
                          ),
                          tags$div(style="display:flex; align-items:center;",
                                   tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;"),
                                   tags$span("Ability to induce MASH-fibrosis")
                          )
                        ),
                        
                        tags$hr(style="margin: 12px 0;"),
                        
                        tags$p("For both rankings, the total bar length indicates MHPS, and stacked segments indicate contributions from PHPS, HHPS, and DHPS."),
                        tags$p("A reference panel indicates body weight changes (red/blue) and fibrosis score (*). Macro-categories are shown on the left."),
                        tags$p("Correlation between metabolic and fibrotic MHPS outputs is shown, highlighting models by quadrant."),
                        
                        tags$hr(style="margin: 12px 0;"),
                        
                        tags$div(style="color:#2C3E50;",
                                 tags$div(style="display:flex; align-items:flex-start; margin-bottom:6px;",
                                          tags$span(style="height:10px;width:10px;background-color:#F1C40F;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                          tags$span("Yellow: high in both rankings (best approximation to human MASH)")
                                 ),
                                 tags$div(style="display:flex; align-items:flex-start; margin-bottom:6px;",
                                          tags$span(style="height:10px;width:10px;background-color:#E67E22;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                          tags$span("Orange: high metabolic relevance, lower MASH–fibrosis relevance")
                                 ),
                                 tags$div(style="display:flex; align-items:flex-start;",
                                          tags$span(style="height:10px;width:10px;background-color:#95A5A6;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                          tags$span("Gray: higher MASH–fibrosis relevance, lower metabolic relevance")
                                 )
                        )
                      )
                    ),
                    
                    # RIGHT: figure card
                    column(
                      width = 7,
                      tags$div(
                        style = "padding: 14px;border: 1px solid #E5E7E9;border-radius: 8px;background-color: #FFFFFF;box-shadow: 0 1px 2px rgba(0,0,0,0.04);text-align:center;height: 100%;",
                        tags$img(src="Ranking.png", style = "width: 100%; height: auto;"),
                        tags$p(
                          style = "font-size: 12px; color: #666; text-align: center; margin-top: 6px; margin-bottom: 0;",
                          HTML("Adapted from Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024).")
                        )
                      )
                    )
                  )
                )
              )
            ),
            
            tabPanel(
              "Summary Table",
              icon = icon("uncharted"),
              
              fluidRow(
                column(
                  width = 12,
                  tags$div(
                    style="padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 6px;margin-bottom: 12px;font-size: 14px;color: #2C3E50;",
                    HTML("&#128083; <b>How to use:</b> Explore study-design details for each model. Use the download button to export the table as CSV.")
                  ),
                  tags$h3("Summary of Study Designs", style="color:#2C3E50; margin-bottom: 6px;"),
                  tags$p("Details of the study designs of the different models compared in the main study cohort."),
                  tags$div(
                    style="display:flex; gap:10px; align-items:center; margin: 10px 0 12px 0;",
                    downloadButton("download_summary_models", "Download Summary")
                  ),
                  DTOutput("data_summary_models")
                )
              )
            ),
            
            tabPanel(
              "All Metadata",
              icon = icon("table"),
              
              fluidRow(
                column(
                  width = 12,
                  tags$div(
                    style="padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 6px;margin-bottom: 12px;font-size: 14px;color: #2C3E50;",
                    HTML("&#128083; <b>How to use:</b> Browse all available metadata records. Use the download button to export the full table.")
                  ),
                  tags$h3("Available Metadata", style="color:#2C3E50; margin-bottom: 6px;"),
                  tags$p("Available metadata for all the animals used in the original publication."),
                  tags$div(
                    style="display:flex; gap:10px; align-items:center; margin: 10px 0 12px 0;",
                    downloadButton("download_all_metadata", "Download Animals Metadata")
                  ),
                  DTOutput("dataT")
                )
              )
            )
          )
        )
        ,
        
        
        
        ## Third menu item -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        tabItem(tabName = "hits_of_interest", 
                tabBox(id = "t3", width = 12,
                       tabPanel("Gene Selection Heatmap", icon = icon("chart-line"),
                                fluidRow(
                                  column(
                                    width = 12,
                                    tags$h3("Differential Expression Analysis: Genes of Interest"),
                                    tags$div(style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 4px;margin-bottom: 10px;font-size: 14px;color: #2C3E50;",
                                             HTML("&#128083; <b>How to use:</b> Select genes from the left sidebar. The heatmap updates automatically based on your selection.")),
                                    
                                    fluidRow(
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 5px;height: 100%;",
                                          tags$h4("Heatmap Color Scale", style = "color: #2980B9;"),
                                          tags$div(style = "display: flex; align-items: center; margin-bottom: 8px;",tags$span(style = "height: 12px; width: 12px; background-color: red; border-radius: 50%; display: inline-block; margin-right: 8px;"),tags$span("Upregulated genes")),
                                          tags$div(style = "display: flex; align-items: center; margin-bottom: 8px;",tags$span(style = "height: 12px; width: 12px; background-color: blue; border-radius: 50%; display: inline-block; margin-right: 8px;"),tags$span("Downregulated genes")),
                                          tags$div(style = "display: flex; align-items: center;",tags$span(style = "height: 12px; width: 12px; background-color: white; border-radius: 50%; display: inline-block; margin-right: 8px;"),tags$span("No significant change"))
                                        )),
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 5px;height: 100%;",
                                          tags$h4("Statistical Significance", style = "color: #27AE60;"),
                                          tags$div(style = "margin-bottom: 8px;",HTML("<b>$</b>: p-value < 0.05")),
                                          tags$div(HTML("<b>*</b>: adjusted p-value < 0.05"))
                                        ))
                                    ),
                                    tags$div(style = "margin-top: 15px;padding: 15px;border: 1px solid #BDC3C7;border-radius: 5px;background-color: #FFFFFF;", plotOutput("heatmapPlotGenes", width = "100%"))
                                  ))),
                       
                       tabPanel("Pathway Selection Heatmap", icon = icon("chart-line"),
                                fluidRow(
                                  column(
                                    width = 12,
                                    tags$h3("KEGG Pathway Enrichment Analysis: Pathways of Interest"),
                                    tags$div(style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 4px;margin-bottom: 10px;font-size: 14px;color: #2C3E50;",
                                             HTML("&#128083; <b>How to use:</b> Select pathways from the left sidebar. The heatmap updates automatically to display pathway enrichment patterns.")),
                                    
                                    fluidRow(
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 5px;height: 100%;",
                                          tags$h4("Heatmap Color Scale", style = "color: #2980B9;"),
                                          tags$div(style = "display: flex; align-items: center; margin-bottom: 8px;",tags$span(style = "height: 12px; width: 12px; background-color: #F1C40F; border-radius: 50%; display: inline-block; margin-right: 8px;"), tags$span("Upregulated pathways (NES > 0)")),
                                          tags$div(style = "display: flex; align-items: center; margin-bottom: 8px;",tags$span(style = "height: 12px; width: 12px; background-color: #8E44AD; border-radius: 50%; display: inline-block; margin-right: 8px;"), tags$span("Downregulated pathways (NES < 0)")),
                                          tags$div(style = "display: flex; align-items: center;",tags$span(style = "height: 12px; width: 12px; background-color: white; border-radius: 50%; display: inline-block; margin-right: 8px;"),tags$span("No significant enrichment"))
                                        )),
                                      column(
                                        width = 6,
                                        tags$div(
                                          style = "padding: 12px;background-color: #ECF0F1;border-radius: 5px;height: 100%;",
                                          tags$h4("Statistical Significance", style = "color: #27AE60;"),
                                          tags$div(style = "margin-bottom: 8px;",HTML("<b>$</b>: p-value < 0.05")),
                                          tags$div(HTML("<b>*</b>: adjusted p-value < 0.05"))
                                        ))),
                                    
                                    # Heatmap container
                                    tags$div(style = "margin-top: 15px;padding: 15px;border: 1px solid #BDC3C7;border-radius: 5px;background-color: #FFFFFF;", plotOutput("heatmapPlotPaths", width = "100%")
                                    )
                                  ))
                       )
                )),
        
        
        ## Forth menu item -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        tabItem(tabName = "new_model",
                tabBox(id="t4",  width=12, 
                       tabPanel("New data upload", icon=icon("database"),
                                fluidRow(
                                  column(width = 5, 
                                         uiOutput("next_menu_content"), # Dynamic UI output
                                         uiOutput("dynamic_content")
                                  ),
                                  column(width = 7,
                                         align = "right",
                                         tags$div(
                                           style = "padding: 10px 12px;background-color: #F8F9FA;border-left: 4px solid #3498DB;border-radius: 4px;margin-bottom: 15px;font-size: 14px;color: #2C3E50;text-align: left;",
                                           HTML("<b>New Model Testing</b><br/>Upload experimental data from a new rodent model and benchmark it against the reference dataset to assess its metabolic relevance and MASH–fibrosis induction potential.<br/><br/><b>
                                                &#128083; How to use:</b><br/>
                                                1. From the sidebar on the left of the screen<br/>
                                                a. Enter model's name (Optional)<br/>
                                                b. Select model's species<br/>
                                                c. Select available data layers (Phenotypes, Histology, or RNA-seq) according to availability. Ideally, all three layers should be provided<br/><br/>
                                                2. The new menu appears on the top-left of the main screen. Navigate between the tab buttons (Phenotypes/Histology/RNA-Seq) to upload the available data files as promted<br/>
                                                3. Click the <b>Validation</b> button below once all selected data have been uploaded<br/>
                                                4. Upon successful validation, press button to proceed to the analysis"))
                                         ,tags$br(), tags$br(),
                                         uiOutput("validation_content")
                                  )
                                )
                       )
                )
        ),
        
        
        ## Fifth menu item -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        tabItem(
          tabName = "tutorial",
          tabBox(
            id = "t5",
            width = 12,
            
            tabPanel(
              "Tutorial",
              icon = icon("question-circle"),
              
              fluidRow(
                column(
                  width = 12,
                  
                  # --- Hero / intro box (matches your other tabs)
                  tags$div(
                    style = "padding: 12px 14px; background-color: #F8F9FA; border-left: 4px solid #3498DB; border-radius: 6px; margin-bottom: 15px; font-size: 14px; color: #2C3E50;",
                    tags$div(
                      style = "font-size: 18px; font-weight: bold; margin-bottom: 6px;",
                      "MHPS Tool Tutorial"
                    ),
                    tags$p(
                      style = "margin: 0;",
                      HTML("Welcome to the tutorial for the <b>MASLD Human Proximity Score (MHPS)</b>. This guide explains how to navigate the tool and where to find each type of result.")
                    )
                  ),
                  
                  
                  # --- Quick Start + Glossary in columns
                  fluidRow(
                    # LEFT: 30-second Quick Start
                    column(
                      width = 8,
                      
                      tags$div(
                        style = "padding: 12px 14px; background-color: #ECF0F1; border-radius: 8px; margin-bottom: 15px; color: #2C3E50; font-size: 14px; height: 100%;",
                        
                        tags$div(
                          style = "font-weight: bold; font-size: 15px; margin-bottom: 8px;",
                          "\u26A1 30-second Quick Start"
                        ),
                        
                        # Step 1
                        tags$div(
                          style = "display:flex; align-items:flex-start; margin-bottom:8px;",
                          tags$span(style="font-weight:bold; margin-right:10px;", "1."),
                          tags$span(
                            tags$b("Explore the reference:"),
                            tags$span(style="margin-left:1px;",
                                      "Open ", tags$b("LITMUS Dataset"),
                                      " to view model summaries and rankings."
                            )
                          )
                        ),
                        
                        # Step 2
                        tags$div(
                          style = "display:flex; align-items:flex-start; margin-bottom:8px;",
                          tags$span(style="font-weight:bold; margin-right:10px;", "2."),
                          tags$span(
                            tags$b("Inspect hits:"),
                            tags$span(style="margin-left:1px;",
                                      "Use ", tags$b("Selected Hits Testing"),
                                      " to generate gene/pathway heatmaps."
                            )
                          )
                        ),
                        
                        # Step 3
                        tags$div(
                          style = "display:flex; align-items:flex-start; margin-bottom:8px;",
                          tags$span(style="font-weight:bold; margin-right:10px;", "3."),
                          tags$span(
                            tags$b("Benchmark a new model:"),
                            tags$span(style="margin-left:1px;",
                                      "Go to ", tags$b("New Model Testing"),
                                      ", select available layers, then upload files. To run the analysis click ",
                                      tags$b("Validation"),
                                      " \u2192 ",
                                      tags$b("Continue to Analysis"),
                                      " to compute PHPS/HHPS/DHPS and MHPS."
                            )
                          )
                        ),
                        
                        tags$p(
                          style = "margin:10px 0 0 0; font-size:12.5px; color:#566573;",
                          tags$b("Tip:"),
                          tags$span(style="margin-left:1px;",
                                    "In ", tags$b("New Model Testing"),
                                    ", you can load ", tags$b("example files"),
                                    " to try the workflow end-to-end before uploading your own data."
                          )
                        )
                      )
                    ),
                    
                    # RIGHT: Acronym glossary (compact)
                    column(
                      width = 4,
                      
                      tags$div(
                        style = "padding: 12px 12px; background-color: #F8F9FA; border-left: 4px solid #3498DB; border-radius: 8px; margin-bottom: 15px; font-size: 13.5px; color: #2C3E50; height: 100%;",
                        
                        tags$div(style="font-weight:bold; margin-bottom:8px;", "Acronyms"),
                        
                        tags$div(style="margin-bottom:6px;",
                                 tags$b("MHPS"), tags$span(": MASLD Human Proximity Score")
                        ),
                        tags$div(style="margin-bottom:6px;",
                                 tags$b("PHPS"), tags$span(": Phenotypic Human Proximity Score")
                        ),
                        tags$div(style="margin-bottom:6px;",
                                 tags$b("HHPS"), tags$span(": Histology Human Proximity Score")
                        ),
                        tags$div(style="margin-bottom:0px;",
                                 tags$b("DHPS"), tags$span(": DSEA Human Proximity Score")
                        )
                      )
                    )
                  )
                  ,
                  
                  
                  
                  # --- TOOL STRUCTURE section
                  tags$h3("Tool structure", style = "color:#2C3E50; margin-bottom: 10px;"),
                  
                  fluidRow(
                    column(
                      width = 12,
                      tags$div(
                        style = "padding: 12px;background-color:#ECF0F1;border-radius:8px;color:#2C3E50;",
                        tags$div(style="display:flex;align-items:flex-start;margin-bottom:8px;",
                                 tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                 HTML("<b>Menus</b>: located in the sidebar (top-left). Each menu opens a major section of the tool.")
                        ),
                        tags$div(style="display:flex;align-items:flex-start;margin-bottom:8px;",
                                 tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                 HTML("<b>Tabs </b>: found at the top of each menu and contain documentation, figures, and outputs relevant to that section.")
                        ),
                        tags$div(style="display:flex;align-items:flex-start;",
                                 tags$span(style="height:10px;width:10px;background-color:#3498DB;border-radius:50%;display:inline-block;margin-right:8px;margin-top:6px;"),
                                 HTML("<b>Header buttons </b>: link to external resources (raw/processed data and source code) and remain available across all menus (blue, top bar).")
                        )
                      )
                    )
                  ),
                  
                  tags$br(),
                  
                  # --- MAIN MENUS section
                  tags$h3("Main menus", style = "color:#2C3E50; margin-bottom: 10px;"),
                  
                  fluidRow(
                    column(
                      width = 6,
                      tags$div(
                        style = "padding: 12px;border:1px solid #E5E7E9;border-radius:8px;background-color:#FFFFFF;height:100%;",
                        tags$h4(style="margin-top:0;color:#2C3E50;", HTML("1. <b>Home</b>")),
                        tags$p(
                          style="color:#2C3E50;margin-bottom:0;",
                          HTML("Introduces MHPS and explains the three sub-scores (<b>PHPS</b>, <b>HHPS</b>, <b>DHPS</b>) in dedicated tabs within the Home menu.")
                        )
                      ),
                      tags$br(),
                      tags$div(
                        style = "padding: 12px;border:1px solid #E5E7E9;border-radius:8px;background-color:#FFFFFF;height:100%;",
                        tags$h4(style="margin-top:0;color:#2C3E50;", HTML("2. <b>LITMUS Dataset</b>")),
                        tags$p(
                          style="color:#2C3E50;margin-bottom:0;",
                          "Access the reference dataset, model summaries, and MHPS-based rankings across rodent models."
                        )
                      ),
                      tags$br(),
                      tags$div(
                        style = "padding: 12px;border:1px solid #E5E7E9;border-radius:8px;background-color:#FFFFFF;height:100%;",
                        tags$h4(style="margin-top:0;color:#2C3E50;", HTML("3. <b>Selected Hits Testing</b>")),
                        tags$p(
                          style="color:#2C3E50;margin-bottom:0;",
                          "Interactively visualise differential gene expression and pathway enrichment across the rodent dataset. Select genes/pathways from the sidebar to generate heatmaps."
                        )
                      ),
                      tags$br(),
                      tags$div(
                        style = "padding: 12px;border:1px solid #E5E7E9;border-radius:8px;background-color:#FFFFFF;height:100%;",
                        tags$h4(style="margin-top:0;color:#2C3E50;", HTML("4. <b>New Model Testing</b>")),
                        tags$p(
                          style="color:#2C3E50;margin-bottom:0;",
                          HTML("Upload data for a new model and benchmark it against the reference dataset. The tool computes <b>PHPS</b>, <b>HHPS</b>, and <b>DHPS</b> (as available), then integrates them into <b>MHPS</b> to assess metabolic relevance and MASH–fibrosis induction potential.")
                        )
                      )
                    )
                  ),
                  
                  tags$br(),
                  
                  # --- Support box
                  tags$div(
                    style = "padding: 10px 12px; background-color: #F8F9FA; border-left: 4px solid #3498DB; border-radius: 6px; margin-top: 5px; font-size: 13.5px; color: #2C3E50;",
                    tags$div(style="font-weight:bold; margin-bottom:4px;", "Inquiries and technical support"),
                    tags$div(
                      HTML("For questions, comments, or technical issues, please contact <a href='mailto:ik352@cam.ac.uk'><b><span style='color: #2980B9; text-decoration: underline;'>ik352@cam.ac.uk</span></b></a>.")
                    )
                  )
                )
              )
            )
          )
        )
        
        
        
        
        
        
      )
    ),
    tags$footer(
      style = "
    text-align: center;
    font-size: 12px;
    color: #777;
    padding: 10px;
  ",
      HTML(
        "© 2026 — MHPS tool. Based on Vacca, Kamzolas, Mørch Harder <i>et al.</i>, Nature Metabolism (2024)."
      )
    )
    
  )
)


