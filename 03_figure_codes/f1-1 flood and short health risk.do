do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

capture graph set window fontface "Times New Roman"
capture graph set print fontface "Times New Roman"
  

******************** ratio figures ******************

cd "$fig_data/1_fever_exposure"
openall
do "$dofile/04_support_codes/keep parm.do"

* ============================================================
**# 1. Keep three short-term outcomes and 3/6/9/12-month exposure windows
* ============================================================

keep if inlist(parm, ///
    "flood_3m_ratio_csv", ///
    "flood_6m_ratio_csv", ///
    "flood_9m_ratio_csv", ///
    "flood_12m_ratio_csv")


replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

cap drop stderr dof t


* ============================================================
**# 2. Identify exposure windows
* ============================================================

gen exp_m = .
replace exp_m = 3  if parm == "flood_3m_ratio_csv"
replace exp_m = 6  if parm == "flood_6m_ratio_csv"
replace exp_m = 9  if parm == "flood_9m_ratio_csv"
replace exp_m = 12 if parm == "flood_12m_ratio_csv"

label define month_lab ///
    3  "3" ///
    6  "6" ///
    9  "9" ///
    12 "12", replace
label values exp_m month_lab

* ============================================================
**# 3. Fever graph
* ============================================================


sort exp_m

twoway ///
    (rcap min95 max95 exp_m if inlist(exp_m, 3, 6), ///
        lcolor("157 81 79") lwidth(0.75)) ///
    (scatter estimate exp_m if inlist(exp_m, 3, 6), ///
        msymbol(circle) ///
        mcolor("157 81 79") ///
        mlcolor(white) ///
        mlwidth(0.35) ///
        msize(3)) ///
    (rcap min95 max95 exp_m if inlist(exp_m, 9, 12), ///
        lcolor("74 111 161") lwidth(0.75)) ///
    (scatter estimate exp_m if inlist(exp_m, 9, 12), ///
        msymbol(circle) ///
        mcolor("74 111 161") ///
        mlcolor(white) ///
        mlwidth(0.35) ///
        msize(3)) ///
    , ///
    scheme(s1color) ///
    xtitle("", size(3.2)) ///
    ytitle("", size(3.3) margin(r=1)) ///
    xlabel(3 6 9 12, valuelabel labsize(3.0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.0) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs6) lwidth(0.35)) ///
	legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(fcolor(white) lcolor(white) margin(2 2 2 2)) ///
    xsize(5.5) ysize(5.2) ///
    name(ratio_fever, replace)

graph save "$fig/1_fever_exposure/fever.gph", replace

*********************************************************************************
************************************* period *************************************
local base_dir "$fig_data/1_fever_exposure"
local out_dir  "$fig/1_fever_exposure"

cap mkdir "$fig/1_fever_exposure"


cd "$fig_data/1_fever_exposure"
openall
do "$dofile/04_support_codes/keep parm.do"




    * Convert coefficients to percentage points.
    replace estimate = estimate * 100
    replace min95    = min95 * 100
    replace max95    = max95 * 100

    * Identify 1-12 month exposure windows from parm.
    cap drop win
    gen win = .

    forvalues k = 1/12 {
        replace win = `k' if strpos(parm, "_`k'm_") > 0
    }

    keep if !missing(win)
    sort win

	
    * Set graph titles, exposure-window ranges, and colors.
    local ttl ""
    local red_end 6
    local split_x 6.5
    local col1 ""
    local col2 ""


	local ttl "Fever"
	local col1 "157 81 79"
	local col2 "74 111 161"
	local yl "-20 (10) 50"
	local yrl -20
	local yru 50
   

    local red_lab  "1-6m"
    local blue_lab "7-12m"
	local ytitle_opt ""

    twoway ///
        (rcap min95 max95 win if win <= 7, ///
            lcolor("`col1'") lwidth(0.65)) ///
        (connected estimate win if win <= 7, ///
            msymbol(circle) ///
            mcolor("`col1'") ///
            mlcolor(white) ///
            mlwidth(0.35) ///
            msize(2.7) ///
            lcolor("`col1'") ///
            lwidth(0.65) ///
            lpattern(solid)) ///
        (rcap min95 max95 win if win >= 7, ///
            lcolor("`col2'") lwidth(0.65)) ///
        (connected estimate win if win >= 7, ///
            msymbol(circle) ///
            mcolor("`col2'") ///
            mlcolor(white) ///
            mlwidth(0.35) ///
            msize(2.7) ///
            lcolor("`col2'") ///
            lwidth(0.65) ///
            lpattern(solid)) ///
        , ///
        scheme(s1color) ///
        title("", size(3.8) color(gs2)) ///
        xtitle("{bf:Flood exposure window (months)}", size(3.2)) ///
        `ytitle_opt' ///
        xlabel(1(1)12, labsize(2.8) angle(45) nogrid) ///
        ylabel(`yl', format(%9.0f) labsize(2.8) angle(0) nogrid) ///
        xscale(range(0.7 12.3)) ///
        yscale(range(`yrl' `yru')) ///
        yline(0, lpattern(shortdash) lcolor(gs7) lwidth(0.35)) ///
        xline(`split_x', lpattern(shortdash) lcolor(gs12) lwidth(0.3)) ///
        legend( ///
            order(2 "`red_lab'" 4 "`blue_lab'") ///
            rows(1) ///
            size(3.1) ///
            symxsize(6.5) ///
            symysize(3.2) ///
            region(fcolor(white) lcolor(white)) ///
            position(6) ///
        ) ///
        graphregion(fcolor(white) lcolor(white)) ///
        plotregion(fcolor(white) lcolor(white) margin(2 2 2 2)) ///
        xsize(6.2) ///
        ysize(5.2) ///
        name(period_fever, replace)

    graph save "`out_dir'/period_fever.gph", replace

*=============================================================
**# Combine two graphs: ratio panels on top and period panels on bottom
*=============================================================

local out_dir "$fig/1_fever_exposure"

graph combine ///
    "$fig/1_fever_exposure/fever.gph" ///
    "`out_dir'/period_fever.gph", ///
    rows(2) ///
    cols(1) ///
    imargin(3 3 3 3) ///
    xsize(6) ///
    ysize(11) ///
    graphregion(margin(1) fcolor(white) lcolor(white)) ///
    iscale(1.2) ///
    l1title("{bf:Association with child fever prevalence}" "(percentage points)", size(5.2) margin(r=0.1)) ///
    name(short_health_6panel, replace)

graph save "$fig/1_fever_exposure/short_health_6panel.gph", replace

