/* 合并版：补充数据目录下 9 个 do 文件。原文件保持不变。\n   中间主数据和 using 数据均使用 tempfile，不写入 $data；最后仅保存最终结果。 */

clear all
set more off
do "G:/3 city and conflict/3 experiment/1 stata_code/4. 儿童发烧/预处理/1 数据前的加载_clean_global.do"


*======================================================================
* 1. 补充数据1-洪水数据重新处理.do
*======================================================================
* 处理 1-12 月洪水指标并合并到主数据。
import delimited "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\flood_1m_12.csv", clear varnames(1) case(preserve)

keep SURVEY_C year month ///
flood_1m_occurred flood_1m_days flood_1m_area flood_1m_ratio flood_1m_pixels flood_1m_pixeldays flood_1m_ratio_pixeldays ///
flood_2m_occurred flood_2m_days flood_2m_area flood_2m_ratio flood_2m_pixels flood_2m_pixeldays flood_2m_ratio_pixeldays ///
flood_3m_occurred flood_3m_days flood_3m_area flood_3m_ratio flood_3m_pixels flood_3m_pixeldays flood_3m_ratio_pixeldays ///
flood_4m_occurred flood_4m_days flood_4m_area flood_4m_ratio flood_4m_pixels flood_4m_pixeldays flood_4m_ratio_pixeldays ///
flood_5m_occurred flood_5m_days flood_5m_area flood_5m_ratio flood_5m_pixels flood_5m_pixeldays flood_5m_ratio_pixeldays ///
flood_6m_occurred flood_6m_days flood_6m_area flood_6m_ratio flood_6m_pixels flood_6m_pixeldays flood_6m_ratio_pixeldays ///
flood_7m_occurred flood_7m_days flood_7m_area flood_7m_ratio flood_7m_pixels flood_7m_pixeldays flood_7m_ratio_pixeldays ///
flood_8m_occurred flood_8m_days flood_8m_area flood_8m_ratio flood_8m_pixels flood_8m_pixeldays flood_8m_ratio_pixeldays ///
flood_9m_occurred flood_9m_days flood_9m_area flood_9m_ratio flood_9m_pixels flood_9m_pixeldays flood_9m_ratio_pixeldays ///
flood_10m_occurred flood_10m_days flood_10m_area flood_10m_ratio flood_10m_pixels flood_10m_pixeldays flood_10m_ratio_pixeldays ///
flood_11m_occurred flood_11m_days flood_11m_area flood_11m_ratio flood_11m_pixels flood_11m_pixeldays flood_11m_ratio_pixeldays ///
flood_12m_occurred flood_12m_days flood_12m_area flood_12m_ratio flood_12m_pixels flood_12m_pixeldays flood_12m_ratio_pixeldays

rename year  v007
rename month v006

forvalues i = 1/12 {
    rename flood_`i'm_occurred       flood_`i'm_occurred_csv
    rename flood_`i'm_days           flood_`i'm_days_csv
    rename flood_`i'm_area           flood_`i'm_area_csv
    rename flood_`i'm_ratio          flood_`i'm_ratio_csv
    rename flood_`i'm_pixels         flood_`i'm_pixels_csv
    rename flood_`i'm_pixeldays      flood_`i'm_pixeldays_csv
    rename flood_`i'm_ratio_pixeldays flood_`i'm_ratio_pixeldays_csv
}

duplicates drop SURVEY_C v007 v006, force
tempfile flood_1m_12
save `flood_1m_12', replace

use "$data/KR_PR_Africa.dta", clear
merge m:1 SURVEY_C v007 v006 using ///
`flood_1m_12'

keep if _merge==1 | _merge==3
drop _merge


*======================================================================
* 2. 补充数据2-DHS附近30公里hospital.do
*======================================================================
tempfile master_2
save `master_2', replace
* 合并 DHS 30km hospital 指标。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\DHS_hospital_30_with_urban_boundary_and_centroid_distance.csv", ///
    clear varnames(1) case(preserve)

rename year  v007
rename month v006

* describe DHSID v007 v006
* duplicates report DHSID v007 v006
duplicates drop DHSID v007 v006, force
isid DHSID v007 v006
tempfile hospital30
save `hospital30', replace

