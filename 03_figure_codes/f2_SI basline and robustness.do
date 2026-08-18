capture graph set window fontface "Times New Roman"
capture graph set print  fontface "Times New Roman"

* ============================================================
**# Global variables
* ============================================================
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

local fa_dir "baseline_alternative_specification"
local outdir "$fig/baseline_alternative_extra"
cap mkdir "`outdir'"
cap mkdir "$fig/export-svg"

* ============================================================
**# Helper: create plotting variables
* ============================================================
capture program drop _prep_coef_plot
program define _prep_coef_plot

    capture confirm variable estimate_pct
    if !_rc {
        cap drop estimate_plot
        cap drop min95_plot
        cap drop max95_plot
        gen double estimate_plot = estimate_pct
        gen double min95_plot    = min95_pct
        gen double max95_plot    = max95_pct
    }
    else {
        cap drop estimate_plot
        cap drop min95_plot
        cap drop max95_plot
        gen double estimate_plot = estimate * 100
        gen double min95_plot    = min95 * 100
        gen double max95_plot    = max95 * 100
    }

    cap drop plot_window_num
    gen byte plot_window_num = .

    capture confirm numeric variable window_num
    if !_rc {
        replace plot_window_num = window_num if inlist(window_num, 3, 6, 9, 12)
    }

    capture confirm string variable exposure_var
    if !_rc {
        replace plot_window_num = 3  if missing(plot_window_num) & strpos(exposure_var, "_3m_")  > 0
        replace plot_window_num = 6  if missing(plot_window_num) & strpos(exposure_var, "_6m_")  > 0
        replace plot_window_num = 9  if missing(plot_window_num) & strpos(exposure_var, "_9m_")  > 0
        replace plot_window_num = 12 if missing(plot_window_num) & strpos(exposure_var, "_12m_") > 0
    }

    capture confirm string variable parm
    if !_rc {
        replace plot_window_num = 3  if missing(plot_window_num) & strpos(parm, "3m")  > 0
        replace plot_window_num = 6  if missing(plot_window_num) & strpos(parm, "6m")  > 0
        replace plot_window_num = 9  if missing(plot_window_num) & strpos(parm, "9m")  > 0
        replace plot_window_num = 12 if missing(plot_window_num) & strpos(parm, "12m") > 0
    }

    capture confirm string variable window
    if !_rc {
        replace plot_window_num = 3  if missing(plot_window_num) & window == "3m"
        replace plot_window_num = 6  if missing(plot_window_num) & window == "6m"
        replace plot_window_num = 9  if missing(plot_window_num) & window == "9m"
        replace plot_window_num = 12 if missing(plot_window_num) & window == "12m"
    }

    capture confirm numeric variable window
    if !_rc {
        replace plot_window_num = window if missing(plot_window_num) & inlist(window, 3, 6, 9, 12)
    }

    cap drop x
    gen x = plot_window_num

    label define xlabel4 3 "3" 6 "6" 9 "9" 12 "12", replace
    label values x xlabel4

end

* ============================================================
**# 1. Occurred
* ============================================================

cd "$fig_data/`fa_dir'/occurred"
openall
do "$dofile/04_support_codes/keep parm.do"

_prep_coef_plot

graph twoway ///
    (rspike min95_plot max95_plot x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate_plot x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95_plot max95_plot x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate_plot x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95_plot max95_plot x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate_plot x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95_plot max95_plot x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate_plot x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Flood occurrence}", size(3.5)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-2(2)8, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-2 8)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(order(2 "wt" 4 "wt_norm" ) ///
        rows(1) position(6) ring(1) size(3) ///
        region(lcolor(white) fcolor(white))) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(g_occurred, replace)

graph save "`outdir'/occurred.gph", replace

* ============================================================
**# 2. Positive tertiles: low vs high positive exposure
* ============================================================

cd "$fig_data/`fa_dir'/positive_tertiles_T1_T2"
openall

_prep_coef_plot

cap drop group_value
gen byte group_value = .
replace group_value = 1 if parm == "flood_low"
replace group_value = 2 if parm == "flood_high"

cap drop x_low
cap drop x_high
gen double x_low  = x - 0.5 if group_value == 1
gen double x_high = x + 0.5 if group_value == 2

