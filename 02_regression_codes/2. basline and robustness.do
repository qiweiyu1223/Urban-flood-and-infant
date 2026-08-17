
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

* ============================================================
**# Load Africa data
* ============================================================
use "$data/KR_PR_Africa_4.dta", clear

**# Weights
cap drop wt wt_norm sum_wt_survey wt_equal_survey

gen double wt = v005 / 1000000 if v005 < .

summarize wt if wt < .
gen double wt_norm = wt / r(sum) * r(N) if wt < .

bysort survey_group: egen sum_wt_survey = total(wt)
levelsof survey_group if wt < ., local(surveys)
local S : word count `surveys'

count if wt < .
local N = r(N)

gen double wt_equal_survey = wt / sum_wt_survey * (`N' / `S') ///
    if wt < . & sum_wt_survey > 0
	
*****************************************************
egen cluster_id = group(survey_group v001)
egen stratum_id = group(survey_group v022)
egen country_ym = group(c_name v007 v006)
egen country_year = group(c_name v007)
egen admin1_id = group(survey_group v024)
** urban_id

gen lon_grid05 = floor(dhs_lon * 2) / 2 if !missing(dhs_lon)
gen lat_grid05 = floor(dhs_lat * 2) / 2 if !missing(dhs_lat)
egen grid05_id = group(lon_grid05 lat_grid05), missing

egen stratum_ym   = group(stratum_id v007 v006)
egen stratum_year = group(stratum_id v007)
egen admin1_ym    = group(admin1_id v007 v006)
egen admin1_year  = group(admin1_id v007)

**# Fixed effect
local FE_base "absorb(urban_id v007 v006) vce(cluster urban_id)"
local FE_r1   "absorb(grid05_id v007 v006) vce(cluster urban_id)"
local FE_r2   "absorb(urban_id v007#v006) vce(cluster urban_id)"
local FE_r3 "absorb(c_name hv007 v006) cluster(urban_id)"
local FE_r4 "absorb(c_name hv007#v006) cluster(urban_id)"
* ============================================================
* Baseline controls
* ============================================================

local base_control ///
    i.b4 ib1.agegrp ///
    ib1.bord_grp ///
    c.v136 i.v190 ///
    i.v106 c.v012

* ============================================================
* Extended controls: spatial environment and accessibility
* ============================================================
local spatial_control ///
    log1_dhs_to_urban_boundary_km  ///

* ============================================================
* Extended controls: household assets
* ============================================================

local asset_control ///
    ph_electric ///
    ph_bike ph_moto ph_car
* ============================================================
* Extended controls: household environment and WASH
* ============================================================
local wash_control ///
    ph_rooms_sleep ///
    ph_wtr_improve ///
	ph_wtr_time
* ============================================================
* All extended controls
* ============================================================
local extend_control ///
    `asset_control' ///
    `wash_control'
* ============================================================
**# Exposure variables
* ============================================================
local flood  flood_3m_ratio_csv flood_6m_ratio_csv flood_9m_ratio_csv flood_12m_ratio_csv
local occurred flood_3m_occurred_csv flood_6m_occurred_csv flood_9m_occurred_csv flood_12m_occurred_csv
local area log1_flood_3m_area_csv log1_flood_6m_area_csv log1_flood_9m_area_csv log1_flood_12m_area_csv 
			 
local fa_dir "baseline_alternative_specification"		  
cap mkdir "$result/`fa_dir'"

****************************************************************************************
**# 1. baseline specification 
**(absorb(urban_id v007 v006) vce(cluster urban_id)) √
local dir "baseline"
cap mkdir "$fig_data/`fa_dir'/`dir'"
		
local n=1 
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control' tmp_mean_`w'm pre_mean_`w'm, `FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}

**# 2. FE_r1 absorb(grid05_id v007 v006) vce(cluster urban_id) √
local dir "fe1"
cap mkdir "$fig_data/`fa_dir'/`dir'"
	
local n=1
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12	
	reghdfe ch_fever `x' `base_control' `spatial_control' tmp_mean_`w'm pre_mean_`w'm , `FE_r1'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}

**# 3. FE_r2 absorb(urban_id hv007#hv006) vce(cluster urban_id)  √
local dir "fe2"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control' tmp_mean_`w'm pre_mean_`w'm , `FE_r2'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}



**# 4. FE_r3 absorb(c_name hv007 v006) cluster(urban_id)  √
local dir "fe3"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control' tmp_mean_`w'm pre_mean_`w'm, `FE_r3'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}


*****************************************************************************************

**#5. 2018-2022 sample √
local dir "selecttime"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control' tmp_mean_`w'm pre_mean_`w'm if sur_time==1, `FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}


**#6. DHS_flood exclusion √
local dir "DHS_flood"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control' tmp_mean_`w'm pre_mean_`w'm  if flood30_`w'm==0, `FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}