use `master_2', clear

capture drop ///
    dhs_to_city_centroid_distance_c2 ///
    dhs_to_city_centroid_distance_c3 ///
    c1h_ids_norm ///
    dhs_lon ///
    dhs_lat ///
    city_centroid_lon ///
    city_centroid_lat ///

rename dhs_to_city_centroid_m dhs_to_city_centroid_2m
rename dhs_to_city_centroid_km dhs_to_city_centroid_2km

* describe DHSID v007 v006
merge m:1 DHSID v007 v006 using `hospital30'

* tab _merge
keep if _merge == 1 | _merge == 3
drop _merge


*======================================================================
* 3. 补充数据3-道路是否中断数据.do
*======================================================================
tempfile master_3
save `master_3', replace
* 合并 hospital / road / flood metrics。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\2-2. dhs_city_matches_with_level_road_flood_metrics.csv", ///
    clear varnames(1) case(preserve)

rename year  v007
rename month v006

* describe DHSID v007 v006
* codebook DHSID v007 v006
capture drop c1h_ids
capture drop c1h_names c1h_name city_name matched_c_name

* duplicates report DHSID v007 v006
* duplicates list DHSID v007 v006
duplicates drop DHSID v007 v006, force
isid DHSID v007 v006

tempfile city_metrics
save `city_metrics', replace

use `master_3', clear

* describe DHSID v007 v006
* codebook DHSID v007 v006
merge m:1 DHSID v007 v006 using `city_metrics'

* tab _merge
keep if _merge == 1 | _merge == 3
drop _merge


*======================================================================
* 4. 补充数据4-uban_centre.do
*======================================================================
tempfile master_4
save `master_4', replace
* 合并 urban centre 指标并统一变量名。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\Africa_Tier1_Urban_Centres.csv", ///
    clear varnames(1) case(preserve)

rename id target_id

* describe target_id
* duplicates report target_id
* duplicates drop target_id, force

tempfile urban_centre
save `urban_centre', replace

use `master_4', clear

capture drop ///
    DEM_ghspop ///
    DEM_gpw ///
    DEM_landscan ///
    DEM_worldpop ///
    DEM_dem_mean ///
    DEM_dem_min ///
    DEM_dem_p10 ///
    DEM_dem_p25 ///
    DEM_dem_std ///
    DEM_dem_relief_p90_p10 ///
    DEM_buffer_dem_mean ///
    DEM_buffer_dem_p10 ///
    DEM_city_minus_buffer_mean ///
    DEM_low_ratio_below_buffer_p25 ///
    SHAPE_level ///
    SHAPE_area_m2 ///
    SHAPE_perimeter_m ///
    SHAPE_compactness ///
    SHAPE_convexity ///
    SHAPE_mrr_long_m ///
    SHAPE_mrr_short_m ///
    SHAPE_elongation_ratio ///
    SHAPE_elongation_inv ///
    SHAPE_rectangularity ///
    SHAPE_perim_area_ratio
	
* describe target_id
* duplicates report target_id
merge m:1 target_id using `urban_centre'

* tab _merge
keep if _merge == 1 | _merge == 3
drop _merge

* Urban centre area variables

capture rename uc_area_m2  UC_area_m2
capture rename uc_area_km2 UC_area_km2


* DEM / topography variables
capture rename gpw                 		 DEM_gpw
capture rename landscan                  DEM_landscan
capture rename worldpop                  DEM_worldpop
capture rename ghspop                 	 DEM_ghspop
capture rename dem_mean                  DEM_mean
capture rename dem_min                   DEM_min
capture rename dem_p10                   DEM_p10
capture rename dem_p25                   DEM_p25
capture rename dem_std                   DEM_std
capture rename dem_relief_p90_p10        DEM_relief_p90_p10
capture rename buffer_dem_mean           DEM_buffer_mean
capture rename buffer_dem_p10            DEM_buffer_p10
capture rename city_minus_buffer_mean    DEM_city_minus_buffer_mean
capture rename low_ratio_below_buffer_p25 DEM_low_ratio_buffer_p25



