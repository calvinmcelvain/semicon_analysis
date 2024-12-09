clear all

* Setting working dir.
capture cd "C:\Users\mcelvain\OneDrive - University of Iowa\ms_26\ui_24f\ECON_5810\vsp\semicon_analysis"

***** Depdencies *****
* ssc install esttab, replace


*=========================
*  Heterogenous Effects
*=========================


*--------------------
*   Placebo check
*--------------------


* Importing
use "data/trim/annual.dta", clear

* Making set plecebos of pre-policy periods
gen plecebo1 = (year > 2013 & year < 2019)
gen plecebo2 = (year > 2014 & year < 2019)
gen plecebo3 = (year > 2015 & year < 2019)
local plecebos plecebo1 plecebo2 plecebo3

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Estimation
foreach plecebo in `plecebos' {
	foreach model in `models' {
		quietly xtlsdvc `model' `plecebo' `expl_vars' dff lgexp, i(ab) b(1) v(200)
		estimates store `model'_`plecebo'ab
		quietly predict fit_`model'_`plecebo'ab, xb
		quietly predict ep_`model'_`plecebo'ab, e
		
		quietly xtlsdvc `model' `plecebo' `expl_vars' dff lgexp, i(bb) b(1) v(200)
		estimates store `model'_`plecebo'bb
		quietly predict fit_`model'_`plecebo'bb, xb
		quietly predict ep_`model'_`plecebo'bb, e
	}
	
	quietly esttab lgemp_`plecebo'ab lgcapx_`plecebo'ab lgxrd_`plecebo'ab lgxrdint_`plecebo'ab eqr_`plecebo'ab using `"output/estimates/models_`plecebo'ab.txt"', replace ///
	se star(* 0.1 ** 0.05 *** 0.01) ///
	label
	quietly esttab lgemp_`plecebo'ab lgcapx_`plecebo'ab lgxrd_`plecebo'ab lgxrdint_`plecebo'ab eqr_`plecebo'ab using `"output/estimates/models_`plecebo'ab.tex"', replace ///
	se star(* 0.1 ** 0.05 *** 0.01) ///
	label
	
	quietly esttab lgemp_`plecebo'bb lgcapx_`plecebo'bb lgxrd_`plecebo'bb lgxrdint_`plecebo'bb eqr_`plecebo'bb using `"output/estimates/models_`plecebo'bb.txt"', replace ///
	se star(* 0.1 ** 0.05 *** 0.01) ///
	label
	quietly esttab lgemp_`plecebo'bb lgcapx_`plecebo'bb lgxrd_`plecebo'bb lgxrdint_`plecebo'bb eqr_`plecebo'bb using `"output/estimates/models_`plecebo'bb.tex"', replace ///
	se star(* 0.1 ** 0.05 *** 0.01) ///
	label
}

* Exporting	
save "data\trim\plecebo_res.dta", replace


*--------------------
*   COVID check
*--------------------


* Importing
use "data/trim/annual.dta", clear

* COVID control
gen covid = (year > 2019 & year < 2023)

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Estimation
foreach model in `models' {
	quietly xtlsdvc `model' ppolicy covid `expl_vars' dff lgexp, i(ab) b(1) v(200)
	estimates store `model'_covidab
	quietly predict fit_`model'_covidab, xb
	quietly predict ep_`model'_covidab, e
	
	quietly xtlsdvc `model' ppolicy covid `expl_vars' dff lgexp, i(bb) b(1) v(200)
	estimates store `model'_covidbb
	quietly predict fit_`model'_covidbb, xb
	quietly predict ep_`model'_covidbb, e
}

* Saving estimations
quietly esttab lgemp_covidab lgcapx_covidab lgxrd_covidab lgxrdint_covidab eqr_covidab using `"output/estimates/models_covidab.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_covidab lgcapx_covidab lgxrd_covidab lgxrdint_covidab eqr_covidab using `"output/estimates/models_covidab.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_covidbb lgcapx_covidbb lgxrd_covidbb lgxrdint_covidbb eqr_covidbb using `"output/estimates/models_covidbb.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_covidbb lgcapx_covidbb lgxrd_covidbb lgxrdint_covidbb eqr_covidbb using `"output/estimates/models_covidbb.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

* Exporting	
save "data\trim\covid_res.dta", replace


*------------------------
* Dispersed Policy Vars
*------------------------


* Importing
use "data/trim/annual.dta", clear

