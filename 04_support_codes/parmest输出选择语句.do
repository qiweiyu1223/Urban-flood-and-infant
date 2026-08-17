*============================================================
* Unified parmest output script
*
* args:
*   x        = exposure variable, e.g. flood_6m_ratio
*   n        = model id number
*   dir      = output folder / heterogeneity folder name
*   fa_dir   = parent folder name
*   mode     = main / hetero_old / hetero_new / hetero_key
*   h        = heterogeneity variable name, optional
*   ngroups  = number of groups, optional
*
* Examples:
*
* Main model:
* Example: call the unified parmest selector helper.
*     "`x'" "`n'" "`dir'" "`fa_dir'" "main"
*
* Old heterogeneity:
* Example: call the unified parmest selector helper.
*     "`x'" "`n'" "`dir'" "`fa_dir'" "hetero_old" "`dir'"
*
* New heterogeneity:
* Example: call the unified parmest selector helper.
*     "`x'" "`n'" "`dir'" "`fa_dir'" "hetero_new" "`h'"
*
* Key heterogeneity:
* Example: call the unified parmest selector helper.
*     "`x'" "`n'" "`dir'" "`fa_dir'" "hetero_key" "`h'" "`ngroups'"
*============================================================

args x n dir fa_dir mode h ngroups


*------------------------------------------------------------
**# 0. Default argument handling
*    Compatible with two calling conventions:
*
*    New call:
*    do xxx.do "`x'" "`n'" "`dir'" "`fa_dir'" "hetero_key" "dist_q4"
*
*    Legacy call:
*    do xxx.do "`x'" "`n'" "`dir'" "`fa_dir'" "dist_q4"
*------------------------------------------------------------

if "`mode'" == "" {
    local mode "main"
}

* If the fifth argument is dist_q2, dist_q3, dist_q4, dist_q5, or residence_ur,
* this indicates key heterogeneity analysis, but hetero_key was omitted in the call.
if inlist("`mode'", "dist_q2", "dist_q3", "dist_q4", "dist_q5", "residence_ur") {
    local h "`mode'"
    local mode "hetero_key"
}

* If the fifth argument is a legacy heterogeneity variable,
* automatically identify it as hetero_old.
if inlist("`mode'", "poor", "low_edu", "large_hh", "low_road", "low_hf") {
    local h "`mode'"
    local mode "hetero_old"
}

* If the fifth argument is a new heterogeneity variable,
* automatically identify it as hetero_new.
if inlist("`mode'", "high_roadflood", "ph_electric", "ph_bike", "ph_cart", "ph_moto") {
    local h "`mode'"
    local mode "hetero_new"
}

if inlist("`mode'", "ph_car", "ph_wtr_improve_clean", "long_wtr_time", "ph_wtr_basic_clean") {
    local h "`mode'"
    local mode "hetero_new"
}

* If h is still empty, set h = dir by default.
if "`h'" == "" {
    local h "`dir'"
}

*------------------------------------------------------------
**# 1. Automatically identify exposure windows
*------------------------------------------------------------

local win ""
local win_num ""

forvalues k = 1/12 {
    if strpos("`x'", "_`k'm_") > 0 {
        local win "`k'm"
        local win_num "`k'"
    }
}


*------------------------------------------------------------
**# 2. Automatically identify metric types
* Note: ratio_pixeldays must be listed before ratio.
*------------------------------------------------------------

local type ""

if strpos("`x'", "_ratio_pixeldays") > 0 {
    local type "ratio_pixeldays"
}
else if strpos("`x'", "_pixeldays") > 0 {
    local type "pixeldays"
}
else if strpos("`x'", "_occurred") > 0 {
    local type "occurred"
}
else if strpos("`x'", "_ratio") > 0 {
    local type "ratio"
}
else if strpos("`x'", "_area") > 0 {
    local type "area"
}
else if strpos("`x'", "_days") > 0 {
    local type "days"
}
else if strpos("`x'", "_pixels") > 0 {
    local type "pixels"
}


*------------------------------------------------------------
**# 3. Check identification results
*------------------------------------------------------------

if "`type'" == "" | "`win'" == "" {
    di as error "未识别变量类型或时间窗口: `x'"
    exit
}


