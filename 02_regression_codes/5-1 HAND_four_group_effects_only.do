*------------------------------------------------------------
**# 0. Load data and output folder
*------------------------------------------------------------

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
use "$data/KR_PR_Africa_4.dta", clear

global outdir "$fig_data/mapped_water_HAND_four_group"
cap mkdir "$fig_data/mapped_water_HAND_four_group"

*------------------------------------------------------------
**# 1. Define outcome and exposure
*------------------------------------------------------------

local y ch_fever
local x flood_6m_ratio_csv

*------------------------------------------------------------
**# 2. Fixed effects
*------------------------------------------------------------

local FE "absorb(urban_id v007 v006) vce(cluster urban_id)"

*------------------------------------------------------------
**# 3. Define controls
*------------------------------------------------------------

local base_control ///
    i.b4 ib1.agegrp ib1.bord_grp ///
    c.v136 i.v190 i.v106 c.v012 ///
    log1_road_total_length_m

*------------------------------------------------------------
**# 3.1 Weather controls matched to flood window
*------------------------------------------------------------

local w ""

if strpos("`x'", "_1m_")  local w 1
if strpos("`x'", "_2m_")  local w 2
if strpos("`x'", "_3m_")  local w 3
if strpos("`x'", "_4m_")  local w 4
if strpos("`x'", "_5m_")  local w 5
if strpos("`x'", "_6m_")  local w 6
if strpos("`x'", "_7m_")  local w 7
if strpos("`x'", "_8m_")  local w 8
if strpos("`x'", "_9m_")  local w 9
if strpos("`x'", "_10m_") local w 10
if strpos("`x'", "_11m_") local w 11
if strpos("`x'", "_12m_") local w 12

if "`w'" == "" {
    local w 6
}

local weather_control ""

foreach v in tmp_mean_`w'm pre_mean_`w'm {
    capture confirm variable `v'

    if !_rc {
        local weather_control "`weather_control' c.`v'"
    }
}

di as text "Base controls: `base_control'"
di as text "Weather controls: `weather_control'"
di as text "Fixed effects: `FE'"

*============================================================
**# 4. Construct has_mapped_water
*============================================================

capture confirm variable WATER_distance_m

if _rc {
    di as error "WATER_distance_m does not exist."
    exit 111
}

capture drop has_mapped_water

gen byte has_mapped_water = .

replace has_mapped_water = 1 ///
    if WATER_distance_m == 0

replace has_mapped_water = 0 ///
    if WATER_distance_m > 0 & WATER_distance_m < .

label define has_mapped_water_lab ///
    0 "No mapped water within area" ///
    1 "Mapped water within area", replace

label values has_mapped_water has_mapped_water_lab

label variable has_mapped_water ///
    "Mapped water within study area"

* Check original and constructed variables
summarize WATER_distance_m if !missing(WATER_distance_m), detail

tab has_mapped_water, missing
tab has_mapped_water if !missing(has_mapped_water)

* Confirm that the classification is internally consistent
assert WATER_distance_m == 0 ///
    if has_mapped_water == 1

assert WATER_distance_m > 0 ///
    if has_mapped_water == 0

*============================================================
**# 5. Four-group models:
*
* 0. No mapped water + not low-lying
* 1. Mapped water + not low-lying
* 2. No mapped water + low-lying
* 3. Mapped water + low-lying
*============================================================

local hand_vars ///
    hand_mean ///
    hand_median ///
    hand_p10 ///
    hand_lt5_ratio

local model_index 1

tempname post_group

