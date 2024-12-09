clear all

* Setting wokring dir.
capture cd "C:\Users\mcelvain\OneDrive - University of Iowa\ms_26\ui_24f\ECON_5810\vsp\semicon_analysis"

***** Depdencies *****
* ssc install xtabond2, replace
* ssc install estout, replace


*=========================
*   AB & BB Estimatiors
*=========================


* Importing
use "data/trim/annual.dta", clear

* Lists of dependent vars and control vars for each model
local models lgemp lgcapx lgxrd lgxrdint eqr
local expl_vars tobin lgat lgage dteq nita

* Running each model w/ different lags
forv lag = 2/3 {
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
	mat H = J(4, 2, .)
	mat rown H = `model'_ab2 `model'_ab3 `model'_bb2 `model'_bb3
	mat coln H = chi2 pval
	
	mat AR = J(8, 2, .)
	mat rown AR = ar1_ab2 ar2_ab2 ar1_ab3 ar2_ab3 ar1_bb2 ar2_bb2 ar1_bb3 ar2_bb3
	mat coln AR = z pval
	
	local i = 1
	foreach est in `model'_ab2 `model'_ab3 `model'_bb2 `model'_bb3 {
		quietly estimates restore `est'
		mat H[`i', 1] = `e(hansen)'
		mat H[`i', 2] = `e(hansenp)'
		mat AR[`= 2 * `i' - 1', 1] = `e(ar1)'
		mat AR[`= 2 * `i' - 1', 2] = `e(ar1p)'
		mat AR[`= 2 * `i'', 1] = `e(ar2)'
		mat AR[`= 2 * `i'', 2] = `e(ar2p)'
		local i = `i' + 1
	}
	
	mat2txt, mat(H) saving(`"output\estimates\_other_reports\hansen_`model'.txt"') title(`"Hansen Tests for `model' estimations"') replace
	mat2txt, mat(AR) saving(`"output\estimates\_other_reports\ar_`model'.txt"') title(`"AR Tests for `model' estimations"') replace
}


*=========================
*   LSDVC Estimatior
*=========================


* Running each model
foreach model in `models' {
	quietly xtlsdvc `model' ppolicy `expl_vars' dff lgexp, i(ab) b(1) v(200)
	estimates store `model'_lsdvcab
	quietly predict fit_`model'_lsdvcab, xb
	quietly predict ep_`model'_lsdvcab, e
	
	quietly xtlsdvc `model' ppolicy `expl_vars' dff lgexp, i(bb) b(1) v(200)
	estimates store `model'_lsdvcbb
	quietly predict fit_`model'_lsdvcbb, xb
	quietly predict ep_`model'_lsdvcbb, e
}

* Saving estimations
quietly esttab lgemp_lsdvcab lgcapx_lsdvcab lgxrd_lsdvcab lgxrdint_lsdvcab eqr_lsdvcab using `"output/estimates/models_lsdvcab.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

quietly esttab lgemp_lsdvcbb lgcapx_lsdvcbb lgxrd_lsdvcbb lgxrdint_lsdvcbb eqr_lsdvcbb using `"output/estimates/models_lsdvcbb.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label


*=========================
*     FE Estimatior
*=========================


* Running each model
foreach model in `models' {
	quietly xtreg `model' ppolicy `expl_vars' dff lgexp, fe vce(robust)
	estimates store `model'_fe
	quietly predict fit_`model'_fe, xb
	quietly predict ep_`model'_fe, e
}

* Saving estimations
quietly esttab lgemp_fe lgcapx_fe lgxrd_fe lgxrdint_fe eqr_fe using `"output/estimates/models_fe.txt"', replace ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label

* Exporting	
save "data\trim\est_res.dta", replace
