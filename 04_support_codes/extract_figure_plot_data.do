*============================================================
* Extract plotting data for all figure do-files
*
* Source folder:
*   E:/桌面/儿童发烧-do文件/02_code/03_figure_codes
*
* Included (current filenames; 2026-08-21):
*   f1-1 flood and short health risk.do
*   f1-2 fever and other disease.do
*   f2 basline and robustness.do
*   f3 flooded hospital.do
*   f4 estimate across distance.do
*   f5 HAND_four_group_effects_plot.do
*   SI_f2 occurred and positive tertiles.do
*   SI_f3 1h_2h_3h basline and robustness.do
*   SI_f4 estimate across distance_5 groups.do
*   SI_f5 sample_counts(2,3,4,5 groups).do
*   SI_f6 social and urban development.do
*
* Excluded by design:
*   SI_f1 kdensity.do
*
* Output folder:
*   E:/桌面/儿童发烧-do文件/04_figure data
*
* This script only exports the data used for plotting. It does
* not save or export graphs.
*============================================================

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

local figdata_root "E:/桌面/儿童发烧-do文件/04_figure data"
cap mkdir "`figdata_root'"

*============================================================
**# Helper: prepare and save the 3/6/9/12-month ratio plots
*============================================================

capture program drop _save_ratio_panel
program define _save_ratio_panel
    syntax, SOURCEdir(string) OUTfile(string) FIGNAME(string) ///
        MODEL(string) MODELORDER(integer) SUBTITLE(string)

    cd "$fig_data/baseline_alternative_specification/`sourcedir'"
    openall
    do "$dofile/04_support_codes/keep parm.do"

    cap drop x
    gen x = month

    replace estimate = estimate * 100
    replace min95    = min95 * 100
    replace max95    = max95 * 100

    gen figure_name = "`figname'"
    gen model = "`model'"
    gen model_order = `modelorder'
    gen subtitle = "`subtitle'"

    keep figure_name model_order model subtitle parm month x estimate min95 max95 p
    order figure_name model_order model subtitle parm month x estimate min95 max95 p
    sort model_order month parm

    save "`outfile'", replace
end

capture program drop _prep_coef_export
program define _prep_coef_export

    cap drop estimate_plot
    cap drop min95_plot
    cap drop max95_plot

    capture confirm variable estimate_pct
    if !_rc {
        gen double estimate_plot = estimate_pct
    }
    else {
        gen double estimate_plot = estimate * 100
    }

    capture confirm variable min95_pct
    if !_rc {
        gen double min95_plot = min95_pct
    }
    else {
        gen double min95_plot = min95 * 100
    }

    capture confirm variable max95_pct
    if !_rc {
        gen double max95_plot = max95_pct
    }
    else {
        gen double max95_plot = max95 * 100
    }

    cap drop plot_window_num
    gen byte plot_window_num = .

    capture confirm numeric variable month
    if !_rc {
        replace plot_window_num = month if missing(plot_window_num) & inlist(month, 3, 6, 9, 12)
    }

    capture confirm numeric variable window_num
    if !_rc {
        replace plot_window_num = window_num if missing(plot_window_num) & inlist(window_num, 3, 6, 9, 12)
    }

    capture confirm string variable exposure_var
    if !_rc {
        replace plot_window_num = 3  if missing(plot_window_num) & strpos(exposure_var, "_3m_")  > 0
        replace plot_window_num = 6  if missing(plot_window_num) & strpos(exposure_var, "_6m_")  > 0
        replace plot_window_num = 9  if missing(plot_window_num) & strpos(exposure_var, "_9m_")  > 0
        replace plot_window_num = 12 if missing(plot_window_num) & strpos(exposure_var, "_12m_") > 0
    }

    capture confirm string variable parm
    if !_rc {
        replace plot_window_num = 3  if missing(plot_window_num) & strpos(parm, "3m")  > 0
        replace plot_window_num = 6  if missing(plot_window_num) & strpos(parm, "6m")  > 0
        replace plot_window_num = 9  if missing(plot_window_num) & strpos(parm, "9m")  > 0
        replace plot_window_num = 12 if missing(plot_window_num) & strpos(parm, "12m") > 0
    }

    capture confirm string variable window
    if !_rc {
        replace plot_window_num = 3  if missing(plot_window_num) & strpos(window, "3m")  > 0
        replace plot_window_num = 6  if missing(plot_window_num) & strpos(window, "6m")  > 0
        replace plot_window_num = 9  if missing(plot_window_num) & strpos(window, "9m")  > 0
        replace plot_window_num = 12 if missing(plot_window_num) & strpos(window, "12m") > 0
    }

    capture confirm numeric variable window
    if !_rc {
        replace plot_window_num = window if missing(plot_window_num) & inlist(window, 3, 6, 9, 12)
    }

    cap drop x
    gen x = plot_window_num

end

*============================================================
**# f1-1 flood and short health risk.do
*============================================================

local out_f1 "`figdata_root'/f1_1_short_health"
cap mkdir "`out_f1'"

cd "$fig_data/1_fever_exposure"
openall
do "$dofile/04_support_codes/keep parm.do"

keep if inlist(parm, ///
    "flood_3m_ratio_csv", ///
    "flood_6m_ratio_csv", ///
    "flood_9m_ratio_csv", ///
    "flood_12m_ratio_csv")

replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

cap drop stderr
cap drop dof
cap drop t
cap drop exp_m

gen exp_m = .
replace exp_m = 3  if parm == "flood_3m_ratio_csv"
replace exp_m = 6  if parm == "flood_6m_ratio_csv"
replace exp_m = 9  if parm == "flood_9m_ratio_csv"
replace exp_m = 12 if parm == "flood_12m_ratio_csv"

label define month_lab 3 "3" 6 "6" 9 "9" 12 "12", replace
label values exp_m month_lab

gen figure_name  = "f1_1_ratio"
gen str40 figure_panel = "3/6/9/12-month exposure"
order figure_name figure_panel exp_m parm estimate min95 max95 p
sort exp_m

save "`out_f1'/f1_1_ratio.dta", replace

cd "$fig_data/1_fever_exposure"
openall
do "$dofile/04_support_codes/keep parm.do"

replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

cap drop win
gen win = .
forvalues k = 1/12 {
    replace win = `k' if strpos(parm, "_`k'm_") > 0
}

keep if !missing(win)
sort win

gen figure_name  = "f1_1_period"
gen str40 figure_panel = "1-12-month exposure window"
order figure_name figure_panel win parm estimate min95 max95 p

save "`out_f1'/f1_1_period.dta", replace

*============================================================
**# f2 basline and robustness.do
*============================================================

local out_f2 "`figdata_root'/f2_baseline_robust"
cap mkdir "`out_f2'"

_save_ratio_panel, sourcedir("baseline") ///
    outfile("`out_f2'/main_f2a.dta") figname("main_f2a") ///
    model("Baseline") modelorder(1) subtitle("urban year month")

_save_ratio_panel, sourcedir("fe1") ///
    outfile("`out_f2'/main_f2b.dta") figname("main_f2b") ///
    model("Model 1") modelorder(2) subtitle("grid year month")

_save_ratio_panel, sourcedir("fe2") ///
    outfile("`out_f2'/main_f2c.dta") figname("main_f2c") ///
    model("Model 2") modelorder(3) subtitle("urban year × month")

_save_ratio_panel, sourcedir("fe3") ///
    outfile("`out_f2'/main_f2d.dta") figname("main_f2d") ///
    model("Model 3") modelorder(4) subtitle("country year month")

