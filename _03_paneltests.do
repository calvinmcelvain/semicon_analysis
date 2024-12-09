clear all

* Setting working dir.
capture cd "C:\Users\mcelvain\OneDrive - University of Iowa\ms_26\ui_24f\ECON_5810\vsp\semicon_analysis"

***** Depdencies *****
* ssc install mat2txt, replace


*=========================
*          VIFs
*=========================


* Importing
use "data/trim/annual.dta", clear

* Initializing empty matrix to store VIFs
mat vif = J(8, 1, .)
mat coln vif = VIFs

* Running pooled regression on arbitrary model to get VIFs of expl vars
quietly reg eqr ppolicy tobin lgat lgage dteq nita dff lgexp
quietly vif

* Saving VIFs obtained above to matrix
forv i=1/8 {
	mat vif[`i', 1] = `r(vif_`i')'
}

* Saving names according to their order
mat rown vif = `r(name_1)' `r(name_2)' `r(name_3)' `r(name_4)' `r(name_5)' `r(name_6)' `r(name_7)' `r(name_8)'

* Exporting VIF matrix
mat2txt, mat(vif) saving("output\panel_tests\vif.txt") title("Variance Inflation Factors") replace


*===========================
* Autocorr. Woodridge (2010)
*===========================


* List for dependent vars
local depvars lgemp lgcapx lgxrd lgxrdint eqr

* Initializing empty matrix to store tests
mat wood = J(5, 2, .)
mat rown wood = lgemp lgcapx lgxrd lgxrdint eqr
mat coln wood = pval fstat

* Running test for each model
local i = 1
foreach depvar in `depvars' {
	quietly xtserial `depvar' ppolicy tobin lgat lgage dteq nita dff lgexp
	mat wood[`i', 1] = `r(p)'
	mat wood[`i', 2] = `r(F)'
	local i = `i' + 1
}

* Exporting wood matrix
mat2txt, mat(wood) saving("output\panel_tests\wood.txt") title("Autocorrelation Test (Woodridge, 2010)") replace


*==========================================
* Heteroscedasticity (Breusch et al., 1979)
*==========================================


* Intializing empty matrix to store tests
mat het = J(5, 2,.)
mat rown het = lgemp lgcapx lgxrd xrdint eqr
mat coln het = pval chi2

* Running test for each model
local i = 1
foreach depvar in `depvars' {
	quietly reg `depvar' ppolicy tobin lgat lgage dteq nita dff lgexp
	quietly hettest
	mat het[`i', 1] = `r(p)'
	mat het[`i', 2] = `r(chi2)'
	local i = `i' + 1
}

* Exporting wood matrix
mat2txt, mat(het) saving("output\panel_tests\het.txt") title("Heteroscedasticity Test (Breusch et al., 1979)") replace


*======================================
* Unit Roots (Harris & Tzavalis, 1999)
*======================================


* Initializing empty matrix to store unit roots
mat unitroots = J(8, 4, .)
mat rown unitroots = ppolicy tobin lgat lgage dteq nita dff lgexp
mat coln unitroots = rho pval d.rho d.pval

* Getting unit roots for each var
local i = 1
foreach var in ppolicy tobin lgat lgage dteq nita dff lgexp {
    quietly xtunitroot ht `var', trend
	mat unitroots[`i', 1] = `r(rho)'
	mat unitroots[`i', 2] = `r(p)'

    quietly xtunitroot ht d.`var', trend
	mat unitroots[`i', 3] = `r(rho)'
	mat unitroots[`i', 4] = `r(p)'

    local i = `i' + 1
}

* Exporting unitroots matrix
mat2txt, mat(unitroots) saving("output\panel_tests\unitroots.txt") title("Unit-root Tests (Harris & Tzavalis, 1999)") replace
