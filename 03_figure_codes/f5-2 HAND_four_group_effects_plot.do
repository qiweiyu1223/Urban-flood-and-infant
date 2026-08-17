*============================================================
* Plot four-group HAND x mapped-water flood-effect estimates
*
* Keep only four-panel graph
*
* Modified:
*   1. Four subplots have separately adjustable y-axis settings
*   2. Lower-saturation colors
*   3. No estimate labels or significance stars
*   4. Unified terminology:
*      Mapped-water presence x HAND level
*============================================================

clear all
set more off
set scheme s1color

capture graph set window fontface "Times New Roman"
capture graph set print fontface "Times New Roman"

global resultdir ///
    "E:\桌面\儿童发烧-do文件\04_parmest data\mapped_water_HAND_four_group"

global outdir "$resultdir"

capture confirm file ///
    "$resultdir/HAND_four_group_effects_long.dta"

if _rc {
    di as error ///
        "Missing input: $resultdir/HAND_four_group_effects_long.dta"

    di as error ///
        "Please run 5-2 HAND_four_group_effects_only.do first."

    exit 601
}

use "$resultdir/HAND_four_group_effects_long.dta", clear

*============================================================
**# 0. Manual y-axis settings for each subplot
*============================================================

*------------------------------------------------------------
* Panel 1: Mapped water + Low HAND
*------------------------------------------------------------

local y_low_has_water_low     0
local y_high_has_water_low   20
local y_ticks_has_water_low  "0(5)20"

*------------------------------------------------------------
* Panel 2: No mapped water + Low HAND
*------------------------------------------------------------

local y_low_no_water_low    -300
local y_high_no_water_low    100
local y_ticks_no_water_low  "-300(100)100"

*------------------------------------------------------------
* Panel 3: Mapped water + High HAND
*------------------------------------------------------------

local y_low_has_water_notlow    -100
local y_high_has_water_notlow    100
local y_ticks_has_water_notlow  "-100(50)100"

*------------------------------------------------------------
* Panel 4: No mapped water + High HAND
*------------------------------------------------------------

local y_low_no_water_notlow    -400
local y_high_no_water_notlow    400
local y_ticks_no_water_notlow  "-400(200)400"

*============================================================
**# 1. Prepare plotting data
*============================================================

capture drop metric_order
capture drop group_order
capture drop estimate_pct
capture drop min95_pct
capture drop max95_pct

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

label define metric_order_lab ///
    1 "Mean HAND" ///
    2 "Median HAND" ///
    3 "P10 HAND" ///
    4 "Share of HAND < 5 m", replace

label values metric_order metric_order_lab

*------------------------------------------------------------
* Mapped-water x HAND group order
*
* 1. Mapped water + Low HAND
* 2. No mapped water + Low HAND
* 3. Mapped water + High HAND
* 4. No mapped water + High HAND
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

label define group_order_lab ///
    1 "Mapped water + Low HAND" ///
    2 "No mapped water + Low HAND" ///
    3 "Mapped water + High HAND" ///
    4 "No mapped water + High HAND", replace

label values group_order group_order_lab

* Check whether all groups were successfully identified
assert !missing(metric_order)
assert !missing(group_order)

tab group_order, missing

*------------------------------------------------------------
* Convert effects to percentage points
*------------------------------------------------------------

gen double estimate_pct = estimate * 100
gen double min95_pct    = min95 * 100
gen double max95_pct    = max95 * 100

sort metric_order group_order

*============================================================
**# 2. Color settings
*============================================================

* Mapped water + Low HAND
local col_has_water_low      "166 122 122"
local out_has_water_low      "116 82 82"

* No mapped water + Low HAND
local col_no_water_low       "194 161 123"
local out_no_water_low       "132 106 78"

* Mapped water + High HAND
local col_has_water_notlow   "126 154 176"
local out_has_water_notlow   "82 108 130"

* No mapped water + High HAND
local col_no_water_notlow    "134 160 134"
local out_no_water_notlow    "88 112 88"

*============================================================
**# 3. Four panels: one group per subplot
*============================================================