_save_ratio_panel, sourcedir("selecttime") ///
    outfile("`out_f2'/main_f2e.dta") figname("main_f2e") ///
    model("Model 4") modelorder(5) subtitle("2018–2022 sample")

_save_ratio_panel, sourcedir("DHS_flood") ///
    outfile("`out_f2'/main_f2f.dta") figname("main_f2f") ///
    model("Model 5") modelorder(6) subtitle("without local flood exposure")

_save_ratio_panel, sourcedir("extendcontrol") ///
    outfile("`out_f2'/main_f2g.dta") figname("main_f2g") ///
    model("Model 6") modelorder(7) subtitle("additional controls")

_save_ratio_panel, sourcedir("weighted_continuous_wt") ///
    outfile("`out_f2'/main_f2h.dta") figname("main_f2h") ///
    model("Model 7") modelorder(8) subtitle("controlling for survey weights")

*============================================================
**# f3 flooded hospital.do
*============================================================

local out_f3 "`figdata_root'/f3_flooded_hospital"
cap mkdir "`out_f3'"

cd "$fig_data/facilities_and_flood"
openall

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

replace estimate = estimate * 100
replace min95    = min95 * 100
replace max95    = max95 * 100

cap drop x
gen x = .
replace x = 1 if parm == "hospital_total_flood_pct_6m"
replace x = 2 if parm == "primary_flood_pct_6m"
replace x = 3 if parm == "secondary_flood_pct_6m"
replace x = 4 if parm == "water_flood_pct_6m"
replace x = 5 if parm == "school_flood_pct_6m"
replace x = 6 if parm == "road_flood_pct_6m"

label define xlabel_flood ///
    1 "All hospitals" ///
    2 "Primary hospitals" ///
    3 "Secondary hospitals" ///
    4 "Water facilities" ///
    5 "Schools" ///
    6 "Roads", replace
label values x xlabel_flood

gen figure_name = "f3_flooded_facilities"
gen panel = "Flooded facilities"
gen figure_title = "Percentage of facilities flooded"
gen str40 facility_type = ""
replace facility_type = "All health facilities"           if x == 1
replace facility_type = "Basic / non-hospital facilities"  if x == 2
replace facility_type = "Hospital facilities"              if x == 3
replace facility_type = "Water facilities"                 if x == 4
replace facility_type = "Schools"                          if x == 5
replace facility_type = "Roads"                            if x == 6

keep figure_name panel figure_title facility_type x parm estimate min95 max95 p
order figure_name panel figure_title facility_type x parm estimate min95 max95 p
sort x

save "`out_f3'/f3_flooded_facilities.dta", replace

use "$data/KR_PR_Africa_4.dta", clear

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

tempfile f3_base
save `f3_base', replace

use `f3_base', clear

collapse (sum) ///
    uc_hosp_l0 uc_hosp_l1 uc_hosp_l2 uc_hosp_l3 ///
    patch_hosp_l0 patch_hosp_l1 patch_hosp_l2 patch_hosp_l3

gen share_uc_l0 = uc_hosp_l0 / patch_hosp_l0 * 100 if patch_hosp_l0 > 0
gen share_nonuc_l0 = (patch_hosp_l0 - uc_hosp_l0) / patch_hosp_l0 * 100 if patch_hosp_l0 > 0
gen share_uc_l1 = uc_hosp_l1 / patch_hosp_l1 * 100 if patch_hosp_l1 > 0
gen share_nonuc_l1 = (patch_hosp_l1 - uc_hosp_l1) / patch_hosp_l1 * 100 if patch_hosp_l1 > 0
gen share_uc_l2 = uc_hosp_l2 / patch_hosp_l2 * 100 if patch_hosp_l2 > 0
gen share_nonuc_l2 = (patch_hosp_l2 - uc_hosp_l2) / patch_hosp_l2 * 100 if patch_hosp_l2 > 0
gen share_uc_l3 = uc_hosp_l3 / patch_hosp_l3 * 100 if patch_hosp_l3 > 0
gen share_nonuc_l3 = (patch_hosp_l3 - uc_hosp_l3) / patch_hosp_l3 * 100 if patch_hosp_l3 > 0

foreach v in share_nonuc_l0 share_nonuc_l1 share_nonuc_l2 share_nonuc_l3 {
    replace `v' = 0 if `v' < 0 & !missing(`v')
}

foreach v in share_uc_l0 share_uc_l1 share_uc_l2 share_uc_l3 {
    replace `v' = 100 if `v' > 100 & !missing(`v')
}

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
gen uc_start    = 0
gen uc_end      = share_uc
gen nonuc_start = share_uc
gen nonuc_end   = share_uc + share_nonuc
replace nonuc_end = 100 if nonuc_end > 100 & !missing(nonuc_end)

gen uc_mid    = (uc_start + uc_end) / 2
gen nonuc_mid = (nonuc_start + nonuc_end) / 2
gen uc_pct_lab    = string(share_uc, "%4.1f") + "%"
gen nonuc_pct_lab = string(share_nonuc, "%4.1f") + "%"
replace uc_pct_lab = "" if share_uc < 5
replace nonuc_pct_lab = "" if share_nonuc < 5

gen figure_name = "f3_hospital_composition"
gen panel = "Hospital composition"
gen figure_title = "Urban centre vs Patch outside urban centre hospital share"
gen str60 hospital_level = ""
replace hospital_level = "Basic / non-hospital facility" if level_order == 1
replace hospital_level = "Primary / district / general hospital" if level_order == 2
replace hospital_level = "Regional / provincial / referral hospital" if level_order == 3
replace hospital_level = "National / teaching / tertiary hospital" if level_order == 4

keep figure_name panel figure_title hospital_level level_order y ///
    share_uc share_nonuc uc_start uc_end nonuc_start nonuc_end ///
    uc_mid nonuc_mid uc_pct_lab nonuc_pct_lab
order figure_name panel figure_title hospital_level level_order y ///
    share_uc share_nonuc uc_start uc_end nonuc_start nonuc_end ///
    uc_mid nonuc_mid uc_pct_lab nonuc_pct_lab
sort level_order

save "`out_f3'/f3_hospital_composition.dta", replace

use `f3_base', clear

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

gen str32 figure_name = "f3_area_ratio"
gen str20 panel = "Area ratio"
gen str40 figure_title = "UC area / Patch outside UC area"

keep figure_name panel figure_title urban_id ///
    patch3h_area_km2 ///
    uc_area_km2 ///
    patch3h_non_uc_area_km2 ///
    uc_mergedcatchment_area_ratio ///
    uc_patchout_area_ratio_raw ///
    uc_patchout_area_ratio ///
    uc_patchout_area_pct
order figure_name panel figure_title urban_id ///
    patch3h_area_km2 uc_area_km2 patch3h_non_uc_area_km2 ///
    uc_mergedcatchment_area_ratio uc_patchout_area_ratio_raw ///
    uc_patchout_area_ratio uc_patchout_area_pct

save "`out_f3'/f3_area_ratio_raw.dta", replace

use `f3_base', clear

collapse ///
    (count) N = uc_patchout_area_pct ///
    (mean) mean = uc_patchout_area_pct ///
    (sd) sd = uc_patchout_area_pct ///
    (min) min = uc_patchout_area_pct ///
    (p25) p25 = uc_patchout_area_pct ///
    (median) median = uc_patchout_area_pct ///
    (p75) p75 = uc_patchout_area_pct ///
    (max) max = uc_patchout_area_pct

gen figure_name = "f3_area_ratio"
gen panel = "Area ratio"
gen figure_title = "UC area / Patch outside UC area boxplot summary"
gen N_total = `N_total'
gen N_invalid_area = `N_invalid_area'
gen N_gt1 = `N_gt1'
gen N_used = `N_used'
gen N_excluded = `N_excluded'

