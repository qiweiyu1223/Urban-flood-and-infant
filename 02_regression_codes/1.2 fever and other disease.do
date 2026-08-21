*============================================================
* Fever and other child diseases:
* One specification per disease or symptom
*
* Purpose:
*   Examine individual-level co-occurrence between child fever
*   and other diseases or symptoms.
*
* Model:
*   fever_pct =
*       disease/symptom
*       + basic individual and household controls
*       + DHS cluster fixed effects
*
* Estimation:
*   Weighted linear probability model
*   DHS sampling weight: v005 / 1,000,000
*   Standard errors clustered by DHS cluster
*
* Interpretation:
*   The coefficient is the adjusted difference in fever
*   probability, in percentage points, between children with
*   and without the corresponding disease or symptom.
*
* Important:
*   This is a descriptive association and is not interpreted
*   as a causal effect.
*============================================================

clear all
set more off

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"


*============================================================
**# 1. Load Africa data
*============================================================

use "$data/KR_PR_Africa_4.dta", clear


*============================================================
**# 2. DHS weight and cluster identifier
*============================================================

*------------------------------------------------------------
* DHS sampling weight
*------------------------------------------------------------

capture confirm variable v005

if _rc {
    di as error "变量 v005 不存在，无法生成DHS调查权重。"
    exit 111
}

cap drop wt

gen double wt = v005 / 1000000 ///
    if !missing(v005) & v005 > 0

label variable wt "DHS sampling weight"


*------------------------------------------------------------
* DHS cluster identifier
*
* Prefer v021 because it is the standard DHS PSU variable.
* Use v001 as fallback.
* survey_group is included because cluster numbers repeat
* across DHS surveys.
*------------------------------------------------------------

cap drop cluster_id

capture confirm variable v021

if !_rc {

    egen long cluster_id = group(survey_group v021) ///
        if !missing(survey_group, v021)

}
else {

    capture confirm variable v001

    if _rc {
        di as error ///
            "变量 v021 和 v001 均不存在，无法构造DHS cluster。"
        exit 111
    }

    egen long cluster_id = group(survey_group v001) ///
        if !missing(survey_group, v001)
}

label variable cluster_id "DHS cluster identifier"


*============================================================
**# 3. Outcome variable: child fever
*
* Convert the binary outcome to 0/100 so the coefficients
* can be interpreted directly as percentage-point differences.
*============================================================

capture confirm variable ch_fever

if _rc {
    di as error "变量 ch_fever 不存在，请检查数据。"
    exit 111
}

cap drop fever_pct

gen double fever_pct = .

replace fever_pct = 100 if ch_fever == 1
replace fever_pct = 0   if ch_fever == 0

label variable fever_pct ///
    "Child fever indicator, 0/100"


* Report invalid fever codes, if any
quietly count if ///
    !missing(ch_fever) & ///
    !inlist(ch_fever, 0, 1)

if r(N) > 0 {
    di as error ///
        "警告：ch_fever中有 " r(N) ///
        " 个非0/1值，这些观测已作为缺失值处理。"
}


*============================================================
**# 4. Construct cough variable
*============================================================

cap drop cough

capture confirm variable h31

if !_rc {

    gen byte cough = .

    replace cough = 1 ///
        if inlist(h31, 1, 2)

    replace cough = 0 ///
        if h31 == 0

    label variable cough "Cough"

}
else {

    di as error ///
        "变量 h31 不存在，无法构造cough；后续将跳过cough。"
}


*============================================================
**# 5. Other disease and symptom variables
*============================================================

local candidate_disease ///
    cough ///
    ch_diar ///
    ch_ari ///
    nt_ch_any_anem ///
    nt_ch_sev_anem ///
    nt_ch_wast ///
    nt_ch_sev_wast ///
    nt_ch_underwt ///
    nt_ch_sev_underwt ///
    nt_ch_stunt ///
    nt_ch_sev_stunt