* Water variables

capture rename water_occurrence_mean     WATER_occurrence_mean
capture rename permanent_water_ratio     WATER_permanent_ratio
capture rename seasonal_water_ratio      WATER_seasonal_ratio
capture rename ever_water_ratio          WATER_ever_ratio
capture rename distance_to_water_m       WATER_distance_m
capture rename water_change_abs_mean     WATER_change_abs_mean
capture rename water_change_norm_mean    WATER_change_norm_mean
capture rename water_recurrence_mean     WATER_recurrence_mean


* Nighttime light variables

capture rename ntl_mean          NTL_mean
capture rename ntl_sum           NTL_sum
capture rename ntl_p90           NTL_p90
capture rename ntl_2013_mean     NTL_2013_mean
capture rename ntl_2020_mean     NTL_2020_mean
capture rename ntl_growth        NTL_growth
capture rename ntl_growth_rate   NTL_growth_rate


* Built-up variables

capture rename builtup_2000_m2                 BU_2000_m2
capture rename builtup_2010_m2                 BU_2010_m2
capture rename builtup_2015_m2                 BU_2015_m2
capture rename builtup_2020_m2                 BU_2020_m2

capture rename builtup_2000                    BU_2000
capture rename builtup_2010                    BU_2010
capture rename builtup_2015                    BU_2015
capture rename builtup_2020                    BU_2020

capture rename builtup_growth_2000_2020        BU_growth_2000_2020
capture rename builtup_growth_2010_2020        BU_growth_2010_2020
capture rename builtup_growth_rate_2000_2020   BU_grate_2000_2020
capture rename builtup_growth_rate_2010_2020   BU_grate_2010_2020

capture rename builtup_area                    BU_area
capture rename builtup_ratio                   BU_ratio
capture rename builtup_density                 BU_density


* GFD flood frequency variables

capture rename gfd_event_count_mean          GFD_event_count_mean
capture rename gfd_event_count_max           GFD_event_count_max
capture rename gfd_event_count_mean_annual   GFD_event_count_annual

capture rename gfd_duration_sum_mean         GFD_duration_sum_mean
capture rename gfd_duration_sum_max          GFD_duration_sum_max
capture rename gfd_duration_sum_mean_annual  GFD_duration_sum_annual

capture rename gfd_flooded_any_ratio         GFD_any_ratio
capture rename gfd_flooded_any_area_km2      GFD_any_area_km2

capture rename gfd_frequent_2plus_ratio      GFD_freq_2plus_ratio
capture rename gfd_frequent_3plus_ratio      GFD_freq_3plus_ratio
capture rename gfd_frequent_5plus_ratio      GFD_freq_5plus_ratio

capture rename gfd_flooded_pixel_sum         GFD_flooded_pixel_sum
capture rename gfd_any_flood_pixel_sum       GFD_any_flood_pixel_sum


* Urban shape variables

capture rename city_level          SHAPE_level
capture rename area_m2             SHAPE_area_m2
capture rename perimeter_m         SHAPE_perimeter_m
capture rename compactness         SHAPE_compactness
capture rename convexity           SHAPE_convexity
capture rename mrr_long_m          SHAPE_mrr_long_m
capture rename mrr_short_m         SHAPE_mrr_short_m
capture rename elongation_ratio    SHAPE_elongation_ratio
capture rename elongation_inv      SHAPE_elongation_inv
capture rename rectangularity      SHAPE_rectangularity
capture rename perim_area_ratio    SHAPE_perim_area_ratio