**#7. extendcontrol  √
local dir "extendcontrol"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `extend_control' ///
		`spatial_control' tmp_mean_`w'm pre_mean_`w'm ///
		flood30_`w'm hospital_30km_total NDVI_m`w' EVI_m`w', `FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond(("`x'"=="flood_3m_ratio_csv"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}


****************************************************************************************
 **#8. occurred √
local dir "occurred"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local occurred {
	local w = ""
    if strpos("`x'", "3m")  local w = 3
    if strpos("`x'", "6m")  local w = 6
    if strpos("`x'", "9m")  local w = 9
    if strpos("`x'", "12m") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control'  tmp_mean_`w'm pre_mean_`w'm ,`FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond( ("`x'"=="flood_3m_occurred_T1_3h"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}


**#9. postitive tertiles √
local dir "positive_tertiles_T1_T2"
cap mkdir "$fig_data/`fa_dir'/`dir'"

local first = 1
local n = 1

foreach x of local flood {

    local w = ""
    if strpos("`x'", "_3m_")  local w = 3
    if strpos("`x'", "_6m_")  local w = 6
    if strpos("`x'", "_9m_")  local w = 9
    if strpos("`x'", "_12m_") local w = 12

    * Use the baseline continuous-exposure model to mark the effective sample.
    quietly reghdfe ch_fever `x' `base_control' `spatial_control' ///
        tmp_mean_`w'm pre_mean_`w'm, `FE_base'

    cap drop sample_`w'm
    gen byte sample_`w'm = e(sample)

    * Median among positive-exposure observations only.
    quietly summarize `x' if sample_`w'm == 1 & `x' > 0 & `x' < ., detail
    local p50 = r(p50)

    cap drop flood_low flood_high
    gen byte flood_low  = (`x' > 0 & `x' <= `p50') if sample_`w'm == 1 & `x' < .
    gen byte flood_high = (`x' > `p50' & `x' < .)  if sample_`w'm == 1 & `x' < .

    label var flood_low  "Low positive exposure"
    label var flood_high "High positive exposure"

    reghdfe ch_fever ///
        flood_low flood_high ///
        `base_control' `spatial_control' ///
        tmp_mean_`w'm pre_mean_`w'm ///
        if sample_`w'm == 1, `FE_base'

    outreg2 using "$result/`fa_dir'/`dir'.xls", ///
        `=cond(`first' == 1, "replace", "append")' ///
        se nocons lab dec(3) ///
        keep(flood_low flood_high)

    preserve

        parmest, norestore level(95) idstr("`dir'") idnum(`n')

        keep if inlist(parm, "flood_low", "flood_high")

        gen exposure_var = "`x'"
        gen output_dir   = "`dir'"
        gen parent_dir   = "`fa_dir'"
        gen mode         = "positive_binary"
        gen window       = "`w'm"
        gen window_num   = `w'
        gen flood_type   = "ratio"
        gen cutoff_p50   = `p50'

        gen group_value = .
        replace group_value = 1 if parm == "flood_low"
        replace group_value = 2 if parm == "flood_high"

        gen group_name = ""
        replace group_name = "Low positive exposure"  if group_value == 1
        replace group_name = "High positive exposure" if group_value == 2

        gen estimate_pct = estimate * 100
        gen min95_pct    = min95 * 100
        gen max95_pct    = max95 * 100

        save "$fig_data/`fa_dir'/`dir'/ratio_`w'm.dta", replace

    restore

    local first = 0
    local n = `n' + 1
}
****************************************************************************
**# 10. wt  √
local weight_list wt wt_norm wt_equal_survey

foreach weight_var of local weight_list {

local dir "weighted_continuous_`weight_var'"
cap mkdir "$fig_data/`fa_dir'/`dir'"

    local first = 1
    local n = 1

    foreach x of local flood {

        local w = ""
        if strpos("`x'", "_3m_")  local w = 3
        if strpos("`x'", "_6m_")  local w = 6
        if strpos("`x'", "_9m_")  local w = 9
        if strpos("`x'", "_12m_") local w = 12

        reghdfe ch_fever `x' `base_control' `spatial_control' ///
            tmp_mean_`w'm pre_mean_`w'm ///
            [pw=`weight_var'], `FE_base'

        outreg2 using "$result/`fa_dir'/`dir'.xls", ///
            `=cond(`first' == 1, "replace", "append")' ///
            se nocons lab dec(3) keep(`x')

        preserve

            parmest, norestore level(95) idstr("`dir'") idnum(`n')
            keep if parm == "`x'"

            gen exposure_var = "`x'"
            gen output_dir   = "`dir'"
            gen parent_dir   = "`fa_dir'"
            gen mode         = "weighted_continuous"
            gen weight_var   = "`weight_var'"
            gen window       = "`w'm"
            gen window_num   = `w'
            gen flood_type   = "ratio"

            gen estimate_pct = estimate * 100
            gen min95_pct    = min95 * 100
            gen max95_pct    = max95 * 100

            save "$fig_data/`fa_dir'/`dir'/ratio_`w'm.dta", replace

        restore

        local first = 0
        local n = `n' + 1
    }
}