* New post-policy vars.
gen ppolicy18 = (year > 2017)
gen ppolicy19 = (year > 2018)
gen ppolicy20 = (year > 2019)
gen ppolicy22 = (year > 2021)
gen ppolicy23 = (year > 2022)

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Estimation
foreach model in `models' {
	quietly xtlsdvc `model' ppolicy18 ppolicy19 ppolicy20 ppolicy22 ppolicy23 `expl_vars' dff lgexp, i(ab) b(1) v(200)
	estimates store `model'_policyab
	quietly predict fit_`model'_policyab, xb
	quietly predict ep_`model'_policyab, e
	
	quietly xtlsdvc `model' ppolicy18 ppolicy19 ppolicy20 ppolicy22 ppolicy23 `expl_vars' dff lgexp, i(bb) b(1) v(200)
	estimates store `model'_policybb
	quietly predict fit_`model'_policybb, xb
	quietly predict ep_`model'_policybb, e
}

* Saving estimations
quietly esttab lgemp_policyab lgcapx_policyab lgxrd_policyab lgxrdint_policyab eqr_policyab using `"output/estimates/models_policyab.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_policyab lgcapx_policyab lgxrd_policyab lgxrdint_policyab eqr_policyab using `"output/estimates/models_policyab.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_policybb lgcapx_policybb lgxrd_policybb lgxrdint_policybb eqr_policybb using `"output/estimates/models_policybb.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_policybb lgcapx_policybb lgxrd_policybb lgxrdint_policybb eqr_policybb using `"output/estimates/models_policybb.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

* Exporting	
save "data\trim\policy_res.dta", replace


*=========================
*      Sensitivity
*=========================


* Importing
use "data/trim/annual.dta", clear

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Running each model w/ different lags
forv lag = 1/4 {
	foreach model in `models' {
		quietly xtabond2 l(0/1).`model' ppolicy `expl_vars' dff lgexp, r noc sm nol gmm(l.`model' lgexp `expl_vars', lag(1 `lag') c) iv(dff ppolicy)
		estimates store `model'_ab`lag'
		quietly predict difffit_`model'_ab`lag', xb diff
		quietly predict fit_`model'_ab`lag', xb
		quietly predict ep_`model'_ab`lag', res
		
		quietly xtabond2 l(0/1).`model' ppolicy `expl_vars' dff lgexp, r noc sm gmm(l.`model' lgexp `expl_vars', lag(1 `lag') c) iv(dff ppolicy)
		estimates store `model'_bb`lag'
		quietly predict difffit_`model'_bb`lag', xb diff
		quietly predict fit_`model'_bb`lag', xb
		quietly predict ep_`model'_bb`lag', res
	}
	
	quietly esttab lgemp_ab`lag' lgcapx_ab`lag' lgxrd_ab`lag' lgxrdint_ab`lag' eqr_ab`lag' using `"output/estimates/models_ab`lag'.txt"', replace ///
	se star(* 0.1 ** 0.05 *** 0.01) ///
	label
	
	quietly esttab  lgemp_bb`lag' lgcapx_bb`lag' lgxrd_bb`lag' lgxrdint_bb`lag' eqr_bb`lag' using `"output/estimates/models_bb`lag'.txt"', replace ///
	se star(* 0.1 ** 0.05 *** 0.01) ///
	label
}

