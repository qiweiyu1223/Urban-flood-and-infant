*============================================================
* Coefficient plot:
* Child fever and other diseases or symptoms
*
* Input:
*   fever_other_disease_one_model_results.dta
*
* Estimates:
*   Weighted linear probability model
*   DHS cluster fixed effects
*   Standard errors clustered by DHS cluster
*
* Interpretation:
*   Adjusted difference in child fever incidence,
*   measured in percentage points.
*============================================================


*============================================================
**# 12. Load plotting data
*============================================================
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
use ///
    "$fig_data/SI_fever_other_disease/fever_other_disease_one_model_results.dta", ///
    clear


*============================================================
**# 13. Output path
*============================================================

local outdir "$fig_data/SI_fever_other_disease"

cap mkdir "`outdir'"
cap mkdir "$fig/SI_fever_other_disease"


*============================================================
**# 14. Check and standardize variable names
*============================================================

*------------------------------------------------------------
* Rename disease to parm for compatibility with older code
*------------------------------------------------------------

capture confirm variable parm

if _rc {

    capture confirm variable disease

    if !_rc {
        rename disease parm
    }
}


*------------------------------------------------------------
* Confirm required variables
*------------------------------------------------------------

capture confirm variable parm

if _rc {
    di as error ///
        "当前数据中既没有parm，也没有disease，无法绘图。"
    exit 111
}

capture confirm variable estimate

if _rc {
    di as error "缺少estimate变量。"
    exit 111
}

capture confirm variable min95

if _rc {
    di as error "缺少min95变量。"
    exit 111
}

capture confirm variable max95

if _rc {
    di as error "缺少max95变量。"
    exit 111
}


*============================================================
**# 15. Generate y-axis order
*============================================================

capture drop y
capture drop group_id

gen byte y = .

replace y = 11 if parm == "cough"
replace y = 10 if parm == "ch_diar"
replace y = 9  if parm == "ch_ari"

replace y = 8  if parm == "nt_ch_any_anem"
replace y = 7  if parm == "nt_ch_sev_anem"

replace y = 6  if parm == "nt_ch_wast"
replace y = 5  if parm == "nt_ch_sev_wast"

replace y = 4  if parm == "nt_ch_underwt"
replace y = 3  if parm == "nt_ch_sev_underwt"

replace y = 2  if parm == "nt_ch_stunt"
replace y = 1  if parm == "nt_ch_sev_stunt"


label define disease_lab ///
    11 "Cough" ///
    10 "Diarrhea" ///
    9  "ARI" ///
    8  "Any anemia" ///
    7  "Severe anemia" ///
    6  "Wasting" ///
    5  "Severe wasting" ///
    4  "Underweight" ///
    3  "Severe underweight" ///
    2  "Stunting" ///
    1  "Severe stunting", ///
    replace

label values y disease_lab

label variable y ///
    "Disease or symptom"


*============================================================
**# 16. Define disease groups
*============================================================

gen byte group_id = .

* Acute symptoms:
* cough, diarrhea and ARI
replace group_id = 1 ///
    if inlist(y, 9, 10, 11)

* Anemia
replace group_id = 2 ///
    if inlist(y, 7, 8)

* Wasting
replace group_id = 3 ///
    if inlist(y, 5, 6)

* Underweight
replace group_id = 4 ///
    if inlist(y, 3, 4)

* Stunting
replace group_id = 5 ///
    if inlist(y, 1, 2)


label define group_lab ///
    1 "Acute symptoms" ///
    2 "Anemia" ///
    3 "Wasting" ///
    4 "Underweight" ///
    5 "Stunting", ///
    replace

label values group_id group_lab

label variable group_id ///
    "Disease category"


*============================================================
**# 17. Check unmatched variables
*============================================================

di as text ///
    "以下变量没有匹配到y轴顺序；如果为空，说明全部匹配成功。"

list ///
    parm ///
    estimate ///
    min95 ///
    max95 ///
    if missing(y), ///
    noobs ///
    abbreviate(30)


* Drop disease variables not included in the plotting order
drop if missing(y)


*============================================================
**# 18. Check missing coefficient results
*============================================================

