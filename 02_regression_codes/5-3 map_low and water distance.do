*============================================================
* Generate near_water, low_city, and water_lowcity_cat
* Keep only T1_id_3h, DHSID, and constructed variables
*============================================================

*------------------------------------------------------------
**# 0. Load data and output folder
*------------------------------------------------------------
do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

use "$data/KR_PR_Africa_4.dta", clear

global outdir "G:\3 city and conflict\6 map\初始文件\原始dta-提取四个low-water变量"

*------------------------------------------------------------
**# 1. Check required variables
*------------------------------------------------------------

foreach v in DHSID T1_id_3h WATER_distance_m DEM_city_minus_buffer_mean {
    capture confirm variable `v'
    if _rc {
        di as error "Required variable `v' does not exist."
        exit 111
    }
}

*============================================================
**# 2. Construct near_water
*============================================================

* Smaller WATER_distance_m means the location is closer to water.
* near_water = 1 if WATER_distance_m <= median
* near_water = 0 if WATER_distance_m > median

cap drop p50_water_distance near_water

quietly summarize WATER_distance_m if !missing(WATER_distance_m), detail
local p50_water_distance = r(p50)

gen near_water = .
replace near_water = 0 if !missing(WATER_distance_m)
replace near_water = 1 if WATER_distance_m <= `p50_water_distance' ///
    & !missing(WATER_distance_m)

label define near_water_lab ///
    0 "Far from water" ///
    1 "Near water", replace

label values near_water near_water_lab
label var near_water "Near water, based on median WATER_distance_m"

di as result "Median WATER_distance_m = `p50_water_distance'"
tab near_water, missing

*============================================================
**# 3. Construct low_city
*============================================================

* DEM_city_minus_buffer_mean = city elevation - buffer elevation
* low_city = 1 if urban centre is lower than surrounding buffer

cap drop low_city

gen low_city = .
replace low_city = 0 if !missing(DEM_city_minus_buffer_mean)
replace low_city = 1 if DEM_city_minus_buffer_mean < 0 ///
    & !missing(DEM_city_minus_buffer_mean)

label define low_city_lab ///
    0 "City not lower than buffer" ///
    1 "City lower than buffer", replace

label values low_city low_city_lab
label var low_city "Urban centre lower than surrounding buffer"

tab low_city, missing

*============================================================
**# 4. Construct water_lowcity_cat
*============================================================

cap drop water_lowcity_cat

gen water_lowcity_cat = .
replace water_lowcity_cat = 0 if near_water == 0 & low_city == 0
replace water_lowcity_cat = 1 if near_water == 1 & low_city == 0
replace water_lowcity_cat = 2 if near_water == 0 & low_city == 1
replace water_lowcity_cat = 3 if near_water == 1 & low_city == 1

label define water_lowcity_cat_lab ///
    0 "Cat0: Far water + not low-lying" ///
    1 "Cat1: Near water + not low-lying" ///
    2 "Cat2: Far water + low-lying" ///
    3 "Cat3: Near water + low-lying", replace

label values water_lowcity_cat water_lowcity_cat_lab
label var water_lowcity_cat "Near water x low-lying urban centre type"

tab water_lowcity_cat, missing
tab near_water low_city, missing

*============================================================
**# 5. Keep only required variables and export
*============================================================

keep T1_id_3h DHSID low_city near_water water_lowcity_cat

order T1_id_3h DHSID low_city near_water water_lowcity_cat

duplicates report T1_id_3h DHSID

save "$outdir/DHS_T1_3h_near_water_low_city.dta", replace

export delimited using ///
    "$outdir/DHS_T1_3h_near_water_low_city.csv", ///
    replace nolabel

di as result "Output saved:"
di as result "$outdir/DHS_T1_3h_near_water_low_city.dta"
di as result "$outdir/DHS_T1_3h_near_water_low_city.csv"
