capture graph set window fontface "Times New Roman"
capture graph set print fontface "Times New Roman"

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

* ============================================================
**# Load Africa data
* ============================================================
use "$data/KR_PR_Africa_4.dta", clear


********************************************************************************
* Panel A. Percentage of flooded facilities by facility type
********************************************************************************

cap mkdir "$fig/facilities_and_flood"

cd "$fig_data/facilities_and_flood"
openall


* ============================================================
**# 1. Filter the six flood-percentage parameters
* ============================================================

local fpct ///
    hospital_total_flood_pct_6m ///
    primary_flood_pct_6m ///
    secondary_flood_pct_6m ///
    water_flood_pct_6m ///
    school_flood_pct_6m ///
    road_flood_pct_6m

cap drop keep_parm
gen byte keep_parm = 0

foreach v of local fpct {
    replace keep_parm = 1 if parm == "`v'"
}

keep if keep_parm == 1


* ============================================================
**# 2. Convert estimates and confidence intervals to percent
* ============================================================

replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100


* ============================================================
**# 3. Set x-axis order
* ============================================================

gen x = .

replace x = 1 if parm == "hospital_total_flood_pct_6m"
replace x = 2 if parm == "primary_flood_pct_6m"
replace x = 3 if parm == "secondary_flood_pct_6m"
replace x = 4 if parm == "water_flood_pct_6m"
replace x = 5 if parm == "school_flood_pct_6m"
replace x = 6 if parm == "road_flood_pct_6m"

label define xlabel_flood ///
    1 "{bf:All hospitals}" ///
    2 "{bf:Primary hospitals}" ///
    3 "{bf:Secondary hospitals}" ///
    4 "{bf:Water facilities}" ///
    5 "{bf:Schools}" ///
    6 "{bf:Roads}", replace

label values x xlabel_flood

sort x


* ============================================================
**# Panel A
* ============================================================

local hospital_color "86 125 145"
local other_color    "150 130 105"


twoway ///
    (rcap min95 max95 x if inrange(x,1,3), ///
        lcolor("`hospital_color'%80") ///
        lwidth(0.65)) ///
    (scatter estimate x if inrange(x,1,3), ///
        msymbol(circle) ///
        mcolor("`hospital_color'%85") ///
        mlcolor(white) ///
        mlwidth(0.20) ///
        msize(2.5)) ///
    (rcap min95 max95 x if inrange(x,4,6), ///
        lcolor("`other_color'%80") ///
        lwidth(0.65)) ///
    (scatter estimate x if inrange(x,4,6), ///
        msymbol(circle) ///
        mcolor("`other_color'%85") ///
        mlcolor(white) ///
        mlwidth(0.20) ///
        msize(2.5)) ///
    , ///
    scheme(s1color) ///
    xtitle("") ///
    ytitle(    "{bf:Association with child fever prevalence}" ///
    "(percentage points)" , ///
        size(2.3) margin(r=0.5)) ///
    xlabel( ///
		1 "All health facilities" ///
		2 `""Basic / non-hospital" "facilities""' ///
		3 "Hospital facilities" ///
		4 "Water facilities" ///
		5 "Schools" ///
		6 "Roads", ///
        labsize(2.1) ///
        angle(0) ///
        noticks) ///
    ylabel(-40(20)40, ///
        format(%9.0f) ///
        labsize(2.1) ///
        angle(0) ///
        nogrid) ///
    yscale(range(-45 45)) ///
    yline(0, ///
        lpattern(shortdash) ///
        lcolor(gs9) ///
        lwidth(0.35)) ///
    xscale( range(0.65 6.35) noline) ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 2 1 2)) ///
    plotregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 2 2 2)) ///
    legend(off) ///
    xsize(12) ///
    ysize(5.2) ///
    name(flood_pct_facility, replace)

graph save ///
    "$fig/facilities_and_flood/flood_pct_facility.gph", ///
    replace



********************************************************************************
**# Panel C
********************************************************************************

*------------------------------------------------------------
**# 1. Load data
*------------------------------------------------------------

use "$data/KR_PR_Africa_4.dta", clear


*------------------------------------------------------------
**# 2. Check variables
*------------------------------------------------------------

local vars ///
    uc_hosp_l0 uc_hosp_l1 uc_hosp_l2 uc_hosp_l3 ///
    patch_hosp_l0 patch_hosp_l1 patch_hosp_l2 patch_hosp_l3 ///
    patch3h_area_km2 uc_area_km2 patch3h_non_uc_area_km2 ///
    uc_mergedcatchment_area_ratio ///
    uc_patchout_area_ratio_raw uc_patchout_area_ratio uc_patchout_area_pct

foreach v of local vars {
    cap confirm variable `v'
    if _rc {
        di as error "变量不存在：`v'"
        exit 111
    }
}


*------------------------------------------------------------
**# 3. Deduplicate by urban_id
*------------------------------------------------------------

