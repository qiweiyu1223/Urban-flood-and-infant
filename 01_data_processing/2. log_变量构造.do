* ============================================================
* 预设置
* ============================================================
clear all
set mem 700m
set mat 2000
set maxvar 10000
set level 95, perm
set more off
do "G:/3 city and conflict/3 experiment/1 stata_code/4. 儿童发烧/预处理/1 数据前的加载_clean_global.do"
* ============================================================
* 全局变量
* ============================================================
global dir "G:/3 city and conflict"
global dofile "$dir/3 experiment/1 stata_code"
global data "$dir/2 merge data"
global fig "$dir/3 experiment/4 figure"
global fig_data "$dir/3 experiment/5 figure data"
global result "$dir/3 experiment/6 result or table"

use "$data/KR_PR_Africa_3_new.dta", clear

rename hospital_total_flooded_count_3m  hosp_flood_3m
rename hospital_total_flooded_count_6m  hosp_flood_6m
rename hospital_total_flooded_count_9m  hosp_flood_9m
rename hospital_total_flooded_count_12m hosp_flood_12m
rename primary_flooded_count_3m  pri_flood_3m
rename primary_flooded_count_6m  pri_flood_6m
rename primary_flooded_count_9m  pri_flood_9m
rename primary_flooded_count_12m pri_flood_12m
rename secondary_flooded_count_6m sec_flood_6m
rename tertiary_flooded_count_6m ter_flood_6m
* ============================================================
* 数据预处理
* ============================================================
* 1.变量log以及其他处理
local flood_d_a flood_1m_area flood_2m_area flood_3m_area flood_4m_area flood_5m_area flood_6m_area flood_7m_area flood_8m_area flood_9m_area flood_10m_area flood_11m_area flood_12m_area ///
flood_3m_days flood_6m_days flood_9m_days flood_12m_days road_total_length_m ///
			 flood_3m_area_csv flood_6m_area_csv flood_9m_area_csv flood_12m_area_csv ///
			 flood_3m_days_csv flood_6m_days_csv flood_9m_days_csv flood_12m_days_csv ///
			 water_flooded_count_3m water_flooded_count_6m  law_flooded_count_3m ///
			 law_flooded_count_6m commerce_flooded_count_3m commerce_flooded_count_6m ///
			 school_flooded_count_3m school_flooded_count_6m hosp_flood_6m pri_flood_6m ///
			 sec_flood_6m ter_flood_6m flood_3m_area_T1_1h flood_6m_area_T1_1h flood_9m_area_T1_1h flood_12m_area_T1_1h flood_3m_area_T1_2h flood_6m_area_T1_2h flood_9m_area_T1_2h flood_12m_area_T1_2h flood_3m_area_T1_3h flood_6m_area_T1_3h flood_9m_area_T1_3h flood_12m_area_T1_3h ///
			 flood_3m_days_T1_1h flood_6m_days_T1_1h flood_9m_days_T1_1h flood_12m_days_T1_1h flood_3m_days_T1_2h flood_6m_days_T1_2h flood_9m_days_T1_2h flood_12m_days_T1_2h flood_3m_days_T1_3h flood_6m_days_T1_3h flood_9m_days_T1_3h flood_12m_days_T1_3h
			 
			 

foreach v of local flood_d_a {
	gen log1_`v'=log(`v'+1)
	gen log01_`v'=log(`v'+0.1)
	gen log001_`v'=log(`v'+0.001) 
	gen arc_`v'= ln(`v'+ sqrt(`v'^2 + 1))
	gen leps_`v' = ln(`v' + 0.01)
}

cap drop cough
gen cough = .
replace cough = 1 if h31 == 1 | h31 == 2
replace cough = 0 if h31 == 0



* 城市医疗设施数量
capture drop log1_city_hf_total
gen log1_city_hf_total = ln(1 + city_hf_total) ///
    if !missing(city_hf_total)

* DHS 到城市边界距离，单位已经是 km
capture drop log1_dhs_to_urban_boundary_km
gen log1_dhs_to_urban_boundary_km = ln(1 + dhs_to_urban_boundary_km) ///
    if !missing(dhs_to_urban_boundary_km)

* 距水体距离：先从 m 转成 km，再取 log
capture drop water_distance_km
gen water_distance_km = WATER_distance_m / 1000 ///
    if !missing(WATER_distance_m)

capture drop log1_water_distance_km
gen log1_water_distance_km = ln(1 + water_distance_km) ///
    if !missing(water_distance_km)

