*======================================================================
* Fixed-effects identification diagnostics
*
* Analytical sample:
*   283,996 child observations
*   1,777 urban centres
*
* Main exposure:
*   flood_6m_ratio_csv
*
* Baseline FE:
*   urban_id + interview year (v007) + interview month (v006)
*======================================================================

do "E:/桌面/儿童发烧-do文件/02_code/01_data_processing/1 数据前的加载_clean_global.do"

* ============================================================
**# Load Africa data
* ============================================================
use "$data/KR_PR_Africa_4.dta", clear

set more off

local flood   flood_6m_ratio_csv
local urban   urban_id
local year    v007
local month   v006

local tol = 1e-12


*======================================================================
**# 1. Define analytical exposure sample
*======================================================================

capture drop analysis_sample

gen byte analysis_sample = ///
    !missing(`flood') & ///
    !missing(`urban')

count if analysis_sample
local N_obs = r(N)

egen byte tag_urban = tag(`urban') if analysis_sample

count if tag_urban == 1
local N_urban = r(N)


di as txt ""
di as txt "Analytical observations = " ///
    as result %12.0fc `N_obs'

di as txt "Urban centres = " ///
    as result %12.0fc `N_urban'


* Expected:
* N_obs   = 283,996
* N_urban = 1,777


*======================================================================
**# 2. Check temporal variation within urban centres
*======================================================================

preserve

keep if analysis_sample


* One observation per urban centre × interview year-month
collapse ///
    (mean) flood_period = `flood', ///
    by(`urban' `year' `month')


* Number of distinct interview periods
bysort `urban': gen n_periods = _N


* Within-centre exposure range
bysort `urban': ///
    egen double flood_min = min(flood_period)

bysort `urban': ///
    egen double flood_max = max(flood_period)

gen double flood_range = ///
    flood_max - flood_min


* Indicator for actual temporal variation
gen byte flood_varies = ///
    flood_range > `tol'


* One observation per urban centre
bysort `urban': keep if _n == 1


count
local N_urban_check = r(N)


count if n_periods >= 2
local N_multi = r(N)


count if flood_varies == 1
local N_vary = r(N)


local pct_multi = ///
    100 * `N_multi' / `N_urban_check'

local pct_vary_all = ///
    100 * `N_vary' / `N_urban_check'

local pct_vary_multi = ///
    100 * `N_vary' / `N_multi'


di as txt ""
di as txt "Urban centres = " ///
    as result %8.0fc `N_urban_check'

di as txt "Centres observed in >=2 periods = " ///
    as result %8.0fc `N_multi' ///
    as txt " (" ///
    as result %5.2f `pct_multi' ///
    as txt "%)"

di as txt "Centres with temporal flood variation = " ///
    as result %8.0fc `N_vary' ///
    as txt " (" ///
    as result %5.2f `pct_vary_all' ///
    as txt "% of all centres)"

di as txt "Varying centres among multi-period centres = " ///
    as result %5.2f `pct_vary_multi' ///
    as txt "%"

restore


*======================================================================
**# 3. Residualize flood exposure using baseline fixed effects
*
* Note:
* reghdfe may automatically remove one singleton observation.
* This does not change the analytical sample definition above.
*======================================================================

capture drop fe_resid fe_sample


reghdfe `flood' ///
    if analysis_sample & ///
    !missing(`year') & ///
    !missing(`month'), ///
    absorb(`urban' `year' `month') ///
    residuals(fe_resid)


gen byte fe_sample = e(sample)


count if fe_sample
local N_fe = r(N)


di as txt ""
di as txt "Observations used for FE residualization = " ///
    as result %12.0fc `N_fe'


*======================================================================
**# 4. Raw versus residualized exposure variation
*======================================================================

quietly summarize `flood' if fe_sample

local raw_sd  = r(sd)
local raw_var = r(Var)


quietly summarize fe_resid if fe_sample

local resid_sd  = r(sd)
local resid_var = r(Var)


local sd_retained = ///
    100 * `resid_sd' / `raw_sd'

local var_retained = ///
    100 * `resid_var' / `raw_var'


di as txt ""
di as txt "Raw exposure SD = " ///
    as result %9.6f `raw_sd'

di as txt "Residualized exposure SD = " ///
    as result %9.6f `resid_sd'

di as txt "SD retained after FE = " ///
    as result %6.2f `sd_retained' ///
    as txt "%"

di as txt "Variance retained after FE = " ///
    as result %6.2f `var_retained' ///
    as txt "%"


*======================================================================
**# 5. Check consistency within urban-centre × year-month cells
*======================================================================

preserve

keep if analysis_sample

egen long interview_ym = group(`year' `month')


bysort `urban' interview_ym: ///
    egen double flood_min_uym = min(`flood')

bysort `urban' interview_ym: ///
    egen double flood_max_uym = max(`flood')

gen double flood_range_uym = ///
    flood_max_uym - flood_min_uym


egen byte tag_uym = ///
    tag(`urban' interview_ym)


count if tag_uym == 1
local N_uym = r(N)


count if ///
    tag_uym == 1 & ///
    flood_range_uym > `tol'

local N_inconsistent = r(N)


di as txt ""
di as txt "Urban-centre × year-month cells = " ///
    as result %10.0fc `N_uym'

di as txt "Cells with inconsistent exposure = " ///
    as result %10.0fc `N_inconsistent'

restore


*======================================================================
**# 6. Final publication-oriented summary
*======================================================================

di as txt ""
di as txt "============================================================"
di as txt "FIXED-EFFECT IDENTIFICATION DIAGNOSTICS"
di as txt "============================================================"


di as txt "Analytical observations              = " ///
    as result %12.0fc `N_obs'

di as txt "Urban centres                        = " ///
    as result %12.0fc `N_urban'


di as txt "Centres observed in >=2 periods      = " ///
    as result %8.0fc `N_multi' ///
    as txt " (" ///
    as result %5.2f `pct_multi' ///
    as txt "%)"


di as txt "Centres with temporal flood variation= " ///
    as result %8.0fc `N_vary' ///
    as txt " (" ///
    as result %5.2f `pct_vary_all' ///
    as txt "%)"


di as txt "Among multi-period centres           = " ///
    as result %6.2f `pct_vary_multi' ///
    as txt "%"


di as txt "FE-residualization observations      = " ///
    as result %12.0fc `N_fe'


di as txt "Raw exposure SD                      = " ///
    as result %9.6f `raw_sd'


di as txt "Residualized exposure SD             = " ///
    as result %9.6f `resid_sd'


di as txt "SD retained after FE                 = " ///
    as result %6.2f `sd_retained' ///
    as txt "%"


di as txt "Variance retained after FE           = " ///
    as result %6.2f `var_retained' ///
    as txt "%"


di as txt "Inconsistent urban × year-month cells= " ///
    as result %8.0fc `N_inconsistent'


di as txt "============================================================"