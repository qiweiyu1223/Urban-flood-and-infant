

cap mkdir "$fig/SI_sup"
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
    title("{bf:3h catchment (baseline)}", size(3.8)) ///
    subtitle("(283,965 obs.)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)40, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 40)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g1, replace)

graph save "$fig/SI_sup/baseline.gph", replace


*------------------------------------------------------------
* Panel 2 - Graph 1: 2h catchment
* The first three graphs share ylabel / yscale settings.
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/hours_compare_2h"
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
	title("{bf:2h catchment}", size(3.8)) ///
    subtitle("(266,909 obs.)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)40, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 40)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g1, replace)
	

graph save "$fig/SI_sup/2h.gph", replace



*------------------------------------------------------------
* Panel 2 - Graph 1: 1h catchment
* The first three graphs share ylabel / yscale settings.
*------------------------------------------------------------
cd "$fig_data/baseline_alternative_specification/hours_compare_1h"
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
	title("{bf:1h catchment}", size(3.8)) ///
    subtitle("(216,971 obs.)", size(3.2)) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(3 6 9 12, valuelabel labsize(3.5) angle(0) noticks nogrid) ///
    ylabel(-20(10)40, format(%9.0f) labsize(3.4) angle(0) nogrid) ///
    xscale(range(2 13)) ///
    yscale(range(-20 40)) ///
    yline(0, lp(shortdash) lcolor(gs5) lwidth(0.4)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(margin(small)) ///
    name(p1_g1, replace)
	

graph save "$fig/SI_sup/1h.gph", replace



graph combine ///
    "$fig/SI_sup/baseline.gph" ///
    "$fig/SI_sup/2h.gph" ///
	"$fig/SI_sup/1h.gph", ///
    col(3) row(1) ///
    imargin(1 1 1 1) ///
    xsize(20) ysize(8) ///
    graphregion(margin(0.1) fcolor(white) lcolor(white)) ///
    iscale(1) ///
    l1title("{bf:Association with child fever prevalence}" "(percentage points)", size(3.8) margin(r=0.1)) ///
    b1title("{bf:Flood exposure window across model specifications (months)}", size(3.8) margin(t=0.1)) ///
    name(main_8_split, replace)

graph save "$fig/SI_sup/hours_compare.gph", replace