*======================================================================
* 5. 补充数据5-hours_boundary_dis.do
*======================================================================
tempfile master_5
save `master_5', replace
* 合并不同 hours 的 flood ratio 和 boundary distance 指标。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\GEE补充数据\不同hours的匹配\merge.csv", ///
    clear varnames(1) case(preserve)

rename year  v007
rename month v006

drop SURVEY_C c_name

* duplicates report DHSID v007 v006
* duplicates tag DHSID v007 v006, gen(dup_hours)
* count if dup_hours > 0
* display "Number of duplicated DHSID-v007-v006 records in using data = " r(N)
* browse if dup_hours > 0
duplicates drop DHSID v007 v006, force
isid DHSID v007 v006

tempfile hours
save `hours', replace

use `master_5', clear

merge m:1 DHSID v007 v006 using `hours'

* tab _merge
keep if _merge == 1 | _merge == 3
drop _merge


*======================================================================
* 6. 补充数据6-hospital_vars.do
*======================================================================
tempfile master_6
save `master_6', replace
* 合并 hospital variables。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\hosp_vars.csv", ///
    clear varnames(1) case(preserve)

isid DHSID 

tempfile hosp_var
save `hosp_var', replace

use `master_6', clear

merge m:1 DHSID using `hosp_var'

* tab _merge
keep if _merge == 1 | _merge == 3
drop _merge


*======================================================================
* 7. 补充数据7-地形起伏urban.do
*======================================================================
tempfile master_7
save `master_7', replace
* 合并 urban 地形起伏指标。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\Tier_1_Urban_Centres_HAND_metrics.csv", ///
    clear varnames(1) case(preserve)

isid id
rename id urban_id

tempfile hosp_dem
save `hosp_dem', replace

use `master_7', clear

merge m:1 urban_id using `hosp_dem'

* tab _merge
keep if _merge == 1 | _merge == 3
drop _merge


*======================================================================
* 8. 补充数据8-重新计算catchment以及医院数量计算.do
*======================================================================
tempfile master_8
save `master_8', replace
* 合并 urban catchment 和 health facility counts。
import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\T1_urban_catchment_health_facility_counts.csv", ///
    clear varnames(1) case(preserve)

confirm variable urban_id
drop if missing(urban_id)

* duplicates report urban_id
isid urban_id

tempfile catch_hosp
save `catch_hosp', replace

use `master_8', clear

confirm variable urban_id

merge m:1 urban_id using `catch_hosp', gen(_merge_hosp)

* tab _merge_hosp
keep if inlist(_merge_hosp, 1, 3)
drop _merge_hosp

*变量重新赋值1（医院计数）
local upper ///
    uc_hosp_total uc_hosp_l0 uc_hosp_l1 uc_hosp_l2 uc_hosp_l3 ///
    patch_hosp_total patch_hosp_l0 patch_hosp_l1 patch_hosp_l2 patch_hosp_l3

local lower ///
    urban_facility_total urban_basic urban_primary urban_regional urban_national ///
    catchment_facility_total catchment_basic catchment_primary ///
    catchment_regional catchment_national

forvalues i = 1/10 {
    local var_upper : word `i' of `upper'
    local var_lower : word `i' of `lower'

    replace `var_upper' = `var_lower'
}

