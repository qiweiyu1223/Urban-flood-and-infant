*******************************************************
**# 0. Data and baseline setup
*******************************************************
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
*-----------------------------
**## Paths; adjust locally if needed
*-----------------------------


use "$data/KR_PR_Africa_4.dta", clear

*-----------------------------
**## Generate cluster_id if it does not already exist
*-----------------------------
cap confirm variable cluster_id
if _rc {
    egen cluster_id = group(v000 v001)
}

*-----------------------------
**# Outcome, core exposure, controls, and fixed effects
* Update these definitions here if needed.
*-----------------------------
local y   ch_fever
local x   flood_3m_ratio_csv

**## Current conservative control set; update if needed
local controls i.b4 ib1.agegrp ib1.bord_grp c.v136 i.v190 i.v106 c.v012 ///
    log1_road_total_length_m ///
    log1_dhs_to_urban_boundary_km ///
    DEM_city_minus_buffer_mean ///
    tmp_mean_3m pre_mean_3m


**## Store fixed effects in local macros to avoid repetition
local absorb_fe urban_id v007 v006
local vceopt    vce(cluster urban_id)

*-----------------------------
**# Panel A moderator list
*-----------------------------
local mods ///
    NTL_2013_mean ///
    NTL_2020_mean ///
    NTL_growth ///
    NTL_growth_rate ///
    BU_area ///
    BU_ratio ///
    BU_density ///
    BU_growth_2010_2020 ///
    BU_grate_2010_2020 ///
    DEM_landscan ///
    DEM_ghspop ///
    DEM_worldpop ///
    DEM_gpw


*******************************************************
**# 1. Loop regressions by median split and extract High-Low differences
*******************************************************
tempfile results
tempname posth

postfile `posth' ///
    str40 moderator ///
    str40 label ///
    double estimate se p min95 max95 N ///
    using `results', replace

foreach m of local mods {

    di as text "--------------------------------------"
    di as text "Running moderator: `m'"

    *-----------------------------------------
    * Check whether the variable exists.
    *-----------------------------------------
    cap confirm variable `m'
    if _rc {
        di as error "Variable `m' not found, skipped."
        continue
    }

    *-----------------------------------------
    * Keep only observations with nonmissing variables needed for this regression.
    *-----------------------------------------
    tempvar touse high
    gen byte `touse' = !missing(`y', `x', `m', cluster_id, v007, v006)

    * Apply stricter sample restrictions when controls are missing.
    * For robustness, check the controls one by one.
    foreach vv in b4 agegrp bord_grp v136 v190 v106 v012 ///
        log1_road_total_length_m ///
        log1_dhs_to_urban_boundary_km DEM_city_minus_buffer_mean ///
        tmp_mean_3m pre_mean_3m {
        cap confirm variable `vv'
        if !_rc {
            replace `touse' = 0 if missing(`vv')
        }
    }

    *-----------------------------------------
    * Skip the model if the sample is too small.
    *-----------------------------------------
    quietly count if `touse'==1
    if r(N) < 100 {
        di as error "Too few observations for `m', skipped."
        continue
    }

    *-----------------------------------------
    * Split High and Low groups at the median.
    *-----------------------------------------
    quietly summarize `m' if `touse'==1, detail
    local med = r(p50)

    gen byte `high' = .
    replace `high' = (`m' >= `med') if `touse'==1

    * Skip if the split produces only zeros or only ones.
    quietly tab `high' if `touse'==1
    if r(r) < 2 {
        di as error "`m' cannot be split into two groups, skipped."
        drop `touse' `high'
        continue
    }

    *-----------------------------------------
    * Regression with the interaction between x and high.
    *-----------------------------------------
    quietly reghdfe `y' c.`x'##i.`high' `controls' ///
        if `touse'==1, absorb(`absorb_fe') `vceopt'

    *-----------------------------------------
    * Extract the High-Low difference.
    * This is the interaction term: 1.high#c.x.
    *-----------------------------------------
    quietly lincom 1.`high'#c.`x'

    local b  = r(estimate)
    local se = r(se)
    local p  = r(p)
    local ll = r(lb)
    local ul = r(ub)
    local NN = e(N)

    *-----------------------------------------
    * Cleaner display labels.
    *-----------------------------------------
    local lab = "`m'"
    if "`m'" == "NTL_2013_mean"          local lab = "Nighttime lights (2013)"
    if "`m'" == "NTL_2020_mean"          local lab = "Nighttime lights (2020)"
    if "`m'" == "NTL_growth"             local lab = "Nighttime lights growth"
    if "`m'" == "NTL_growth_rate"        local lab = "Nighttime lights growth rate"
    if "`m'" == "BU_area"                local lab = "Built-up area"
    if "`m'" == "BU_ratio"               local lab = "Built-up ratio"
    if "`m'" == "BU_density"             local lab = "Built-up density"
    if "`m'" == "BU_growth_2010_2020"    local lab = "Built-up growth (2010-2020)"
    if "`m'" == "BU_grate_2010_2020"     local lab = "Built-up growth rate (2010-2020)"
    if "`m'" == "DEM_landscan"           local lab = "Population proxy (LandScan)"
    if "`m'" == "DEM_ghspop"             local lab = "Population proxy (GHS-POP)"
    if "`m'" == "DEM_worldpop"           local lab = "Population proxy (WorldPop)"
    if "`m'" == "DEM_gpw"                local lab = "Population proxy (GPW)"

    post `posth' ("`m'") ("`lab'") (`b') (`se') (`p') (`ll') (`ul') (`NN')

    drop `touse' `high'
}