di as text ///
    "以下变量的系数或置信区间存在缺失；如果为空，说明结果完整。"

list ///
    parm ///
    estimate ///
    min95 ///
    max95 ///
    if missing(estimate, min95, max95), ///
    noobs ///
    abbreviate(30)


* Missing estimates cannot be plotted
drop if missing(estimate, min95, max95)


* Confirm that plotting observations remain
count

if r(N) == 0 {
    di as error "没有任何有效变量可用于绘图。"
    exit 2000
}


*============================================================
**# 19. Sort by y-axis order
*============================================================

gsort -y


*============================================================
**# 20. Dynamically determine x-axis range
*
* The coefficient and confidence interval are measured
* in percentage points.
*
* Add approximately 2 percentage points of padding and
* round outward to the nearest multiple of 5.
* Always include zero on the x-axis.
*============================================================

quietly summarize min95, meanonly
local xmin = r(min)

quietly summarize max95, meanonly
local xmax = r(max)


* Round the lower and upper limits outward
local xleft = ///
    floor((`xmin' - 2) / 5) * 5

local xright = ///
    ceil((`xmax' + 2) / 5) * 5


* Always include zero
if `xleft' > 0 {
    local xleft = 0
}

if `xright' < 0 {
    local xright = 0
}


* Ensure that the graph has a reasonable minimum width
if (`xright' - `xleft') < 10 {

    local xmid = (`xleft' + `xright') / 2

    local xleft = ///
        floor((`xmid' - 5) / 5) * 5

    local xright = ///
        ceil((`xmid' + 5) / 5) * 5
}


* Ensure zero remains included after minimum-width adjustment
if `xleft' > 0 {
    local xleft = 0
}

if `xright' < 0 {
    local xright = 0
}


di as text ///
    "Dynamic x-axis range: `xleft' to `xright' percentage points"


*============================================================
**# 21. Color settings
*============================================================

* Acute symptoms
local col_acute ///
    "83 157 169"

* Anemia
local col_anemia ///
    "205 132 71"

* Wasting
local col_wasting ///
    "165 91 91"

* Underweight
local col_underweight ///
    "82 120 166"

* Stunting
local col_stunting ///
    "137 113 160"


*============================================================
**# 22. Vertical coefficient plot
*============================================================

capture drop x
gen byte x = 12 - y

*============================================================
**# 22. Two-panel horizontal coefficient plot
*============================================================


*------------------------------------------------------------
* Panel A. Acute symptoms
*------------------------------------------------------------

twoway ///
    ///
    (rcap min95 max95 y ///
        if group_id == 1, ///
        horizontal ///
        lcolor("`col_acute'%85") ///
        lwidth(0.90)) ///
    ///
    (scatter y estimate ///
        if group_id == 1, ///
        msymbol(circle) ///
        mcolor("`col_acute'%95") ///
        mlcolor(white) ///
        mlwidth(0.25) ///
        msize(2.7)) ///
    ///
    , ///
    ///
    title( ///
        "{bf:Acute symptoms}", ///
        size(3.2) ///
        margin(b=1)) ///
    ///
    ylabel( ///
        11 "Cough" ///
        10 "Diarrhea" ///
        9  "ARI", ///
        angle(0) ///
        labsize(2.8) ///
        noticks ///
        nogrid) ///
    ///
    xlabel(20(5)40, ///
        angle(0) ///
        labsize(3) ///
        format(%9.0f) ///
        noticks ///
        glcolor(gs14) ///
        glwidth(0.25)) ///
    ///
    yscale( ///
        range(8.55 11.45) ///
        noline) ///
    ///
    xscale( ///
        range(20 42) ///
        noline) ///
    ///
    xtitle("") ///
    ytitle("") ///
    legend(off) ///
    ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 2 2 2)) ///
    ///
    plotregion( ///
        fcolor(white) ///
        lcolor(gs13) ///
        lwidth(0.30) ///
        margin(3 3 3 3)) ///
    ///
    name(g_fever_acute, replace) fxsize(170)


*------------------------------------------------------------
* Panel B. Other health conditions
*------------------------------------------------------------

twoway ///
    ///
    /* Anemia */ ///
    (rcap min95 max95 y ///
        if group_id == 2, ///
        horizontal ///
        lcolor("`col_anemia'%85") ///
        lwidth(0.90)) ///
    ///
    (scatter y estimate ///
        if group_id == 2, ///
        msymbol(circle) ///
        mcolor("`col_anemia'%95") ///
        mlcolor(white) ///
        mlwidth(0.25) ///
        msize(2.7)) ///
    ///
    /* Wasting */ ///
    (rcap min95 max95 y ///
        if group_id == 3, ///
        horizontal ///
        lcolor("`col_wasting'%85") ///
        lwidth(0.90)) ///
    ///
    (scatter y estimate ///
        if group_id == 3, ///
        msymbol(circle) ///
        mcolor("`col_wasting'%95") ///
        mlcolor(white) ///
        mlwidth(0.25) ///
        msize(2.7)) ///
    ///
    /* Underweight */ ///
    (rcap min95 max95 y ///
        if group_id == 4, ///
        horizontal ///
        lcolor("`col_underweight'%85") ///
        lwidth(0.90)) ///
    ///
    (scatter y estimate ///
        if group_id == 4, ///
        msymbol(circle) ///
        mcolor("`col_underweight'%95") ///
        mlcolor(white) ///
        mlwidth(0.25) ///
        msize(2.7)) ///
    ///
    /* Stunting */ ///
    (rcap min95 max95 y ///
        if group_id == 5, ///
        horizontal ///
        lcolor("`col_stunting'%85") ///
        lwidth(0.90)) ///
    ///
    (scatter y estimate ///
        if group_id == 5, ///
        msymbol(circle) ///
        mcolor("`col_stunting'%95") ///
        mlcolor(white) ///
        mlwidth(0.25) ///
        msize(2.7)) ///
    ///
    , ///
    ///
    title( ///
        "{bf:Other health conditions}", ///
        size(3.2) ///
        color(gs4) ///
        margin(b=1)) ///
    ///
    xline(0, ///
        lpattern(shortdash) ///
        lcolor(gs9) ///
        lwidth(0.40)) ///
    ///
    yline(6.5 4.5 2.5, ///
        lpattern(solid) ///
        lcolor(gs14) ///
        lwidth(0.25)) ///
    ///
    ylabel( ///
        8 "Any anemia" ///
        7 "Severe anemia" ///
        6 "Wasting" ///
        5 "Severe wasting" ///
        4 "Underweight" ///
        3 "Severe underweight" ///
        2 "Stunting" ///
        1 "Severe stunting", ///
        angle(0) ///
        labsize(2.65) ///
        noticks ///
        nogrid) ///
    ///
    xlabel(0(5)15, ///
        angle(0) ///
        labsize(3) ///
        format(%9.0f) ///
        noticks ///
        nogrid ///
        glcolor(gs14) ///
        glwidth(0.25)) ///
    ///
    yscale( ///
        range(0.45 8.55) ///
        noline) ///
    ///
    xscale( ///
        range(-1 15) ///
        noline) ///
    ///
    xtitle("") ///
    ytitle("") ///
    legend(off) ///
    ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 2 2 2)) ///
    ///
    plotregion( ///
        fcolor(white) ///
        lcolor(gs13) ///
        lwidth(0.30) ///
        margin(3 3 3 3)) ///
    ///
    name(g_fever_other, replace)  fxsize(200)


*------------------------------------------------------------
* Combine the two panels
*------------------------------------------------------------

graph combine ///
    g_fever_acute ///
    g_fever_other, ///
    cols(2) ///
    imargin(1 1 1 1) ///
    graphregion( ///
        fcolor(white) ///
        lcolor(white) ///
        margin(2 2 2 2)) ///
    b1title( ///
        "{bf:Adjusted difference in child fever prevalence (percentage points)}", ///
        size(4.5) ///
        margin(t=2)) ///
    xsize(11) ///
    ysize(4) ///
    name(g_relation_fever_other_disease, replace) ///
	    iscale(1.5) 


*============================================================
**# 23. Save graph
*============================================================

graph save ///
    "$fig/SI_fever_other_disease/relation.gph", ///
    replace

