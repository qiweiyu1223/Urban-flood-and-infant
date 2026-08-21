*============================================================
* SI figure: distance heterogeneity, 5-group version
*
* Left panel:
*   Coefficient plot for dist_q5 only
*
* Right panels:
*   Wealth, maternal education, household/facility conditions,
*   and Health-facility availability by dist_q5
*============================================================

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
set scheme s1color
capture graph set window fontface "Arial"
capture graph set print fontface "Arial"

*============================================================
**# 0. Distance labels and cutoffs
*============================================================

local q5_cut1 0
local q5_cut2 7.5
local q5_cut3 17.5
local q5_cut4 35

local q5_lab1 "Inside"
local q5_lab2 "0-`q5_cut2' km"
local q5_lab3 "`q5_cut2'-`q5_cut3' km"
local q5_lab4 "`q5_cut3'-`q5_cut4' km"
local q5_lab5 ">`q5_cut4' km"

local distvar dhs_to_urban_boundary_km

*============================================================
**# 1. Path settings
*============================================================

local indir  "$fig_data/urban_boundary_distance"
local outdir "$fig/urban_boundary_distance_SI"

cap mkdir "`outdir'"
cap mkdir "$fig/export-svg"

*============================================================
**# 2. Left panel: distance heterogeneity, 5 groups
*============================================================

local f "`indir'/dist_q5/ratio_6m.dta"

capture confirm file "`f'"
if _rc {
    di as error "File not found: `f'"
    di as error "Please run the dist_q5 regression/parmest code first."
    exit 601
}

use "`f'", clear

capture confirm variable parm
if _rc {
    di as error "Variable parm does not exist in `f'."
    exit 111
}

capture confirm variable estimate
if _rc {
    di as error "Variable estimate does not exist in `f'."
    exit 111
}

capture confirm variable min95
if _rc {
    di as error "Variable min95 does not exist in `f'."
    exit 111
}

capture confirm variable max95
if _rc {
    di as error "Variable max95 does not exist in `f'."
    exit 111
}

capture confirm variable p
if _rc {
    gen p = .
}

keep if inlist(parm, ///
    "dist5_q1", ///
    "dist5_q2", ///
    "dist5_q3", ///
    "dist5_q4", ///
    "dist5_q5")

count
if r(N) == 0 {
    di as error "No dist_q5 coefficients found in `f'."
    exit 111
}

capture drop estimate_pct
capture drop min95_pct
capture drop max95_pct

gen estimate_pct = estimate * 100
gen min95_pct    = min95    * 100
gen max95_pct    = max95    * 100

capture drop group_order
capture drop y
capture drop group_label

gen group_order = .
replace group_order = 1 if parm == "dist5_q1"
replace group_order = 2 if parm == "dist5_q2"
replace group_order = 3 if parm == "dist5_q3"
replace group_order = 4 if parm == "dist5_q4"
replace group_order = 5 if parm == "dist5_q5"

gen y = .
replace y = 5 if group_order == 1
replace y = 4 if group_order == 2
replace y = 3 if group_order == 3
replace y = 2 if group_order == 4
replace y = 1 if group_order == 5

gen str20 group_label = ""
replace group_label = "`q5_lab1'" if group_order == 1
replace group_label = "`q5_lab2'" if group_order == 2
replace group_label = "`q5_lab3'" if group_order == 3
replace group_label = "`q5_lab4'" if group_order == 4
replace group_label = "`q5_lab5'" if group_order == 5

local col_q5_dot "172 63 64"
local col_q5_ci  "172 63 64%55"