order figure_name panel figure_title N_total N_invalid_area N_gt1 ///
    N_used N_excluded N mean sd min p25 median p75 max

save "`out_f3'/f3_area_ratio_summary.dta", replace

*============================================================
**# f4 estimate across distance.do
*============================================================

local out_f4 "`figdata_root'/f4_distance"
cap mkdir "`out_f4'"

local q4_cut1 0
local q4_cut2 10
local q4_cut3 30
local q4_lab1 "Inside"
local q4_lab2 "0-`q4_cut2' km"
local q4_lab3 "`q4_cut2'-`q4_cut3' km"
local q4_lab4 ">`q4_cut3' km"
local distvar dhs_to_urban_boundary_km
local indir "$fig_data/urban_boundary_distance"

local model_dirs dist_q2 dist_q3 dist_q4
tempfile allparm
clear
save `allparm', emptyok replace

local n_read = 0
foreach d of local model_dirs {
    local f "`indir'/`d'/ratio_6m.dta"

    capture confirm file "`f'"
    if _rc {
        di as error "File not found, skipped: `f'"
        continue
    }

    use "`f'", clear

    capture confirm variable parm
    if _rc {
        di as error "File `f' has no variable parm. Skipped."
        continue
    }

    capture confirm variable estimate
    if _rc {
        di as error "File `f' has no variable estimate. Skipped."
        continue
    }

    capture drop source_dir
    capture drop source_file
    capture drop source_path
    gen source_dir  = "`d'"
    gen source_file = "ratio_6m.dta"
    gen source_path = "`f'"

    append using `allparm'
    save `allparm', replace
    local ++n_read
}

if `n_read' == 0 {
    di as error "No ratio_6m.dta files were successfully read."
    exit 601
}

use `allparm', clear

cap drop keep_parm
gen keep_parm = 0
replace keep_parm = 1 if inlist(parm, "dist2_near", "dist2_far")
replace keep_parm = 1 if inlist(parm, "dist3_near", "dist3_mid", "dist3_far")
replace keep_parm = 1 if inlist(parm, "dist4_q1", "dist4_q2", "dist4_q3", "dist4_q4")
keep if keep_parm == 1
drop keep_parm

count
if r(N) == 0 {
    di as error "No distance heterogeneity coefficients matched."
    exit 111
}

capture confirm variable min95
if _rc {
    di as error "Variable min95 does not exist."
    exit 111
}

capture confirm variable max95
if _rc {
    di as error "Variable max95 does not exist."
    exit 111
}

capture confirm variable p
if _rc {
    gen p = .
}

cap drop expected_source
cap drop source_match
cap drop any_source_match
gen str10 expected_source = ""
replace expected_source = "dist_q2" if inlist(parm, "dist2_near", "dist2_far")
replace expected_source = "dist_q3" if inlist(parm, "dist3_near", "dist3_mid", "dist3_far")
replace expected_source = "dist_q4" if inlist(parm, "dist4_q1", "dist4_q2", "dist4_q3", "dist4_q4")

gen source_match = source_dir == expected_source
bys parm: egen any_source_match = max(source_match)
keep if source_match == 1 | any_source_match == 0
bys parm source_dir: keep if _n == 1
drop source_match any_source_match

cap drop estimate_pct
cap drop min95_pct
cap drop max95_pct
gen estimate_pct = estimate * 100
gen min95_pct    = min95    * 100
gen max95_pct    = max95    * 100

cap drop hetero_var
cap drop group_order
cap drop y
gen hetero_var = source_dir
gen group_order = .
replace group_order = 1 if parm == "dist2_near"
replace group_order = 2 if parm == "dist2_far"
replace group_order = 1 if parm == "dist3_near"
replace group_order = 2 if parm == "dist3_mid"
replace group_order = 3 if parm == "dist3_far"
replace group_order = 1 if parm == "dist4_q1"
replace group_order = 2 if parm == "dist4_q2"
replace group_order = 3 if parm == "dist4_q3"
replace group_order = 4 if parm == "dist4_q4"

gen y = .
replace y = 10 if hetero_var == "dist_q2" & group_order == 1
replace y =  9 if hetero_var == "dist_q2" & group_order == 2
replace y =  7 if hetero_var == "dist_q3" & group_order == 1
replace y =  6 if hetero_var == "dist_q3" & group_order == 2
replace y =  5 if hetero_var == "dist_q3" & group_order == 3
replace y =  3 if hetero_var == "dist_q4" & group_order == 1
replace y =  2 if hetero_var == "dist_q4" & group_order == 2
replace y =  1 if hetero_var == "dist_q4" & group_order == 3
replace y =  0 if hetero_var == "dist_q4" & group_order == 4

gen figure_name = "main_f4a"
gen figure_panel = "Main distance heterogeneity"
gen str20 group_label = ""
replace group_label = "<=15 km" if hetero_var == "dist_q2" & group_order == 1
replace group_label = ">15 km"  if hetero_var == "dist_q2" & group_order == 2
replace group_label = "0-5 km"  if hetero_var == "dist_q3" & group_order == 1
replace group_label = "5-25 km" if hetero_var == "dist_q3" & group_order == 2
replace group_label = ">25 km"  if hetero_var == "dist_q3" & group_order == 3
replace group_label = "`q4_lab1'" if hetero_var == "dist_q4" & group_order == 1
replace group_label = "`q4_lab2'" if hetero_var == "dist_q4" & group_order == 2
replace group_label = "`q4_lab3'" if hetero_var == "dist_q4" & group_order == 3
replace group_label = "`q4_lab4'" if hetero_var == "dist_q4" & group_order == 4

keep figure_name figure_panel hetero_var group_order group_label y ///
    parm estimate min95 max95 p estimate_pct min95_pct max95_pct ///
    source_dir source_file source_path
order figure_name figure_panel hetero_var group_order group_label y ///
    parm estimate min95 max95 p estimate_pct min95_pct max95_pct ///
    source_dir source_file source_path
sort hetero_var group_order

save "`out_f4'/main_f4a.dta", replace

use "$data/KR_PR_Africa_4.dta", clear

capture confirm variable `distvar'
if _rc {
    di as error "变量不存在：`distvar'"
    exit 111
}

cap drop dist_q4
gen dist_q4 = .
replace dist_q4 = 1 if `distvar' == 0 & !missing(`distvar')
replace dist_q4 = 2 if `distvar' > 0  & `distvar' <= `q4_cut2' & !missing(`distvar')
replace dist_q4 = 3 if `distvar' > `q4_cut2' & `distvar' <= `q4_cut3' & !missing(`distvar')
replace dist_q4 = 4 if `distvar' > `q4_cut3' & !missing(`distvar')

label define dist4_lab ///
    1 "`q4_lab1'" ///
    2 "`q4_lab2'" ///
    3 "`q4_lab3'" ///
    4 "`q4_lab4'", replace
label values dist_q4 dist4_lab

cap drop v106_clean
capture confirm variable v106
if !_rc {
    gen v106_clean = v106
    replace v106_clean = . if !inlist(v106, 0, 1, 2, 3)
    label define edu_lab 0 "No" 1 "Primary" 2 "Secondary" 3 "Higher", replace
    label values v106_clean edu_lab
}

capture confirm variable v190
if !_rc {
    label define wealth_lab 1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest", replace
    label values v190 wealth_lab
}