*------------------------------------------------------------
* Keep only variables that exist in the dataset.
*------------------------------------------------------------

local other_disease ""

foreach v of local candidate_disease {

    capture confirm variable `v'

    if !_rc {

        local other_disease ///
            `other_disease' `v'

    }
    else {

        di as error ///
            "变量不存在，跳过：`v'"
    }
}

if "`other_disease'" == "" {
    di as error "没有找到任何可用的疾病或症状变量。"
    exit 111
}

di as text ///
    "最终纳入分析的疾病/症状变量："

di as result ///
    "`other_disease'"


*============================================================
**# 6. Clean disease variables
*
* All disease variables must be binary:
*   0 = No
*   1 = Yes
*
* Nonmissing values other than 0 and 1 are treated as missing.
*============================================================

foreach v of local other_disease {

    quietly count if ///
        !missing(`v') & ///
        !inlist(`v', 0, 1)

    local invalid_n = r(N)

    if `invalid_n' > 0 {

        di as error ///
            "警告：`v'中有 `invalid_n' 个非0/1值，已作为缺失值处理。"

        replace `v' = . ///
            if !missing(`v') & ///
               !inlist(`v', 0, 1)
    }
}


*============================================================
**# 7. Variable labels
*============================================================

capture label variable cough ///
    "Cough"

capture label variable ch_diar ///
    "Diarrhea"

capture label variable ch_ari ///
    "ARI"

capture label variable nt_ch_any_anem ///
    "Any anemia"

capture label variable nt_ch_sev_anem ///
    "Severe anemia"

capture label variable nt_ch_wast ///
    "Wasting"

capture label variable nt_ch_sev_wast ///
    "Severe wasting"

capture label variable nt_ch_underwt ///
    "Underweight"

capture label variable nt_ch_sev_underwt ///
    "Severe underweight"

capture label variable nt_ch_stunt ///
    "Stunting"

capture label variable nt_ch_sev_stunt ///
    "Severe stunting"


*============================================================
**# 8. Parsimonious individual and household controls
*
* Included:
*   Child sex
*   Child age group
*   Birth-order group
*   Household wealth quintile
*   Maternal education
*   Maternal age
*   Household size
*
* Excluded:
*   Flood variables
*   Temperature and precipitation
*   Roads and health facilities
*   DEM and water distance
*   Other spatial and environmental variables
*============================================================

local simple_control ""


*------------------------------------------------------------
* Child sex
*------------------------------------------------------------

capture confirm variable b4

if !_rc {
    local simple_control ///
        `simple_control' i.b4
}


*------------------------------------------------------------
* Child age group
*------------------------------------------------------------

capture confirm variable agegrp

if !_rc {
    local simple_control ///
        `simple_control' ib1.agegrp
}


*------------------------------------------------------------
* Birth-order group
*------------------------------------------------------------

capture confirm variable bord_grp

if !_rc {
    local simple_control ///
        `simple_control' ib1.bord_grp
}


*------------------------------------------------------------
* Household wealth quintile
*------------------------------------------------------------

capture confirm variable v190

if !_rc {
    local simple_control ///
        `simple_control' i.v190
}


*------------------------------------------------------------
* Maternal education
*------------------------------------------------------------

capture confirm variable v106

if !_rc {
    local simple_control ///
        `simple_control' i.v106
}


*------------------------------------------------------------
* Maternal age
*------------------------------------------------------------

capture confirm variable v012

if !_rc {
    local simple_control ///
        `simple_control' c.v012
}


*------------------------------------------------------------
* Household size
*------------------------------------------------------------

capture confirm variable v136

if !_rc {
    local simple_control ///
        `simple_control' c.v136
}


di as text ///
    "本模型使用的基础控制变量："

di as result ///
    "`simple_control'"


*============================================================
**# 9. Output paths
*============================================================

cap mkdir "$fig_data/SI_fever_other_disease"
cap mkdir "$result"

local out_xls ///
    "$result/SI_fever_other_disease_one_model.xls"

capture erase "`out_xls'"


*============================================================
**# 10. Prepare result data
*============================================================

tempname posth
tempfile coef_results

postfile `posth' ///
    str32 disease ///
    str80 disease_label ///
    double estimate ///
    double se ///
    double min95 ///
    double max95 ///
    double p ///
    double N ///
    double N_cluster ///
    using `coef_results', replace


*============================================================
**# 11. Loop regressions
*
* One weighted LPM for each disease or symptom.
*============================================================

local n_success = 0

foreach y of local other_disease {

    di as text ///
        "============================================================"

    di as text ///
        "Processing: `y'"

    di as text ///
        "============================================================"


    *--------------------------------------------------------
    * Variable label
    *--------------------------------------------------------

    local ylab : variable label `y'

    if `"`ylab'"' == "" {
        local ylab "`y'"
    }


    *--------------------------------------------------------
    * Initial sample check
    *--------------------------------------------------------

    quietly count if ///
        !missing( ///
            fever_pct, ///
            `y', ///
            wt, ///
            cluster_id ///
        )

    if r(N) == 0 {

        di as error ///
            "没有可用样本，跳过：`y'"

        continue
    }


    *--------------------------------------------------------
    * Disease variable must have both 0 and 1
    *--------------------------------------------------------

    quietly levelsof `y' ///
        if !missing( ///
            fever_pct, ///
            `y', ///
            wt, ///
            cluster_id ///
        ), ///
        local(levels_y)

    local nlevels_y : word count `levels_y'

    if `nlevels_y' < 2 {

        di as error ///
            "变量没有足够变异，跳过：`y'"

        continue
    }


    *--------------------------------------------------------
    * Check whether both fever outcomes are observed
    *--------------------------------------------------------

    quietly levelsof fever_pct ///
        if !missing( ///
            fever_pct, ///
            `y', ///
            wt, ///
            cluster_id ///
        ), ///
        local(levels_fever)

    local nlevels_fever : word count `levels_fever'

    if `nlevels_fever' < 2 {

        di as error ///
            "当前样本中的fever_pct没有足够变异，跳过：`y'"

        continue
    }


    *--------------------------------------------------------
    * Main specification
    *
    * Weighted linear probability model
    * DHS cluster fixed effects
    * Standard errors clustered by DHS cluster
    *--------------------------------------------------------

    capture quietly reghdfe fever_pct ///
        `y' ///
        `simple_control' ///
        [pw = wt], ///
        absorb(cluster_id) ///
        vce(cluster cluster_id)

    if _rc {

        local regression_rc = _rc

        di as error ///
            "模型估计失败，跳过：`y'；错误代码：`regression_rc'"

        continue
    }


    *--------------------------------------------------------
    * Ensure that the disease coefficient was estimated
    *--------------------------------------------------------

    capture scalar disease_b = _b[`y']

    if _rc {

        di as error ///
            "变量 `y' 因共线性或无组内变异被删除，跳过。"

        continue
    }

    capture scalar disease_se = _se[`y']

    if _rc | missing(disease_se) | disease_se <= 0 {

        di as error ///
            "变量 `y' 的标准误无效，跳过。"

        continue
    }


    *--------------------------------------------------------
    * Confidence interval and p-value
    *--------------------------------------------------------

    scalar regression_df = e(df_r)

    if missing(regression_df) | regression_df <= 0 {

        scalar critical_value = ///
            invnormal(0.975)

        scalar disease_p = ///
            2 * (1 - normal( ///
                abs(disease_b / disease_se) ///
            ))

    }
    else {

        scalar critical_value = ///
            invttail(regression_df, 0.025)

        scalar disease_p = ///
            2 * ttail( ///
                regression_df, ///
                abs(disease_b / disease_se) ///
            )
    }

    scalar disease_lb = ///
        disease_b - critical_value * disease_se

    scalar disease_ub = ///
        disease_b + critical_value * disease_se


    *--------------------------------------------------------
    * Count clusters in the estimation sample
    *--------------------------------------------------------

    tempvar estimation_sample cluster_tag

    gen byte `estimation_sample' = e(sample)

    egen byte `cluster_tag' = tag(cluster_id) ///
        if `estimation_sample' == 1

    quietly count if `cluster_tag' == 1

    local Ncl = r(N)

    drop `estimation_sample' `cluster_tag'


    *--------------------------------------------------------
    * Store estimation sample size before running outreg2
    *--------------------------------------------------------

    local model_N = e(N)


    *--------------------------------------------------------
    * Save coefficient results
    *--------------------------------------------------------

    post `posth' ///
        ("`y'") ///
        (`"`ylab'"') ///
        (disease_b) ///
        (disease_se) ///
        (disease_lb) ///
        (disease_ub) ///
        (disease_p) ///
        (`model_N') ///
        (`Ncl')


    *--------------------------------------------------------
    * Export regression table
    *--------------------------------------------------------

    local ++n_success

    local out_option "append"

    if `n_success' == 1 {
        local out_option "replace"
    }

    outreg2 using "`out_xls'", ///
        `out_option' ///
        se ///
        nocons ///
        lab ///
        dec(3) ///
        keep(`y') ///
        addtext( ///
            Disease, "`ylab'", ///
            Model, "Weighted LPM", ///
            Cluster FE, "Yes", ///
            Basic controls, "Yes", ///
            SE clustered by, "DHS cluster", ///
            DHS weight, "Yes" ///
        )
}