* 取水时间：如果 ph_wtr_time 是分钟，且没有特殊异常编码，可以这样处理
capture drop log1_ph_wtr_time
gen log1_ph_wtr_time = ln(1 + ph_wtr_time) ///
    if !missing(ph_wtr_time) & ph_wtr_time >= 0


* ============================================================
* 儿童年龄组
* ============================================================

gen agegrp = .
replace agegrp = 1 if b8 >= 0  & b8 <= 5
replace agegrp = 2 if b8 >= 6  & b8 <= 11
replace agegrp = 3 if b8 >= 12 & b8 <= 23
replace agegrp = 4 if b8 >= 24 & b8 <= 35
replace agegrp = 5 if b8 >= 36 & b8 <= 47
replace agegrp = 6 if b8 >= 48 & b8 <= 59

label define agegrp ///
    1 "0-5 months" ///
    2 "6-11 months" ///
    3 "12-23 months" ///
    4 "24-35 months" ///
    5 "36-47 months" ///
    6 "48-59 months", replace

label values agegrp agegrp


// * ============================================================
// * 假设 tmp_0/pre_0 是调查前最近一个月
// * 生成前 1-12 月气温、降水均值
// * ============================================================
//
// forvalues w = 1/12 {
//
//     local tmp_vars
//     local pre_vars
//
//     forvalues j = 0/`=`w'-1' {
//         local tmp_vars `tmp_vars' tmp_`j'
//         local pre_vars `pre_vars' pre_`j'
//     }
//
//     egen tmp_mean_`w'm = rowmean(`tmp_vars')
//     egen pre_mean_`w'm = rowmean(`pre_vars')
// }
//

* ============================================================
* 出生顺序分组
* bord = birth order number
* ============================================================

capture drop bord_grp

gen bord_grp = .
replace bord_grp = 1 if bord == 1
replace bord_grp = 2 if bord == 2
replace bord_grp = 3 if bord == 3
replace bord_grp = 4 if bord >= 4 & !missing(bord)

label define bord_grp ///
    1 "1st birth" ///
    2 "2nd birth" ///
    3 "3rd birth" ///
    4 "4th+ birth", replace

label values bord_grp bord_grp

tab bord_grp, missing


* ============================================================
* time 2017-2023, 2018-2022
* ============================================================
gen sur_time=.
replace sur_time=1 if v007>2017 & v007<2023
replace sur_time=0 if v007==2017 | v007==2023


gen SHAPE_area_km2 = SHAPE_area_m2 / 1000000 if !missing(SHAPE_area_m2)

label variable SHAPE_area_km2 "City area, km2"

* ============================================================
* 用城市面积 km2 标准化洪水面积
* flood_area / city_area
* ============================================================

foreach w in 3 6 9 12 {

    capture drop flood_`w'm_area_ratio_km2

    gen flood_`w'm_area_ratio_km2 = flood_`w'm_area / SHAPE_area_km2 ///
        if !missing(flood_`w'm_area, SHAPE_area_km2) & SHAPE_area_km2 > 0

    label variable flood_`w'm_area_ratio_km2 ///
        "Flood area normalized by city area, `w'-month window"
// 	drop if flood_`w'm_area_ratio_km2>1
	
}

gen west_africa = .
replace west_africa = 1 if ///
    inlist(c_name, ///
        "senegal-and-gambia","burkina-faso","benin","guinea","mali","nigeria", ///
        "sierra-leone","ghana","liberia") ///
    | inlist(c_name, ///
        "mauritania","niger","ivory-coast","togo")

replace west_africa = 0 if ///
    inlist(c_name, ///
        "malawi","tanzania","uganda","ethiopia","rwanda","kenya","madagascar") ///
    | inlist(c_name, ///
        "cameroon","gabon","zambia","mozambique")

	
label define west_africa 0 "Non–West Africa" 1 "West Africa"
label values west_africa west_africa

*------------------------------------------------------------
* Clean urban/rural residence variable
* v025: type of place of residence
* Usually: 1 = Urban, 2 = Rural
* Other codes such as 3 are set to missing
*------------------------------------------------------------

capture drop residence_ur

gen residence_ur = .
replace residence_ur = 0 if v025 == 1
replace residence_ur = 1 if v025 == 2

label define residence_ur_lab ///
    0 "Urban" ///
    1 "Rural", replace

label values residence_ur residence_ur_lab

tab v025 residence_ur, missing
tab residence_ur, missing


save "$data/KR_PR_Africa_4.dta", replace