twoway ///
    (rcap min95_pct max95_pct y, horizontal ///
        lcolor("`col_q5_ci'") lwidth(medthick)) ///
    (scatter y estimate_pct, ///
        msymbol(O) ///
        msize(medlarge) ///
        mcolor("`col_q5_dot'") ///
        mlcolor(white) ///
        mlwidth(vthin)), ///
    xline(0, lpattern(solid) lcolor(gs8) lwidth(medthin)) ///
    ylabel( ///
        5 "`q5_lab1'" ///
        4 "`q5_lab2'" ///
        3 "`q5_lab3'" ///
        2 "`q5_lab4'" ///
        1 "`q5_lab5'", ///
        angle(0) labsize(2.0)) ///
    xlabel(-5(5)35, angle(0) labsize(2.1) glcolor(gs14)) ///
    yscale(range(0.4 5.6)) ///
    xscale(range(-5 35)) ///
    xtitle("{bf:Association with child fever prevalence}" "(percentage points)", ///
        size(2) margin(t=0.5)) ///
    ytitle("") ///
    legend(off) ///
    graphregion(color(white) margin(1 1 1 1)) ///
    plotregion(color(white) lcolor(none) margin(1 1 1 1)) ///
    title("{bf:Distance to urban boundary}", ///
        size(2.2) color(gs2)) ///
    name(g_main, replace) ///
    fxsize(55)

*============================================================
**# 3. Prepare original DHS data once
*============================================================

use "$data/KR_PR_Africa_4.dta", clear

capture confirm variable `distvar'
if _rc {
    di as error "变量不存在：`distvar'"
    exit 111
}

capture drop dist_q5
gen dist_q5 = .
replace dist_q5 = 1 if `distvar' == 0 & !missing(`distvar')
replace dist_q5 = 2 if `distvar' > 0 & `distvar' <= `q5_cut2' & !missing(`distvar')
replace dist_q5 = 3 if `distvar' > `q5_cut2' & `distvar' <= `q5_cut3' & !missing(`distvar')
replace dist_q5 = 4 if `distvar' > `q5_cut3' & `distvar' <= `q5_cut4' & !missing(`distvar')
replace dist_q5 = 5 if `distvar' > `q5_cut4' & !missing(`distvar')

label define dist5_lab ///
    1 "`q5_lab1'" ///
    2 "`q5_lab2'" ///
    3 "`q5_lab3'" ///
    4 "`q5_lab4'" ///
    5 "`q5_lab5'", replace
label values dist_q5 dist5_lab

tab dist_q5, missing

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

tempfile base_dhs
save `base_dhs', replace

local c1 "0 114 178%75"
local c2 "172 63 64%75"
local c3 "62 150 81%75"
local c4 "218 124 48%75"

*============================================================
**# B1. Wealth distribution by dist_q5
*============================================================

capture graph drop g_wel

use `base_dhs', clear

