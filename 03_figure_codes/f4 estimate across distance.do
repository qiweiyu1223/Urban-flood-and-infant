*============================================================
* Distance heterogeneity + SES / facility / hospital patterns
* 4-group distance version
*
* Main distance groups:
*   1 Inside
*   2 0-10 km
*   3 10-30 km
*   4 >30 km
*
* Output:
*   Final .gph
*============================================================

clear all
set more off
set scheme s1color
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
capture graph set window fontface "Times New Roman"

*============================================================
**# 0. Distance labels and cutoffs
*============================================================

local q4_cut1 0
local q4_cut2 10
local q4_cut3 30

local q4_lab1 "Inside"
local q4_lab2 "0-`q4_cut2' km"
local q4_lab3 "`q4_cut2'-`q4_cut3' km"
local q4_lab4 ">`q4_cut3' km"

*------------------------------------------------------------
* Distance variable
* Use the distance-to-urban-boundary variable here.
*------------------------------------------------------------

local distvar dhs_to_urban_boundary_km


*============================================================
**# 1. Path settings
*============================================================

local indir  "$fig_data/urban_boundary_distance"
local outdir "$fig/urban_boundary_distance"

cap mkdir "`outdir'"

*============================================================
**# 2. Part A. Distance heterogeneity main figure
*    Keep only 2-group / 3-group / 4-group results
*============================================================

local col_q2 "0 114 178"
local col_q3 "213 94 0"
local col_q4 "0 158 115"

local model_dirs ///
    dist_q2 ///
    dist_q3 ///
    dist_q4

tempfile allparm
clear
save `allparm', emptyok replace

local n_read = 0

foreach d of local model_dirs {

    local f "`indir'/`d'/ratio_6m.dta"

    capture confirm file "`f'"
    if _rc {
        di as error "File not found, skipped: `f'"
        continue
    }

    di as text "Appending: `f'"

    use "`f'", clear

    capture confirm variable parm
    if _rc {
        di as error "File `f' has no variable parm. Skipped."
        continue
    }

    capture confirm variable estimate
    if _rc {
        di as error "File `f' has no variable estimate. Skipped."
        continue
    }

    capture drop source_dir
    capture drop source_file
    capture drop source_path

    gen source_dir  = "`d'"
    gen source_file = "ratio_6m.dta"
    gen source_path = "`f'"

    append using `allparm'
    save `allparm', replace

    local ++n_read
}

if `n_read' == 0 {
    di as error "No ratio_6m.dta files were successfully read."
    exit 601
}

use `allparm', clear


*------------------------------------------------------------
* Keep only target coefficients
*------------------------------------------------------------

capture drop keep_parm
gen keep_parm = 0

replace keep_parm = 1 if inlist(parm, ///
    "dist2_near", "dist2_far")

replace keep_parm = 1 if inlist(parm, ///
    "dist3_near", "dist3_mid", "dist3_far")

replace keep_parm = 1 if inlist(parm, ///
    "dist4_q1", "dist4_q2", "dist4_q3", "dist4_q4")

keep if keep_parm == 1
drop keep_parm

count
if r(N) == 0 {
    di as error "No distance heterogeneity coefficients matched."
    list source_dir parm estimate min95 max95, noobs abbreviate(30)
    exit 111
}


*------------------------------------------------------------
* Check required variables
*------------------------------------------------------------

capture confirm variable min95
if _rc {
    di as error "Variable min95 does not exist."
    exit 111
}

capture confirm variable max95
if _rc {
    di as error "Variable max95 does not exist."
    exit 111
}

capture confirm variable p
if _rc {
    gen p = .
}


*------------------------------------------------------------
* Keep intended source only
*------------------------------------------------------------

capture drop expected_source
gen expected_source = ""

replace expected_source = "dist_q2" if inlist(parm, ///
    "dist2_near", "dist2_far")

replace expected_source = "dist_q3" if inlist(parm, ///
    "dist3_near", "dist3_mid", "dist3_far")