* Getting the reported Hansen and AR tests
foreach model in `models' {
	mat H = J(8, 2, .)
	mat rown H = `model'_ab1 `model'_ab2 `model'_ab3 `model'_ab4 `model'_bb1 `model'_bb2 `model'_bb3 `model'_bb4
	mat coln H = chi2 pval
	
	mat AR = J(8, 2, .)
	mat rown AR = ar2_ab1 ar2_ab2 ar2_ab3 ar2_ab4 ar2_bb1 ar2_bb2 ar2_bb3 ar2_bb4
	mat coln AR = z pval
	
	local i = 1
	local ests `model'_ab1 `model'_ab2 `model'_ab3 `model'_ab4 `model'_bb1 `model'_bb2 `model'_bb3 `model'_bb4
	foreach est in `ests' {
		quietly estimates restore `est'
		mat H[`i', 1] = `e(hansen)'
		mat H[`i', 2] = `e(hansenp)'
		mat AR[`i', 1] = `e(ar2)'
		mat AR[`i', 2] = `e(ar2p)'
		local i = `i' + 1
	}
	
	mat2txt, mat(H) saving(`"output\estimates\_other_reports\hansen_`model'.txt"') title(`"Hansen Tests for `model' estimations"') replace
	mat2txt, mat(AR) saving(`"output\estimates\_other_reports\ar_`model'.txt"') title(`"AR Tests for `model' estimations"') replace
}

* Exporting	
save "data\trim\sensitivity_res.dta", replace


*=========================
*     Heterogeneity
*=========================


* Importing
use "data/trim/annual.dta", clear

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Making var to diff between 45 and (20 adn 25) since 25 only has 1 firm
gen sector = 1 if gsector == 45
replace sector = 0 if missing(sector)

* Estimation
foreach model in `models' {
	quietly xtlsdvc `model' ppolicy `expl_vars' dff lgexp if sector == 1, i(ab) b(1) v(200)
	estimates store `model'_45ab
	quietly predict fit_`model'_45ab, xb
	quietly predict ep_`model'_45ab, e
	
	quietly xtlsdvc `model' ppolicy `expl_vars' dff lgexp if sector == 1, i(bb) b(1) v(200)
	estimates store `model'_45bb
	quietly predict fit_`model'_45bb, xb
	quietly predict ep_`model'_45bb, e
	
	quietly xtlsdvc `model' ppolicy `expl_vars' dff lgexp if sector == 0, i(ab) b(1) v(200)
	estimates store `model'_20ab
	quietly predict fit_`model'_20ab, xb
	quietly predict ep_`model'_20ab, e
	
	quietly xtlsdvc `model' ppolicy `expl_vars' dff lgexp if sector == 0, i(bb) b(1) v(200)
	estimates store `model'_20bb
	quietly predict fit_`model'_20bb, xb
	quietly predict ep_`model'_20bb, e
}

quietly esttab lgemp_45ab lgcapx_45ab lgxrd_45ab lgxrdint_45ab eqr_45ab using `"output/estimates/models_45ab.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_45ab lgcapx_45ab lgxrd_45ab lgxrdint_45ab eqr_45ab using `"output/estimates/models_45ab.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_45bb lgcapx_45bb lgxrd_45bb lgxrdint_45bb eqr_45bb using `"output/estimates/models_45bb.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_45bb lgcapx_45bb lgxrd_45bb lgxrdint_45bb eqr_45bb using `"output/estimates/models_45bb.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_20ab lgcapx_20ab lgxrd_20ab lgxrdint_20ab eqr_20ab using `"output/estimates/models_20ab.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_20ab lgcapx_20ab lgxrd_20ab lgxrdint_20ab eqr_20ab using `"output/estimates/models_20ab.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_20bb lgcapx_20bb lgxrd_20bb lgxrdint_20bb eqr_20bb using `"output/estimates/models_20bb.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_20bb lgcapx_20bb lgxrd_20bb lgxrdint_20bb eqr_20bb using `"output/estimates/models_20bb.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label


* Exporting	
save "data\trim\heterogeneity_res.dta", replace


*=========================
*   Long v Short Term
*=========================


* Importing
use "data/trim/annual.dta", clear

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Creating an interaction terms
gen ppolicy_lgemp = ppolicy * c.l.lgemp
gen ppolicy_lgcapx = ppolicy * c.l.lgcapx
gen ppolicy_lgxrd = ppolicy * c.l.lgxrd
gen ppolicy_lgxrdint = ppolicy * c.l.lgxrdint
gen ppolicy_eqr = ppolicy * c.l.eqr

* Estimation
foreach model in `models' {
	quietly xtlsdvc `model' ppolicy ppolicy_`model' `expl_vars' dff lgexp, i(ab) b(1) v(200)
	estimates store `model'_interactab
	quietly predict fit_`model'_interactab, xb
	quietly predict ep_`model'_interactab, e
	
	quietly xtlsdvc `model' ppolicy ppolicy_`model' `expl_vars' dff lgexp, i(bb) b(1) v(200)
	estimates store `model'_interactbb
	quietly predict fit_`model'_interactbb, xb
	quietly predict ep_`model'_interactbb, e
}

* Saving estimations
quietly esttab lgemp_interactab lgcapx_interactab lgxrd_interactab lgxrdint_interactab eqr_interactab using `"output/estimates/models_interactab.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_interactab lgcapx_interactab lgxrd_interactab lgxrdint_interactab eqr_interactab using `"output/estimates/models_interactab.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_interactbb lgcapx_interactbb lgxrd_interactbb lgxrdint_interactbb eqr_interactbb using `"output/estimates/models_interactbb.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label
quietly esttab lgemp_interactbb lgcapx_interactbb lgxrd_interactbb lgxrdint_interactbb eqr_interactbb using `"output/estimates/models_interactbb.tex"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

* Exporting	
save "data\trim\interact_res.dta", replace


