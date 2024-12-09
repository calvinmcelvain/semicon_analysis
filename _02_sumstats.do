clear all

* Setting working dir.
capture cd "C:\Users\mcelvain\OneDrive - University of Iowa\ms_26\ui_24f\ECON_5810\vsp\semicon_analysis"


***** Depdencies *****
* ssc install estout, replace
* ssc install mat2txt, replace


*=========================
*   Correlation Matrix
*=========================


* Importing
use "data/trim/annual.dta", clear

* Calculating correlation matrix
correlate lgemp lgcapx lgxrd lgxrdint eqr ppolicy tobin lgat lgage dteq nita dff lgexp

* Exporting correlation matrix to txt file
matrix C = r(C)
mat2txt , matrix(C) saving("output\stats\corr_matrix.txt") replace


*=========================
*   Summary Statistics
*=========================


* Computing summary statistics for all obs.
estpost sum lgemp emp lgcapx capx lgxrd xrd lgxrdint xrdint eqr ppolicy tobin lgat at lgage age dteq nita dff lgexp

* Exporting summary stats
esttab using "output/stats/sumstats_all.txt", cells("count(fmt(0)) mean(fmt(2)) Var(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") replace

* Creating local var GSIC sector, industry group, industry, & sub-industry codes
levelsof gsector, l(gsector)
levelsof ggroup, l(ggroup)
levelsof gind, l(gind)
levelsof gsubind, l(gsubind)
local gics gsector ggroup gind gsubind

* Computing summary statistics for GSICS codes
foreach gic in `gics' {
	foreach code in ``gic'' {
		estpost sum lgemp emp lgcapx capx lgxrd xrd lgxrdint xrdint eqr ppolicy tobin lgat at lgage age dteq nita dff lgexp nita if `gic' == `code'
		esttab using `"output/stats/sumstats_`gic'/`code'.txt"', cells("count(fmt(0)) mean(fmt(2)) Var(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") replace
	}
}