cap drop large_hh
capture confirm variable v136
if !_rc {
    sum v136 if !missing(v136), detail
    gen large_hh = (v136 > r(p50)) if !missing(v136)
}

cap drop ph_wtr_improve_clean
capture confirm variable ph_wtr_improve
if !_rc {
    gen ph_wtr_improve_clean = .
    replace ph_wtr_improve_clean = 0 if ph_wtr_improve == 0
    replace ph_wtr_improve_clean = 1 if ph_wtr_improve == 1
}

cap drop long_wtr_time
capture confirm variable ph_wtr_time
if !_rc {
    sum ph_wtr_time if !missing(ph_wtr_time), detail
    gen long_wtr_time = (ph_wtr_time > r(p50)) if !missing(ph_wtr_time)
}

tempfile base_dhs
save `base_dhs', replace

use `base_dhs', clear
capture confirm variable v190
if !_rc {
    keep if !missing(dist_q4, v190)
    contract dist_q4 v190
    bys dist_q4: egen total = total(_freq)
    gen pct = 100 * _freq / total
    gen x = (dist_q4 - 1) * 6 + v190
    gen figure_name = "main_f4b"
    gen figure_panel = "Wealth distribution by dist_q4"
    gen str20 distance_group = ""
    replace distance_group = "`q4_lab1'" if dist_q4 == 1
    replace distance_group = "`q4_lab2'" if dist_q4 == 2
    replace distance_group = "`q4_lab3'" if dist_q4 == 3
    replace distance_group = "`q4_lab4'" if dist_q4 == 4
    gen str20 wealth_group = ""
    replace wealth_group = "Poorest" if v190 == 1
    replace wealth_group = "Poorer"  if v190 == 2
    replace wealth_group = "Middle"  if v190 == 3
    replace wealth_group = "Richer"  if v190 == 4
    replace wealth_group = "Richest" if v190 == 5
    order figure_name figure_panel distance_group wealth_group
    sort dist_q4 v190
    save "`out_f4'/main_f4b_wealth.dta", replace
}

use `base_dhs', clear
capture confirm variable v106_clean
if !_rc {
    keep if !missing(dist_q4, v106_clean)
    contract dist_q4 v106_clean
    bys dist_q4: egen total = total(_freq)
    gen pct = 100 * _freq / total
    gen edu_order = v106_clean + 1
    gen x = (dist_q4 - 1) * 5 + edu_order
    gen figure_name = "main_f4c"
    gen figure_panel = "Maternal education distribution by dist_q4"
    gen str20 distance_group = ""
    replace distance_group = "`q4_lab1'" if dist_q4 == 1
    replace distance_group = "`q4_lab2'" if dist_q4 == 2
    replace distance_group = "`q4_lab3'" if dist_q4 == 3
    replace distance_group = "`q4_lab4'" if dist_q4 == 4
    gen str20 education_group = ""
    replace education_group = "No education" if v106_clean == 0
    replace education_group = "Primary"      if v106_clean == 1
    replace education_group = "Secondary"    if v106_clean == 2
    replace education_group = "Higher"       if v106_clean == 3
    order figure_name figure_panel distance_group education_group
    sort dist_q4 v106_clean
    save "`out_f4'/main_f4c_education.dta", replace
}

local infra_vars ///
    ph_electric ///
    ph_wtr_improve_clean ///
    long_wtr_time ///
    large_hh

tempfile infra_long
clear
save `infra_long', emptyok replace

local n_infra = 0
use `base_dhs', clear

foreach v of local infra_vars {
    capture confirm variable `v'
    if _rc {
        di as error "变量不存在，跳过: `v'"
        continue
    }

    preserve
        keep if !missing(dist_q4, `v')
        collapse (mean) pct = `v', by(dist_q4)
        replace pct = pct * 100
        gen str40 item = "`v'"
        replace item = "Electricity" if item == "ph_electric"
        replace item = "Improved water" if item == "ph_wtr_improve_clean"
        replace item = "Long water collection" if item == "long_wtr_time"
        replace item = "Large household" if item == "large_hh"
        append using `infra_long'
        save `infra_long', replace
        local ++n_infra
    restore
}

if `n_infra' > 0 {
    use `infra_long', clear
    gen figure_name = "main_f4d"
    gen figure_panel = "Household conditions by dist_q4"
    gen str20 distance_group = ""
    replace distance_group = "`q4_lab1'" if dist_q4 == 1
    replace distance_group = "`q4_lab2'" if dist_q4 == 2
    replace distance_group = "`q4_lab3'" if dist_q4 == 3
    replace distance_group = "`q4_lab4'" if dist_q4 == 4
    order figure_name figure_panel distance_group item
    sort item dist_q4
    save "`out_f4'/main_f4d_household_conditions.dta", replace
}

use `base_dhs', clear

cap drop hosp_basic
cap drop hosp_pst
cap drop hosp_pst_miss
local hosp_plot_vars ""

capture confirm variable hosp30_l1
if !_rc {
    capture confirm variable hosp30_l2
    if !_rc {
        capture confirm variable hosp30_l3
        if !_rc {
            egen hosp_pst = rowtotal(hosp30_l1 hosp30_l2 hosp30_l3)
            egen hosp_pst_miss = rowmiss(hosp30_l1 hosp30_l2 hosp30_l3)
            replace hosp_pst = . if hosp_pst_miss == 3
        }
    }
}

capture confirm variable hosp30_l0
if !_rc {
    gen hosp_basic = hosp30_l0
}

capture confirm variable hosp_pst
if _rc {
    capture confirm variable hospital_30km_primary
    if !_rc {
        capture confirm variable hospital_30km_secondary
        if !_rc {
            capture confirm variable hospital_30km_tertiary
            if !_rc {
                egen hosp_pst = rowtotal( ///
                    hospital_30km_primary ///
                    hospital_30km_secondary ///
                    hospital_30km_tertiary)
                egen hosp_pst_miss = rowmiss( ///
                    hospital_30km_primary ///
                    hospital_30km_secondary ///
                    hospital_30km_tertiary)
                replace hosp_pst = . if hosp_pst_miss == 3
            }
        }
    }
}

capture confirm variable hosp_pst
if !_rc {
    local hosp_plot_vars "`hosp_plot_vars' hosp_pst"
}

capture confirm variable hosp_basic
if !_rc {
    local hosp_plot_vars "`hosp_plot_vars' hosp_basic"
}