replace expected_source = "dist_q4" if inlist(parm, ///
    "dist4_q1", "dist4_q2", "dist4_q3", "dist4_q4")

capture drop source_match
capture drop any_source_match

gen source_match = source_dir == expected_source
bys parm: egen any_source_match = max(source_match)

keep if source_match == 1 | any_source_match == 0
bys parm source_dir: keep if _n == 1

drop source_match any_source_match


*------------------------------------------------------------
* Convert coefficients to percentage points
*------------------------------------------------------------

capture drop estimate_pct
capture drop min95_pct
capture drop max95_pct

gen estimate_pct = estimate * 100
gen min95_pct    = min95    * 100
gen max95_pct    = max95    * 100


*------------------------------------------------------------
* Plotting order
*------------------------------------------------------------

capture drop hetero_var
capture drop group_order
capture drop y

gen hetero_var = source_dir

gen group_order = .

replace group_order = 1 if parm == "dist2_near"
replace group_order = 2 if parm == "dist2_far"

replace group_order = 1 if parm == "dist3_near"
replace group_order = 2 if parm == "dist3_mid"
replace group_order = 3 if parm == "dist3_far"

replace group_order = 1 if parm == "dist4_q1"
replace group_order = 2 if parm == "dist4_q2"
replace group_order = 3 if parm == "dist4_q3"
replace group_order = 4 if parm == "dist4_q4"

gen y = .

replace y = 10 if hetero_var == "dist_q2" & group_order == 1
replace y =  9 if hetero_var == "dist_q2" & group_order == 2

replace y =  7 if hetero_var == "dist_q3" & group_order == 1
replace y =  6 if hetero_var == "dist_q3" & group_order == 2
replace y =  5 if hetero_var == "dist_q3" & group_order == 3

replace y =  3 if hetero_var == "dist_q4" & group_order == 1
replace y =  2 if hetero_var == "dist_q4" & group_order == 2
replace y =  1 if hetero_var == "dist_q4" & group_order == 3
replace y =  0 if hetero_var == "dist_q4" & group_order == 4


*------------------------------------------------------------
* x-axis range
*------------------------------------------------------------

quietly summarize min95_pct, meanonly
local xmin = r(min)

quietly summarize max95_pct, meanonly
local xmax = r(max)

