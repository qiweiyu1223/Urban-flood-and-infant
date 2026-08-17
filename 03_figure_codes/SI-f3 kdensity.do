do "$dofile/4. 儿童发烧/预处理/1 数据前的加载_clean_global.do"

* Optional preprocessing when adding new variables
// Optional log-variable construction step is disabled here.

* ============================================================
**# Load Africa data
* ============================================================
use "$data/KR_PR_Africa_4.dta", clear

* ============================================================
* Flood exposure ratio distribution
* Positive observations only, truncated at p99
* ============================================================

cap mkdir "$fig_data/儿童发烧"
cap mkdir "$fig_data/儿童发烧/flood_ratio_distribution_p99"


* ============================================================
**# 1. Zero share plot (panel 1)
* ============================================================
preserve

gen zero_3m  = flood_3m_ratio_csv  == 0 if !missing(flood_3m_ratio_csv)
gen zero_6m  = flood_6m_ratio_csv  == 0 if !missing(flood_6m_ratio_csv)
gen zero_9m  = flood_9m_ratio_csv  == 0 if !missing(flood_9m_ratio_csv)
gen zero_12m = flood_12m_ratio_csv == 0 if !missing(flood_12m_ratio_csv)

collapse ///
    (mean) zero_3m zero_6m zero_9m zero_12m

foreach w in 3 6 9 12 {
    replace zero_`w'm = zero_`w'm * 100
}

gen id = 1
reshape long zero_@m, i(id) j(window)
rename zero_m zero_pct

label define winlab ///
    3  "3m" ///
    6  "6m" ///
    9  "9m" ///
    12 "12m", replace
label values window winlab

* Generate x-axis positions.
gen x = .
replace x = 1 if window == 3
replace x = 2 if window == 6
replace x = 3 if window == 9
replace x = 4 if window == 12

* Numeric labels
gen zero_label = string(zero_pct, "%4.1f") + "%"

twoway ///
    (bar zero_pct x if window == 3, ///
        barwidth(0.65) ///
        fcolor("0 114 178%75") ///
        lcolor("0 114 178") ///
        lwidth(0.3)) ///
    (bar zero_pct x if window == 6, ///
        barwidth(0.65) ///
        fcolor("213 94 0%75") ///
        lcolor("213 94 0") ///
        lwidth(0.3)) ///
    (bar zero_pct x if window == 9, ///
        barwidth(0.65) ///
        fcolor("0 158 115%75") ///
        lcolor("0 158 115") ///
        lwidth(0.3)) ///
    (bar zero_pct x if window == 12, ///
        barwidth(0.65) ///
        fcolor("204 121 167%75") ///
        lcolor("204 121 167") ///
        lwidth(0.3)) ///
    (scatter zero_pct x, ///
        msymbol(none) ///
        mlabel(zero_label) ///
        mlabposition(12) ///
        mlabsize(3.2) ///
        mlabcolor(gs4)) ///
    , ///
    scheme(s1color) ///
    xtitle("Flood exposure window", size(3.5)) ///
    ytitle("Share of zero observations (%)", size(3.8)) ///
    xlabel( ///
        1 "3m" ///
        2 "6m" ///
        3 "9m" ///
        4 "12m", ///
        labsize(3.5) noticks) ///
    ylabel(0(20)100, ///
        labsize(3.2) angle(0) nogrid) ///
    yscale(range(0 105) noextend) ///
    xscale(range(0.5 4.5) noextend) ///
    yline(0, lp(solid) lcolor(gs4) lwidth(0.3)) ///
    legend(off) ///
    graphregion(fcolor(white) lcolor(white)) ///
    plotregion(fcolor(white) lcolor(white) margin(zero)) ///
    xsize(6.2) ysize(4.8) ///
    name(zero_share_flood_ratio, replace)

graph save ///
    "$fig_data/儿童发烧/flood_ratio_distribution_p99/zero_share_flood_ratio.gph", ///
    replace

restore


* ============================================================
**# 2. Positive density plots, truncated at p99
* ============================================================

foreach w in 3 6 9 12 {

    quietly summarize flood_`w'm_ratio_csv if flood_`w'm_ratio_csv > 0, detail
    local p99 = r(p99)

    local col ""
    if `w' == 3  local col "0 114 178"
    if `w' == 6  local col "213 94 0"
    if `w' == 9  local col "0 158 115"
    if `w' == 12 local col "204 121 167"

    twoway ///
        (kdensity flood_`w'm_ratio_csv ///
            if flood_`w'm_ratio_csv > 0 & flood_`w'm_ratio_csv <= `p99', ///
            lcolor("`col'") ///
            lwidth(0.8)) ///
        , ///
        scheme(s1color) ///
        xtitle("`w'm exposure", size(3.3)) ///
        ytitle("Density", size(3.3) margin(r=1)) ///
        xlabel(, labsize(3.2) angle(0)) ///
        ylabel(, labsize(3.2) angle(0) nogrid) ///
        legend(off) ///
        graphregion(fcolor(white) lcolor(white)) ///
        plotregion(fcolor(white) lcolor(white)) ///
        xsize(5.5) ysize(4.2) ///
        name(kdensity_flood_`w'm_pos_p99, replace)

    graph save ///
        "$fig_data/儿童发烧/flood_ratio_distribution_p99/kdensity_flood_`w'm_pos_p99.gph", ///
        replace
}


* ============================================================
**# 3. Combine four density plots into one 2x2 panel (panel 2)
* ============================================================

graph combine ///
    kdensity_flood_3m_pos_p99 ///
    kdensity_flood_6m_pos_p99 ///
    kdensity_flood_9m_pos_p99 ///
    kdensity_flood_12m_pos_p99, ///
    rows(2) ///
    imargin(1 1 1 1) ///
    graphregion(fcolor(white) lcolor(white)) ///
    xsize(9.5) ysize(7.5) ///
    iscale(1.0) ///
    name(kden_p99_panel, replace)

graph save ///
    "$fig_data/儿童发烧/flood_ratio_distribution_p99/kden_p99_panel.gph", ///
    replace


* ============================================================
**# 4. Final combine: zero-share panel + density panel
* ============================================================

graph combine ///
    zero_share_flood_ratio ///
    kden_p99_panel, ///
    col(2) ///
    imargin(1 1 1 1) ///
    graphregion(fcolor(white) lcolor(white)) ///
    xsize(14) ysize(7.5) ///
    iscale(1.1) ///
    name(flood_ratio_distribution_all, replace)

graph save ///
    "$fig_data/儿童发烧/flood_ratio_distribution_p99/flood_ratio_distribution_all.gph", ///
    replace
graph export "$fig/export-svg/SI_f3.svg", as(svg) replace