if "`hosp_plot_vars'" != "" {
    tempfile hosp_long
    clear
    save `hosp_long', emptyok replace

    local n_hosp = 0
    use `base_dhs', clear

    cap drop hosp_basic
    cap drop hosp_pst
    cap drop hosp_pst_miss

    capture confirm variable hosp30_l1
    if !_rc {
        capture confirm variable hosp30_l2
        if !_rc {
            capture confirm variable hosp30_l3
            if !_rc {
                egen hosp_pst = rowtotal(hosp30_l1 hosp30_l2 hosp30_l3)
                egen hosp_pst_miss = rowmiss(hosp30_l1 hosp30_l2 hosp30_l3)
                replace hosp_pst = . if hosp_pst_miss == 3
            }
        }
    }

    capture confirm variable hosp30_l0
    if !_rc {
        gen hosp_basic = hosp30_l0
    }

    capture confirm variable hosp_pst
    if _rc {
        capture confirm variable hospital_30km_primary
        if !_rc {
            capture confirm variable hospital_30km_secondary
            if !_rc {
                capture confirm variable hospital_30km_tertiary
                if !_rc {
                    egen hosp_pst = rowtotal( ///
                        hospital_30km_primary ///
                        hospital_30km_secondary ///
                        hospital_30km_tertiary)
                    egen hosp_pst_miss = rowmiss( ///
                        hospital_30km_primary ///
                        hospital_30km_secondary ///
                        hospital_30km_tertiary)
                    replace hosp_pst = . if hosp_pst_miss == 3
                }
            }
        }
    }

    local hosp_plot_vars ""
    capture confirm variable hosp_pst
    if !_rc {
        local hosp_plot_vars "`hosp_plot_vars' hosp_pst"
    }

    capture confirm variable hosp_basic
    if !_rc {
        local hosp_plot_vars "`hosp_plot_vars' hosp_basic"
    }

    foreach v of local hosp_plot_vars {
        preserve
            keep if !missing(dist_q4, `v')
            collapse (mean) mean = `v', by(dist_q4)
            gen str40 item = "`v'"
            replace item = "Higher-level hospital" if item == "hosp_pst"
            replace item = "Basic facility" if item == "hosp_basic"
            append using `hosp_long'
            save `hosp_long', replace
            local ++n_hosp
        restore
    }

    if `n_hosp' > 0 {
        use `hosp_long', clear
        gen figure_name = "main_f4e"
        gen figure_panel = "Health-facility availability by dist_q4"
        gen str20 distance_group = ""
        replace distance_group = "`q4_lab1'" if dist_q4 == 1
        replace distance_group = "`q4_lab2'" if dist_q4 == 2
        replace distance_group = "`q4_lab3'" if dist_q4 == 3
        replace distance_group = "`q4_lab4'" if dist_q4 == 4
        gen str40 plot_label = ""
        replace plot_label = "Hospital facilities" if item == "Higher-level hospital"
        replace plot_label = "Basic / non-hospital facilities" if item == "Basic facility"
        order figure_name figure_panel distance_group item plot_label
        sort item dist_q4
        save "`out_f4'/main_f4e_health_facility.dta", replace
    }
}

*============================================================
**# SI_f2 occurred and positive tertiles.do
*============================================================

local out_f2_si "`figdata_root'/SI_f2_occurred_positive_tertiles"
cap mkdir "`out_f2_si'"

cd "$fig_data/baseline_alternative_specification/occurred"
openall
do "$dofile/04_support_codes/keep parm.do"

_prep_coef_export

gen str24 figure_name  = "SI_f2a_occurred"
gen str40 figure_panel = "Flood occurrence"
capture order figure_name figure_panel plot_window_num x parm estimate_plot min95_plot max95_plot p
sort plot_window_num parm

save "`out_f2_si'/SI_f2a_occurred.dta", replace

cd "$fig_data/baseline_alternative_specification/positive_tertiles_T1_T2"
openall

_prep_coef_export

cap drop group_value
gen byte group_value = .
replace group_value = 1 if parm == "flood_low"
replace group_value = 2 if parm == "flood_high"

cap drop group_name
gen str30 group_name = ""
replace group_name = "Low positive exposure"  if group_value == 1
replace group_name = "High positive exposure" if group_value == 2

cap drop x_low
cap drop x_high
gen double x_low  = x - 0.5 if group_value == 1
gen double x_high = x + 0.5 if group_value == 2

gen str24 figure_name  = "SI_f2b_positive"
gen str40 figure_panel = "Positive exposure intensity"
capture order figure_name figure_panel group_value group_name plot_window_num x x_low x_high ///
    parm estimate_plot min95_plot max95_plot p
sort plot_window_num group_value

save "`out_f2_si'/SI_f2b_positive_tertiles.dta", replace

tempfile si_f2_weighted
clear
save `si_f2_weighted', emptyok replace

local weight_dirs ///
    weighted_continuous_wt ///
    weighted_continuous_wt_norm ///
    weighted_continuous_wt_equal_survey

foreach d of local weight_dirs {
    cd "$fig_data/baseline_alternative_specification/`d'"
    openall

    _prep_coef_export

    cap drop weight_dir
    gen str45 weight_dir = "`d'"

    append using `si_f2_weighted'
    save `si_f2_weighted', replace
}

use `si_f2_weighted', clear

cap drop weight_order
cap drop weight_label
gen byte weight_order = .
replace weight_order = 1 if weight_dir == "weighted_continuous_wt"
replace weight_order = 2 if weight_dir == "weighted_continuous_wt_norm"
replace weight_order = 3 if weight_dir == "weighted_continuous_wt_equal_survey"

gen str24 weight_label = ""
replace weight_label = "wt"              if weight_order == 1
replace weight_label = "wt_norm"         if weight_order == 2
replace weight_label = "wt_equal_survey" if weight_order == 3

cap drop x_wt
gen double x_wt = x
replace x_wt = x - 0.7 if weight_order == 1
replace x_wt = x       if weight_order == 2
replace x_wt = x + 0.7 if weight_order == 3

gen str24 figure_name  = "SI_f2c_weighted"
gen str40 figure_panel = "Weighted continuous exposure"
capture order figure_name figure_panel weight_order weight_label weight_dir ///
    plot_window_num x x_wt parm estimate_plot min95_plot max95_plot p
sort plot_window_num weight_order

save "`out_f2_si'/SI_f2c_weighted_continuous.dta", replace

*============================================================
**# SI_f5 sample_counts(2,3,4,5 groups).do
*============================================================

local out_f4_sample "`figdata_root'/SI_f5_sample_counts"
cap mkdir "`out_f4_sample'"

local distvar dhs_to_urban_boundary_km
local q2_cut1 15
local q3_cut1 5
local q3_cut2 25
local q4_cut2 10
local q4_cut3 30
local q5_cut2 7.5
local q5_cut3 17.5
local q5_cut4 35

local q4_lab1 "Inside"
local q4_lab2 "0-`q4_cut2' km"
local q4_lab3 "`q4_cut2'-`q4_cut3' km"
local q4_lab4 ">`q4_cut3' km"

local q5_lab1 "Inside"
local q5_lab2 "0-`q5_cut2' km"
local q5_lab3 "`q5_cut2'-`q5_cut3' km"
local q5_lab4 "`q5_cut3'-`q5_cut4' km"
local q5_lab5 ">`q5_cut4' km"

use "$data/KR_PR_Africa_4.dta", clear
tempfile sample_base
save `sample_base', replace

tempfile samp_long
clear
save `samp_long', emptyok replace

