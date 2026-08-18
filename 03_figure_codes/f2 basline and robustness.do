capture graph set window fontface "Times New Roman"
capture graph set print  fontface "Times New Roman"

* ============================================================
**# Global variables
* ============================================================
do "$dofile/01_data_processing/1 数据前的加载_clean_global.do"
// ********************************************************************************
// * Part 1. Merge results: Panel 1, fixed-effect specifications
// ********************************************************************************
//
// local base "$fig_data/baseline_alternative_specification"
// local fixed "baseline fe1 fe2 fe3"
// local fl "ratio"
// local mo "3 6 9 12"
//
// cap mkdir "`base'/merge"
//
// foreach m of local mo {
//     foreach l of local fl {
//
//         local first = 1
//
//         foreach f of local fixed {
//
//             local file "`base'/`f'/`l'_`m'm.dta"
//
//             if `first' {
//                 use "`file'", clear
//                 gen fixed_effect = "`f'"
//                 local first = 0
//             }
//             else {
//                 append using "`file'"
//                 replace fixed_effect = "`f'" if missing(fixed_effect)
//             }
//         }
//
//     }
// }
//
//
// ********************************************************************************
// * Part 2. Prepare Panel 1 plotting data
// ********************************************************************************
//
// cap mkdir "$fig/baseline_alternative"
//
// clear
// local first = 1
//
// foreach m of local mo {
//
//     local file "`base'/merge/ratio_`m'm.dta"
//
//     if `first' {
//         use "`file'", clear
//         local first = 0
//     }
//     else {
//         append using "`file'"
//     }
// }
//
// cap drop stderr dof t
// cap drop month x level model
//
// * Keep the true model-source variable.
// gen model = fixed_effect
//
// keep if inlist(parm, ///
//     "flood_3m_ratio_T1_3h",  ///
//     "flood_6m_ratio_T1_3h",  ///
//     "flood_9m_ratio_T1_3h",  ///
//     "flood_12m_ratio_T1_3h")
//
// replace estimate = estimate * 100
// replace min95    = min95 * 100
// replace max95    = max95 * 100
//
// gen month = .
// replace month = 3  if parm == "flood_3m_ratio_T1_3h"
// replace month = 6  if parm == "flood_6m_ratio_T1_3h"
// replace month = 9  if parm == "flood_9m_ratio_T1_3h"
// replace month = 12 if parm == "flood_12m_ratio_T1_3h"
//
// keep if inlist(month, 3, 6, 9, 12)
//
// gen x = month
//
// label define xlabel4 ///
//     3  "3"  ///
//     6  "6"  ///
//     9  "9"  ///
//     12 "12", replace
// label values x xlabel4
//


********************************************************************************
* Part 3. Draw Panel 1: 4 separate subgraphs
********************************************************************************

*------------------------------------------------------------
* Panel 1 - Graph 1: Baseline
* The first three graphs share ylabel / yscale settings.
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/baseline"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100


graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Baseline}", size(3.8)) ///
    subtitle("(urban year month)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g1, replace)

graph save "$fig/baseline_alternative/p1_g1.gph", replace


*------------------------------------------------------------
* Panel 1 - Graph 2: Model 1
*------------------------------------------------------------

cd "$fig_data/baseline_alternative_specification/fe1"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 1}", size(3.8)) ///
    subtitle("(grid year month)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g2, replace)

graph save "$fig/baseline_alternative/p1_g2.gph", replace


*------------------------------------------------------------
* Panel 1 - Graph 3: Model 2
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/fe2"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 2}", size(3.8)) ///
    subtitle("(urban year × month)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g3, replace)

graph save "$fig/baseline_alternative/p1_g3.gph", replace


*------------------------------------------------------------
* Panel 1 - Graph 4: Model 3
* Use separate ylabel / yscale settings for the fourth graph.
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/fe3"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100


graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 3}", size(3.8)) ///
    subtitle("(country year month)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-10(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-10 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g4, replace)

graph save "$fig/baseline_alternative/p1_g4.gph", replace



*------------------------------------------------------------
* Panel 2 - Graph 1: Model 4
* The first three graphs share ylabel / yscale settings.
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/selecttime"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 4}", size(3.8)) ///
    subtitle("(2018–2022 sample)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p2_g1, replace)

graph save "$fig/baseline_alternative/p2_g1.gph", replace


*------------------------------------------------------------
* Panel 2 - Graph 2: Model 5
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/DHS_flood"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 5}", size(3.8)) ///
    subtitle("(without local flood exposure)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-10(10)40, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-10 40)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p2_g2, replace)

graph save "$fig/baseline_alternative/p2_g2.gph", replace


*------------------------------------------------------------
* Panel 2 - Graph 3: Model 6
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/extendcontrol"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 6}", size(3.8)) ///
    subtitle("(additional controls)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p2_g3, replace)

graph save "$fig/baseline_alternative/p2_g3.gph", replace


*------------------------------------------------------------
* Panel 2 - Graph 4: Model 7
* Use separate ylabel / yscale settings for the fourth graph.
*------------------------------------------------------------

cd "$fig_data/baseline_alternative_specification/weighted_continuous_wt"
openall 
do "$dofile/04_support_codes/keep parm.do"

gen x=month
replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

graph twoway ///
    (rspike min95 max95 x if month == 3,  lcolor("0 114 178")   lwidth(0.8)) ///
    (scatter estimate x if month == 3,   msymbol(circle) mcolor("0 114 178")   mlcolor("0 114 178")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 6,  lcolor("213 94 0")    lwidth(0.8)) ///
    (scatter estimate x if month == 6,   msymbol(circle) mcolor("213 94 0")    mlcolor("213 94 0")    mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 9,  lcolor("0 158 115")   lwidth(0.8)) ///
    (scatter estimate x if month == 9,   msymbol(circle) mcolor("0 158 115")   mlcolor("0 158 115")   mlwidth(medium) msize(3)) ///
    (rspike min95 max95 x if month == 12, lcolor("204 121 167") lwidth(0.8)) ///
    (scatter estimate x if month == 12,  msymbol(circle) mcolor("204 121 167") mlcolor("204 121 167") mlwidth(medium) msize(3)), ///
    scheme(s1mono) ///
    title("{bf:Model 7}", size(3.8)) ///
    subtitle("(controlling for survey weights)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)30, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 30)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p2_g4, replace)

graph save "$fig/baseline_alternative/p2_g4.gph", replace



********************************************************************************
* Part 7. Combine 8 graphs
********************************************************************************


graph combine ///
    "$fig/baseline_alternative/p1_g1.gph" ///
    "$fig/baseline_alternative/p1_g2.gph" ///
    "$fig/baseline_alternative/p1_g3.gph" ///
    "$fig/baseline_alternative/p1_g4.gph" ///
    "$fig/baseline_alternative/p2_g1.gph" ///
    "$fig/baseline_alternative/p2_g2.gph" ///
    "$fig/baseline_alternative/p2_g3.gph" ///
    "$fig/baseline_alternative/p2_g4.gph", ///
    col(4) row(2) ///
    imargin(1 1 1 1) ///
    xsize(16) ysize(9) ///
    graphregion(margin(0.1) fcolor(white) lcolor(white)) ///
    iscale(0.77) ///
    l1title("{bf:Association with child fever prevalence} (percentage points)", size(3) margin(r=0.1)) ///
    b1title("{bf:Flood exposure window across model specifications (months)}", size(3) margin(t=0.1)) ///
    name(main_8_split, replace)

graph save "$fig/baseline_alternative/ratio_8_split.gph", replace
graph export "$fig/export-svg/main_f2.svg", as(svg) replace