*------------------------------------------------------------
**# 4. Set output paths
*------------------------------------------------------------

local outdir "$fig_data/`fa_dir'/`dir'"

cap mkdir "$fig_data/`fa_dir'"
cap mkdir "`outdir'"

local outfile "`outdir'/`type'_`win'.dta"

di as text "--------------------------------------------------"
di as text "保存 parmest 结果"
di as text "mode: `mode'"
di as text "输出文件: `outfile'"
di as text "暴露变量: `x'"
di as text "异质性变量: `h'"
di as text "时间窗口: `win'"
di as text "指标类型: `type'"
di as text "--------------------------------------------------"


*------------------------------------------------------------
**# 5. Main mode: standard main regressions with direct parmest export
*------------------------------------------------------------

if "`mode'" == "main" {

    parmest, ///
        saving("`outfile'", replace) ///
        level(95) ///
        idstr("`dir'") ///
        idnum(`n')

    di as text "main 模式 parmest 保存完成: `outfile'"
    exit
}


*------------------------------------------------------------
**# 6. Other modes: run parmest to memory, then filter coefficients
*------------------------------------------------------------

preserve

parmest, ///
    norestore ///
    level(95) ///
    idstr("`dir'") ///
    idnum(`n')


*------------------------------------------------------------
**# 7. Keep mode-specific parm terms
*------------------------------------------------------------

gen keep_parm = 0


*------------------------------------------------------------
**## 7.1 Legacy heterogeneity mode
* parm format:
*   0.h#c.x
*   1.h#c.x
*------------------------------------------------------------

if "`mode'" == "hetero_old" {

    replace keep_parm = 1 if inlist(parm, ///
        "0.`h'#c.`x'", ///
        "1.`h'#c.`x'" ///
    )
}


*------------------------------------------------------------
**## 7.2 New heterogeneity mode
* parm format:
*   x_g0
*   x_g1
*------------------------------------------------------------

else if "`mode'" == "hetero_new" {

    replace keep_parm = 1 if inlist(parm, "x_g0", "x_g1")
}


*------------------------------------------------------------
**## 7.3 Key heterogeneity mode
* Includes:
*   dist_q2
*   dist_q3
*   dist_q4
*   dist_q5
*   residence_ur
*------------------------------------------------------------

else if "`mode'" == "hetero_key" {

    if "`h'" == "dist_q2" {
        replace keep_parm = 1 if inlist(parm, ///
            "dist2_near", ///
            "dist2_far" ///
        )
    }

    else if "`h'" == "dist_q3" {
        replace keep_parm = 1 if inlist(parm, ///
            "dist3_near", ///
            "dist3_mid", ///
            "dist3_far" ///
        )
    }

    else if "`h'" == "dist_q4" {
        replace keep_parm = 1 if inlist(parm, ///
            "dist4_q1", ///
            "dist4_q2", ///
            "dist4_q3", ///
            "dist4_q4" ///
        )
    }

    else if "`h'" == "dist_q5" {
        replace keep_parm = 1 if inlist(parm, ///
            "dist5_q1", ///
            "dist5_q2", ///
            "dist5_q3", ///
            "dist5_q4", ///
            "dist5_q5" ///
        )
    }

    else if "`h'" == "residence_ur" {
        replace keep_parm = 1 if inlist(parm, ///
            "flood_urban", ///
            "flood_rural" ///
        )
    }
}


*------------------------------------------------------------
**## 7.4 Invalid mode input
*------------------------------------------------------------

else {
    di as error "未知 mode: `mode'"
    di as error "mode 只能是 main / hetero_old / hetero_new / hetero_key"
    restore
    exit
}


keep if keep_parm == 1
drop keep_parm


*------------------------------------------------------------
**# 8. Error and display parm if no coefficient is matched
*------------------------------------------------------------

count

if r(N) == 0 {

    di as error "未匹配到对应的异质性系数。"
    di as error "当前 mode: `mode'"
    di as error "当前 h: `h'"
    di as error "当前 x: `x'"
    di as error "当前 parm 列如下："

    list parm estimate min95 max95, noobs

    restore
    exit
}


*------------------------------------------------------------
**# 9. Add common identifier variables
*------------------------------------------------------------

gen exposure_var = "`x'"
gen hetero_var   = "`h'"
gen output_dir   = "`dir'"
gen parent_dir   = "`fa_dir'"
gen mode         = "`mode'"
gen window       = "`win'"
gen window_num   = real("`win_num'")
gen flood_type   = "`type'"


*------------------------------------------------------------
**# 10. Generate group_value
*------------------------------------------------------------

gen group_value = .


* old heterogeneity
if "`mode'" == "hetero_old" {

    replace group_value = 0 if parm == "0.`h'#c.`x'"
    replace group_value = 1 if parm == "1.`h'#c.`x'"
}


* new heterogeneity
if "`mode'" == "hetero_new" {

    replace group_value = 0 if parm == "x_g0"
    replace group_value = 1 if parm == "x_g1"
}


* key heterogeneity
if "`mode'" == "hetero_key" {

    replace group_value = 1 if parm == "dist2_near"
    replace group_value = 2 if parm == "dist2_far"

    replace group_value = 1 if parm == "dist3_near"
    replace group_value = 2 if parm == "dist3_mid"
    replace group_value = 3 if parm == "dist3_far"

    replace group_value = 1 if parm == "dist4_q1"
    replace group_value = 2 if parm == "dist4_q2"
    replace group_value = 3 if parm == "dist4_q3"
    replace group_value = 4 if parm == "dist4_q4"

    replace group_value = 1 if parm == "dist5_q1"
    replace group_value = 2 if parm == "dist5_q2"
    replace group_value = 3 if parm == "dist5_q3"
    replace group_value = 4 if parm == "dist5_q4"
    replace group_value = 5 if parm == "dist5_q5"

    replace group_value = 0 if parm == "flood_urban"
    replace group_value = 1 if parm == "flood_rural"
}


*------------------------------------------------------------
**# 11. Generate default group_name
*------------------------------------------------------------

gen group_name = ""

replace group_name = "Group 0" if group_value == 0
replace group_name = "Group 1" if group_value == 1
replace group_name = "Group 2" if group_value == 2
replace group_name = "Group 3" if group_value == 3
replace group_name = "Group 4" if group_value == 4
replace group_name = "Group 5" if group_value == 5


*------------------------------------------------------------
**# 12. Legacy heterogeneity group names
*------------------------------------------------------------

replace group_name = "Non-poor" if hetero_var == "poor" & group_value == 0
replace group_name = "Poor"     if hetero_var == "poor" & group_value == 1

replace group_name = "Secondary/higher education" if hetero_var == "low_edu" & group_value == 0
replace group_name = "No/primary education"       if hetero_var == "low_edu" & group_value == 1

replace group_name = "Smaller household" if hetero_var == "large_hh" & group_value == 0
replace group_name = "Larger household"  if hetero_var == "large_hh" & group_value == 1

replace group_name = "Higher road access" if hetero_var == "low_road" & group_value == 0
replace group_name = "Lower road access"  if hetero_var == "low_road" & group_value == 1

replace group_name = "Higher HF access" if hetero_var == "low_hf" & group_value == 0
replace group_name = "Lower HF access"  if hetero_var == "low_hf" & group_value == 1


*------------------------------------------------------------
**# 13. New heterogeneity group names
*------------------------------------------------------------

replace group_name = "Low road-flood exposure"  if hetero_var == "high_roadflood" & group_value == 0
replace group_name = "High road-flood exposure" if hetero_var == "high_roadflood" & group_value == 1

replace group_name = "No electricity"  if hetero_var == "ph_electric" & group_value == 0
replace group_name = "Has electricity" if hetero_var == "ph_electric" & group_value == 1

replace group_name = "No bicycle"  if hetero_var == "ph_bike" & group_value == 0
replace group_name = "Has bicycle" if hetero_var == "ph_bike" & group_value == 1

replace group_name = "No cart"  if hetero_var == "ph_cart" & group_value == 0
replace group_name = "Has cart" if hetero_var == "ph_cart" & group_value == 1

replace group_name = "No motorcycle"  if hetero_var == "ph_moto" & group_value == 0
replace group_name = "Has motorcycle" if hetero_var == "ph_moto" & group_value == 1

replace group_name = "No car"  if hetero_var == "ph_car" & group_value == 0
replace group_name = "Has car" if hetero_var == "ph_car" & group_value == 1

replace group_name = "Unimproved water" if hetero_var == "ph_wtr_improve_clean" & group_value == 0
replace group_name = "Improved water"   if hetero_var == "ph_wtr_improve_clean" & group_value == 1

replace group_name = "Shorter water collection time" if hetero_var == "long_wtr_time" & group_value == 0
replace group_name = "Longer water collection time"  if hetero_var == "long_wtr_time" & group_value == 1

replace group_name = "Non-basic water" if hetero_var == "ph_wtr_basic_clean" & group_value == 0
replace group_name = "Basic water"     if hetero_var == "ph_wtr_basic_clean" & group_value == 1


*------------------------------------------------------------
**# 14. Key heterogeneity group names
*------------------------------------------------------------

replace group_name = "Nearer to city centroid" ///
    if hetero_var == "dist_q2" & group_value == 1

replace group_name = "Farther from city centroid" ///
    if hetero_var == "dist_q2" & group_value == 2


replace group_name = "Tertile 1: nearest" ///
    if hetero_var == "dist_q3" & group_value == 1

replace group_name = "Tertile 2" ///
    if hetero_var == "dist_q3" & group_value == 2

replace group_name = "Tertile 3: farthest" ///
    if hetero_var == "dist_q3" & group_value == 3


replace group_name = "Quartile 1: nearest" ///
    if hetero_var == "dist_q4" & group_value == 1

replace group_name = "Quartile 2" ///
    if hetero_var == "dist_q4" & group_value == 2

replace group_name = "Quartile 3" ///
    if hetero_var == "dist_q4" & group_value == 3

replace group_name = "Quartile 4: farthest" ///
    if hetero_var == "dist_q4" & group_value == 4


replace group_name = "Quintile 1: nearest" ///
    if hetero_var == "dist_q5" & group_value == 1

replace group_name = "Quintile 2" ///
    if hetero_var == "dist_q5" & group_value == 2

replace group_name = "Quintile 3" ///
    if hetero_var == "dist_q5" & group_value == 3

replace group_name = "Quintile 4" ///
    if hetero_var == "dist_q5" & group_value == 4

replace group_name = "Quintile 5: farthest" ///
    if hetero_var == "dist_q5" & group_value == 5


replace group_name = "Urban" ///
    if hetero_var == "residence_ur" & group_value == 0

replace group_name = "Rural" ///
    if hetero_var == "residence_ur" & group_value == 1


*------------------------------------------------------------
**# 15. Convert coefficients to percentage points
*------------------------------------------------------------

gen estimate_pct = estimate * 100
gen min95_pct    = min95 * 100
gen max95_pct    = max95 * 100


*------------------------------------------------------------
**# 16. Sorting variables
*------------------------------------------------------------

gen het_order = .

replace het_order = 1 if hetero_var == "poor"
replace het_order = 2 if hetero_var == "low_edu"
replace het_order = 3 if hetero_var == "large_hh"
replace het_order = 4 if hetero_var == "low_road"
replace het_order = 5 if hetero_var == "low_hf"

replace het_order = 11 if hetero_var == "high_roadflood"
replace het_order = 12 if hetero_var == "ph_electric"
replace het_order = 13 if hetero_var == "ph_bike"
replace het_order = 14 if hetero_var == "ph_cart"
replace het_order = 15 if hetero_var == "ph_moto"
replace het_order = 16 if hetero_var == "ph_car"
replace het_order = 17 if hetero_var == "ph_wtr_improve_clean"
replace het_order = 18 if hetero_var == "long_wtr_time"
replace het_order = 19 if hetero_var == "ph_wtr_basic_clean"

replace het_order = 21 if hetero_var == "dist_q2"
replace het_order = 22 if hetero_var == "dist_q3"
replace het_order = 23 if hetero_var == "dist_q4"
replace het_order = 24 if hetero_var == "dist_q5"
replace het_order = 25 if hetero_var == "residence_ur"


*------------------------------------------------------------
**# 17. Save
*------------------------------------------------------------

save "`outfile'", replace

di as text "保存完成: `outfile'"

restore
