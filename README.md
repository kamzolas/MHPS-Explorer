# 🧬 MHPS Explorer  
## MASLD Human Proximity Score Web Tool

**Software Developer**: Ioannis Kamzolas  
**email**: *ik352@cam.ac.uk*

---

## Overview

**MHPS Explorer** is an interactive Shiny application designed to benchmark rodent MASLD models against human disease using integrated multi-layer evidence:

- **PHPS** – Phenotypic Human Proximity Score  
- **HHPS** – Histological Human Proximity Score  
- **DHPS** – DSEA Human Proximity Score (Transcriptomics)  
- **MHPS** – Integrated MASLD Human Proximity Score  

The framework integrates phenotypic, histological, and transcriptomic similarity to human MASLD.

---

## Repository Structure

This GitHub repository contains the **application source code only**:

```
ui.R
server.R
global.R
renv.lock
renv/
www/
example_files/
```

Due to size limitations, large data directories are hosted separately.

---

## Required Data (Zenodo)

The following folders are required to run the application:

- `R_sources/`
- `file_sources/`

They are archived and publicly available at:

https://zenodo.org/records/18620900

---

## Installation Instructions

### 1️⃣ Clone the repository

```bash
git clone https://github.com/kamzolas/MHPS-Explorer.git
cd MHPS-Explorer
```

Or download as ZIP from GitHub.

---

### 2️⃣ Download Required Data

From Zenodo:

- Download `R_sources.zip`
- Download `file_sources.zip`

Unzip both files into the **root directory** of the repository.

Your folder structure must look like:

```
MHPS-Explorer/
│
├── R_sources/
├── file_sources/
├── ui.R
├── server.R
├── global.R
├── renv/
├── renv.lock
└── www/
```

The application will **not run** if these folders are missing.

---

### 3️⃣ Restore the R Environment

This project uses **renv** for reproducibility.

In R:

```r
install.packages("renv")   # if needed
renv::restore()
```

---

### 4️⃣ Run the Application

```r
shiny::runApp()
```

Or open `MHPS_webtool_ShinyApp.Rproj` in RStudio and click **Run App**.

---

## System Requirements

- R ≥ 4.0 recommended  
- macOS, Linux, or Windows  
- Internet connection required for Altmetric badge rendering  

---

## Data Summary

The integrated dataset includes:

- 598 animals  
- 509 mice  
- 89 rats  
- 41 MASLD models  
- Integrated phenotypic, histological, and transcriptomic layers  

---

## Citation

If you use **MHPS Explorer**, please cite:

Vacca M, Kamzolas I, Mørch Harder L et al.  
*Nature Metabolism* (2024)  
https://www.nature.com/articles/s42255-024-01043-6  

---

## Reproducibility

- Code version-controlled via GitHub: https://github.com/kamzolas/MHPS-Explorer   
- Data archived with DOI via Zenodo: https://zenodo.org/records/18620900  
- R environment locked using `renv`  

This ensures full reproducibility of the MHPS framework.
