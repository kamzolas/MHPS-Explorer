#### Load the required packages ####
# if packages are not installed already,
# install them using function install.packages(" ")

library(shiny) # shiny features
library(shinydashboard) # shinydashboard functions
# #library(jpeg)
library(DT)  # for DT tables
library(promises)
library(readxl)
library(DESeq2)
library("edgeR")
library("preprocessCore")
library("sva")
library(plotly)
library(pheatmap)
library(RColorBrewer)
library(tibble)
library(ggplot2)
library(reshape2)

library(KEGGREST)
library(GSEABase)
library(gep2pep)
library(repo)
library(parallel)
library(stringr)
library(openxlsx)
library(dplyr)
library(ggtext)




#Set application paths
DATA_DIR <- "file_sources"
R_DIR    <- "R_sources"
IMG_DIR  <- "www"

source(file.path(R_DIR,"DESeq2_Functions_Shiny.R"))
source(file.path(R_DIR, "Plotly_Functions_Shiny.R"))
source(file.path(R_DIR, "Genes from the whole degs.R"))
source(file.path(R_DIR, "Paths from the whole dataset.R"))
source(file.path(R_DIR, "HHPS calculation/Histology Ranking_Metabolic+Fibrotic.R"))
source(file.path(R_DIR, "PHHP calculation/ComputePHPS.R"))
source(file.path(R_DIR, "DHPS calculation/RUN_DHPS.R"))

source(file.path(R_DIR, "DHPS calculation/groupGENES_AB_AC.R"))
source(file.path(R_DIR, "DHPS calculation/groupKEGG_AB_AC.R"))
source(file.path(R_DIR, "DHPS calculation/Create_Repository_KEGG_GENES.R"))
source(file.path(R_DIR, "DHPS calculation/Compute_RodentRegulationTable.R"))
source(file.path(R_DIR, "DHPS calculation/buildPEPs_Repository_KEGG_GENES.R"))
source(file.path(R_DIR, "DHPS calculation/ComputeDHPS.R"))


#Read heavy files here instead of the server.R
# SUMMARY_MODELS <- read_excel(file.path(DATA_DIR,"42255_2024_1043_MOESM4_ESM.xlsx"), sheet = 2)[-1, ]
# MY_DATA <- read_excel(file.path(DATA_DIR,"Table S9 - METADATA per animal - FINAL(16May2024).xlsx"))
# MERGED_DEGS <- read.csv(file.path(DATA_DIR,"merged_dif.expressed_data.csv"))
# MERGED_PATHS <- read.csv(file.path(DATA_DIR,"merged_KEGG_paths.csv"))

SUMMARY_MODELS <- readRDS(file.path(DATA_DIR,"42255_2024_1043_MOESM4_ESM.RDS"))
MY_DATA <- readRDS(file.path(DATA_DIR,"Table S9 - METADATA per animal - FINAL(16May2024).RDS"))
MERGED_DEGS <- readRDS(file.path(DATA_DIR,"merged_dif.expressed_data.RDS"))
MERGED_PATHS <- readRDS(file.path(DATA_DIR,"merged_KEGG_paths.RDS"))

# Column names without state. This will be used in the selectinput for choices in the shinydashboard
c1 = c("Phenotypes", "Histology", "RNA-Seq")


# Function to validate uploaded phenotypic data
validate_pheno_file <- function(data) {
  
  errors <- c()
  
  if (ncol(data) > 8) {
    errors <- c(errors, "The file contains more than 8 columns. Please use the columns as in the provided example")
  }
  if (names(data)[1] != "SampleName") {
    errors <- c(errors, "The first column must be 'SampleName'.")
  }
  if (names(data)[2] != "DietGroup") {
    errors <- c(errors, "The second column must be 'DietGroup'.")
  }
  
  if (length(errors) > 0) {
    return(paste(errors, collapse = " "))
  } else {
    return(NULL)
  }
}

