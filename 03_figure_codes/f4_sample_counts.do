*============================================================
* Sample counts by distance groups
*
* Includes:
*   Q2: 2 groups
*   Q3: 3 groups
*   Q4: 4 groups
*   Q5: 5 groups
*============================================================

clear all
set more off
set scheme s1color

capture graph set window fontface "Times New Roman"
capture graph set print  fontface "Times New Roman"

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

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

local q4_lab1 "Inside"
local q4_lab2 "0-`q4_cut2' km"
local q4_lab3 "`q4_cut2'-`q4_cut3' km"
local q4_lab4 ">`q4_cut3' km"

local q5_lab1 "Inside"
local q5_lab2 "0-`q5_cut2' km"
local q5_lab3 "`q5_cut2'-`q5_cut3' km"
local q5_lab4 "`q5_cut3'-`q5_cut4' km"
local q5_lab5 ">`q5_cut4' km"

local outdir "$fig/urban_boundary_distance"
cap mkdir "`outdir'"
cap mkdir "$fig/export-svg"

use "$data/KR_PR_Africa_4.dta", clear

capture confirm variable `distvar'
if _rc {
    di as error "变量不存在：`distvar'"
    exit 111
}

tempfile base_dhs
save `base_dhs', replace

tempfile samp_long
clear
save `samp_long', emptyok replace

*-------------------------
* Q2 sample counts
*-------------------------
use `base_dhs', clear

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

*-------------------------
* Q3 sample counts
*-------------------------
use `base_dhs', clear

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

*-------------------------
* Q4 sample counts
*-------------------------
use `base_dhs', clear

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

*-------------------------
* Q5 sample counts
*-------------------------
use `base_dhs', clear

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
replace y = 3 if dist_q5_samp == 1
replace y = 2 if dist_q5_samp == 2
replace y = 1 if dist_q5_samp == 3
replace y = 0 if dist_q5_samp == 4
replace y = -1 if dist_q5_samp == 5

gen str24 group_label = ""
replace group_label = "`q5_lab1'" if dist_q5_samp == 1
replace group_label = "`q5_lab2'" if dist_q5_samp == 2
replace group_label = "`q5_lab3'" if dist_q5_samp == 3
replace group_label = "`q5_lab4'" if dist_q5_samp == 4
replace group_label = "`q5_lab5'" if dist_q5_samp == 5

append using `samp_long'
save `samp_long', replace

*------------------------------------------------------------
* Draw sample size graph
*------------------------------------------------------------

use `samp_long', clear

gen n_label = string(N_sample, "%12.0fc")

quietly summarize N_sample, meanonly
local nmax = r(max)
local nmax2 = ceil((`nmax' * 1.00) / 10000) * 10000
if `nmax2' <= 0 {
    local nmax2 = 1
}

cap drop xpos
gen xpos = .

replace xpos = 0 if hetero_var == "dist_q2" & dist_q2_samp == 1
replace xpos = 1 if hetero_var == "dist_q2" & dist_q2_samp == 2

replace xpos = 3 if hetero_var == "dist_q3" & dist_q3_samp == 1
replace xpos = 4 if hetero_var == "dist_q3" & dist_q3_samp == 2
replace xpos = 5 if hetero_var == "dist_q3" & dist_q3_samp == 3

replace xpos = 7  if hetero_var == "dist_q4" & dist_q4_samp == 1
replace xpos = 8  if hetero_var == "dist_q4" & dist_q4_samp == 2
replace xpos = 9  if hetero_var == "dist_q4" & dist_q4_samp == 3
replace xpos = 10 if hetero_var == "dist_q4" & dist_q4_samp == 4

replace xpos = 12 if hetero_var == "dist_q5" & dist_q5_samp == 1
replace xpos = 13 if hetero_var == "dist_q5" & dist_q5_samp == 2
replace xpos = 14 if hetero_var == "dist_q5" & dist_q5_samp == 3
replace xpos = 15 if hetero_var == "dist_q5" & dist_q5_samp == 4
replace xpos = 16 if hetero_var == "dist_q5" & dist_q5_samp == 5

list hetero_var group_label dist_q2_samp dist_q3_samp dist_q4_samp dist_q5_samp ///
    N_sample if missing(xpos)

gen str40 figure_panel = "Sample size by distance groups"

twoway ///
    (bar N_sample xpos if hetero_var == "dist_q2", ///
        barwidth(0.70) ///
        fcolor("88 133 175%75") ///
        lcolor("32 82 130") ///
        lwidth(thin)) ///
    (bar N_sample xpos if hetero_var == "dist_q3", ///
        barwidth(0.70) ///
        fcolor("191 111 74%75") ///
        lcolor("142 70 39") ///
        lwidth(thin)) ///
    (bar N_sample xpos if hetero_var == "dist_q4", ///
        barwidth(0.70) ///
        fcolor("88 160 120%75") ///
        lcolor("38 105 72") ///
        lwidth(thin)) ///
    (bar N_sample xpos if hetero_var == "dist_q5", ///
        barwidth(0.70) ///
        fcolor("150 105 170%70") ///
        lcolor("102 66 125") ///
        lwidth(thin)) ///
    (scatter N_sample xpos, ///
        msymbol(none) ///
        mlabel(n_label) ///
        mlabposition(12) ///
        mlabsize(2.2) ///
        mlabcolor(gs4)), ///
    xlabel(0 "<=15 km" ///
           1 ">15 km" ///
           3 "0-5 km" ///
           4 "5-25 km" ///
           5 ">25 km" ///
           7 "Inside" ///
           8 "0-10 km" ///
           9 "10-30 km" ///
           10 ">30 km" ///
           12 "Inside" ///
           13 "0-7.5 km" ///
           14 "7.5-17.5 km" ///
           15 "17.5-35 km" ///
           16 ">35 km", ///
           angle(30) labsize(2.3) nogrid) ///
    xscale(range(-0.6 16.6)) ///
    ylabel(0(40000)`nmax2', ///
           angle(0) labsize(2.4) nogrid) ///
    yscale(range(0 `nmax2')) ///
    xtitle("") ///
    ytitle("Sample size", size(3.0) margin(r=1)) ///
    legend(order(1 "2 groups" 2 "3 groups" 3 "4 groups" 4 "5 groups") ///
           rows(1) ///
           size(3.0) ///
           position(6) ///
           ring(1) ///
           region(lcolor(white) fcolor(white)) ///
           symxsize(5) ///
           keygap(0.8)) ///
    graphregion(color(white) margin(1 1 1 1)) ///
    plotregion(color(white) lcolor(none) margin(1 1 1 1)) ///
    xsize(15) ///
    ysize(10) ///
    name(g_sample, replace)

graph save "`outdir'/Sample_size_q2_q3_q4_q5.gph", replace