use `sample_base', clear
gen dist_q2_samp = .
replace dist_q2_samp = 1 if `distvar' <= `q2_cut1' & !missing(`distvar')
replace dist_q2_samp = 2 if `distvar' >  `q2_cut1' & !missing(`distvar')
keep if !missing(dist_q2_samp)
contract dist_q2_samp, freq(N_sample)
gen str10 hetero_var = "dist_q2"
gen y = .
replace y = 16 if dist_q2_samp == 1
replace y = 15 if dist_q2_samp == 2
gen str24 group_label = ""
replace group_label = "<=15 km" if dist_q2_samp == 1
replace group_label = ">15 km"  if dist_q2_samp == 2
append using `samp_long'
save `samp_long', replace

use `sample_base', clear
gen dist_q3_samp = .
replace dist_q3_samp = 1 if `distvar' >= 0 & `distvar' <= `q3_cut1' & !missing(`distvar')
replace dist_q3_samp = 2 if `distvar' > `q3_cut1' & `distvar' <= `q3_cut2' & !missing(`distvar')
replace dist_q3_samp = 3 if `distvar' > `q3_cut2' & !missing(`distvar')
keep if !missing(dist_q3_samp)
contract dist_q3_samp, freq(N_sample)
gen str10 hetero_var = "dist_q3"
gen y = .
replace y = 13 if dist_q3_samp == 1
replace y = 12 if dist_q3_samp == 2
replace y = 11 if dist_q3_samp == 3
gen str24 group_label = ""
replace group_label = "0-5 km"  if dist_q3_samp == 1
replace group_label = "5-25 km" if dist_q3_samp == 2
replace group_label = ">25 km"  if dist_q3_samp == 3
append using `samp_long'
save `samp_long', replace

use `sample_base', clear
gen dist_q4_samp = .
replace dist_q4_samp = 1 if `distvar' == 0 & !missing(`distvar')
replace dist_q4_samp = 2 if `distvar' > 0  & `distvar' <= `q4_cut2' & !missing(`distvar')
replace dist_q4_samp = 3 if `distvar' > `q4_cut2' & `distvar' <= `q4_cut3' & !missing(`distvar')
replace dist_q4_samp = 4 if `distvar' > `q4_cut3' & !missing(`distvar')
keep if !missing(dist_q4_samp)
contract dist_q4_samp, freq(N_sample)
gen str10 hetero_var = "dist_q4"
gen y = .
replace y = 8 if dist_q4_samp == 1
replace y = 7 if dist_q4_samp == 2
replace y = 6 if dist_q4_samp == 3
replace y = 5 if dist_q4_samp == 4
gen str24 group_label = ""
replace group_label = "`q4_lab1'" if dist_q4_samp == 1
replace group_label = "`q4_lab2'" if dist_q4_samp == 2
replace group_label = "`q4_lab3'" if dist_q4_samp == 3
replace group_label = "`q4_lab4'" if dist_q4_samp == 4
append using `samp_long'
save `samp_long', replace

use `sample_base', clear
gen dist_q5_samp = .
replace dist_q5_samp = 1 if `distvar' == 0 & !missing(`distvar')
replace dist_q5_samp = 2 if `distvar' > 0 & `distvar' <= `q5_cut2' & !missing(`distvar')
replace dist_q5_samp = 3 if `distvar' > `q5_cut2' & `distvar' <= `q5_cut3' & !missing(`distvar')
replace dist_q5_samp = 4 if `distvar' > `q5_cut3' & `distvar' <= `q5_cut4' & !missing(`distvar')
replace dist_q5_samp = 5 if `distvar' > `q5_cut4' & !missing(`distvar')
keep if !missing(dist_q5_samp)
contract dist_q5_samp, freq(N_sample)
gen str10 hetero_var = "dist_q5"
gen y = .
replace y = 3  if dist_q5_samp == 1
replace y = 2  if dist_q5_samp == 2
replace y = 1  if dist_q5_samp == 3
replace y = 0  if dist_q5_samp == 4
replace y = -1 if dist_q5_samp == 5
gen str24 group_label = ""
replace group_label = "`q5_lab1'" if dist_q5_samp == 1
replace group_label = "`q5_lab2'" if dist_q5_samp == 2
replace group_label = "`q5_lab3'" if dist_q5_samp == 3
replace group_label = "`q5_lab4'" if dist_q5_samp == 4
replace group_label = "`q5_lab5'" if dist_q5_samp == 5
append using `samp_long'
save `samp_long', replace

use `samp_long', clear

gen str24 figure_name  = "SI_f5_sample_counts"
gen str40 figure_panel = "Sample size by distance groups"
gen n_label = string(N_sample, "%12.0fc")

cap drop xpos
gen xpos = .
replace xpos = 0  if hetero_var == "dist_q2" & dist_q2_samp == 1
replace xpos = 1  if hetero_var == "dist_q2" & dist_q2_samp == 2
replace xpos = 3  if hetero_var == "dist_q3" & dist_q3_samp == 1
replace xpos = 4  if hetero_var == "dist_q3" & dist_q3_samp == 2
replace xpos = 5  if hetero_var == "dist_q3" & dist_q3_samp == 3
replace xpos = 7  if hetero_var == "dist_q4" & dist_q4_samp == 1
replace xpos = 8  if hetero_var == "dist_q4" & dist_q4_samp == 2
replace xpos = 9  if hetero_var == "dist_q4" & dist_q4_samp == 3
replace xpos = 10 if hetero_var == "dist_q4" & dist_q4_samp == 4
replace xpos = 12 if hetero_var == "dist_q5" & dist_q5_samp == 1
replace xpos = 13 if hetero_var == "dist_q5" & dist_q5_samp == 2
replace xpos = 14 if hetero_var == "dist_q5" & dist_q5_samp == 3
replace xpos = 15 if hetero_var == "dist_q5" & dist_q5_samp == 4
replace xpos = 16 if hetero_var == "dist_q5" & dist_q5_samp == 5

capture order figure_name figure_panel hetero_var group_label y xpos N_sample n_label ///
    dist_q2_samp dist_q3_samp dist_q4_samp dist_q5_samp
sort hetero_var xpos

save "`out_f4_sample'/sample_counts_q2_q3_q4_q5.dta", replace

*============================================================
**# SI_f4 estimate across distance_5 groups.do
*============================================================

local out_f4_si "`figdata_root'/SI_f4_distance_5_groups"
cap mkdir "`out_f4_si'"

local distvar dhs_to_urban_boundary_km
local q5_cut2 7.5
local q5_cut3 17.5
local q5_cut4 35
local q5_lab1 "Inside"
local q5_lab2 "0-`q5_cut2' km"
local q5_lab3 "`q5_cut2'-`q5_cut3' km"
local q5_lab4 "`q5_cut3'-`q5_cut4' km"
local q5_lab5 ">`q5_cut4' km"

use "$fig_data/urban_boundary_distance/dist_q5/ratio_6m.dta", clear
keep if inlist(parm, "dist5_q1", "dist5_q2", "dist5_q3", "dist5_q4", "dist5_q5")

_prep_coef_export

gen group_order = .
replace group_order = 1 if parm == "dist5_q1"
replace group_order = 2 if parm == "dist5_q2"
replace group_order = 3 if parm == "dist5_q3"
replace group_order = 4 if parm == "dist5_q4"
replace group_order = 5 if parm == "dist5_q5"

gen y = 6 - group_order
gen str24 group_label = ""
replace group_label = "`q5_lab1'" if group_order == 1
replace group_label = "`q5_lab2'" if group_order == 2
replace group_label = "`q5_lab3'" if group_order == 3
replace group_label = "`q5_lab4'" if group_order == 4
replace group_label = "`q5_lab5'" if group_order == 5

gen str24 figure_name  = "SI_f4a_dist_q5"
gen str40 figure_panel = "Coefficient plot: dist_q5"
capture order figure_name figure_panel group_order group_label y parm ///
    estimate_plot min95_plot max95_plot p
sort group_order

save "`out_f4_si'/SI_f4a_dist_q5_coefficients.dta", replace

use "$data/KR_PR_Africa_4.dta", clear

capture drop dist_q5
gen dist_q5 = .
replace dist_q5 = 1 if `distvar' == 0 & !missing(`distvar')
replace dist_q5 = 2 if `distvar' > 0 & `distvar' <= `q5_cut2' & !missing(`distvar')
replace dist_q5 = 3 if `distvar' > `q5_cut2' & `distvar' <= `q5_cut3' & !missing(`distvar')
replace dist_q5 = 4 if `distvar' > `q5_cut3' & `distvar' <= `q5_cut4' & !missing(`distvar')
replace dist_q5 = 5 if `distvar' > `q5_cut4' & !missing(`distvar')
keep if !missing(dist_q5)

