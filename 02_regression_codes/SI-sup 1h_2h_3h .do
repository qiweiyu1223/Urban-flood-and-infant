
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

* Optional preprocessing when adding new variables
// Optional log-variable construction step is disabled here.
* ============================================================
**# Load Africa data
* ============================================================
use "$data/KR_PR_Africa_4.dta", clear

**# 2. Survey weight and interview timing
gen wt = v005 / 1000000

egen cluster_id = group(survey_group v001)
egen stratum_id = group(survey_group v022)
egen country_ym = group(survey_group v007 v006)
egen country_year = group(survey_group v007)
egen admin1_id = group(survey_group v024)

gen lon_grid05 = floor(dhs_lon * 2) / 2 if !missing(dhs_lon)
gen lat_grid05 = floor(dhs_lat * 2) / 2 if !missing(dhs_lat)
egen grid05_id = group(lon_grid05 lat_grid05), missing


**# Baseline model
local FE_base "absorb(urban_id v007 v006) cluster(urban_id)"

// local FE_r4 "absorb(admin1_id v007 v006) cluster(cluster_id)"
* ============================================================
**# Baseline controls
* Child characteristics, birth order, household size, household wealth, and maternal characteristics
* Climate controls tmp_mean_`w'm and pre_mean_`w'm are added by exposure window inside the regression loop.
* ============================================================
* 
* ============================================================
* Extended controls: spatial environment and accessibility
* ============================================================
local spatial_control ///
    log1_dhs_to_urban_boundary_km
* Baseline controls
* ============================================================

local base_control ///
    i.b4 ib1.agegrp ///
    ib1.bord_grp ///
    c.v136 i.v190 ///
    i.v106 c.v012
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
			 
local fa_dir "baseline_alternative_specification"		  
**# baseline specification
local dir "baseline"
cap mkdir "$fig_data/`fa_dir'/`dir'"
cap mkdir "$result/`fa_dir'"


*2h
local flood_hours flood_3m_ratio_T1_2h flood_6m_ratio_T1_2h flood_9m_ratio_T1_2h flood_12m_ratio_T1_2h
**# hours
local dir "hours_compare_2h"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood_hours {
	local w = ""
    if strpos("`x'", "_3m_")  local w = 3
    if strpos("`x'", "_6m_")  local w = 6
    if strpos("`x'", "_9m_")  local w = 9
    if strpos("`x'", "_12m_") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control'  tmp_mean_`w'm pre_mean_`w'm ,`FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond( ("`x'"=="flood_3m_ratio_T1_2h"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
	do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}



*1h
local flood_hours flood_3m_ratio_T1_1h flood_6m_ratio_T1_1h flood_9m_ratio_T1_1h flood_12m_ratio_T1_1h
**# hours
local dir "hours_compare_1h"
cap mkdir "$fig_data/`fa_dir'/`dir'"
local n=1	
foreach x of local flood_hours {
	local w = ""
    if strpos("`x'", "_3m_")  local w = 3
    if strpos("`x'", "_6m_")  local w = 6
    if strpos("`x'", "_9m_")  local w = 9
    if strpos("`x'", "_12m_") local w = 12
	reghdfe ch_fever `x' `base_control' `spatial_control'  tmp_mean_`w'm pre_mean_`w'm ,`FE_base'
	outreg2 using "$result/`fa_dir'/`dir'.xls", ///
		`=cond( ("`x'"=="flood_3m_ratio_T1_1h"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
	do "$dofile/04_support_codes/parmest输出选择语句.do" "`x'" "`n'" "`dir'" "`fa_dir'"
	local n=`n'+1
}