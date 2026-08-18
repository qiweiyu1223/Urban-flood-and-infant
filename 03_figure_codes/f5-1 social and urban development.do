*******************************************************
**# 3. Plot High-Low differences only
*******************************************************

use "$fig_data/SI_panelA_SES/PanelA_SES_HighLow_difference.dta", clear


twoway ///
    (rcap min95 max95 order if p < 0.05, horizontal ///
        lcolor("145 145 145") lwidth(vthin)) ///
    (rcap min95 max95 order if p > 0.05, horizontal ///
        lcolor("195 195 195") lwidth(vthin)) ///
    (scatter order estimate if p < 0.05, ///
        msymbol(circle) ///
        msize(2.0) ///
        mcolor("76 102 150") ///
        mlcolor("76 102 150")) ///
    (scatter order estimate if p > 0.05, ///
        msymbol(circle) ///
        msize(1.8) ///
        mcolor("195 195 195") ///
        mlcolor("195 195 195")) ///
    , ///
    ylab(1(1)`=_N', valuelabel angle(0) noticks labsize(2.4)) ///
    yscale(reverse) ///
    ytitle("") ///
    xtitle("Difference in flood-exposure association: High group - Low group", size(3.1)) ///
    xline(0, lpattern(solid) lcolor("120 120 120") lwidth(vthin)) ///
    xlabel(, labsize(3.2) grid glcolor("245 245 245") glwidth(vthin)) ///
    legend(order(3 "p < 0.05" 4 "p > 0.05") ///
           cols(2) size(3) region(lcolor(none) fcolor(none))) ///
    graphregion(color(white) margin(2 2 2 2)) ///
    plotregion(color(white) margin(2 2 2 2)) ///
    bgcolor(white) ///
    title("Socioeconomic and urban-development moderators", ///
          size(3.5) color(black)) ///
    name(panelA_SES_diff, replace)

graph save "$fig/SI_panelA_SES/PanelA_SES_HighLow_difference.gph", replace
