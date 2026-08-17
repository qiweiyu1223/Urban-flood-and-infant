do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
* ============================================================
**# 0. Distance settings
*    Keep all distance cutoffs here so later adjustments only require edits in this block.
* ============================================================

local distvar dhs_to_urban_boundary_km

local q2_cut1 15

local q3_cut1 5
local q3_cut2 25

local q4_cut1 0
local q4_cut2 10
local q4_cut3 30

local q5_cut1 0
local q5_cut2 7.5
local q5_cut3 17.5
local q5_cut4 35

* ============================================================
**# Load Africa data
* ============================================================

use "$data/KR_PR_Africa_4.dta", clear


* ============================================================
* Check distance variable
* ============================================================

capture confirm variable `distvar'
if _rc {
    di as error "Distance variable `distvar' does not exist."
    exit 111
}

sum `distvar', detail


* ============================================================
* Fixed effects
* ============================================================

capture drop cluster_id
egen cluster_id = group(v000 v001)

local FE_base "absorb(urban_id v007 v006) vce(cluster urban_id)"


* ============================================================
* Baseline controls
* ============================================================

local child_control ///
    i.b4 ib1.agegrp ///
    ib1.bord_grp

local household_control ///
    c.v136 i.v190 ///
    i.v106 c.v012

local spatial_control ///
    log1_road_total_length_m

local base_control ///
    `child_control' ///
    `household_control'

local control ///
    `base_control' ///
    `spatial_control'


* ============================================================
**# 1. Construct key heterogeneity variables
* ============================================================

*------------------------------------------------------------
* A. Distance to urban-centre boundary groups
*    Note: variable names remain dist_q2/dist_q3/dist_q4/dist_q5.
*    This preserves compatibility with the existing parmest output helper.
*------------------------------------------------------------

*------------------------------------------------------------
* A1. 2 groups
*------------------------------------------------------------

capture drop dist_q2

gen dist_q2 = .
replace dist_q2 = 1 if !missing(`distvar') ///
    & `distvar' <= `q2_cut1'