capture confirm variable v190
if !_rc {

    preserve

        keep if !missing(dist_q5, v190)
        contract dist_q5 v190
        bys dist_q5: egen total = total(_freq)
        gen pct = 100 * _freq / total

        gen x = (dist_q5 - 1) * 6 + v190

        local c_inside = 3
        local c_0_75   = 9
        local c_75_175 = 15
        local c_175_35 = 21
        local c_35plus = 27

        local wel1 "198 219 239%90"
        local wel2 "158 202 225%90"
        local wel3 "107 174 214%90"
        local wel4 "49 130 189%90"
        local wel5 "8 81 156%90"

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
            (function y=0, range(0 29.7) lcolor(black) lpattern(solid) lwidth(thin)), ///
            xlabel(, nolabel noticks) ///
            ylabel(0(10)50, angle(0) labsize(1.7) grid glcolor(gs14)) ///
            yscale(range(0 62)) ///
            xscale(range(0.3 29.7) noline) ///
            text(59 `c_inside' "`q5_lab1'", size(1.7) placement(c)) ///
            text(59 `c_0_75'   "`q5_lab2'", size(1.7) placement(c)) ///
            text(59 `c_75_175' "`q5_lab3'", size(1.7) placement(c)) ///
            text(59 `c_175_35' "`q5_lab4'", size(1.7) placement(c)) ///
            text(59 `c_35plus' "`q5_lab5'", size(1.7) placement(c)) ///
            ytitle("Percent (%)", size(1.95) margin(r=0.5)) ///
            xtitle("") ///
            legend(order(1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest") ///
                rows(1) ///
                position(6) ///
                ring(1) ///
                symxsize(3.2) ///
                symysize(2.4) ///
                size(1.45) ///
                keygap(0.25) ///
                colgap(0.65) ///
                rowgap(0.15) ///
                region(lcolor(none) fcolor(none))) ///
            graphregion(color(white) margin(1 1 1 1)) ///
            plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
            title("{bf:Wealth}", size(1.8) color(gs2)) ///
            name(g_wel, replace) ///
            fysize(82)

    restore
}
else {
    di as error "v190 not found; wealth graph skipped."
}

*============================================================
**# B2. Maternal education distribution by dist_q5
*============================================================

capture graph drop g_edu

use `base_dhs', clear

capture confirm variable v106_clean
if !_rc {

    preserve

        keep if !missing(dist_q5, v106_clean)
        contract dist_q5 v106_clean
        bys dist_q5: egen total = total(_freq)
        gen pct = 100 * _freq / total

        gen edu_order = v106_clean + 1
        gen x = (dist_q5 - 1) * 5 + edu_order

        local c_inside = 2.5
        local c_0_75   = 7.5
        local c_75_175 = 12.5
        local c_175_35 = 17.5
        local c_35plus = 22.5

        local edu0 "244 204 204%90"
        local edu1 "226 148 148%90"
        local edu2 "198 87 87%90"
        local edu3 "145 35 35%90"

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
            (function y=0, range(0 25) lcolor(black) lpattern(solid) lwidth(thin)), ///
            xlabel(, nolabel noticks) ///
            ylabel(0(20)60, angle(0) labsize(1.7) grid glcolor(gs14)) ///
            yscale(range(0 76)) ///
            xscale(range(0.3 25) noline) ///
            text(72 `c_inside' "`q5_lab1'", size(1.7) placement(c)) ///
            text(72 `c_0_75'   "`q5_lab2'", size(1.7) placement(c)) ///
            text(72 `c_75_175' "`q5_lab3'", size(1.7) placement(c)) ///
            text(72 `c_175_35' "`q5_lab4'", size(1.7) placement(c)) ///
            text(72 `c_35plus' "`q5_lab5'", size(1.7) placement(c)) ///
            ytitle("Percent (%)", size(1.95) margin(r=0.5)) ///
            xtitle("") ///
            legend(order(1 "No education" 2 "Primary" 3 "Secondary" 4 "Higher") ///
                rows(1) ///
                position(6) ///
                ring(1) ///
                size(1.45) ///
                symxsize(3.2) ///
                symysize(2.4) ///
                keygap(0.25) ///
                colgap(0.65) ///
                rowgap(0.15) ///
                region(lcolor(none) fcolor(none))) ///
            graphregion(color(white) margin(1 1 1 1)) ///
            plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
            title("{bf:Maternal education}", size(1.8) color(gs2)) ///
            name(g_edu, replace) ///
            fysize(82)

    restore
}
else {
    di as error "v106_clean not found; education graph skipped."
}

*============================================================
**# B3. Household / facility-related conditions by dist_q5
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

        keep if !missing(dist_q5, `v')
        collapse (mean) pct = `v', by(dist_q5)
        replace pct = pct * 100

        gen str40 item = "`v'"
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

    twoway ///
        (connected pct dist_q5 if item == "Electricity", ///
            lcolor("`c1'") mcolor("`c1'") msymbol(O) msize(vsmall) lwidth(medthin)) ///
        (connected pct dist_q5 if item == "Improved water", ///
            lcolor("`c2'") mcolor("`c2'") msymbol(D) msize(vsmall) lwidth(medthin)) ///
        (connected pct dist_q5 if item == "Long water collection", ///
            lcolor("`c3'") mcolor("`c3'") msymbol(T) msize(vsmall) lwidth(medthin)) ///
        (connected pct dist_q5 if item == "Large household", ///
            lcolor("`c4'") mcolor("`c4'") msymbol(S) msize(vsmall) lwidth(medthin)), ///
        xlabel(1 "`q5_lab1'" 2 "`q5_lab2'" 3 "`q5_lab3'" 4 "`q5_lab4'" 5 "`q5_lab5'", ///
            labsize(1.45) angle(25)) ///
        ylabel(, angle(0) labsize(1.65) grid glcolor(gs14)) ///
        xtitle("") ///
        ytitle("Percent (%)", size(1.95) margin(r=0.5)) ///
        legend(order(1 "Electricity" 2 "Improved water" ///
                     4 "Large household" 3 "Long water collection") ///
            rows(2) ///
            size(1.45) ///
            position(6) ///
            ring(1) ///
            symxsize(3.2) ///
            symysize(2.4) ///
            keygap(0.25) ///
            colgap(0.65) ///
            rowgap(0.15) ///
            region(lcolor(none) fcolor(none))) ///
        graphregion(color(white) margin(1 1 1 1)) ///
        plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
        title("{bf:Household conditions}", size(1.8) color(gs2)) ///
        name(g_infra, replace) ///
        fysize(88)
}
else {
    di as error "No infrastructure/facility-related variables found."
}

*============================================================
**# B4. Health-facility availability by dist_q5
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
            local hosp_plot_vars "`hosp_plot_vars' hosp_pst"
        }
    }
}

capture confirm variable hosp30_l0
if !_rc {
    gen hosp_basic = hosp30_l0
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

            keep if !missing(dist_q5, `v')
            collapse (mean) mean = `v', by(dist_q5)

            gen str40 item = "`v'"
            replace item = "Higher-level hospital" if item == "hosp_pst"
            replace item = "Basic facility" if item == "hosp_basic"

            append using `hosp_long'
            save `hosp_long', replace

            local ++n_hosp

        restore
    }

    if `n_hosp' > 0 {

        use `hosp_long', clear

        twoway ///
            (connected mean dist_q5 if item == "Higher-level hospital", ///
                lcolor("`c1'") mcolor("`c1'") msymbol(O) msize(vsmall) lwidth(medthin)) ///
            (connected mean dist_q5 if item == "Basic facility", ///
                lcolor("`c2'") mcolor("`c2'") msymbol(D) msize(vsmall) lwidth(medthin)), ///
            xlabel(1 "`q5_lab1'" 2 "`q5_lab2'" 3 "`q5_lab3'" 4 "`q5_lab4'" 5 "`q5_lab5'", ///
                labsize(1.45) angle(25)) ///
            ylabel(, angle(0) labsize(1.65) grid glcolor(gs14)) ///
            xtitle("") ///
            ytitle("Mean count", size(1.95) margin(r=0.5)) ///
			legend(order( ///
				1 "Hospital facilities" ///
				2 "Basic / non-hospital facilities") ///
                rows(2) ///
                size(1.45) ///
                position(6) ///
                ring(1) ///
                symxsize(3.2) ///
                symysize(2.4) ///
                keygap(0.25) ///
                colgap(0.65) ///
                rowgap(0.15) ///
                region(lcolor(none) fcolor(none))) ///
            graphregion(color(white) margin(1 1 1 1)) ///
            plotregion(color(white) lcolor(none) margin(1 1 2 1)) ///
            title("{bf:Health-facility availability}", size(1.8) color(gs2)) ///
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
    name(g_final_dist5, replace) ///
    iscale(1) ///
    xsize(26) ///
    ysize(13)

graph save "`outdir'/final_distance5_SES_facility_hospital_ratio_6m_withN.gph", replace
graph export "$fig/export-svg/SI_f4_distance5.svg", as(svg) replace