local xleft  = floor((`xmin' - 20) / 50) * 50
local xright = ceil((`xmax' + 20) / 50) * 50


cap drop figure_panel group_label

gen figure_panel = "Main distance heterogeneity"
gen group_label = ""

replace group_label = "<=15 km" if hetero_var == "dist_q2" & group_order == 1
replace group_label = ">15 km"  if hetero_var == "dist_q2" & group_order == 2

replace group_label = "0-5 km"  if hetero_var == "dist_q3" & group_order == 1
replace group_label = "5-25 km" if hetero_var == "dist_q3" & group_order == 2
replace group_label = ">25 km"  if hetero_var == "dist_q3" & group_order == 3

replace group_label = "`q4_lab1'" if hetero_var == "dist_q4" & group_order == 1
replace group_label = "`q4_lab2'" if hetero_var == "dist_q4" & group_order == 2
replace group_label = "`q4_lab3'" if hetero_var == "dist_q4" & group_order == 3
replace group_label = "`q4_lab4'" if hetero_var == "dist_q4" & group_order == 4


*------------------------------------------------------------
* Main distance heterogeneity figure
*------------------------------------------------------------

local col_q2_dot "0 114 178"
local col_q2_ci  "0 114 178%55"

local col_q3_dot "213 94 0"
local col_q3_ci  "213 94 0%55"

local col_q4_dot "0 158 115"
local col_q4_ci  "0 158 115%55"

twoway ///
    (rcap min95_pct max95_pct y if hetero_var=="dist_q2", horizontal ///
        lcolor("`col_q2_ci'") lwidth(medthick)) ///
    (scatter y estimate_pct if hetero_var=="dist_q2", ///
        msymbol(O) ///
        msize(medlarge) ///
        mcolor("`col_q2_dot'") ///
        mlcolor(white) ///
        mlwidth(vthin)) ///
    ///
    (rcap min95_pct max95_pct y if hetero_var=="dist_q3", horizontal ///
        lcolor("`col_q3_ci'") lwidth(medthick)) ///
    (scatter y estimate_pct if hetero_var=="dist_q3", ///
        msymbol(O) ///
        msize(medlarge) ///
        mcolor("`col_q3_dot'") ///
        mlcolor(white) ///
        mlwidth(vthin)) ///
    ///
    (rcap min95_pct max95_pct y if hetero_var=="dist_q4", horizontal ///
        lcolor("`col_q4_ci'") lwidth(medthick)) ///
    (scatter y estimate_pct if hetero_var=="dist_q4", ///
        msymbol(O) ///
        msize(medlarge) ///
        mcolor("`col_q4_dot'") ///
        mlcolor(white) ///
        mlwidth(vthin)), ///
    xline(0, lpattern(solid) lcolor(gs8) lwidth(medthin)) ///
    ylabel( ///
        10 "<=15 km" ///
         9 ">15 km" ///
         7 "0-5 km" ///
         6 "5-25 km" ///
         5 ">25 km" ///
         3 "`q4_lab1'" ///
         2 "`q4_lab2'" ///
         1 "`q4_lab3'" ///
         0 "`q4_lab4'", ///
        angle(0) labsize(2.0)) ///
    xlabel(-5(5)30, angle(0) labsize(2.1) glcolor(gs14)) ///
    yscale(range(-0.8 10.8)) ///
    xscale(range(-5 35)) ///
    xtitle("Effect on child fever incidence (%)", ///
        size(2.3) margin(t=1)) ///
    ytitle("") ///
    legend(order(2 4 6) ///
        label(2 "2 groups") ///
        label(4 "3 groups") ///
        label(6 "4 groups") ///
        rows(1) ///
        position(6) ///
        ring(1) ///
        size(2) ///
        symxsize(3.5) ///
        symysize(2.5) ///
        keygap(0.3) ///
        colgap(1) ///
        region(lcolor(none) fcolor(none))) ///
    graphregion(color(white) margin(1 1 1 1)) ///
    plotregion(color(white) lcolor(none) margin(1 1 1 1)) ///
    name(g_main, replace) ///
    fxsize(48)


*============================================================
**# 3. Part B. Prepare original DHS data once
*============================================================

use "$data/KR_PR_Africa_4.dta", clear

capture confirm variable `distvar'
if _rc {
    di as error "变量不存在：`distvar'"
    exit 111
}


*------------------------------------------------------------
* Generate dist_q4 according to selected distance cutoffs
*------------------------------------------------------------

capture drop dist_q4
gen dist_q4 = .

replace dist_q4 = 1 if `distvar' == 0 & !missing(`distvar')
replace dist_q4 = 2 if `distvar' > 0  & `distvar' <= `q4_cut2' & !missing(`distvar')
replace dist_q4 = 3 if `distvar' > `q4_cut2' & `distvar' <= `q4_cut3' & !missing(`distvar')
replace dist_q4 = 4 if `distvar' > `q4_cut3' & !missing(`distvar')

label define dist4_lab ///
    1 "`q4_lab1'" ///
    2 "`q4_lab2'" ///
    3 "`q4_lab3'" ///
    4 "`q4_lab4'", replace

label values dist_q4 dist4_lab

tab dist_q4, missing


*------------------------------------------------------------
* Clean SES and facility variables
*------------------------------------------------------------

capture drop v106_clean
capture confirm variable v106
if !_rc {
    gen v106_clean = v106
    replace v106_clean = . if !inlist(v106, 0, 1, 2, 3)

    label define edu_lab ///
        0 "No" ///
        1 "Primary" ///
        2 "Secondary" ///
        3 "Higher", replace

    label values v106_clean edu_lab
}