# Function to validate uploaded raw counts data
validate_rawcounts_file <- function(data, sample_names) {
  errors <- c()
  
  matched_columns <- names(data)[names(data) %in% sample_names]
  
  if (length(matched_columns) == 0) {
    errors <- c(errors, "None of the columns in the raw counts file match the SampleNames in the phenotypes file.")
  }
  
  if (length(errors) > 0) {
    return(paste(errors, collapse = " "))
  } else {
    return(NULL)
  }
}

# Function to validate all the new data when pressing the "Validation" button
validate_data <- function(selected, pheno, histo, counts) {
  errors <- character(0)  # Initialize an empty character vector for errors
  
  # Check if "Phenotypes" is selected
  if ("Phenotypes" %in% selected && is.null(pheno$filename))
    errors <- c(errors, "Upload the phenotypic file") # Check if phenotypic file is uploaded
  
  # Check if "Histology" is selected
  if ("Histology" %in% selected) {
    # Check if histology scores are within valid ranges
    if (is.null(histo$steatosis) || is.na(histo$steatosis)) {
      errors <- c(errors, "Provide all histological scores. If not available remove this data layer")
    } else if(is.null(histo$ballooning)  || is.na(histo$ballooning)) {
      errors <- c(errors, "Provide all histological scores. If not available remove this data layer")
    } else if(is.null(histo$inflammation)  || is.na(histo$inflammation)) {
      errors <- c(errors, "Provide all histological scores. If not available remove this data layer")
    } else if(is.null(histo$fibrosis)  || is.na(histo$fibrosis)) {
      errors <- c(errors, "Provide all histological scores. If not available remove this data layer")
    } else {
      if (!is.na(histo$steatosis) && (histo$steatosis < 0 || histo$steatosis > 3)) {
        errors <- c(errors, "Steatosis score must be between 0 and 3.")
      }
      if (!is.na(histo$ballooning) && (histo$ballooning < 0 || histo$ballooning > 2)) {
        errors <- c(errors, "Ballooning score must be between 0 and 2.")
      }
      if (!is.na(histo$inflammation) && (histo$inflammation < 0 || histo$inflammation > 3)) {
        errors <- c(errors, "Inflammation score must be between 0 and 3.")
      }
      if (!is.na(histo$fibrosis) && (histo$fibrosis < 0 || histo$fibrosis > 4)) {
        errors <- c(errors, "Fibrosis score must be between 0 and 4, and agree with C6 selection.")
      }
      if ((histo$fibrosis >= 0 && histo$fibrosis <= 4) &&
        !(
        (histo$fibrosis >= 0 && histo$fibrosis < 1 && histo$perisinusoidal_fibrosis == "F0") ||
        (histo$fibrosis >= 1 && histo$fibrosis < 2 && (histo$perisinusoidal_fibrosis == "F1 (Periportal)" || histo$perisinusoidal_fibrosis == "F1 (Perisinusoidal)")) ||
        (histo$fibrosis >= 2 && histo$perisinusoidal_fibrosis == "F2-4")
      )) {
        errors <- c(
          errors,
          paste0(
            "Fibrosis score ", histo$fibrosis," is incompatible with C6 selection (", histo$perisinusoidal_fibrosis,"). Please ensure they correspond to the same fibrosis stage."))
        
      }
      
    }
  }
  
  # Check if "RNA-Seq" is selected
  if ("RNA-Seq" %in% selected) {
    
    if (!("Upload the phenotypic file" %in% errors) && is.null(pheno$filename))
      errors <- c(errors, "First upload the phenotypic file")
      
    # Check if counts file is uploaded
    if (is.null(counts$filename))
      errors <- c(errors, "Upload the raw counts. If not available remove this data layer")
    
    }
  
  return(errors)
}