capture drop v106_clean
capture confirm variable v106
if !_rc {
    gen v106_clean = v106
    replace v106_clean = . if !inlist(v106, 0, 1, 2, 3)
}

capture drop large_hh
capture confirm variable v136
if !_rc {
    quietly summarize v136 if !missing(v136), detail
    gen large_hh = (v136 > r(p50)) if !missing(v136)
}

capture drop ph_wtr_improve_clean
capture confirm variable ph_wtr_improve
if !_rc {
    gen ph_wtr_improve_clean = .
    replace ph_wtr_improve_clean = 0 if ph_wtr_improve == 0
    replace ph_wtr_improve_clean = 1 if ph_wtr_improve == 1
}

capture drop long_wtr_time
capture confirm variable ph_wtr_time
if !_rc {
    quietly summarize ph_wtr_time if !missing(ph_wtr_time), detail
    gen long_wtr_time = (ph_wtr_time > r(p50)) if !missing(ph_wtr_time)
}

tempfile f4si_base
save `f4si_base', replace

use `f4si_base', clear
capture confirm variable v190
if !_rc {
    keep if !missing(dist_q5, v190)
    contract dist_q5 v190
    bysort dist_q5: egen total = total(_freq)
    gen pct = 100 * _freq / total
    gen x = (dist_q5 - 1) * 6 + v190
    gen str24 distance_group = ""
    replace distance_group = "`q5_lab1'" if dist_q5 == 1
    replace distance_group = "`q5_lab2'" if dist_q5 == 2
    replace distance_group = "`q5_lab3'" if dist_q5 == 3
    replace distance_group = "`q5_lab4'" if dist_q5 == 4
    replace distance_group = "`q5_lab5'" if dist_q5 == 5
    gen str24 wealth_group = ""
    replace wealth_group = "Poorest" if v190 == 1
    replace wealth_group = "Poorer"  if v190 == 2
    replace wealth_group = "Middle"  if v190 == 3
    replace wealth_group = "Richer"  if v190 == 4
    replace wealth_group = "Richest" if v190 == 5
    gen str24 figure_name  = "SI_f4b_wealth"
    gen str40 figure_panel = "Wealth distribution by dist_q5"
    capture order figure_name figure_panel dist_q5 distance_group v190 wealth_group x _freq total pct
    sort dist_q5 v190
    save "`out_f4_si'/SI_f4b_wealth_distribution.dta", replace
}

use `f4si_base', clear
capture confirm variable v106_clean
if !_rc {
    keep if !missing(dist_q5, v106_clean)
    contract dist_q5 v106_clean
    bysort dist_q5: egen total = total(_freq)
    gen pct = 100 * _freq / total
    gen edu_order = v106_clean + 1
    gen x = (dist_q5 - 1) * 5 + edu_order
    gen str24 distance_group = ""
    replace distance_group = "`q5_lab1'" if dist_q5 == 1
    replace distance_group = "`q5_lab2'" if dist_q5 == 2
    replace distance_group = "`q5_lab3'" if dist_q5 == 3
    replace distance_group = "`q5_lab4'" if dist_q5 == 4
    replace distance_group = "`q5_lab5'" if dist_q5 == 5
    gen str24 education_group = ""
    replace education_group = "No education" if v106_clean == 0
    replace education_group = "Primary"      if v106_clean == 1
    replace education_group = "Secondary"    if v106_clean == 2
    replace education_group = "Higher"       if v106_clean == 3
    gen str24 figure_name  = "SI_f4c_education"
    gen str40 figure_panel = "Maternal education by dist_q5"
    capture order figure_name figure_panel dist_q5 distance_group v106_clean education_group edu_order x _freq total pct
    sort dist_q5 v106_clean
    save "`out_f4_si'/SI_f4c_maternal_education.dta", replace
}

use `f4si_base', clear
tempfile f4si_infra
clear
save `f4si_infra', emptyok replace

use `f4si_base', clear
local infra_vars ///
    ph_electric ///
    ph_wtr_improve_clean ///
    long_wtr_time ///
    large_hh

foreach v of local infra_vars {
    capture confirm variable `v'
    if !_rc {
        preserve
            keep if !missing(dist_q5, `v')
            collapse (mean) pct = `v', by(dist_q5)
            replace pct = pct * 100
            gen str40 item = "`v'"
            replace item = "Electricity"            if item == "ph_electric"
            replace item = "Improved water"         if item == "ph_wtr_improve_clean"
            replace item = "Long water collection"  if item == "long_wtr_time"
            replace item = "Large household"        if item == "large_hh"
            append using `f4si_infra'
            save `f4si_infra', replace
        restore
    }
}

use `f4si_infra', clear
capture confirm variable dist_q5
if !_rc {
    gen str24 distance_group = ""
    replace distance_group = "`q5_lab1'" if dist_q5 == 1
    replace distance_group = "`q5_lab2'" if dist_q5 == 2
    replace distance_group = "`q5_lab3'" if dist_q5 == 3
    replace distance_group = "`q5_lab4'" if dist_q5 == 4
    replace distance_group = "`q5_lab5'" if dist_q5 == 5
    gen str24 figure_name  = "SI_f4d_conditions"
    gen str40 figure_panel = "Household and facility conditions"
    capture order figure_name figure_panel dist_q5 distance_group item pct
    sort item dist_q5
    save "`out_f4_si'/SI_f4d_household_facility_conditions.dta", replace
}

use `f4si_base', clear

capture drop hosp_basic
capture drop hosp_pst
capture drop hosp_pst_miss

capture confirm variable hosp30_l0
if !_rc {
    gen hosp_basic = hosp30_l0
}

capture confirm variable hosp30_l1
if !_rc {
    capture confirm variable hosp30_l2
    if !_rc {
        capture confirm variable hosp30_l3
        if !_rc {
            egen hosp_pst = rowtotal(hosp30_l1 hosp30_l2 hosp30_l3)
            egen hosp_pst_miss = rowmiss(hosp30_l1 hosp30_l2 hosp30_l3)
            replace hosp_pst = . if hosp_pst_miss == 3
        }
    }
}

capture confirm variable hosp_pst
if _rc {
    capture confirm variable hospital_30km_primary
    if !_rc {
        capture confirm variable hospital_30km_secondary
        if !_rc {
            capture confirm variable hospital_30km_tertiary
            if !_rc {
                egen hosp_pst = rowtotal( ///
                    hospital_30km_primary ///
                    hospital_30km_secondary ///
                    hospital_30km_tertiary)
                egen hosp_pst_miss = rowmiss( ///
                    hospital_30km_primary ///
                    hospital_30km_secondary ///
                    hospital_30km_tertiary)
                replace hosp_pst = . if hosp_pst_miss == 3
            }
        }
    }
}

tempfile f4si_hosp_base
save `f4si_hosp_base', replace

tempfile f4si_hosp
clear
save `f4si_hosp', emptyok replace

use `f4si_hosp_base', clear
capture confirm variable hosp_pst
if !_rc {
    preserve
        keep if !missing(dist_q5, hosp_pst)
        collapse (mean) mean = hosp_pst, by(dist_q5)
        gen str40 item = "Higher-level hospital"
        append using `f4si_hosp'
        save `f4si_hosp', replace
    restore
}

capture confirm variable hosp_basic
if !_rc {
    preserve
        keep if !missing(dist_q5, hosp_basic)
        collapse (mean) mean = hosp_basic, by(dist_q5)
        gen str40 item = "Basic facility"
        append using `f4si_hosp'
        save `f4si_hosp', replace
    restore
}