cap confirm variable urban_id

if !_rc {
    keep urban_id `vars'
    drop if missing(urban_id)
    duplicates drop urban_id, force
}
else {
    di as error "缺少 urban_id。Panel C 需要按城市中心去重。"
    exit 111
}

tempfile base
save `base', replace


* ============================================================
**# Figure C: facility-level shares
* Urban centre vs Patch outside urban centre
* ============================================================

use `base', clear


*------------------------------------------------------------
**# 4. Aggregate to the overall level
*------------------------------------------------------------

collapse (sum) ///
    uc_hosp_l0 uc_hosp_l1 uc_hosp_l2 uc_hosp_l3 ///
    patch_hosp_l0 patch_hosp_l1 patch_hosp_l2 patch_hosp_l3


*------------------------------------------------------------
**# 5. Calculate UC and patch-outside-UC shares
*------------------------------------------------------------

gen share_uc_l0 = uc_hosp_l0 / patch_hosp_l0 * 100 ///
    if patch_hosp_l0 > 0

gen share_nonuc_l0 = (patch_hosp_l0 - uc_hosp_l0) / patch_hosp_l0 * 100 ///
    if patch_hosp_l0 > 0


gen share_uc_l1 = uc_hosp_l1 / patch_hosp_l1 * 100 ///
    if patch_hosp_l1 > 0

gen share_nonuc_l1 = (patch_hosp_l1 - uc_hosp_l1) / patch_hosp_l1 * 100 ///
    if patch_hosp_l1 > 0


gen share_uc_l2 = uc_hosp_l2 / patch_hosp_l2 * 100 ///
    if patch_hosp_l2 > 0

gen share_nonuc_l2 = (patch_hosp_l2 - uc_hosp_l2) / patch_hosp_l2 * 100 ///
    if patch_hosp_l2 > 0


gen share_uc_l3 = uc_hosp_l3 / patch_hosp_l3 * 100 ///
    if patch_hosp_l3 > 0

gen share_nonuc_l3 = (patch_hosp_l3 - uc_hosp_l3) / patch_hosp_l3 * 100 ///
    if patch_hosp_l3 > 0


*------------------------------------------------------------
**# 6. Clean shares
*------------------------------------------------------------

foreach v in share_nonuc_l0 share_nonuc_l1 share_nonuc_l2 share_nonuc_l3 {
    replace `v' = 0 if `v' < 0 & !missing(`v')
}

foreach v in share_uc_l0 share_uc_l1 share_uc_l2 share_uc_l3 {
    replace `v' = 100 if `v' > 100 & !missing(`v')
}


*------------------------------------------------------------
**# 7. Reshape to long format
*------------------------------------------------------------

gen id = 1

reshape long share_uc_ share_nonuc_, i(id) j(level) string

rename share_uc_    share_uc
rename share_nonuc_ share_nonuc

gen level_order = .

replace level_order = 1 if level == "l0"
replace level_order = 2 if level == "l1"
replace level_order = 3 if level == "l2"
replace level_order = 4 if level == "l3"

gen y = level_order


*------------------------------------------------------------
**# 8. Build stacked-bar endpoints
*------------------------------------------------------------

gen uc_start    = 0
gen uc_end      = share_uc
gen nonuc_start = share_uc
gen nonuc_end   = share_uc + share_nonuc

replace nonuc_end = 100 if nonuc_end > 100 & !missing(nonuc_end)


*------------------------------------------------------------
**# 9. Generate percentage labels
*------------------------------------------------------------

gen uc_mid    = (uc_start + uc_end) / 2
gen nonuc_mid = (nonuc_start + nonuc_end) / 2

gen uc_pct_lab    = string(share_uc, "%4.1f") + "%"
gen nonuc_pct_lab = string(share_nonuc, "%4.1f") + "%"

replace uc_pct_lab = "" if share_uc < 5
replace nonuc_pct_lab = "" if share_nonuc < 5


*------------------------------------------------------------
**# 10. Horizontal 100% stacked bar chart
*------------------------------------------------------------

* ============================================================
**# Panel B: hospital composition
* ============================================================

twoway ///
    (rbar uc_start uc_end y, horizontal ///
        barwidth(0.58) ///
        fcolor("120 155 187%90") ///
        lcolor(white) ///
        lwidth(0.3)) ///
    (rbar nonuc_start nonuc_end y, horizontal ///
        barwidth(0.58) ///
        fcolor("204 145 112%90") ///
        lcolor(white) ///
        lwidth(0.3)) ///
    (scatter y uc_mid, ///
        msymbol(none) ///
        mlabel(uc_pct_lab) ///
        mlabposition(0) ///
        mlabsize(2.0) ///
        mlabcolor(black)) ///
    (scatter y nonuc_mid, ///
        msymbol(none) ///
        mlabel(nonuc_pct_lab) ///
        mlabposition(0) ///
        mlabsize(2.0) ///
        mlabcolor(black)) ///
    , ///
    ylabel( ///
        1 `"Basic / non-hospital"' ///
        2 `"Primary / district / general"' ///
        3 `"Secondary / referral"' ///
        4 `"National / teaching / tertiary"', ///
        angle(0) ///
        labsize(2.05) ///
        noticks) ///
    yscale(reverse range(0.45 4.55)) ///
    xlabel(0(20)100, ///
        labsize(2.2) ///
        angle(0) ///
        nogrid) ///
    xscale(range(0 100)) ///
    xtitle("{bf:Share of hospitals in the 3-hour catchment (%)}", ///
        size(2.35) ///
        margin(t=2)) ///
    ytitle("") ///
    legend( ///
        order(1 "Urban centre" 2 "Outside urban centre") ///
        rows(1) ///
        size(2.0) ///
        position(6) ///
        ring(1) ///
        symxsize(5) ///
        region(lcolor(white))) ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 1 1 2)) ///
    plotregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(1 1 1 1)) ///
    xsize(10.5) ///
    ysize(5.0) ///
    name(g_hosp_share, replace)



********************************************************************************
**# Panel D
********************************************************************************

* ============================================================
**# Figure D: UC / patch-outside-UC area-share box plot
* ============================================================

use `base', clear


*------------------------------------------------------------
**# 11. Check variables and count excluded observations
*------------------------------------------------------------

confirm variable urban_id
confirm variable uc_area_km2
confirm variable patch3h_non_uc_area_km2
confirm variable uc_patchout_area_ratio_raw
confirm variable uc_patchout_area_ratio
confirm variable uc_patchout_area_pct


count
local N_total = r(N)


count if missing(uc_area_km2) ///
    | missing(patch3h_non_uc_area_km2) ///
    | patch3h_non_uc_area_km2 <= 0

local N_invalid_area = r(N)


count if uc_patchout_area_ratio_raw > 1 ///
    & !missing(uc_patchout_area_ratio_raw)

local N_gt1 = r(N)


count if !missing(uc_patchout_area_pct)
local N_used = r(N)

local N_excluded = `N_total' - `N_used'


label variable uc_patchout_area_pct ///
    "Urban centre area / Patch outside UC area (%)"

summarize uc_patchout_area_pct, detail


display "Total observations:              `N_total'"
display "Invalid area observations:       `N_invalid_area'"
display "Raw area ratio greater than 1:   `N_gt1'"
display "Observations used:               `N_used'"
display "Observations excluded:           `N_excluded'"


*------------------------------------------------------------
**# 12. Standard box plot
*------------------------------------------------------------

gen area_ratio_group = 1

label define area_ratio_lab ///
    1 "UC / Patch outside UC", replace

label values area_ratio_group area_ratio_lab

graph box uc_patchout_area_pct, ///
    over(area_ratio_group, label(nolabels)) ///
    nooutsides ///
    bar(1, ///
        fcolor("138 183 139%75") ///
        lcolor("55 101 58") ///
        lwidth(0.3)) ///
    marker(1, mcolor("55 101 58")) ///
    ylabel(0(1)7, ///
        angle(0) ///
        labsize(2.2) ///
        nogrid) ///
    yscale(range(-0.2 7)) ///
    ytitle("{bf:UC/outside-UC area ratio (%)}", ///
        size(2.25) ///
        margin(r=0.5)) ///
    note("") ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 2 1 1)) ///
    plotregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(1 2 1 1)) ///
    xsize(4.5) ///
    ysize(5.0) ///
    name(g_area_ratio_green, replace) ///
    fxsize(22)