postclose `posth'

*******************************************************
**# 2. Clean result data, group moderators, and build y-axis labels
*******************************************************
use `results', clear

*------------------------------------------------------
**## 2.1 Assign moderator categories
*     1 = Nighttime lights
*     2 = Built-up environment
*     3 = Population proxy
*------------------------------------------------------
gen cat = .

replace cat = 1 if inlist(moderator, ///
    "NTL_2013_mean", ///
    "NTL_2020_mean", ///
    "NTL_growth", ///
    "NTL_growth_rate")

replace cat = 2 if inlist(moderator, ///
    "BU_area", ///
    "BU_ratio", ///
    "BU_density", ///
    "BU_growth_2010_2020", ///
    "BU_grate_2010_2020")

replace cat = 3 if inlist(moderator, ///
    "DEM_landscan", ///
    "DEM_ghspop", ///
    "DEM_worldpop", ///
    "DEM_gpw")

label define cat_lab ///
    1 "Nighttime lights" ///
    2 "Built-up environment" ///
    3 "Population proxy", replace

label values cat cat_lab


*------------------------------------------------------
**## 2.2 Set within-category display order
*------------------------------------------------------
gen within = .

replace within = 1 if moderator == "NTL_2013_mean"
replace within = 2 if moderator == "NTL_2020_mean"
replace within = 3 if moderator == "NTL_growth"
replace within = 4 if moderator == "NTL_growth_rate"

replace within = 1 if moderator == "BU_area"
replace within = 2 if moderator == "BU_ratio"
replace within = 3 if moderator == "BU_density"
replace within = 4 if moderator == "BU_growth_2010_2020"
replace within = 5 if moderator == "BU_grate_2010_2020"

replace within = 1 if moderator == "DEM_landscan"
replace within = 2 if moderator == "DEM_ghspop"
replace within = 3 if moderator == "DEM_worldpop"
replace within = 4 if moderator == "DEM_gpw"


*------------------------------------------------------
**## 2.3 Generate publication-friendly variable labels
*------------------------------------------------------
capture drop pretty_label
gen str80 pretty_label = ""

replace pretty_label = "Nighttime lights, 2013" ///
    if moderator == "NTL_2013_mean"

replace pretty_label = "Nighttime lights, 2020" ///
    if moderator == "NTL_2020_mean"

replace pretty_label = "Nighttime lights growth" ///
    if moderator == "NTL_growth"

replace pretty_label = "Nighttime lights growth rate" ///
    if moderator == "NTL_growth_rate"

replace pretty_label = "Built-up area" ///
    if moderator == "BU_area"

replace pretty_label = "Built-up ratio" ///
    if moderator == "BU_ratio"

replace pretty_label = "Built-up density" ///
    if moderator == "BU_density"

replace pretty_label = "Built-up growth, 2010-2020" ///
    if moderator == "BU_growth_2010_2020"

replace pretty_label = "Built-up growth rate, 2010-2020" ///
    if moderator == "BU_grate_2010_2020"

replace pretty_label = "Population proxy, LandScan" ///
    if moderator == "DEM_landscan"

replace pretty_label = "Population proxy, GHS-POP" ///
    if moderator == "DEM_ghspop"

replace pretty_label = "Population proxy, WorldPop" ///
    if moderator == "DEM_worldpop"

replace pretty_label = "Population proxy, GPW" ///
    if moderator == "DEM_gpw"


*------------------------------------------------------
**## 2.4 Sort and generate y-axis position variable order
*------------------------------------------------------
sort cat within
gen order = _n


*------------------------------------------------------
**## 2.5 Generate significance markers
*------------------------------------------------------
gen sig5  = p < 0.05
gen sig10 = p >= 0.05 & p < 0.10
gen nonsig = p >= 0.10


*------------------------------------------------------
**## 2.6 Attach value labels to order
*     This is the key step for fixing missing y-axis value labels.
*------------------------------------------------------
capture label drop order_lab

forvalues i = 1/`=_N' {
    local thislab = pretty_label[`i']
    label define order_lab `i' "`thislab'", add
}

label values order order_lab


*------------------------------------------------------
**## 2.7 Save cleaned results
cap mkdir "$fig_data/SI_panelA_SES"
cap mkdir "$fig/SI_panelA_SES"
cap mkdir "$result/SI_panelA_SES"
*------------------------------------------------------
save "$fig_data/SI_panelA_SES/PanelA_SES_HighLow_difference.dta", replace

export excel using "$result/SI_panelA_SES/PanelA_SES_HighLow_difference.xlsx", ///
    firstrow(variables) replace
	
	