use `f4si_hosp', clear
capture confirm variable dist_q5
if !_rc {
    gen str24 distance_group = ""
    replace distance_group = "`q5_lab1'" if dist_q5 == 1
    replace distance_group = "`q5_lab2'" if dist_q5 == 2
    replace distance_group = "`q5_lab3'" if dist_q5 == 3
    replace distance_group = "`q5_lab4'" if dist_q5 == 4
    replace distance_group = "`q5_lab5'" if dist_q5 == 5
    gen str24 figure_name  = "SI_f4e_hospital"
    gen str40 figure_panel = "Hospital accessibility by dist_q5"
    capture order figure_name figure_panel dist_q5 distance_group item mean
    sort item dist_q5
    save "`out_f4_si'/SI_f4e_hospital_accessibility.dta", replace
}

*============================================================
**# SI_f6 social and urban development.do
*============================================================

local out_f5_1 "`figdata_root'/SI_f6_social_urban"
cap mkdir "`out_f5_1'"

use "$fig_data/SI_panelA_SES/PanelA_SES_HighLow_difference.dta", clear

cap drop plot_group
gen str10 plot_group = ""
replace plot_group = "p<0.05" if p < 0.05
replace plot_group = "p>0.05" if p > 0.05 & !missing(p)
keep if plot_group != ""

gen figure_name  = "SI_f6"
gen figure_title = "Socioeconomic and urban-development moderators"
gen x_axis       = "Difference in flood effect: High group - Low group"

cap drop moderator_label
capture decode order, gen(moderator_label)
if _rc {
    capture confirm numeric variable order
    if !_rc {
        gen str20 moderator_label = string(order)
    }
    else {
        gen str40 moderator_label = order
    }
}

order figure_name figure_title x_axis ///
    order moderator_label plot_group estimate min95 max95 p sig5 sig10 nonsig

save "`out_f5_1'/SI_f6_social_urban.dta", replace

*============================================================
**# f5 HAND_four_group_effects_plot.do
*============================================================

local out_f5_2 "`figdata_root'/f5_HAND_groups"
cap mkdir "`out_f5_2'"

local resultdir "E:/桌面/儿童发烧-do文件/04_parmest data/mapped_water_HAND_four_group"

capture confirm file "`resultdir'/HAND_four_group_effects_long.dta"
if _rc {
    di as error "Missing input: `resultdir'/HAND_four_group_effects_long.dta"
    exit 601
}

use "`resultdir'/HAND_four_group_effects_long.dta", clear

capture drop metric_order
capture drop group_order
capture drop estimate_pct
capture drop min95_pct
capture drop max95_pct

gen byte metric_order = .
replace metric_order = 1 if hand_metric == "hand_mean"
replace metric_order = 2 if hand_metric == "hand_median"
replace metric_order = 3 if hand_metric == "hand_p10"
replace metric_order = 4 if hand_metric == "hand_lt5_ratio"

label define metric_order_lab ///
    1 "Mean HAND" ///
    2 "Median HAND" ///
    3 "P10 HAND" ///
    4 "Share of HAND < 5 m", replace
label values metric_order metric_order_lab

gen byte group_order = .
replace group_order = 1 if group_code == "has_water_low"
replace group_order = 2 if group_code == "no_water_low"
replace group_order = 3 if group_code == "has_water_notlow"
replace group_order = 4 if group_code == "no_water_notlow"

label define group_order_lab ///
    1 "Mapped water and low-lying" ///
    2 "No mapped water and low-lying" ///
    3 "Mapped water and not low-lying" ///
    4 "No Mapped water and not low-lying", replace
label values group_order group_order_lab

assert !missing(metric_order)
assert !missing(group_order)

gen double estimate_pct = estimate * 100
gen double min95_pct    = min95 * 100
gen double max95_pct    = max95 * 100

gen figure_name = "f5_HAND_four_groups"
gen str40 figure_panel = ""
replace figure_panel = "Mapped water and low-lying" if group_order == 1
replace figure_panel = "No mapped water and low-lying" if group_order == 2
replace figure_panel = "Mapped water and not low-lying" if group_order == 3
replace figure_panel = "No Mapped water and not low-lying" if group_order == 4

order figure_name figure_panel metric_order group_order ///
    hand_metric group_code estimate min95 max95 estimate_pct min95_pct max95_pct
sort group_order metric_order

save "`out_f5_2'/f5_HAND_four_groups_all.dta", replace

preserve
    keep if group_order == 1
    save "`out_f5_2'/f5_has_water_low.dta", replace
restore

preserve
    keep if group_order == 2
    save "`out_f5_2'/f5_no_water_low.dta", replace
restore

preserve
    keep if group_order == 3
    save "`out_f5_2'/f5_has_water_notlow.dta", replace
restore

preserve
    keep if group_order == 4
    save "`out_f5_2'/f5_no_water_notlow.dta", replace
restore

*============================================================
**# f1-2 fever and other disease.do
*============================================================

local out_si_f1 "`figdata_root'/f1_2_other_disease"
cap mkdir "`out_si_f1'"

use "$fig_data/SI_fever_other_disease/fever_other_disease_one_model_results.dta", clear

capture confirm variable parm
if _rc {
    capture confirm variable disease
    if !_rc {
        rename disease parm
    }
}

capture confirm variable parm
if _rc {
    di as error "当前数据中既没有parm，也没有disease，无法导出绘图数据。"
    exit 111
}

foreach v in estimate min95 max95 {
    capture confirm variable `v'
    if _rc {
        di as error "缺少`v'变量。"
        exit 111
    }
}

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
    1  "Severe stunting", replace
label values y disease_lab

gen byte group_id = .
replace group_id = 1 if inlist(y, 9, 10, 11)
replace group_id = 2 if inlist(y, 7, 8)
replace group_id = 3 if inlist(y, 5, 6)
replace group_id = 4 if inlist(y, 3, 4)
replace group_id = 5 if inlist(y, 1, 2)

label define group_lab ///
    1 "Acute symptoms" ///
    2 "Anemia" ///
    3 "Wasting" ///
    4 "Underweight" ///
    5 "Stunting", replace
label values group_id group_lab

drop if missing(y)
drop if missing(estimate, min95, max95)

gen figure_name = "f1_2"
gen str50 figure_panel = "Fever and other diseases or symptoms"

order figure_name figure_panel group_id y parm estimate min95 max95
gsort -y

save "`out_si_f1'/f1_2_other_disease.dta", replace

*============================================================
**# SI_f3 1h_2h_3h basline and robustness.do
*============================================================

local out_si_fsup "`figdata_root'/SI_f3_hours"
cap mkdir "`out_si_fsup'"

_save_ratio_panel, sourcedir("baseline") ///
    outfile("`out_si_fsup'/SI_f3_3h_baseline.dta") ///
    figname("SI_f3_3h") model("3h catchment") modelorder(1) ///
    subtitle("baseline")

_save_ratio_panel, sourcedir("hours_compare_2h") ///
    outfile("`out_si_fsup'/SI_f3_2h.dta") ///
    figname("SI_f3_2h") model("2h catchment") modelorder(2) ///
    subtitle("2h catchment")

_save_ratio_panel, sourcedir("hours_compare_1h") ///
    outfile("`out_si_fsup'/SI_f3_1h.dta") ///
    figname("SI_f3_1h") model("1h catchment") modelorder(3) ///
    subtitle("1h catchment")

di as result "Done. Figure plotting data exported to: `figdata_root'"