capture confirm variable v190
if !_rc {
    label define wealth_lab ///
        1 "Poorest" ///
        2 "Poorer" ///
        3 "Middle" ///
        4 "Richer" ///
        5 "Richest", replace

    label values v190 wealth_lab
}

capture drop large_hh
capture confirm variable v136
if !_rc {
    sum v136 if !missing(v136), detail
    gen large_hh = (v136 > r(p50)) if !missing(v136)
}

capture drop ph_wtr_improve_clean
capture confirm variable ph_wtr_improve
if !_rc {
    gen ph_wtr_improve_clean = .
    replace ph_wtr_improve_clean = 0 if ph_wtr_improve == 0
    replace ph_wtr_improve_clean = 1 if ph_wtr_improve == 1
}

capture drop long_wtr_time
capture confirm variable ph_wtr_time
if !_rc {
    sum ph_wtr_time if !missing(ph_wtr_time), detail
    gen long_wtr_time = (ph_wtr_time > r(p50)) if !missing(ph_wtr_time)
}


*------------------------------------------------------------
* Save cleaned original data to tempfile
*------------------------------------------------------------

tempfile base_dhs
save `base_dhs', replace


*------------------------------------------------------------
* Colors for descriptive panels
*------------------------------------------------------------

local c1 "0 114 178%75"
local c2 "172 63 64%75"
local c3 "62 150 81%75"
local c4 "218 124 48%75"
local c5 "120 80 150%70"


*============================================================
* B1. Wealth distribution by dist_q4
*============================================================

capture graph drop g_wel

use `base_dhs', clear

