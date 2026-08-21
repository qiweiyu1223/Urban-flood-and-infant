*============================================================
* SI Table 1. Descriptive statistics for core regression variables
*
* Scope:
* - Uses only the Stata files in:
*   Child fever Stata code folder
* - Excludes fixed effects.
* - Excludes extended derived variables such as top-coded variables,
*   log-transformed variables, distance-group indicators, interaction
*   terms, and categories generated from continuous variables.
*
* Output:
*   $result/SI_t1_descriptive_statistics.xlsx
*============================================================

clear all
set more off

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

use "$data/KR_PR_Africa_4.dta", clear

*------------------------------------------------------------
**# 1. Core variables used by the regressions
*------------------------------------------------------------

* Main health outcomes.
local outcome_vars ///
    ch_fever cough ch_diar

* Main flood exposure variables.
local flood_vars ///
    flood_1m_ratio_csv flood_2m_ratio_csv flood_3m_ratio_csv ///
    flood_4m_ratio_csv flood_5m_ratio_csv flood_6m_ratio_csv ///
    flood_7m_ratio_csv flood_8m_ratio_csv flood_9m_ratio_csv ///
    flood_10m_ratio_csv flood_11m_ratio_csv flood_12m_ratio_csv ///
    flood_6m_ratio ///
    flood30_3m flood30_6m flood30_9m flood30_12m

* Baseline child, household, and maternal controls.
local baseline_control_vars ///
    b4 agegrp bord_grp ///
    v136 v190 v106 v012

* Core spatial, accessibility, household environment, and vegetation controls.
* For logged road length used in regressions, report the underlying raw
* road-length variable when it exists; do not report the log-transformed form.
local environment_control_vars ///
    road_total_length_m city_hf_total dhs_to_urban_boundary_km ///
    ph_rooms_sleep ph_wtr_improve ph_wtr_time ///
    hospital_30km_total ///
    NDVI_m3 NDVI_m6 NDVI_m9 NDVI_m12 ///
    EVI_m3 EVI_m6 EVI_m9 EVI_m12

* Weather controls matched to exposure windows.
local weather_vars ///
    tmp_mean_1m tmp_mean_2m tmp_mean_3m tmp_mean_4m ///
    tmp_mean_5m tmp_mean_6m tmp_mean_7m tmp_mean_8m ///
    tmp_mean_9m tmp_mean_10m tmp_mean_11m tmp_mean_12m ///
    pre_mean_1m pre_mean_2m pre_mean_3m pre_mean_4m ///
    pre_mean_5m pre_mean_6m pre_mean_7m pre_mean_8m ///
    pre_mean_9m pre_mean_10m pre_mean_11m pre_mean_12m

* Flooded facility shares used in the mechanism regressions.
* Log-transformed flooded-facility counts are intentionally excluded.
local facility_vars ///
    hospital_total_flood_pct_6m primary_flood_pct_6m ///
    water_flood_pct_6m law_flood_pct_6m commerce_flood_pct_6m ///
    school_flood_pct_6m

* Continuous source variables used for social and urban-development
* heterogeneity. The generated high/low group indicators are excluded.
local urban_development_vars ///
    NTL_2013_mean NTL_2020_mean NTL_growth NTL_growth_rate ///
    BU_area BU_ratio BU_density BU_growth_2010_2020 ///
    BU_grate_2010_2020 ///
    DEM_landscan DEM_ghspop DEM_worldpop DEM_gpw

* Continuous source variables for near-water and low-lying-city analysis.
* The generated categorical variables are excluded.
local water_lowlying_source_vars ///
    WATER_distance_m DEM_city_minus_buffer_mean

local stat_vars ///
    `outcome_vars' ///
    `flood_vars' ///
    `baseline_control_vars' ///
    `environment_control_vars' ///
    `weather_vars' ///
    `facility_vars' ///
    `urban_development_vars' ///
    `water_lowlying_source_vars'

*------------------------------------------------------------
**# 2. English variable descriptions
*    Use variable labels instead of desc_* locals to avoid Stata's
*    local-macro name length limit.
*------------------------------------------------------------

capture label variable ch_fever "Child had fever in the two weeks before the survey"
capture label variable cough "Child had cough in the two weeks before the survey"
capture label variable ch_diar "Child had diarrhea in the two weeks before the survey"

capture label variable flood_1m_ratio_csv "Flood exposure ratio in the 1-month window before survey"
capture label variable flood_2m_ratio_csv "Flood exposure ratio in the 2-month window before survey"
capture label variable flood_3m_ratio_csv "Flood exposure ratio in the 3-month window before survey"
capture label variable flood_4m_ratio_csv "Flood exposure ratio in the 4-month window before survey"
capture label variable flood_5m_ratio_csv "Flood exposure ratio in the 5-month window before survey"
capture label variable flood_6m_ratio_csv "Flood exposure ratio in the 6-month window before survey"
capture label variable flood_7m_ratio_csv "Flood exposure ratio in the 7-month window before survey"
capture label variable flood_8m_ratio_csv "Flood exposure ratio in the 8-month window before survey"
capture label variable flood_9m_ratio_csv "Flood exposure ratio in the 9-month window before survey"
capture label variable flood_10m_ratio_csv "Flood exposure ratio in the 10-month window before survey"
capture label variable flood_11m_ratio_csv "Flood exposure ratio in the 11-month window before survey"
capture label variable flood_12m_ratio_csv "Flood exposure ratio in the 12-month window before survey"
capture label variable flood_6m_ratio "Alternative flood exposure ratio in the 6-month window before survey"
capture label variable flood30_3m "Flood exposure within 30 km of the DHS cluster in the 3-month window"
capture label variable flood30_6m "Flood exposure within 30 km of the DHS cluster in the 6-month window"
capture label variable flood30_9m "Flood exposure within 30 km of the DHS cluster in the 9-month window"
capture label variable flood30_12m "Flood exposure within 30 km of the DHS cluster in the 12-month window"