replace dist_q2 = 2 if !missing(`distvar') ///
    & `distvar' > `q2_cut1'

label define dist_q2_lab ///
    1 "Within `q2_cut1' km of urban boundary" ///
    2 "Beyond `q2_cut1' km from urban boundary", replace
label values dist_q2 dist_q2_lab


*------------------------------------------------------------
* A2. 3 groups
*------------------------------------------------------------

capture drop dist_q3

gen dist_q3 = .
replace dist_q3 = 1 if !missing(`distvar') ///
    & `distvar' <= `q3_cut1'
replace dist_q3 = 2 if !missing(`distvar') ///
    & `distvar' > `q3_cut1' ///
    & `distvar' <= `q3_cut2'
replace dist_q3 = 3 if !missing(`distvar') ///
    & `distvar' > `q3_cut2'

label define dist_q3_lab ///
    1 "0-`q3_cut1' km from urban boundary" ///
    2 "`q3_cut1'-`q3_cut2' km from urban boundary" ///
    3 ">`q3_cut2' km from urban boundary", replace
label values dist_q3 dist_q3_lab


*------------------------------------------------------------
* A3. 4 groups
*     Recommended as the main result.
*------------------------------------------------------------

capture drop dist_q4

gen dist_q4 = .
replace dist_q4 = 1 if !missing(`distvar') ///
    & `distvar' == 0
replace dist_q4 = 2 if !missing(`distvar') ///
    & `distvar' > 0 ///
    & `distvar' <= `q4_cut2'
replace dist_q4 = 3 if !missing(`distvar') ///
    & `distvar' > `q4_cut2' ///
    & `distvar' <= `q4_cut3'
replace dist_q4 = 4 if !missing(`distvar') ///
    & `distvar' > `q4_cut3'

label define dist_q4_lab ///
    1 "Inside urban centre" ///
    2 "0-`q4_cut2' km from urban boundary" ///
    3 "`q4_cut2'-`q4_cut3' km from urban boundary" ///
    4 ">`q4_cut3' km from urban boundary", replace
label values dist_q4 dist_q4_lab


*------------------------------------------------------------
* A4. 5 groups
*------------------------------------------------------------

capture drop dist_q5

gen dist_q5 = .
replace dist_q5 = 1 if !missing(`distvar') ///
    & `distvar' == 0
replace dist_q5 = 2 if !missing(`distvar') ///
    & `distvar' > 0 ///
    & `distvar' <= `q5_cut2'
replace dist_q5 = 3 if !missing(`distvar') ///
    & `distvar' > `q5_cut2' ///
    & `distvar' <= `q5_cut3'
replace dist_q5 = 4 if !missing(`distvar') ///
    & `distvar' > `q5_cut3' ///
    & `distvar' <= `q5_cut4'
replace dist_q5 = 5 if !missing(`distvar') ///
    & `distvar' > `q5_cut4'

label define dist_q5_lab ///
    1 "Inside urban centre" ///
    2 "0-`q5_cut2' km from urban boundary" ///
    3 "`q5_cut2'-`q5_cut3' km from urban boundary" ///
    4 "`q5_cut3'-`q5_cut4' km from urban boundary" ///
    5 ">`q5_cut4' km from urban boundary", replace
label values dist_q5 dist_q5_lab


* ============================================================
**# 2. Quick checks
* ============================================================

di as text "============================================================"
di as text "Check distance-based heterogeneity groups"
di as text "============================================================"

tab dist_q2, missing
tab dist_q3, missing
tab dist_q4, missing
tab dist_q5, missing

di as text "============================================================"
di as text "Bounds for each distance group"
di as text "============================================================"

tabstat `distvar', by(dist_q2) ///
    stat(n min max mean p50) columns(statistics)

tabstat `distvar', by(dist_q3) ///
    stat(n min max mean p50) columns(statistics)

tabstat `distvar', by(dist_q4) ///
    stat(n min max mean p50) columns(statistics)

tabstat `distvar', by(dist_q5) ///
    stat(n min max mean p50) columns(statistics)


* ============================================================
**## 2.2 Manually display sample size by each distance interval
* ============================================================

di as text "============================================================"
di as text "Manual sample size display by distance interval"
di as text "============================================================"

count if dist_q2 == 1
di as result "Q2 group 1: <= `q2_cut1' km, N = " r(N)

count if dist_q2 == 2
di as result "Q2 group 2: > `q2_cut1' km, N = " r(N)


count if dist_q3 == 1
di as result "Q3 group 1: <= `q3_cut1' km, N = " r(N)

count if dist_q3 == 2
di as result "Q3 group 2: `q3_cut1'-`q3_cut2' km, N = " r(N)

count if dist_q3 == 3
di as result "Q3 group 3: > `q3_cut2' km, N = " r(N)


count if dist_q4 == 1
di as result "Q4 group 1: Inside urban centre, N = " r(N)

count if dist_q4 == 2
di as result "Q4 group 2: 0-`q4_cut2' km, N = " r(N)

count if dist_q4 == 3
di as result "Q4 group 3: `q4_cut2'-`q4_cut3' km, N = " r(N)

count if dist_q4 == 4
di as result "Q4 group 4: > `q4_cut3' km, N = " r(N)


count if dist_q5 == 1
di as result "Q5 group 1: Inside urban centre, N = " r(N)

count if dist_q5 == 2
di as result "Q5 group 2: 0-`q5_cut2' km, N = " r(N)

count if dist_q5 == 3
di as result "Q5 group 3: `q5_cut2'-`q5_cut3' km, N = " r(N)

count if dist_q5 == 4
di as result "Q5 group 4: `q5_cut3'-`q5_cut4' km, N = " r(N)

count if dist_q5 == 5
di as result "Q5 group 5: > `q5_cut4' km, N = " r(N)	
	
	
* ============================================================
**# 3. Exposure variables
* ============================================================

local xs ///
    flood_6m_ratio_csv
    // flood_3m_ratio flood_6m_ratio flood_9m_ratio flood_12m_ratio


* ============================================================
**# 4. Output settings
* ============================================================

local out_xls "$result/urban_boundary_distance.xls"

local fa_dir "urban_boundary_distance"

local n = 0
local first_outreg = 1


* ============================================================
**# 5. Key heterogeneity models
* ============================================================

foreach x of local xs {

    *--------------------------------------------------------
    * Automatically identify the exposure window.
    *--------------------------------------------------------

    local win_num ""

    forvalues k = 1/12 {
        if strpos("`x'", "_`k'm_") > 0 {
            local win_num "`k'"
        }
    }

    if "`win_num'" == "" {
        di as error "无法识别暴露窗口: `x'"
        continue
    }

    local climate_control tmp_mean_`win_num'm pre_mean_`win_num'm

    di as text "============================================================"
    di as text "Exposure variable: `x'"
    di as text "Climate controls : `climate_control'"
    di as text "Distance variable : `distvar'"
    di as text "============================================================"


    *========================================================
    * A. Distance: 2 groups
    *========================================================

    local ++n
    local h dist_q2
    local dir dist_q2
    local htitle "Distance to urban boundary: 2 groups"

    capture drop dist2_near dist2_far

    gen dist2_near = `x' * (dist_q2 == 1) if !missing(`x', dist_q2)
    gen dist2_far  = `x' * (dist_q2 == 2) if !missing(`x', dist_q2)

    label var dist2_near "Within `q2_cut1' km"
    label var dist2_far  "Beyond `q2_cut1' km"

    reghdfe ch_fever ///
        dist2_near dist2_far ///
        i.dist_q2 ///
        `control' `climate_control', ///
        `FE_base'

    lincom dist2_far - dist2_near
    local diff_b  = r(estimate)
    local diff_se = r(se)
    local diff_p  = r(p)

    outreg2 using "`out_xls'", ///
        `=cond(`first_outreg'==1, "replace", "append")' ///
        keep(dist2_near dist2_far) ///
        se nocons lab dec(3) ///
        ctitle("`htitle'") ///
        addtext(Exposure, "`x'", Heterogeneity, "`h'", ///
                Distance, "`distvar'", Controls, "Yes", FE, "Yes") ///
        addstat("Difference: far - near", `diff_b', ///
                "SE of difference", `diff_se', ///
                "P-value of difference", `diff_p')

    local first_outreg = 0

    do "$dofile/04_support_codes/parmest输出选择语句.do" ///
        "`x'" "`n'" "`dir'" "`fa_dir'" "`h'" "2"


    *========================================================
    * B. Distance: 3 groups
    *========================================================

    local ++n
    local h dist_q3
    local dir dist_q3
    local htitle "Distance to urban boundary: 3 groups"

    capture drop dist3_near dist3_mid dist3_far

    gen dist3_near = `x' * (dist_q3 == 1) if !missing(`x', dist_q3)
    gen dist3_mid  = `x' * (dist_q3 == 2) if !missing(`x', dist_q3)
    gen dist3_far  = `x' * (dist_q3 == 3) if !missing(`x', dist_q3)

    label var dist3_near "0-`q3_cut1' km"
    label var dist3_mid  "`q3_cut1'-`q3_cut2' km"
    label var dist3_far  ">`q3_cut2' km"

    reghdfe ch_fever ///
        dist3_near dist3_mid dist3_far ///
        i.dist_q3 ///
        `control' `climate_control', ///
        `FE_base'

    lincom dist3_far - dist3_near
    local diff31_b  = r(estimate)
    local diff31_se = r(se)
    local diff31_p  = r(p)

    lincom dist3_mid - dist3_near
    local diff21_b  = r(estimate)
    local diff21_se = r(se)
    local diff21_p  = r(p)

    outreg2 using "`out_xls'", ///
        append ///
        keep(dist3_near dist3_mid dist3_far) ///
        se nocons lab dec(3) ///
        ctitle("`htitle'") ///
        addtext(Exposure, "`x'", Heterogeneity, "`h'", ///
                Distance, "`distvar'", Controls, "Yes", FE, "Yes") ///
        addstat("Group 3 - Group 1", `diff31_b', ///
                "SE: G3 - G1", `diff31_se', ///
                "P-value: G3 - G1", `diff31_p', ///
                "Group 2 - Group 1", `diff21_b', ///
                "SE: G2 - G1", `diff21_se', ///
                "P-value: G2 - G1", `diff21_p')

    do "$dofile/04_support_codes/parmest输出选择语句.do" ///
        "`x'" "`n'" "`dir'" "`fa_dir'" "`h'" "3"


    *========================================================
    * C. Distance: 4 groups
    *========================================================

    local ++n
    local h dist_q4
    local dir dist_q4
    local htitle "Distance to urban boundary: 4 groups"

    capture drop dist4_q1 dist4_q2 dist4_q3 dist4_q4

    gen dist4_q1 = `x' * (dist_q4 == 1) if !missing(`x', dist_q4)
    gen dist4_q2 = `x' * (dist_q4 == 2) if !missing(`x', dist_q4)
    gen dist4_q3 = `x' * (dist_q4 == 3) if !missing(`x', dist_q4)
    gen dist4_q4 = `x' * (dist_q4 == 4) if !missing(`x', dist_q4)

    label var dist4_q1 "Inside urban centre"
    label var dist4_q2 "0-`q4_cut2' km"
    label var dist4_q3 "`q4_cut2'-`q4_cut3' km"
    label var dist4_q4 ">`q4_cut3' km"

    reghdfe ch_fever ///
        dist4_q1 dist4_q2 dist4_q3 dist4_q4 ///
        i.dist_q4 ///
        `control' `climate_control', ///
        `FE_base'

    lincom dist4_q4 - dist4_q1
    local diff41_b  = r(estimate)
    local diff41_se = r(se)
    local diff41_p  = r(p)

    lincom dist4_q3 - dist4_q1
    local diff31_b  = r(estimate)
    local diff31_se = r(se)
    local diff31_p  = r(p)

    lincom dist4_q2 - dist4_q1
    local diff21_b  = r(estimate)
    local diff21_se = r(se)
    local diff21_p  = r(p)

    outreg2 using "`out_xls'", ///
        append ///
        keep(dist4_q1 dist4_q2 dist4_q3 dist4_q4) ///
        se nocons lab dec(3) ///
        ctitle("`htitle'") ///
        addtext(Exposure, "`x'", Heterogeneity, "`h'", ///
                Distance, "`distvar'", Controls, "Yes", FE, "Yes") ///
        addstat("Group 4 - Group 1", `diff41_b', ///
                "SE: G4 - G1", `diff41_se', ///
                "P-value: G4 - G1", `diff41_p', ///
                "Group 3 - Group 1", `diff31_b', ///
                "SE: G3 - G1", `diff31_se', ///
                "P-value: G3 - G1", `diff31_p', ///
                "Group 2 - Group 1", `diff21_b', ///
                "SE: G2 - G1", `diff21_se', ///
                "P-value: G2 - G1", `diff21_p')

    do "$dofile/04_support_codes/parmest输出选择语句.do" ///
        "`x'" "`n'" "`dir'" "`fa_dir'" "`h'" "4"


    *========================================================
    * D. Distance: 5 groups
    *========================================================

    local ++n
    local h dist_q5
    local dir dist_q5
    local htitle "Distance to urban boundary: 5 groups"

    capture drop dist5_q1 dist5_q2 dist5_q3 dist5_q4 dist5_q5

    gen dist5_q1 = `x' * (dist_q5 == 1) if !missing(`x', dist_q5)
    gen dist5_q2 = `x' * (dist_q5 == 2) if !missing(`x', dist_q5)
    gen dist5_q3 = `x' * (dist_q5 == 3) if !missing(`x', dist_q5)
    gen dist5_q4 = `x' * (dist_q5 == 4) if !missing(`x', dist_q5)
    gen dist5_q5 = `x' * (dist_q5 == 5) if !missing(`x', dist_q5)

    label var dist5_q1 "Inside urban centre"
    label var dist5_q2 "0-`q5_cut2' km"
    label var dist5_q3 "`q5_cut2'-`q5_cut3' km"
    label var dist5_q4 "`q5_cut3'-`q5_cut4' km"
    label var dist5_q5 ">`q5_cut4' km"

    reghdfe ch_fever ///
        dist5_q1 dist5_q2 dist5_q3 dist5_q4 dist5_q5 ///
        i.dist_q5 ///
        `control' `climate_control', ///
        `FE_base'

    lincom dist5_q5 - dist5_q1
    local diff51_b  = r(estimate)
    local diff51_se = r(se)
    local diff51_p  = r(p)

    lincom dist5_q4 - dist5_q1
    local diff41_b  = r(estimate)
    local diff41_se = r(se)
    local diff41_p  = r(p)

    lincom dist5_q3 - dist5_q1
    local diff31_b  = r(estimate)
    local diff31_se = r(se)
    local diff31_p  = r(p)

    lincom dist5_q2 - dist5_q1
    local diff21_b  = r(estimate)
    local diff21_se = r(se)
    local diff21_p  = r(p)

    outreg2 using "`out_xls'", ///
        append ///
        keep(dist5_q1 dist5_q2 dist5_q3 dist5_q4 dist5_q5) ///
        se nocons lab dec(3) ///
        ctitle("`htitle'") ///
        addtext(Exposure, "`x'", Heterogeneity, "`h'", ///
                Distance, "`distvar'", Controls, "Yes", FE, "Yes") ///
        addstat("Group 5 - Group 1", `diff51_b', ///
                "SE: G5 - G1", `diff51_se', ///
                "P-value: G5 - G1", `diff51_p', ///
                "Group 4 - Group 1", `diff41_b', ///
                "SE: G4 - G1", `diff41_se', ///
                "P-value: G4 - G1", `diff41_p', ///
                "Group 3 - Group 1", `diff31_b', ///
                "SE: G3 - G1", `diff31_se', ///
                "P-value: G3 - G1", `diff31_p', ///
                "Group 2 - Group 1", `diff21_b', ///
                "SE: G2 - G1", `diff21_se', ///
                "P-value: G2 - G1", `diff21_p')

    do "$dofile/04_support_codes/parmest输出选择语句.do" ///
        "`x'" "`n'" "`dir'" "`fa_dir'" "`h'" "5"
}