graph twoway ///
    (rspike min95_plot max95_plot x_low if group_value == 1, ///
        lcolor("0 114 178") lwidth(0.8)) ///
    (scatter estimate_plot x_low if group_value == 1, ///
        msymbol(circle) mcolor("0 114 178") mlcolor("0 114 178") ///
        mlwidth(medium) msize(3)) ///
    (rspike min95_plot max95_plot x_high if group_value == 2, ///
        lcolor("213 94 0") lwidth(0.8)) ///
    (scatter estimate_plot x_high if group_value == 2, ///
        msymbol(circle) mcolor("213 94 0") mlcolor("213 94 0") ///
        mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Positive exposure intensity}", size(3.5)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-2(2)8, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-2 8)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(order(2 "Low positive" 4 "High positive") ///
        rows(1) position(6) ring(1) size(3) ///
        region(lcolor(white) fcolor(white))) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(g_positive, replace)

graph save "`outdir'/positive_tertiles.gph", replace

* ============================================================
**# 3. Weighted continuous exposure
* ============================================================

tempfile all_weighted
clear
save `all_weighted', emptyok replace

local weight_dirs ///
    weighted_continuous_wt ///
    weighted_continuous_wt_norm ///
    weighted_continuous_wt_equal_survey

foreach d of local weight_dirs {

    cd "$fig_data/`fa_dir'/`d'"
    openall

    _prep_coef_plot

    cap drop weight_dir
    gen str40 weight_dir = "`d'"

    append using `all_weighted'
    save `all_weighted', replace
}

use `all_weighted', clear

cap drop weight_order
cap drop weight_label
gen byte weight_order = .
replace weight_order = 1 if weight_dir == "weighted_continuous_wt"
replace weight_order = 2 if weight_dir == "weighted_continuous_wt_norm"
replace weight_order = 3 if weight_dir == "weighted_continuous_wt_equal_survey"

gen str30 weight_label = ""
replace weight_label = "wt" if weight_order == 1
replace weight_label = "wt_norm" if weight_order == 2
replace weight_label = "wt_equal_survey" if weight_order == 3

cap drop x_wt
gen double x_wt = x
replace x_wt = x - 0.7 if weight_order == 1
replace x_wt = x        if weight_order == 2
replace x_wt = x + 0.7 if weight_order == 3

graph twoway ///
    (rspike min95_plot max95_plot x_wt if weight_order == 1, ///
        lcolor("0 114 178") lwidth(0.8)) ///
    (scatter estimate_plot x_wt if weight_order == 1, ///
        msymbol(circle) mcolor("0 114 178") mlcolor("0 114 178") ///
        mlwidth(medium) msize(3)) ///
    (rspike min95_plot max95_plot x_wt if weight_order == 2, ///
        lcolor("213 94 0") lwidth(0.8)) ///
    (scatter estimate_plot x_wt if weight_order == 2, ///
        msymbol(circle) mcolor("213 94 0") mlcolor("213 94 0") ///
        mlwidth(medium) msize(3)) ///
    (rspike min95_plot max95_plot x_wt if weight_order == 3, ///
        lcolor("0 158 115") lwidth(0.8)) ///
    (scatter estimate_plot x_wt if weight_order == 3, ///
        msymbol(circle) mcolor("0 158 115") mlcolor("0 158 115") ///
        mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Weighted continuous exposure}", size(3.5)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-10(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-10 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(order(2 "wt" 4 "wt_norm" 6 "wt_equal_survey") ///
        rows(1) position(6) ring(1) size(3) ///
        region(lcolor(white) fcolor(white))) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(g_weighted, replace)

graph save "`outdir'/weighted_continuous.gph", replace

* ============================================================
**# 4. Combined graph
* ============================================================

graph combine ///
    "`outdir'/occurred.gph" ///
    "`outdir'/positive_tertiles.gph" ///
    "`outdir'/weighted_continuous.gph", ///
    rows(1) ///
    cols(3) ///
    imargin(1 1 1 1) ///
    xsize(16) ///
    ysize(6) ///
    graphregion(margin(0.1) fcolor(white) lcolor(white)) ///
    iscale(1.1) ///
    l1title("{bf:Association with child fever prevalence}" "(percentage points)", size(4) margin(r=0.1)) ///
    b1title("{bf:Flood exposure window across model specifications (months)}", size(4) margin(t=0.1)) ///
    name(f2_extra_three, replace)

graph save "`outdir'/f2_extra_three.gph", replace
// graph export "$fig/export-svg/f2_extra_three.svg", as(svg) replace
