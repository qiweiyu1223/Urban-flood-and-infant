# Urban Flooding and Child Health

This repository contains Stata code and processed figure-level data for studying the relationship between urban flood exposure and child health outcomes, with a focus on fever among children. The materials are organized to support data preparation, regression analysis, figure production, and transparent access to the processed values used in the main and supplementary figures.

## Repository structure

```text
.
├── 01_data_processing/
├── 02_regression_codes/
├── 03_figure_codes/
├── 04_support_codes/
└── 05_figure_data/
```

## Code folders

### `01_data_processing/`

Stata scripts for preparing the analytical datasets. These scripts define project paths, construct variables, merge supplementary data sources, and save processed files used by the analysis scripts.

Current files include:

- `1 数据前的加载_clean_global.do`
- `2. log_变量构造.do`
- `3. 数据增加和log处理合并.do`
- `补充数据_合并版.do`

Before running the analysis on another computer, update the project path settings in `1 数据前的加载_clean_global.do`, especially the `global dir` definition.

### `02_regression_codes/`

Stata scripts for the main regression analyses, robustness checks, supplementary analyses, and heterogeneity tests.

Current files include:

- `1.1 flood and short health risk.do`
- `1.2 fever and other disease.do`
- `2. basline and robustness.do`
- `3. flooded hospital.do`
- `4. estimate across distances to urban bourdary.do`
- `5-1 HAND_four_group_effects_only.do`
- `5-2 map_low and water distance.do`
- `SI social and urban development.do`
- `SI-1h_2h_3h catchment robust.do`

These scripts cover flood exposure and fever, other childhood health outcomes, baseline and robustness models, flooded health facilities, distance-based heterogeneity, HAND and mapped-water groups, social and urban-development heterogeneity, and alternative flood-catchment durations.

### `03_figure_codes/`

Stata scripts for constructing the main and supplementary figures from regression outputs and prepared plotting datasets.

Current files include:

- `f1-1 flood and short health risk.do`
- `f1-2 fever and other disease.do`
- `f2 basline and robustness.do`
- `f3 flooded hospital.do`
- `f4 estimate across distance.do`
- `f5 HAND_four_group_effects_plot.do`
- `SI_f1 kdensity.do`
- `SI_f2 occurred and positive tertiles.do`
- `SI_f3 1h_2h_3h basline and robustness.do`
- `SI_f4 estimate across distance_5 groups.do`
- `SI_f5 sample_counts(2,3,4,5 groups).do`
- `SI_f6 social and urban development.do`

### `04_support_codes/`

Reusable helper scripts used by the regression and figure programs. These utilities support validation, parameter extraction, output selection, and generation of processed figure datasets.

Current files include:

- `extract_figure_plot_data.do`
- `fixed_effects_validation.do`
- `keep parm.do`
- `parmest输出选择语句.do`
- `SI_t1_descriptive_statistic.do`

In particular, `extract_figure_plot_data.do` is used to create or organize the processed plotting datasets stored in `05_figure_data/`.

## Figure-level data

### `05_figure_data/`

This folder contains processed Stata datasets (`.dta`) underlying the main and supplementary figures. These are figure-level or plotting-ready datasets, not the restricted individual-level source data.

| Folder | Files | Description |
|---|---:|---|
| `f1_1_short_health/` | 2 | Figure data for flood exposure and short-term child health outcomes. |
| `f1_2_other_disease/` | 1 | Figure data for fever and other childhood diseases or symptoms. |
| `f2_baseline_robust/` | 8 | Baseline estimates and robustness-check figure data. |
| `f3_flooded_hospital/` | 4 | Figure data related to flooded hospitals, facility exposure, and hospital composition. |
| `f4_distance/` | 5 | Figure data for heterogeneity by distance to the urban boundary. |
| `f5_HAND_groups/` | 5 | Figure data for mapped-water presence and HAND group analyses. |
| `SI_f2_occurred_positive_tertiles/` | 3 | Supplementary figure data for flood occurrence, positive exposure, and weighted continuous specifications. |
| `SI_f3_hours/` | 3 | Supplementary figure data for alternative flood-catchment durations. |
| `SI_f4_distance_5_groups/` | 5 | Supplementary figure data for five-group distance analyses. |
| `SI_f5_sample_counts/` | 1 | Supplementary sample-count data across distance groups. |
| `SI_f6_social_urban/` | 1 | Supplementary figure data for social and urban-development heterogeneity. |

## Software requirements

The analysis is written for Stata. The scripts use several community-contributed commands, including:

```stata
ssc install ftools, replace
ssc install reghdfe, replace
ssc install outreg2, replace
ssc install parmest, replace
```

Some scripts may also require additional user-written commands such as `openall`. Install any missing commands before running the full workflow.

## Running the workflow

1. Clone or download this repository.
2. Place the required restricted source datasets in the expected local data directory. These source datasets are not included in this repository.
3. Open `01_data_processing/1 数据前的加载_clean_global.do` and update the project root path, especially `global dir`.
4. Search the `.do` files for any remaining absolute local paths and adjust them for your environment.
5. Run the relevant scripts in `01_data_processing/` if the processed analytical data need to be rebuilt.
6. Run the analysis scripts in `02_regression_codes/` to reproduce regression outputs.
7. Use `04_support_codes/` as needed to validate outputs, process parameter estimates, and extract plotting datasets.
8. Run the scripts in `03_figure_codes/` to recreate the figures.
9. Use the datasets in `05_figure_data/` to inspect the processed numerical values underlying the figures.

The repository is organized by analysis module rather than as a single master script. Run only the modules required for the result being reproduced, while preserving the path and data dependencies described in the code comments.

## Data availability and reproducibility

The repository includes Stata code and processed figure-level data. It does not include restricted individual-level survey data or other restricted source datasets needed to rebuild every analytical file from scratch.

The `05_figure_data/` folder improves transparency by providing processed values used in the figures, including estimates, confidence intervals, group labels, and sample-count information where applicable.

## File formats

- `.do`: Stata programs for data preparation, regression analysis, support utilities, and figure construction.
- `.dta`: processed Stata datasets containing figure-level or plotting-ready results.

## Questions and issues

For questions about code organization or reproducibility, please open an issue in this GitHub repository and identify the relevant script, figure, or table.