capture confirm variable v190
if !_rc {

    preserve

        keep if !missing(dist_q4, v190)

        contract dist_q4 v190
        bys dist_q4: egen total = total(_freq)
        gen pct = 100 * _freq / total

        gen x = .
        replace x = (dist_q4 - 1) * 6 + v190

        local c_inside = 3
        local c_0_10   = 9
        local c_10_30  = 15
        local c_30plus = 21

        local wel1 "198 219 239%90"
        local wel2 "158 202 225%90"
        local wel3 "107 174 214%90"
        local wel4 "49 130 189%90"
        local wel5 "8 81 156%90"

        gen figure_panel = "Wealth distribution by dist_q4"
        gen distance_group = ""
        replace distance_group = "`q4_lab1'" if dist_q4 == 1
        replace distance_group = "`q4_lab2'" if dist_q4 == 2
        replace distance_group = "`q4_lab3'" if dist_q4 == 3
        replace distance_group = "`q4_lab4'" if dist_q4 == 4

        gen wealth_group = ""
        replace wealth_group = "Poorest" if v190 == 1
        replace wealth_group = "Poorer"  if v190 == 2
        replace wealth_group = "Middle"  if v190 == 3
        replace wealth_group = "Richer"  if v190 == 4
        replace wealth_group = "Richest" if v190 == 5

        twoway ///
            (bar pct x if v190 == 1, ///
                barwidth(0.85) ///
                fcolor("`wel1'") ///
                lcolor(white)) ///
            (bar pct x if v190 == 2, ///
                barwidth(0.85) ///
                fcolor("`wel2'") ///
                lcolor(white)) ///
            (bar pct x if v190 == 3, ///
                barwidth(0.85) ///
                fcolor("`wel3'") ///
                lcolor(white)) ///
            (bar pct x if v190 == 4, ///
                barwidth(0.85) ///
                fcolor("`wel4'") ///
                lcolor(white)) ///
            (bar pct x if v190 == 5, ///
                barwidth(0.85) ///
                fcolor("`wel5'") ///
                lcolor(white)) ///
            (function y=0, range(0 23.7) lcolor(black) lpattern(solid) lwidth(thin)), ///
            xlabel(, nolabel noticks) ///
            ylabel(0(10)50, angle(0) labsize(1.7) grid glcolor(gs14)) ///
            yscale(range(0 62)) ///
            xscale(range(0.3 23.7) noline) ///
            text(59 `c_inside' "`q4_lab1'", size(1.8) placement(c)) ///
            text(59 `c_0_10'   "`q4_lab2'", size(1.8) placement(c)) ///
            text(59 `c_10_30'  "`q4_lab3'", size(1.8) placement(c)) ///
            text(59 `c_30plus' "`q4_lab4'", size(1.8) placement(c)) ///
            ytitle("Percent (%)", size(1.95) margin(r=1)) ///
            xtitle("") ///
            legend(order(1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest") ///
                rows(1) ///
                position(6) ///
                ring(1) ///
                symxsize(3.2) ///
                symysize(2.4) ///
                size(1.5) ///
                keygap(0.25) ///
                colgap(0.8) ///
                rowgap(0.15) ///
                region(lcolor(none) fcolor(none))) ///
            graphregion(color(white) margin(1 1 1 1)) ///
            plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
            name(g_wel, replace) ///
            fysize(82)

    restore
}
else {
    di as error "v190 not found; wealth graph skipped."
}


*============================================================
* B2. Maternal education distribution by dist_q4
*============================================================

capture graph drop g_edu

use `base_dhs', clear

capture confirm variable v106_clean
if !_rc {

    preserve

        keep if !missing(dist_q4, v106_clean)

        contract dist_q4 v106_clean
        bys dist_q4: egen total = total(_freq)
        gen pct = 100 * _freq / total

        gen edu_order = v106_clean + 1

        gen x = .
        replace x = (dist_q4 - 1) * 5 + edu_order

        local c_inside = 2.5
        local c_0_10   = 7.5
        local c_10_30  = 12.5
        local c_30plus = 17.5

        local edu0 "244 204 204%90"
        local edu1 "226 148 148%90"
        local edu2 "198 87 87%90"
        local edu3 "145 35 35%90"

        gen figure_panel = "Maternal education distribution by dist_q4"
        gen distance_group = ""
        replace distance_group = "`q4_lab1'" if dist_q4 == 1
        replace distance_group = "`q4_lab2'" if dist_q4 == 2
        replace distance_group = "`q4_lab3'" if dist_q4 == 3
        replace distance_group = "`q4_lab4'" if dist_q4 == 4

        gen education_group = ""
        replace education_group = "No education" if v106_clean == 0
        replace education_group = "Primary"      if v106_clean == 1
        replace education_group = "Secondary"    if v106_clean == 2
        replace education_group = "Higher"       if v106_clean == 3

        twoway ///
            (bar pct x if v106_clean == 0, ///
                barwidth(0.85) ///
                fcolor("`edu0'") ///
                lcolor(white)) ///
            (bar pct x if v106_clean == 1, ///
                barwidth(0.85) ///
                fcolor("`edu1'") ///
                lcolor(white)) ///
            (bar pct x if v106_clean == 2, ///
                barwidth(0.85) ///
                fcolor("`edu2'") ///
                lcolor(white)) ///
            (bar pct x if v106_clean == 3, ///
                barwidth(0.85) ///
                fcolor("`edu3'") ///
                lcolor(white)) ///
            (function y=0, range(0 20) lcolor(black) lpattern(solid) lwidth(thin)), ///
            xlabel(, nolabel noticks) ///
            ylabel(0(20)60, angle(0) labsize(1.7) grid glcolor(gs14)) ///
            yscale(range(0 76)) ///
            xscale(range(0.3 20) noline) ///
            text(72 `c_inside' "`q4_lab1'", size(1.8) placement(c)) ///
            text(72 `c_0_10'   "`q4_lab2'", size(1.8) placement(c)) ///
            text(72 `c_10_30'  "`q4_lab3'", size(1.8) placement(c)) ///
            text(72 `c_30plus' "`q4_lab4'", size(1.8) placement(c)) ///
            ytitle("Percent (%)", size(1.95) margin(r=1)) ///
            xtitle("") ///
            legend(order(1 "No education" 2 "Primary" 3 "Secondary" 4 "Higher") ///
                rows(1) ///
                position(6) ///
                ring(1) ///
                size(1.5) ///
                symxsize(3.2) ///
                symysize(2.4) ///
                keygap(0.25) ///
                colgap(0.8) ///
                rowgap(0.15) ///
                region(lcolor(none) fcolor(none))) ///
            graphregion(color(white) margin(1 1 1 1)) ///
            plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
            name(g_edu, replace) ///
            fysize(82)

    restore
}
else {
    di as error "v106_clean not found; education graph skipped."
}


*============================================================
* B3. Household / facility-related conditions by dist_q4
*============================================================

local infra_vars ///
    ph_electric ///
    ph_wtr_improve_clean ///
    long_wtr_time ///
    large_hh

tempfile infra_long
clear
save `infra_long', emptyok replace

local n_infra = 0

use `base_dhs', clear

foreach v of local infra_vars {

    capture confirm variable `v'
    if _rc {
        di as error "变量不存在，跳过: `v'"
        continue
    }

    preserve

        keep if !missing(dist_q4, `v')
        collapse (mean) pct = `v', by(dist_q4)
        replace pct = pct * 100

        gen item = "`v'"
        replace item = "Electricity" if item == "ph_electric"
        replace item = "Improved water" if item == "ph_wtr_improve_clean"
        replace item = "Long water collection" if item == "long_wtr_time"
        replace item = "Large household" if item == "large_hh"

        append using `infra_long'
        save `infra_long', replace

        local ++n_infra

    restore
}

if `n_infra' > 0 {

    use `infra_long', clear

    gen figure_panel = "Household and facility-related conditions by dist_q4"
    gen distance_group = ""
    replace distance_group = "`q4_lab1'" if dist_q4 == 1
    replace distance_group = "`q4_lab2'" if dist_q4 == 2
    replace distance_group = "`q4_lab3'" if dist_q4 == 3
    replace distance_group = "`q4_lab4'" if dist_q4 == 4

    twoway ///
        (connected pct dist_q4 if item == "Electricity", ///
            lcolor("`c1'") mcolor("`c1'") msymbol(O) msize(vsmall) lwidth(medthin)) ///
        (connected pct dist_q4 if item == "Improved water", ///
            lcolor("`c2'") mcolor("`c2'") msymbol(D) msize(vsmall) lwidth(medthin)) ///
        (connected pct dist_q4 if item == "Long water collection", ///
            lcolor("`c3'") mcolor("`c3'") msymbol(T) msize(vsmall) lwidth(medthin)) ///
        (connected pct dist_q4 if item == "Large household", ///
            lcolor("`c4'") mcolor("`c4'") msymbol(S) msize(vsmall) lwidth(medthin)), ///
        xlabel(1 "`q4_lab1'" 2 "`q4_lab2'" 3 "`q4_lab3'" 4 "`q4_lab4'", ///
            labsize(1.65)) ///
        ylabel(, angle(0) labsize(1.65) grid glcolor(gs14)) ///
        xtitle("") ///
        ytitle("Percent (%)", size(1.95) margin(r=1)) ///
        legend(order(1 "Electricity" 2 "Improved water" ///
                     4 "Large household" 3 "Long water collection") ///
            rows(2) ///
            size(1.5) ///
            position(6) ///
            ring(1) ///
            symxsize(3.2) ///
            symysize(2.4) ///
            keygap(0.25) ///
            colgap(0.8) ///
            rowgap(0.15) ///
            region(lcolor(none) fcolor(none))) ///
        graphregion(color(white) margin(1 1 1 1)) ///
        plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
        name(g_infra, replace) ///
        fysize(88)
}
else {
    di as error "No infrastructure/facility-related variables found."
}


*============================================================
* B4. Hospital data by dist_q4
*============================================================

use `base_dhs', clear

capture drop hosp_basic
capture drop hosp_pst
capture drop hosp_pst_miss

local hosp_plot_vars ""

capture confirm variable hosp30_l1
if !_rc {
    capture confirm variable hosp30_l2
    if !_rc {
        capture confirm variable hosp30_l3
        if !_rc {

            egen hosp_pst = rowtotal(hosp30_l1 hosp30_l2 hosp30_l3)
            egen hosp_pst_miss = rowmiss(hosp30_l1 hosp30_l2 hosp30_l3)
            replace hosp_pst = . if hosp_pst_miss == 3

            label variable hosp_pst "Higher-level hospital"
            local hosp_plot_vars "`hosp_plot_vars' hosp_pst"
        }
    }
}

capture confirm variable hosp30_l0
if !_rc {
    gen hosp_basic = hosp30_l0
    label variable hosp_basic "Basic facility"
    local hosp_plot_vars "`hosp_plot_vars' hosp_basic"
}

if "`hosp_plot_vars'" == "" {

    capture confirm variable hospital_30km_primary
    if !_rc {
        capture confirm variable hospital_30km_secondary
        if !_rc {
            capture confirm variable hospital_30km_tertiary
            if !_rc {

                egen hosp_pst = rowtotal( ///
                    hospital_30km_primary ///
                    hospital_30km_secondary ///
                    hospital_30km_tertiary)

                egen hosp_pst_miss = rowmiss( ///
                    hospital_30km_primary ///
                    hospital_30km_secondary ///
                    hospital_30km_tertiary)

                replace hosp_pst = . if hosp_pst_miss == 3

                label variable hosp_pst "Higher-level hospital"
                local hosp_plot_vars "`hosp_plot_vars' hosp_pst"
            }
        }
    }
}

if "`hosp_plot_vars'" == "" {
    di as error "No hospital variables found. Hospital graph skipped."
}
else {

    tempfile hosp_long
    clear
    save `hosp_long', emptyok replace

    local n_hosp = 0

    use `base_dhs', clear

    capture drop hosp_basic
    capture drop hosp_pst
    capture drop hosp_pst_miss

    capture confirm variable hosp30_l1
    if !_rc {
        capture confirm variable hosp30_l2
        if !_rc {
            capture confirm variable hosp30_l3
            if !_rc {
                egen hosp_pst = rowtotal(hosp30_l1 hosp30_l2 hosp30_l3)
                egen hosp_pst_miss = rowmiss(hosp30_l1 hosp30_l2 hosp30_l3)
                replace hosp_pst = . if hosp_pst_miss == 3
            }
        }
    }

    capture confirm variable hosp30_l0
    if !_rc {
        gen hosp_basic = hosp30_l0
    }

    capture confirm variable hosp_pst
    if _rc {
        capture confirm variable hospital_30km_primary
        if !_rc {
            capture confirm variable hospital_30km_secondary
            if !_rc {
                capture confirm variable hospital_30km_tertiary
                if !_rc {
                    egen hosp_pst = rowtotal( ///
                        hospital_30km_primary ///
                        hospital_30km_secondary ///
                        hospital_30km_tertiary)

                    egen hosp_pst_miss = rowmiss( ///
                        hospital_30km_primary ///
                        hospital_30km_secondary ///
                        hospital_30km_tertiary)

                    replace hosp_pst = . if hosp_pst_miss == 3
                }
            }
        }
    }

    local hosp_plot_vars ""
    capture confirm variable hosp_pst
    if !_rc {
        local hosp_plot_vars "`hosp_plot_vars' hosp_pst"
    }

    capture confirm variable hosp_basic
    if !_rc {
        local hosp_plot_vars "`hosp_plot_vars' hosp_basic"
    }

    foreach v of local hosp_plot_vars {

        preserve

            keep if !missing(dist_q4, `v')
            collapse (mean) mean = `v', by(dist_q4)

            gen item = "`v'"
            replace item = "Higher-level hospital" if item == "hosp_pst"
            replace item = "Basic facility" if item == "hosp_basic"

            append using `hosp_long'
            save `hosp_long', replace

            local ++n_hosp

        restore
    }

    if `n_hosp' > 0 {

        use `hosp_long', clear

        gen figure_panel = "Hospital counts by dist_q4"
        gen distance_group = ""
        replace distance_group = "`q4_lab1'" if dist_q4 == 1
        replace distance_group = "`q4_lab2'" if dist_q4 == 2
        replace distance_group = "`q4_lab3'" if dist_q4 == 3
        replace distance_group = "`q4_lab4'" if dist_q4 == 4

        twoway ///
            (connected mean dist_q4 if item == "Higher-level hospital", ///
                lcolor("`c1'") mcolor("`c1'") msymbol(O) msize(vsmall) lwidth(medthin)) ///
            (connected mean dist_q4 if item == "Basic facility", ///
                lcolor("`c2'") mcolor("`c2'") msymbol(D) msize(vsmall) lwidth(medthin)), ///
            xlabel(1 "`q4_lab1'" 2 "`q4_lab2'" 3 "`q4_lab3'" 4 "`q4_lab4'", ///
                labsize(1.65)) ///
            ylabel(, angle(0) labsize(1.65) grid glcolor(gs14)) ///
            xtitle("") ///
            ytitle("Mean count", size(1.95) margin(r=1)) ///
			legend(order( ///
				1 "Hospital facilities" ///
				2 "Basic / non-hospital facilities") ///
                rows(2) ///
                size(1.5) ///
                position(6) ///
                ring(1) ///
                symxsize(3.2) ///
                symysize(2.4) ///
                keygap(0.25) ///
                colgap(0.8) ///
                rowgap(0.15) ///
                region(lcolor(none) fcolor(none))) ///
            graphregion(color(white) margin(1 1 1 1)) ///
            plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
            name(g_hosp, replace) ///
            fysize(88)
    }
}


*============================================================
**# 4. Combine descriptive panels: 2 x 2 layout
*============================================================

capture graph describe g_wel
local has_wel = (_rc == 0)

capture graph describe g_edu
local has_edu = (_rc == 0)

capture graph describe g_infra
local has_infra = (_rc == 0)

capture graph describe g_hosp
local has_hosp = (_rc == 0)


if `has_wel' & `has_edu' & `has_infra' & `has_hosp' {

    graph combine g_wel g_edu g_infra g_hosp, ///
        rows(2) ///
        cols(2) ///
        imargin(0 0 0 0) ///
        graphregion(margin(0 0 0 0) color(white)) ///
        name(g_right, replace) ///
        iscale(1.2) ///
        xsize(16) ///
        ysize(11) ///
        fxsize(150)
}
else {

    local g_list ""

    if `has_wel' {
        local g_list "`g_list' g_wel"
    }

    if `has_edu' {
        local g_list "`g_list' g_edu"
    }

    if `has_infra' {
        local g_list "`g_list' g_infra"
    }

    if `has_hosp' {
        local g_list "`g_list' g_hosp"
    }

    if "`g_list'" == "" {
        di as error "No descriptive graphs were created."
        exit 111
    }

    graph combine `g_list', ///
        rows(2) ///
        imargin(0 0 0 0) ///
        graphregion(margin(0 0 0 0) color(white)) ///
        name(g_right, replace) ///
        iscale(1.2) ///
        xsize(16) ///
        ysize(11) ///
        fxsize(150)
}


*============================================================
**# 5. Final combined graph
*============================================================

graph combine g_main g_right, ///
    cols(2) ///
    imargin(0 0 0 0) ///
    graphregion(margin(0 0 0 0) color(white)) ///
    name(g_final, replace) ///
    iscale(1.1) ///
    xsize(26) ///
    ysize(13)

graph save "`outdir'/final_distance4_SES_facility_hospital_ratio_6m_withN.gph", replace
