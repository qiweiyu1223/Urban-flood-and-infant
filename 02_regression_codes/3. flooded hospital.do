do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"
* ============================================================
**# Load Africa data
* ============================================================
use "$data/KR_PR_Africa_4.dta", clear


**# Baseline model
local FE_base "absorb(urban_id v007 v006) vce(cluster urban_id)"

* Baseline controls
* ============================================================

local base_control ///
    i.b4 ib1.agegrp ///
    ib1.bord_grp ///
    c.v136 i.v190 ///
    i.v106 c.v012
	
* ============================================================
**# Control variables
* Extended controls: spatial environment and accessibility
* ===========================================================

local spatial_control ///
    log1_dhs_to_urban_boundary_km 

local control `base_control' `spatial_control' 

**********************************************************************************************************
	  
local fa_dir "facilities_and_flood"
cap mkdir "$fig_data/`fa_dir'"
cap mkdir "$result/`fa_dir'"
	
*# Flooded facility - hospital #1
*count
local facility_total hospital_total_flood_pct_6m primary_flood_pct_6m secondary_flood_pct_6m water_flood_pct_6m school_flood_pct_6m road_flood_pct_6m
cap mkdir "$fig_data/`fa_dir'"	
local n=1	
foreach x of local facility_total {
	reghdfe ch_fever `x' `control' tmp_mean_6m pre_mean_6m, `FE_base'
	outreg2 using "$result/`fa_dir'/hospital_other_facility.xls", ///
		` =cond(("`x'"=="log1_hosp_flood_6m"), "replace", "append")' ///
		se nocons lab dec(3) keep(`x')
	parmest, saving("$fig_data/`fa_dir'/`x'.dta", replace) level(95) idstr(`x') idnum(`n')
	local n=`n'+1
}