postclose `posth'


*============================================================
**# 12. Check number of successful models
*============================================================

if `n_success' == 0 {

    di as error ///
        "没有任何模型成功估计。请检查疾病变量、控制变量和样本。"

    exit 2000
}

di as result ///
    "成功估计的模型数量：`n_success'"


*============================================================
**# 13. Clean and export coefficient result data
*============================================================

use `coef_results', clear

label variable disease ///
    "Disease variable"

label variable disease_label ///
    "Disease label"

label variable estimate ///
    "Adjusted difference in fever probability, percentage points"

label variable se ///
    "Cluster-robust standard error"

label variable min95 ///
    "Lower 95% confidence limit"

label variable max95 ///
    "Upper 95% confidence limit"

label variable p ///
    "P-value"

label variable N ///
    "Observations"

label variable N_cluster ///
    "DHS clusters"


*------------------------------------------------------------
* Significance indicators
*------------------------------------------------------------

gen str3 sig = ""

replace sig = "***" ///
    if p < 0.01 & !missing(p)

replace sig = "**" ///
    if p >= 0.01 & p < 0.05

replace sig = "*" ///
    if p >= 0.05 & p < 0.10


*------------------------------------------------------------
* Variable order and sorting
*------------------------------------------------------------

order ///
    disease ///
    disease_label ///
    estimate ///
    se ///
    min95 ///
    max95 ///
    p ///
    sig ///
    N ///
    N_cluster

sort estimate


*------------------------------------------------------------
* Save results
*------------------------------------------------------------

save ///
    "$fig_data/SI_fever_other_disease/fever_other_disease_one_model_results.dta", ///
    replace


*============================================================
**# 14. Completion message
*============================================================

di as result ///
    "============================================================"

di as result ///
    "分析完成。"

di as result ///
    "成功估计模型数：`n_success'"

di as result ///
    "回归表：`out_xls'"

di as result ///
    "系数数据：$fig_data/SI_fever_other_disease/fever_other_disease_one_model_results.dta"

di as result ///
    "模型：DHS加权LPM + cluster固定效应"

di as result ///
    "标准误：DHS cluster层面聚类"

di as result ///
    "============================================================"