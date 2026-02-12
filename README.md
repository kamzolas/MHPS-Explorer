🧬 MHPS Explorer
MASLD Human Proximity Score Web Tool

MHPS Explorer is an interactive Shiny application that enables benchmarking of rodent MASLD models against human disease using integrated:

PHPS – Phenotypic Human Proximity Score

HHPS – Histological Human Proximity Score

DHPS – Transcriptomic Disease Human Proximity Score

→ Combined into MHPS (MASLD Human Proximity Score)

This tool accompanies:

Vacca, Kamzolas, Mørch Harder et al.
Nature Metabolism (2024)
https://www.nature.com/articles/s42255-024-01043-6

📦 Repository Structure

This GitHub repository contains:

ui.R

server.R

global.R

renv.lock

renv/

www/

example_files/

Large data directories are not stored in GitHub.

They are deposited separately in Zenodo for reproducibility.

📊 Required Data Files (Zenodo)

The following two folders are required to run the application:

R_sources/

file_sources/

They are available here:

🔗 Zenodo Record:
https://zenodo.org/records/18620900

⚙️ Installation & Setup
Step 1 — Clone this repository
git clone https://github.com/kamzolas/MHPS-Explorer.git
cd MHPS-Explorer


Or download as ZIP from GitHub.

Step 2 — Download Required Data

From Zenodo:

Download:

R_sources.zip

file_sources.zip

Unzip both files into the root directory of this repository

After extraction, your folder structure should look like:

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


⚠️ The app will not run if these folders are missing.

Step 3 — Restore the R Environment

The project uses renv to ensure reproducibility.

Open R in the project folder and run:

install.packages("renv")   # if not installed
renv::restore()


This will install all required packages.

Step 4 — Run the App

From R:

shiny::runApp()


Or open the .Rproj file in RStudio and click Run App.

🖥 System Requirements

R ≥ 4.2 recommended

macOS, Linux, or Windows

Internet connection required for:

Altmetric badge rendering

📚 Citation

If you use MHPS Explorer in your work, please cite:

Vacca M, Kamzolas I, Mørch Harder L et al.
Nature Metabolism (2024)
https://www.nature.com/articles/s42255-024-01043-6

🔬 Data Provenance

Preclinical data include:

598 animals

41 rodent MASLD models

Integrated phenotypic, histological, and transcriptomic profiling

Full datasets are archived via Zenodo for transparency and long-term availability.

🧠 Reproducibility

Code version controlled via GitHub

Data archived with DOI via Zenodo

R environment locked via renv

This ensures full reproducibility of the published MHPS framework.