drop `lower'



*变量重新赋值2（urban_centres 和patchment 面积重新估算）
* ============================================================
* Standardize urban-centre and catchment area variables
* ============================================================

* 检查原始变量是否存在
confirm variable merged_catchment_area_km2
confirm variable urban_area_km2
confirm variable catchment_outside_urban_area_km2
confirm variable urban_over_merged_catchment_rati


* ------------------------------------------------------------
* 删除可能已经存在的目标变量
* ------------------------------------------------------------

capture drop patch3h_area_km2
capture drop uc_area_km2
capture drop patch3h_non_uc_area_km2
capture drop uc_mergedcatchment_area_ratio
capture drop uc_patchout_area_ratio_raw
capture drop uc_patchout_area_ratio
capture drop uc_patchout_area_pct


* ------------------------------------------------------------
* 赋值面积变量
* ------------------------------------------------------------

gen double patch3h_area_km2 = ///
    merged_catchment_area_km2

gen double uc_area_km2 = ///
    urban_area_km2

gen double patch3h_non_uc_area_km2 = ///
    catchment_outside_urban_area_km2


* ------------------------------------------------------------
* UC面积 / 整个catchment面积
* ------------------------------------------------------------

gen double uc_mergedcatchment_area_ratio = ///
    urban_over_merged_catchment_rati


* ------------------------------------------------------------
* UC面积 / catchment中UC以外面积
* ------------------------------------------------------------

gen double uc_patchout_area_ratio_raw = ///
    uc_area_km2 / patch3h_non_uc_area_km2 ///
    if patch3h_non_uc_area_km2 > 0 ///
    & !missing(uc_area_km2)

gen double uc_patchout_area_ratio = ///
    uc_patchout_area_ratio_raw

replace uc_patchout_area_ratio = . ///
    if uc_patchout_area_ratio > 1

gen double uc_patchout_area_pct = ///
    uc_patchout_area_ratio * 100


* ------------------------------------------------------------
* 添加变量标签
* ------------------------------------------------------------

label variable patch3h_area_km2 ///
    "Merged 3-hour catchment area (km2)"

label variable uc_area_km2 ///
    "Urban centre area (km2)"

label variable patch3h_non_uc_area_km2 ///
    "3-hour catchment area outside urban centre (km2)"

label variable uc_mergedcatchment_area_ratio ///
    "Urban centre area / merged catchment area"

label variable uc_patchout_area_ratio_raw ///
    "Urban centre area / patch outside UC area"

label variable uc_patchout_area_ratio ///
    "Urban centre area / patch outside UC area, values <= 1"

label variable uc_patchout_area_pct ///
    "Urban centre area / patch outside UC area (%)"


* ------------------------------------------------------------
* 删除原始变量
* ------------------------------------------------------------

drop merged_catchment_area_km2 ///
     urban_area_km2 ///
     catchment_outside_urban_area_km2 ///
     urban_over_merged_catchment_rati

local final_area_vars ///
    patch3h_area_km2 uc_area_km2 patch3h_non_uc_area_km2 ///
    uc_mergedcatchment_area_ratio ///
    uc_patchout_area_ratio_raw uc_patchout_area_ratio uc_patchout_area_pct

foreach v of local final_area_vars {
    confirm variable `v'
}