compute_MHPS <- function(model_name_, PHPS = NULL, HHPS = NULL, DHPS = NULL) {
  
  # Helper: extract 1st (Metabolic) and 3rd (Fibrotic) columns
  extract_subscore <- function(df, prefix) {
    if (is.null(df)) return(NULL)
    
    out <- data.frame(
      Model = as.character(rownames(df)),
      Metabolic = df[, 1],
      Fibrotic  = df[, 3],
      stringsAsFactors = FALSE
    )
    
    colnames(out)[2:3] <- c(
      paste0(prefix, "_Metabolic"),
      paste0(prefix, "_Fibrotic")
    )
    
    out
  }
  
  # Extract available subscores
  phps <- extract_subscore(PHPS, "PHPS")
  hhps <- extract_subscore(HHPS, "HHPS")
  dhps <- extract_subscore(DHPS, "DHPS")
  
  subscores <- list(phps, hhps, dhps)
  subscores <- subscores[!sapply(subscores, is.null)]
  
  # --- Capture first model in the submitted data ---
  first_model <- NULL
  for (df in subscores) {
    if (!is.null(df) && nrow(df) > 0) {
      first_model <- df$Model[1]
      break
    }
  }
  
  # Merge by Model
  MHPS <- Reduce(
    function(x, y) merge(x, y, by = "Model", all = TRUE),
    subscores
  )
  
  MHPS <- aggregate(
    . ~ Model,
    data = MHPS,
    FUN = function(x) if (all(is.na(x))) NA else mean(x, na.rm = TRUE)
  )
  
  # Calculate MHPS averages
  MHPS$MHPS_Metabolic <- round(rowMeans(
    MHPS[, grep("_Metabolic$", colnames(MHPS)), drop = FALSE],
    na.rm = TRUE
  ), 3)
  
  MHPS$MHPS_Fibrotic <- round(rowMeans(
    MHPS[, grep("_Fibrotic$", colnames(MHPS)), drop = FALSE],
    na.rm = TRUE
  ), 3)
  
  
  #Add rank Top% to the MHPS (metabolic & fibrotic arms)
  add_rank_percentile <- function(scores) {
    rank_ <- rank(-scores, ties.method = "min")
    percentile_ <- rank_ / length(scores) * 100
    list(rank = rank_, percentile = percentile_)
  }
  
  # Metabolic
  met <- add_rank_percentile(MHPS$MHPS_Metabolic)
  MHPS$Rank_MHPS_Metabolic <- met$rank
  MHPS$Percentile_MHPS_Metabolic <- round(met$percentile, 1)
  MHPS$Top_MHPS_Metabolic <- mapply(
    get_label,
    MHPS$Percentile_MHPS_Metabolic,
    MHPS$Rank_MHPS_Metabolic
  )
  
  # Fibrotic
  fib <- add_rank_percentile(MHPS$MHPS_Fibrotic)
  MHPS$Rank_MHPS_Fibrotic <- fib$rank
  MHPS$Percentile_MHPS_Fibrotic <- round(fib$percentile, 1)
  MHPS$Top_MHPS_Fibrotic <- mapply(
    get_label,
    MHPS$Percentile_MHPS_Fibrotic,
    MHPS$Rank_MHPS_Fibrotic
  )
  
  # ---- Reorder columns: MHPS first ----
  mhps_cols <- c(
    "MHPS_Metabolic",
    "Top_MHPS_Metabolic",
    "MHPS_Fibrotic",
    "Top_MHPS_Fibrotic"
  )
  
  ordered_prefixes <- c("PHPS", "HHPS", "DHPS")
  
  other_cols <- unlist(lapply(
    ordered_prefixes,
    function(p) grep(paste0("^", p, "_"), colnames(MHPS), value = TRUE)
  ))
  
  MHPS <- MHPS[, c("Model", mhps_cols, other_cols)]
  
  # ---- Force new model to top ----
  MHPS$.priority <- 1
  
  if (!is.null(model_name_) && nzchar(model_name_)) {
    # Use the provided model name
    MHPS$.priority[
      trimws(tolower(MHPS$Model)) ==
        trimws(tolower(model_name_))
    ] <- 0
  } else if (!is.null(first_model)) {
    # If model name is empty, use the first submitted model in the data
    MHPS$.priority[
      trimws(tolower(MHPS$Model)) ==
        trimws(tolower(first_model))
    ] <- 0
  }
  
  MHPS <- MHPS[order(MHPS$.priority), ]
  MHPS$.priority <- NULL
  
  MHPS[1, 3] = add_top_symbol(MHPS[1, 3])
  MHPS[1, 5] = add_top_symbol(MHPS[1, 5])
  
  colnames(MHPS) <- gsub(
    "^Top_MHPS_Metabolic$",
    "MHPS_Metabolic (Top %)",
    colnames(MHPS)
  )
  
  colnames(MHPS) <- gsub(
    "^Top_MHPS_Fibrotic$",
    "MHPS_Fibrotic (Top %)",
    colnames(MHPS)
  )
  
  
  
  return(MHPS)
}