foreach group_id in 1 2 3 4 {

    local group_title   ""
    local group_name    ""
    local group_color   ""
    local group_outline ""

    local panel_y_low   ""
    local panel_y_high  ""
    local panel_y_ticks ""

    *--------------------------------------------------------
    * Panel 1: Mapped water + Low HAND
    *--------------------------------------------------------

    if `group_id' == 1 {

        local group_title ///
            "{bf:Mapped water + Low HAND}"

        local group_name ///
            "has_water_low"

        local group_color ///
            "`col_has_water_low'"

        local group_outline ///
            "`out_has_water_low'"

        local panel_y_low ///
            `y_low_has_water_low'

        local panel_y_high ///
            `y_high_has_water_low'

        local panel_y_ticks ///
            "`y_ticks_has_water_low'"
    }

    *--------------------------------------------------------
    * Panel 2: No mapped water + Low HAND
    *--------------------------------------------------------

    if `group_id' == 2 {

        local group_title ///
            "{bf:No mapped water + Low HAND}"

        local group_name ///
            "no_water_low"

        local group_color ///
            "`col_no_water_low'"

        local group_outline ///
            "`out_no_water_low'"

        local panel_y_low ///
            `y_low_no_water_low'

        local panel_y_high ///
            `y_high_no_water_low'

        local panel_y_ticks ///
            "`y_ticks_no_water_low'"
    }

    *--------------------------------------------------------
    * Panel 3: Mapped water + High HAND
    *--------------------------------------------------------

    if `group_id' == 3 {

        local group_title ///
            "{bf:Mapped water + High HAND}"

        local group_name ///
            "has_water_notlow"

        local group_color ///
            "`col_has_water_notlow'"

        local group_outline ///
            "`out_has_water_notlow'"

        local panel_y_low ///
            `y_low_has_water_notlow'

        local panel_y_high ///
            `y_high_has_water_notlow'

        local panel_y_ticks ///
            "`y_ticks_has_water_notlow'"
    }

    *--------------------------------------------------------
    * Panel 4: No mapped water + High HAND
    *--------------------------------------------------------

    if `group_id' == 4 {

        local group_title ///
            "{bf:No mapped water + High HAND}"

        local group_name ///
            "no_water_notlow"

        local group_color ///
            "`col_no_water_notlow'"

        local group_outline ///
            "`out_no_water_notlow'"

        local panel_y_low ///
            `y_low_no_water_notlow'

        local panel_y_high ///
            `y_high_no_water_notlow'

        local panel_y_ticks ///
            "`y_ticks_no_water_notlow'"
    }

    *--------------------------------------------------------
    * Draw individual panel
    *--------------------------------------------------------

    twoway ///
        ///
        (rcap min95_pct max95_pct metric_order ///
            if group_order == `group_id', ///
            lcolor("`group_color'") ///
            lwidth(thin)) ///
        ///
        (scatter estimate_pct metric_order ///
            if group_order == `group_id', ///
            msymbol(circle) ///
            msize(2.2) ///
            mcolor("`group_color'") ///
            mlcolor("`group_outline'") ///
            mlwidth(vthin)) ///
        ///
        , ///
        yline(0, ///
            lcolor("135 135 135") ///
            lpattern(shortdash) ///
            lwidth(thin)) ///
        yscale( ///
            range(`panel_y_low' `panel_y_high')) ///
        xscale( ///
            range(0.65 4.35)) ///
        xlabel( ///
            1 "Mean" ///
            2 "Median" ///
            3 "P10" ///
            4 "Share < 5 m", ///
            labsize(2.4) ///
            angle(0) ///
            noticks) ///
        ylabel( ///
            `panel_y_ticks', ///
            labsize(2.0) ///
            angle(0) ///
            grid ///
            glcolor("238 238 238") ///
            glwidth(vthin) ///
            format(%4.0f)) ///
        xtitle("") ///
        ytitle("") ///
        title( ///
            "`group_title'", ///
            size(2.35) ///
            color("45 45 45") ///
            margin(b=1)) ///
        legend(off) ///
        graphregion( ///
            color(white) ///
            margin(3 3 3 3)) ///
        plotregion( ///
            color(white) ///
            margin(3 3 3 3)) ///
        bgcolor(white) ///
        name(g_hand_`group_id', replace)

    graph save ///
        "$outdir/fig_HAND_`group_name'.gph", ///
        replace
}

*============================================================
**# 4. Combine four panels
*
* Layout:
*
*                   Low HAND           High HAND
*
* Row 1:     Mapped water        Mapped water
* Row 2:     No mapped water     No mapped water
*============================================================

graph combine ///
    "$outdir/fig_HAND_has_water_low.gph" ///
    "$outdir/fig_HAND_has_water_notlow.gph" ///
    "$outdir/fig_HAND_no_water_low.gph" ///
    "$outdir/fig_HAND_no_water_notlow.gph", ///
    rows(2) ///
    cols(2) ///
    imargin(1 1 1 1) ///
    xsize(16) ///
    ysize(10) ///
    b1title( ///
        "{bf:Urban-centre HAND metric}", ///
        size(2.7) ///
        margin(t=1)) ///
    l1title( ///
        "{bf:Flood effect on child fever incidence (%)}", ///
        size(2.7) ///
        margin(r=1)) ///
    graphregion( ///
        color(white) ///
        margin(2 2 2 2)) ///
    name( ///
        fig_HAND_bygrp, ///
        replace) ///
    iscale(1.1)

graph save ///
    "$outdir/fig_HAND_four_group_effects_by_group.gph", ///
    replace

di as result ///
    "Done. Four-panel figure saved to: $outdir"