*======================================================================
* 9. 补充数据9-CRU重新处理.do
*======================================================================
tempfile master_9
save `master_9', replace
* ============================================================
* 1. 读取 CRU tmp / pre 10km buffer 数据
* ============================================================

import delimited ///
    "G:\3 city and conflict\2 merge data\处理完的数据\补充文件\DHS_CRU_tmp_pre_lag1_12m_10km_buffer.csv", ///
    clear varnames(1) case(preserve)


* ============================================================
* 2. 修改 using 数据中的基础变量名
*    year  -> hv007
*    month -> hv006
* ============================================================

rename year  hv007
rename month hv006


* ============================================================
* 3. 修改 using 数据中的 tmp / pre 变量名
* ============================================================

rename tmp_lag1m   tmp_mean_1m
rename tmp_lag2m   tmp_mean_2m
rename tmp_lag3m   tmp_mean_3m
rename tmp_lag4m   tmp_mean_4m
rename tmp_lag5m   tmp_mean_5m
rename tmp_lag6m   tmp_mean_6m
rename tmp_lag7m   tmp_mean_7m
rename tmp_lag8m   tmp_mean_8m
rename tmp_lag9m   tmp_mean_9m
rename tmp_lag10m  tmp_mean_10m
rename tmp_lag11m  tmp_mean_11m
rename tmp_lag12m  tmp_mean_12m

rename pre_lag1m   pre_mean_1m
rename pre_lag2m   pre_mean_2m
rename pre_lag3m   pre_mean_3m
rename pre_lag4m   pre_mean_4m
rename pre_lag5m   pre_mean_5m
rename pre_lag6m   pre_mean_6m
rename pre_lag7m   pre_mean_7m
rename pre_lag8m   pre_mean_8m
rename pre_lag9m   pre_mean_9m
rename pre_lag10m  pre_mean_10m
rename pre_lag11m  pre_mean_11m
rename pre_lag12m  pre_mean_12m


* ============================================================
* 4. 只保留需要合并进主数据的变量
* ============================================================

keep DHSID hv007 hv006 ///
    tmp_mean_1m tmp_mean_2m tmp_mean_3m tmp_mean_4m ///
    tmp_mean_5m tmp_mean_6m tmp_mean_7m tmp_mean_8m ///
    tmp_mean_9m tmp_mean_10m tmp_mean_11m tmp_mean_12m ///
    pre_mean_1m pre_mean_2m pre_mean_3m pre_mean_4m ///
    pre_mean_5m pre_mean_6m pre_mean_7m pre_mean_8m ///
    pre_mean_9m pre_mean_10m pre_mean_11m pre_mean_12m


* ============================================================
* 5. 检查并处理 using 数据重复
* ============================================================

duplicates report DHSID hv007 hv006

* 先删除完全重复的整行
duplicates drop

* 再检查 DHSID hv007 hv006 是否唯一
capture isid DHSID hv007 hv006

if _rc != 0 {

    di as error "注意：删除完全重复行后，DHSID hv007 hv006 仍然不唯一。"
    di as error "现在将对同一 DHSID hv007 hv006 的重复记录取均值。"

    collapse ///
        (mean) ///
        tmp_mean_1m tmp_mean_2m tmp_mean_3m tmp_mean_4m ///
        tmp_mean_5m tmp_mean_6m tmp_mean_7m tmp_mean_8m ///
        tmp_mean_9m tmp_mean_10m tmp_mean_11m tmp_mean_12m ///
        pre_mean_1m pre_mean_2m pre_mean_3m pre_mean_4m ///
        pre_mean_5m pre_mean_6m pre_mean_7m pre_mean_8m ///
        pre_mean_9m pre_mean_10m pre_mean_11m pre_mean_12m, ///
        by(DHSID hv007 hv006)
}

* 最终确认 using 数据唯一
isid DHSID hv007 hv006


* ============================================================
* 6. 保存为临时 using 数据
* ============================================================

tempfile cru_var
save `cru_var', replace


* ============================================================
* 7. 打开 DHS master 文件
* ============================================================

use `master_9', clear


* ============================================================
* 8. 删除原数据中已有的 tmp / pre 相关变量
* ============================================================

capture drop ///
    tmp_0 tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6 tmp_7 tmp_8 tmp_9 tmp_10 tmp_11 ///
    tmp_mean_1m tmp_mean_2m tmp_mean_3m tmp_mean_4m tmp_mean_5m tmp_mean_6m ///
    tmp_mean_7m tmp_mean_8m tmp_mean_9m tmp_mean_10m tmp_mean_11m tmp_mean_12m ///
    pre_0 pre_1 pre_2 pre_3 pre_4 pre_5 pre_6 pre_7 pre_8 pre_9 pre_10 pre_11 ///
    pre_mean_1m pre_mean_2m pre_mean_3m pre_mean_4m pre_mean_5m pre_mean_6m ///
    pre_mean_7m pre_mean_8m pre_mean_9m pre_mean_10m pre_mean_11m pre_mean_12m


* ============================================================
* 9. 按 DHSID + 调查年 + 调查月 合并 CRU tmp / pre 指标
*    master: KR_PR_Africa_3_4.dta
*    using : DHS_CRU_tmp_pre_lag1_12m_10km_buffer.csv
* ============================================================

merge m:1 DHSID hv007 hv006 using `cru_var'


* 查看合并结果
tab _merge


* 仅保留 master 原始记录以及成功匹配记录
* 即删除 using-only 记录
keep if _merge == 1 | _merge == 3

drop _merge


* ============================================================
* 10. 保存新文件
* ============================================================

* 合并 CRU 后仅保存最终数据。
save "$data/KR_PR_Africa_3_new.dta", replace
