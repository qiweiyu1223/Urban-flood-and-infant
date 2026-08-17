# Urban Flooding and Child Health

This repository contains the Stata code and figure-level data used to study the relationship between urban flood exposure and child health outcomes, with a particular focus on fever. The materials cover data preparation, regression analysis, robustness and heterogeneity tests, figure construction, and the processed data underlying the main and supplementary figures.

## Repository structure

```text
.
├── 01_data_processing/
├── 02_regression_codes/
├── 03_figure_codes/
├── 04_support_codes/
└── 05_figure_data/
```

### `01_data_processing`

Contains scripts for configuring project paths, constructing analysis variables, transforming measures, and merging supplementary datasets into the main analytical file.

Key tasks include:

- defining the project-wide Stata globals;
- constructing flood, health, demographic, socioeconomic, and spatial variables;
- merging hospital, road, urban-centre, terrain, catchment, and climate information; and
- saving the processed datasets used by the regression scripts.

The main setup file is `1 数据前的加载_clean_global.do`. Edit the `global dir` definition in this file before running the analysis on another computer.

### `02_regression_codes`

Contains the main empirical analyses and supplementary tests. The scripts estimate the association between flood exposure and child fever and generate intermediate regression results for tables and figures.

The analyses include:

- flood exposure windows and short-term child health outcomes;
- baseline estimates and alternative specifications;
- flooded hospitals and other facility-related mechanisms;
- heterogeneity by distance to the urban-centre boundary;
- heterogeneity by social and urban-development characteristics;
- heterogeneity by mapped-water presence and Height Above Nearest Drainage (HAND);
- comparisons using alternative flood-catchment durations;
- associations between fever and other childhood diseases or symptoms; and
- descriptive statistics used in the Supplementary Information.

### `03_figure_codes`

Contains the Stata scripts used to construct the main and supplementary figures from regression outputs and prepared plotting datasets.

The figure scripts cover:

- flood-exposure windows and child fever;
- baseline and robustness estimates;
- flooded health facilities;
- distance-based heterogeneity and sample counts;
- social and urban-development heterogeneity;
- mapped-water presence and HAND groups; and
- supplementary disease, exposure-duration, and distribution plots.

### `04_support_codes`

Contains reusable helper scripts called by the regression and figure programs. These utilities standardize `parmest` output, combine parameter files, retain the variables required for plotting, and extract the data underlying the figures.

In particular, `extract_figure_plot_data.do` creates the processed plotting datasets collected in `05_figure_data`.

### `05_figure_data`

Contains processed Stata datasets (`.dta`) underlying the main and supplementary figures. The subfolders correspond to figure families:

| Folder | Content |
|---|---|
| `f1_short_health` | Flood-exposure windows and short-term child health |
| `f2_baseline_robust` | Baseline estimates and robustness checks |
| `f2_SI_baseline_robust` | Supplementary alternative specifications |
| `f3_flooded_hospital` | Flooded facilities and hospital-related results |
| `f4_distance` | Heterogeneity by distance to the urban boundary |
| `f4_sample_counts` | Sample sizes across distance groups |
| `f4_SI_distance5` | Supplementary five-group distance analysis |
| `f5_1_social_urban` | Social and urban-development heterogeneity |
| `f5_2_HAND_groups` | Mapped-water presence and HAND-group estimates |
| `SI_f1_other_disease` | Fever and other diseases or symptoms |
| `SI_fsup_hours` | Alternative flood-catchment durations |

These files provide the estimates, confidence intervals, group labels, sample counts, and other processed values used in the figures. They do not contain the restricted individual-level source data.

## Software requirements

The analysis is written for Stata. The following community-contributed commands are used by the scripts:

```stata
ssc install ftools, replace
ssc install reghdfe, replace
ssc install outreg2, replace
ssc install parmest, replace
```

Several figure scripts also call `openall`. Make sure that this command is installed or otherwise available on the Stata ado-path before running those scripts.

## Running the analysis

1. Clone or download this repository.
2. Place the required source datasets in a local data directory. The individual-level analytical data are not included in this repository.
3. Open `01_data_processing/1 数据前的加载_clean_global.do` and change `global dir` to the local project root.
4. Search the `.do` files for any remaining absolute paths (for example, paths beginning with `E:/` or `G:/`) and update them for the local environment.
5. Run the relevant data-processing scripts in `01_data_processing` if the processed analytical data must be rebuilt.
6. Run the scripts in `02_regression_codes` to reproduce the regression outputs.
7. Run the scripts in `03_figure_codes` to recreate the figures from the regression and plotting outputs.
8. Run `04_support_codes/extract_figure_plot_data.do` to rebuild the figure-level datasets stored in `05_figure_data`.

The regression scripts are organized by analysis rather than through a single master script. Run only the modules required for the result being reproduced, while preserving the dependencies described in the code comments.

## Data availability and reproducibility

The repository includes processed, figure-level data but not the restricted individual-level source datasets. Reproducing the regressions therefore requires authorized access to the underlying survey and spatial datasets and preparation of the expected Stata files and variables.

The files in `05_figure_data` are intended to improve transparency by providing the numerical values underlying the reported figures. Because the current figure scripts generally read intermediate regression or `parmest` outputs, users who wish to plot directly from `05_figure_data` may need to update the corresponding input paths or `use` statements.

## File formats

- `.do`: Stata programs for data preparation, analysis, and visualization.
- `.dta`: processed Stata datasets containing figure-level results.

## Questions and issues

For questions about the code or reproducibility, please open an issue in this GitHub repository and identify the relevant script and figure or table.