graph save ///
    "$fig/facilities_and_flood/uc_patchout_area_pct_box.gph", ///
    replace



* ============================================================
**# Combine Panels C and D
* ============================================================

graph combine ///
    g_hosp_share ///
    g_area_ratio_green, ///
    cols(2) ///
    xsize(14) ///
    ysize(5.2) ///
    imargin(1 1 1 1) ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(0 0 0 0)) ///
    name(g_combined_hosp_area_ratio, replace) ///
    iscale(1)

graph save ///
    "$fig/facilities_and_flood/combined_uc_nonuc_hospital_area_ratio.gph", ///
    replace



* ============================================================
**# Final figure
*
* Top:    Panel A - Flooded facility percentages
* Bottom: Panel C + Panel D
* ============================================================

graph combine ///
    "$fig/facilities_and_flood/flood_pct_facility.gph" ///
    "$fig/facilities_and_flood/combined_uc_nonuc_hospital_area_ratio.gph", ///
    rows(2) ///
    imargin(0.5 0.5 0.5 0.5) ///
    xsize(12) ///
    ysize(10.5) ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(0 0 0 0)) ///
    iscale(1) ///
    name(hospital_other_main_density, replace)

graph save ///
    "$fig/facilities_and_flood/hospital_other_main_density.gph", ///
    replace