add_top_symbol <- function(label) {
    if (label == "Top1%") {
      return("Top1% 🔥🔥")
    } else if (label == "Top5%") {
      return("Top5% 🔥")
    } else if (label == "Top10%") {
      return("Top10% 🔥")
    } else if (label == "Top20%") {
      return("Top20% 🟢")
    } else if (label == "Top50%") {
      return("Top50% 🟠")
    } else if (label == "Bottom50%") {
      return("Bottom50% ⚪")
    }
  return(label)  # unchanged for other cases
}








plot_MHPS_scatter <- function(MHPS, new_model = NULL) {
  
  # Decide highlight model
  highlight_model <- if (!is.null(new_model) && nzchar(new_model)) {
    new_model
  } else {
    MHPS$Model[1]
  }
  
  MHPS$Highlight <- ifelse(
    trimws(tolower(MHPS$Model)) == trimws(tolower(highlight_model)),
    "New Model",
    "Other Models"
  )
  
  ggplot(MHPS, aes(x = MHPS_Metabolic, y = MHPS_Fibrotic)) +
    stat_density_2d(
      aes(fill = after_stat(level)),
      geom = "polygon",
      alpha = 0.10,
      color = NA
    ) +
    scale_fill_viridis_c(
      option = "C",
      begin = 0.15,
      end = 0.85
    ) +
    geom_vline(
      xintercept = median(MHPS$MHPS_Metabolic, na.rm = TRUE),
      linetype = "dashed",
      linewidth = 1,
      color = "grey30"
    ) +
    geom_hline(
      yintercept = median(MHPS$MHPS_Fibrotic, na.rm = TRUE),
      linetype = "dashed",
      linewidth = 1,
      color = "grey30"
    ) +
    geom_point(
      data = subset(MHPS, Highlight == "Other Models"),
      aes(color = Highlight, shape = Highlight),
      size = 2.5,
      stroke = 0.9,
      fill = "white",
      alpha = 0.9,
      position = position_jitter(width = 0.005, height = 0.005)
    ) +
    geom_point(
      data = subset(MHPS, Highlight == "New Model"),
      aes(color = Highlight, shape = Highlight),
      size = 3.4,
      stroke = 0.9,
      fill = "white",
      alpha = 0.9
    ) +
    scale_color_manual(
      values = c("Other Models" = "grey20", "New Model" = "red")
    ) +
    scale_shape_manual(
      values = c("Other Models" = 21, "New Model" = 24)
    ) +
    geom_text(
      data = subset(MHPS, Highlight == "New Model"),
      aes(label = Model),
      vjust = -1.2,
      fontface = "bold",
      color = "red"
    ) +
    theme_minimal() +
    labs(
      #title = "MHPS Final Ranking: Metabolic vs Fibrotic",
      x = "MHPS Metabolic score",
      y = "MHPS Fibrotic score"
    ) +
    theme(
      legend.position = "none",
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
}



mhps_strength <- function(top_label) {
  if (grepl("Top1%|Top5%|Top10%|Top20%", top_label)) {
    "strong"
  } else if (grepl("Top50%", top_label)) {
    "moderate"
  } else {
    "weak"
  }
}

generate_MHPS_summary <- function(MHPS) {
  
  new_model <- MHPS$Model[1]
  
  metab_score <- MHPS$MHPS_Metabolic[1]
  fib_score   <- MHPS$MHPS_Fibrotic[1]
  
  metab_top <- MHPS$`MHPS_Metabolic (Top %)`[1]
  fib_top   <- MHPS$`MHPS_Fibrotic (Top %)`[1]
  
  metab_strength <- mhps_strength(metab_top)
  fib_strength   <- mhps_strength(fib_top)
  
  ## -----------------------------
  ## Narrative text
  ## -----------------------------
  
  summary_text <- if (metab_strength == "strong" && fib_strength == "strong") {
    
    "The model demonstrates a <b>balanced and high translational alignment</b> with human MASLD,
     capturing both metabolic and fibrotic disease components at a high level. This profile
     supports its suitability for comprehensive mechanistic studies and therapeutic evaluation."
    
  } else if (metab_strength == "strong" && fib_strength == "moderate") {
    
    "The model demonstrates a <b>strong metabolic alignment</b> with human MASLD, while showing
     a <b>moderate representation of fibrotic features</b>. This profile indicates a
     <b>metabolic-dominant disease phenotype</b>, suitable for studies focusing on metabolic
     dysfunction with partial fibrotic involvement."
    
  } else if (metab_strength == "strong" && fib_strength == "weak") {
    
    "The model exhibits a <b>robust metabolic alignment</b> with human MASLD but a
     <b>limited representation of fibrotic pathology</b>. This suggests suitability primarily
     for investigating early or metabolic stages of disease."
    
  } else if (metab_strength == "moderate" && fib_strength == "strong") {
    
    "The model shows a <b>strong fibrotic alignment</b> with human MASLD, accompanied by a
     <b>moderate metabolic component</b>. This profile supports its use in studies emphasizing
     fibrosis-driven disease mechanisms."
    
  } else if (metab_strength == "moderate" && fib_strength == "moderate") {
    
    "The model demonstrates a <b>moderate and mixed alignment</b> with human MASLD across both
     metabolic and fibrotic axes, suggesting an intermediate disease phenotype without strong
     dominance in either domain."
    
  } else if (metab_strength == "weak" && fib_strength == "strong") {
    
    "The model captures <b>fibrotic features of MASLD</b> but shows a <b>limited metabolic
     alignment</b>, indicating a fibrosis-focused disease representation."
    
  } else {
    
    "The model shows a <b>limited translational alignment</b> with human MASLD across both
     metabolic and fibrotic components, suggesting restricted suitability for modeling
     core disease features."
  }
  
  tldr_text <- if (metab_strength == "strong" && fib_strength == "strong") {
    "<b>One-line summary:</b> A <b>balanced, high-fidelity MASLD model</b> capturing both metabolic and fibrotic disease components."
  } else if (metab_strength == "strong" && fib_strength == "moderate") {
    "<b>One-line summary:</b> A <b>metabolic-dominant MASLD model</b> with partial fibrotic representation."
  } else if (metab_strength == "strong" && fib_strength == "weak") {
    "<b>One-line summary:</b> A <b>metabolic-focused early-stage MASLD model</b> with limited fibrosis."
  } else if (metab_strength == "moderate" && fib_strength == "strong") {
    "<b>One-line summary:</b> A <b>fibrosis-dominant MASLD model</b> with moderate metabolic alignment."
  } else if (metab_strength == "moderate" && fib_strength == "moderate") {
    "<b>One-line summary:</b> An <b>intermediate mixed-phenotype MASLD model</b>."
  } else if (metab_strength == "weak" && fib_strength == "strong") {
    "<b>One-line summary:</b> A <b>fibrosis-focused model</b> with limited metabolic relevance."
  } else {
    "<b>One-line summary:</b> A model with <b>limited translational relevance</b> to human MASLD."
  }
  
  
  ## -----------------------------
  ## HTML output
  ## -----------------------------
  
  HTML(sprintf(
    "<div style='text-align: justify; font-size: 14px; margin-top: -35px;'>
      Top model legend:<span style='margin-right:12px;'>Top1%% 🔥🔥</span><span style='margin-right:12px;'>Top10%% 🔥</span><span style='margin-right:12px;'>Top20%% 🟢</span><span style='margin-right:12px;'>Top50%% 🟠</span><span style='margin-right:12px;'>Bottom50%% ⚪</span>
      <hr style='border: 1px solid #ccc; margin:2px 0;'>
      <br></div> 
      
       <div style='
       animation: fadeIn 0.4s ease-in;
       border: 1px solid #ddd;
       border-left: 5px solid #bdbdbd;
       background-color: #f9f9f9;
       padding: 12px 14px;
       margin-top: 10px;
       font-size: 14px;
       '>
      %s
      <br><br><b>Detailed summary:</b>
      '<b>%s</b>' was evaluated across <b>%d preclinical models</b>.
      It achieved a metabolic MHPS score of <b>%.2f (%s)</b> and a fibrotic MHPS score of
      <b>%.2f (%s)</b>.
      <br>
      %s <br>
    </div><br>",
    tldr_text,
    new_model,
    nrow(MHPS),
    metab_score, metab_top,
    fib_score, fib_top,
    summary_text
  ))
}







plot_MHPS_contributions <- function(
    MHPS,
    available_layers,
    arm = c("Metabolic", "Fibrotic"),
    new_model = NULL
) {
  
  available_layers <- unlist(available_layers)
  
  arm <- match.arg(arm)
  
  # ---- Map layers to columns ----
  layer_map <- list(
    "Phenotypes" = paste0("PHPS_", arm),
    "Histology"  = paste0("HHPS_", arm),
    "RNA-Seq"    = paste0("DHPS_", arm)
  )
  
  # Keep only available layers
  score_cols <- unname(layer_map[names(layer_map) %in% available_layers])
  
  if (length(score_cols) == 0) {
    stop("No MHPS layers available for plotting.")
  }
  
  # ---- Prepare long-format data ----
  plot_df <- MHPS[, c("Model", as.character(unlist(score_cols))), drop = FALSE]
  
  long_df <- melt(
    plot_df,
    id.vars = "Model",
    variable.name = "Subscore",
    value.name = "Score"
  )
  
  long_df$Subscore <- gsub(paste0("_", arm), "", long_df$Subscore)
  
  # ---- Order models by total MHPS ----
  total_scores <- aggregate(Score ~ Model, long_df, sum)
  long_df$Model <- factor(
    long_df$Model,
    levels = total_scores$Model[order(total_scores$Score)]
  )
  
  # ---- Colors (paper-consistent) ----
  paper_colors <- c(
    "PHPS" = "#0072B2",
    "HHPS" = "#E69F00",
    "DHPS" = "#009E73"
  )
  
  # ---- Base plot ----
  p <- ggplot(long_df, aes(x = Model, y = Score, fill = Subscore)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    scale_fill_manual(values = paper_colors, name = "Component") +
    labs(
      #title = paste0(arm, " Arm"),
      x = "Model",
      y = "MHPS"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.major.y = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
  
  # ---- Bold label for selected model (optional) ----
  if (is.null(new_model) || new_model == "") {
    new_model <- "New_Model"
  }
  
  # Create bold labels for y-axis
  bold_labels <- sapply(levels(long_df$Model), function(x) {
    if (x == new_model) {
      paste0("**", x, "**")  # bold the new model
    } else {
      x
    }
  })
  
  names(bold_labels) <- levels(long_df$Model)
  
  # Apply to the plot
  p <- p + scale_x_discrete(labels = bold_labels) +
    theme(axis.text.y = element_markdown())  # <-- render markdown
  
  
  return(p)
}