postfile `post_group' ///
    str20 hand_metric ///
    str20 group_code ///
    str40 group_label ///
    double estimate se t p min95 max95 N ///
    using "$outdir/HAND_four_group_effects_long.dta", replace

foreach hv of local hand_vars {

    di as result "============================================================"
    di as result "Testing HAND metric: `hv'"
    di as result "============================================================"

    capture confirm variable `hv'

    if _rc {
        di as error ///
            "Variable `hv' does not exist. Skip this HAND metric."
        continue
    }

    capture drop p50_`hv'
    capture drop hand_lowlying
    capture drop water_hand_cat

    quietly summarize `hv' if !missing(`hv'), detail

    gen double p50_`hv' = r(p50) ///
        if !missing(`hv')

    gen byte hand_lowlying = .

    * Lower HAND values indicate lower-lying areas
    if inlist("`hv'", ///
        "hand_mean", ///
        "hand_median", ///
        "hand_p10") {

        replace hand_lowlying = 0 ///
            if !missing(`hv')

        replace hand_lowlying = 1 ///
            if `hv' <= p50_`hv' & !missing(`hv')
    }

    * A higher proportion below 5 m indicates lower-lying areas
    if "`hv'" == "hand_lt5_ratio" {

        replace hand_lowlying = 0 ///
            if !missing(`hv')

        replace hand_lowlying = 1 ///
            if `hv' >= p50_`hv' & !missing(`hv')
    }

    label define hand_lowlying_lab ///
        0 "Not low-lying" ///
        1 "Low-lying", replace

    label values hand_lowlying hand_lowlying_lab

    label variable hand_lowlying ///
        "Low-lying group based on `hv'"

    *--------------------------------------------------------
    * Construct mapped-water × low-lying four-group variable
    *--------------------------------------------------------

    gen byte water_hand_cat = .

    replace water_hand_cat = 0 ///
        if has_mapped_water == 0 & hand_lowlying == 0

    replace water_hand_cat = 1 ///
        if has_mapped_water == 1 & hand_lowlying == 0

    replace water_hand_cat = 2 ///
        if has_mapped_water == 0 & hand_lowlying == 1

    replace water_hand_cat = 3 ///
        if has_mapped_water == 1 & hand_lowlying == 1

    label define water_hand_cat_lab ///
        0 "No mapped water + not low-lying" ///
        1 "Mapped water + not low-lying" ///
        2 "No mapped water + low-lying" ///
        3 "Mapped water + low-lying", replace

    label values water_hand_cat water_hand_cat_lab

    label variable water_hand_cat ///
        "Mapped water x low-lying category for `hv'"

    tab water_hand_cat, missing

    *--------------------------------------------------------
    * Estimate heterogeneous flood effects
    *--------------------------------------------------------

    reghdfe `y' ///
        c.`x'##ib0.water_hand_cat ///
        `base_control' ///
        `weather_control', ///
        `FE'

    estimates store M_four_`model_index'
    local model_index = `model_index' + 1

    *--------------------------------------------------------
    * Group 0: No mapped water + not low-lying
    * Reference group
    *--------------------------------------------------------

    lincom c.`x'

    post `post_group' ///
        ("`hv'") ///
        ("no_water_notlow") ///
        ("No mapped water + not low-lying") ///
        (r(estimate)) ///
        (r(se)) ///
        (r(t)) ///
        (r(p)) ///
        (r(lb)) ///
        (r(ub)) ///
        (e(N))

    *--------------------------------------------------------
    * Group 1: Mapped water + not low-lying
    *--------------------------------------------------------

    lincom c.`x' + 1.water_hand_cat#c.`x'

    post `post_group' ///
        ("`hv'") ///
        ("has_water_notlow") ///
        ("Mapped water + not low-lying") ///
        (r(estimate)) ///
        (r(se)) ///
        (r(t)) ///
        (r(p)) ///
        (r(lb)) ///
        (r(ub)) ///
        (e(N))

    *--------------------------------------------------------
    * Group 2: No mapped water + low-lying
    *--------------------------------------------------------

    lincom c.`x' + 2.water_hand_cat#c.`x'

    post `post_group' ///
        ("`hv'") ///
        ("no_water_low") ///
        ("No mapped water + low-lying") ///
        (r(estimate)) ///
        (r(se)) ///
        (r(t)) ///
        (r(p)) ///
        (r(lb)) ///
        (r(ub)) ///
        (e(N))

    *--------------------------------------------------------
    * Group 3: Mapped water + low-lying
    *--------------------------------------------------------

    lincom c.`x' + 3.water_hand_cat#c.`x'

    post `post_group' ///
        ("`hv'") ///
        ("has_water_low") ///
        ("Mapped water + low-lying") ///
        (r(estimate)) ///
        (r(se)) ///
        (r(t)) ///
        (r(p)) ///
        (r(lb)) ///
        (r(ub)) ///
        (e(N))
}

postclose `post_group'

*============================================================
**# 6. Export long and wide result tables
*============================================================

use "$outdir/HAND_four_group_effects_long.dta", clear

*------------------------------------------------------------
* Statistical significance
*------------------------------------------------------------

gen str3 sig_level = ""

replace sig_level = "***" ///
    if p < 0.01

replace sig_level = "**" ///
    if p >= 0.01 & p < 0.05

replace sig_level = "*" ///
    if p >= 0.05 & p < 0.10

*------------------------------------------------------------
* Formatted estimate and p-value
*------------------------------------------------------------

gen str30 estimate_p = ///
    string(estimate, "%9.3f") + ///
    ", p = " + string(p, "%9.3f")

replace estimate_p = ///
    string(estimate, "%9.3f") + ", p < 0.001" ///
    if p < 0.001

*------------------------------------------------------------
* HAND metric order
*------------------------------------------------------------

gen byte metric_order = .

replace metric_order = 1 ///
    if hand_metric == "hand_mean"

replace metric_order = 2 ///
    if hand_metric == "hand_median"

replace metric_order = 3 ///
    if hand_metric == "hand_p10"

replace metric_order = 4 ///
    if hand_metric == "hand_lt5_ratio"

*------------------------------------------------------------
* Group order
*------------------------------------------------------------

gen byte group_order = .

replace group_order = 1 ///
    if group_code == "has_water_low"

replace group_order = 2 ///
    if group_code == "no_water_low"

replace group_order = 3 ///
    if group_code == "has_water_notlow"

replace group_order = 4 ///
    if group_code == "no_water_notlow"

sort metric_order group_order

order ///
    hand_metric ///
    group_code ///
    group_label ///
    estimate ///
    se ///
    t ///
    p ///
    min95 ///
    max95 ///
    N ///
    sig_level ///
    estimate_p ///
    metric_order ///
    group_order

save "$outdir/HAND_four_group_effects_long.dta", replace

export excel ///
    using "$outdir/HAND_four_group_effects_long.xlsx", ///
    firstrow(variables) replace

*============================================================
**# 6.1 Create wide result table
*============================================================

preserve

keep ///
    hand_metric ///
    group_code ///
    estimate_p ///
    metric_order

reshape wide estimate_p, ///
    i(hand_metric) ///
    j(group_code) string

rename estimate_phas_water_low ///
    mapped_water_lowlying

rename estimate_pno_water_low ///
    no_mapped_water_lowlying

rename estimate_phas_water_notlow ///
    mapped_water_not_lowlying

rename estimate_pno_water_notlow ///
    no_mapped_water_not_lowlying

order ///
    hand_metric ///
    mapped_water_lowlying ///
    no_mapped_water_lowlying ///
    mapped_water_not_lowlying ///
    no_mapped_water_not_lowlying

sort metric_order
drop metric_order

save "$outdir/HAND_four_group_effects_wide.dta", replace

export excel ///
    using "$outdir/HAND_four_group_effects_wide.xlsx", ///
    firstrow(variables) replace

restore

di as result "Done. Outputs saved to: $outdir"