capture label variable b4 "Child sex"
capture label variable agegrp "Child age group"
capture label variable bord_grp "Birth-order group"
capture label variable v136 "Number of household members"
capture label variable v190 "Household wealth index"
capture label variable v106 "Mother's highest education level"
capture label variable v012 "Mother's age"

capture label variable road_total_length_m "Road length around the survey cluster, in meters"
capture label variable city_hf_total "Number of health facilities in the urban centre"
capture label variable dhs_to_urban_boundary_km "Distance from DHS cluster to urban boundary, in kilometers"
capture label variable ph_rooms_sleep "Number of rooms used for sleeping"
capture label variable ph_wtr_improve "Household has an improved water source"
capture label variable ph_wtr_time "Time needed to collect household water"
capture label variable hospital_30km_total "Number of hospitals within 30 km"

forvalues w = 1/12 {
    capture label variable tmp_mean_`w'm "Mean temperature in the `w'-month window before survey"
    capture label variable pre_mean_`w'm "Mean precipitation in the `w'-month window before survey"
}

capture label variable NDVI_m3 "Mean NDVI in the 3-month window before survey"
capture label variable NDVI_m6 "Mean NDVI in the 6-month window before survey"
capture label variable NDVI_m9 "Mean NDVI in the 9-month window before survey"
capture label variable NDVI_m12 "Mean NDVI in the 12-month window before survey"
capture label variable EVI_m3 "Mean EVI in the 3-month window before survey"
capture label variable EVI_m6 "Mean EVI in the 6-month window before survey"
capture label variable EVI_m9 "Mean EVI in the 9-month window before survey"
capture label variable EVI_m12 "Mean EVI in the 12-month window before survey"

capture label variable hospital_total_flood_pct_6m "Share of hospitals flooded in the 6-month window"
capture label variable primary_flood_pct_6m "Share of primary facilities flooded in the 6-month window"
capture label variable water_flood_pct_6m "Share of water facilities flooded in the 6-month window"
capture label variable law_flood_pct_6m "Share of law-related facilities flooded in the 6-month window"
capture label variable commerce_flood_pct_6m "Share of commerce facilities flooded in the 6-month window"
capture label variable school_flood_pct_6m "Share of schools flooded in the 6-month window"

capture label variable NTL_2013_mean "Mean nighttime light intensity in 2013"
capture label variable NTL_2020_mean "Mean nighttime light intensity in 2020"
capture label variable NTL_growth "Nighttime light growth"
capture label variable NTL_growth_rate "Nighttime light growth rate"
capture label variable BU_area "Built-up area"
capture label variable BU_ratio "Built-up ratio"
capture label variable BU_density "Built-up density"
capture label variable BU_growth_2010_2020 "Built-up area growth from 2010 to 2020"
capture label variable BU_grate_2010_2020 "Built-up area growth rate from 2010 to 2020"
capture label variable DEM_landscan "Population proxy from LandScan"
capture label variable DEM_ghspop "Population proxy from GHS-POP"
capture label variable DEM_worldpop "Population proxy from WorldPop"
capture label variable DEM_gpw "Population proxy from GPW"

capture label variable WATER_distance_m "Distance from urban centre to nearest water body, in meters"
capture label variable DEM_city_minus_buffer_mean "Mean city elevation minus mean buffer elevation"

*------------------------------------------------------------
**# 3. Produce descriptive statistics
*------------------------------------------------------------

tempfile si_t1_stats
tempname posth

postfile `posth' ///
    str48 variable_name ///
    str244 variable_description ///
    double observations mean median standard_deviation ///
    using `si_t1_stats', replace

local already_done ""

foreach v of local stat_vars {
    if strpos(" `already_done' ", " `v' ") > 0 {
        continue
    }
    local already_done "`already_done' `v'"

    capture confirm variable `v'
    if _rc {
        continue
    }

    quietly summarize `v', detail

    local desc : variable label `v'
    if `"`desc'"' == "" {
        local desc "`v'"
    }

    post `posth' ///
        ("`v'") ///
        (`"`desc'"') ///
        (r(N)) ///
        (r(mean)) ///
        (r(p50)) ///
        (r(sd))
}

postclose `posth'

use `si_t1_stats', clear

label variable variable_name "Variable"
label variable variable_description "Definition"
label variable observations "Observations"
label variable mean "Mean"
label variable median "Median"
label variable standard_deviation "Standard deviation"

format observations %12.0fc
format mean median standard_deviation %12.3f

order variable_name variable_description observations mean median standard_deviation

cap mkdir "$result"

save "$result/SI_t1_descriptive_statistics.dta", replace

export excel variable_name variable_description observations mean median standard_deviation ///
    using "$result/SI_t1_descriptive_statistics.xlsx", ///
    firstrow(varlabels) replace

di as result "SI Table 1 descriptive statistics saved to:"
di as result "$result/SI_t1_descriptive_statistics.xlsx"
