🧬 MHPS Explorer
MASLD Human Proximity Score Web Tool

MHPS Explorer is an interactive Shiny application that benchmarks rodent MASLD models against human disease using integrated:

PHPS – Phenotypic Human Proximity Score

HHPS – Histological Human Proximity Score

DHPS – Transcriptomic Disease Human Proximity Score

→ Combined into MHPS (MASLD Human Proximity Score)

This tool accompanies:

Vacca, Kamzolas, Mørch Harder et al.
Nature Metabolism (2024)
https://www.nature.com/articles/s42255-024-01043-6

📦 Repository Structure

This GitHub repository contains the application code only:

ui.R
server.R
global.R
renv.lock
renv/
www/
example_files/


Large data directories are not stored in GitHub to keep the repository lightweight.

📊 Required Data Files (Zenodo)

The following two folders are required to run the application:

R_sources/

file_sources/

They are available via Zenodo:

🔗 https://zenodo.org/records/18620900

⚙️ Installation & Setup
1️⃣ Clone the Repository
git clone https://github.com/kamzolas/MHPS-Explorer.git
cd MHPS-Explorer


Or download as ZIP from GitHub.

2️⃣ Download Required Data

From Zenodo:

Download:

R_sources.zip

file_sources.zip

Unzip both files into the root directory of this repository.

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

3️⃣ Restore the R Environment

This project uses renv for reproducibility.

In R:

install.packages("renv")   # if needed
renv::restore()


This will install all required dependencies.

4️⃣ Run the Application

From R:

shiny::runApp()


Or open MHPS_webtool_ShinyApp.Rproj in RStudio and click Run App.

🖥 System Requirements

R ≥ 4.2 recommended

macOS, Linux, or Windows

Internet connection required for Altmetric badge rendering

📚 Citation

If you use MHPS Explorer in your work, please cite:

Vacca M, Kamzolas I, Mørch Harder L et al.
Nature Metabolism (2024)
https://www.nature.com/articles/s42255-024-01043-6

🔬 Data Provenance

Preclinical dataset includes:

598 animals

41 rodent MASLD models

Integrated phenotypic, histological, and transcriptomic profiling

Full datasets are archived via Zenodo for transparency and long-term availability.
