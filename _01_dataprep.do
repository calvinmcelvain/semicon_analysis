clear all

* Setting working dir.
capture cd "C:\Users\mcelvain\OneDrive - University of Iowa\ms_26\ui_24f\ECON_5810\vsp\semicon_analysis\data"


*=========================
*     Compustat Data
*=========================


* Importing
import delimited "raw\firms.csv", clear

* Dropping missing values
drop if missing(fyear, tic, at, capx, csho, emp, ni, revt, seq, xrd, prcc_f, ppegt)

* Creating year variable
rename fyear year
xtset gvkey year
sort gvkey year
drop datadate

* Making ipodate a year var (see CRSP section for use)
gen ipo_year = year(date(ipodate, "YMD"))
drop ipodate

* Making an initial start year 
bysort gvkey (year): egen initial_year = min(year)

* Dropping unnecessary vars
drop indfmt consol popsrc datafmt curcd costat

* Imputing missing obs. w/ 0 for select vars.
foreach var in intan dlc dltt {
    replace `var' = 0 if missing(`var')
}

* Log transformation of total assets (SIZE)
gen lgat = log(at)

* Log trandformations of employment, R&D exp, and capital exp
gen lgemp = log(emp + 1)
gen lgxrd = log(xrd + 1)
gen lgcapx = log(capx + 1)

* Creating post policy var.
gen ppolicy = (year > 2018)

* Calculating Tobin's q (Erickson and Whited, 2006)
gen tobin = ((prcc_f * csho) + dltt + dlc - act) / ppegt

* Calculating equity-ratio var & log (Firm Health)
gen eqr = seq / (at - intan)

* Calculating R&D intensity & log (if revenue is 0, imputed w/ 0)
gen xrdint = xrd / revt
gen lgxrdint = log(xrdint)
replace lgxrdint = 0 if missing(lgxrdint)

* Calculating debt-to-equity var (PSLACK)
gen dteq = (dltt + dlc) / seq

* Calculating net-income-to-assets var (ASLACK)
gen nita = ni / at

* Creating balanced panel
local start_year = 2006
local end_year = 2023
bysort gvkey: egen year_count = sum(inrange(year, `start_year', `end_year'))
by gvkey: gen complete_data = (year_count == `end_year' - `start_year' + 1)
keep if complete_data
drop if year < `start_year'
drop if year > `end_year'
drop complete_data year_count

* Dropping unused vars
drop ppegt csho dlc dltt intan ni revt seq prcc_f act

* Exporting
save "trim\compa.dta", replace


*=========================
*       CRSP Data
*=========================


* Importing
import delimited "raw\firms_age.csv", clear

* Dropping unneeded vars
drop permno secinfostartdt secinfoenddt securityenddt

* Remaing ticker to match annual.dta for future merge
rename ticker tic 

* Making singular security start years for each firm
gen start_year = year(date(securitybegdt, "YMD"))
drop securitybegdt

* Getting and dropping duplicates after first obs.
sort tic
by tic: gen dup = cond(_N==1, 0, _n)
drop if dup > 1
drop dup

* Exporting
save "trim\crsp.dta", replace

* Merging w/ annual.dta by ticker
merge 1:m tic using "trim\compa.dta"
sort gvkey year

* Dropping obs. not matched w/ master
drop if _merge == 1

* If ipo_year is earlier than stary_year, use ipo_year or initial_year as start
replace start_year = ipo_year if ipo_year < start_year
replace start_year = initial_year if initial_year < start_year

* If missing merge from using (_merge == 2)
drop if missing(start_year)
drop ipo_year _merge tic initial_year

* Calculating log of age (AGE)
gen age = year - start_year + 1
gen lgage = log(age)
drop start_year

* Exporting
save "trim\annual.dta", replace


*=========================
*     Fed Funds Data
*=========================


* Importing
import delimited "raw\ffundsa.csv", clear

* Creating year var
gen DATE_num = date(date, "YMD")
format DATE_num %td
gen year = year(DATE_num)
tsset year
sort year
drop DATE_num date

* Exporting
save "trim\ffundsa.dta", replace

* Merging w/ annual.dta 
merge 1:m year using "trim\annual.dta"
sort gvkey year
keep if _merge == 3
drop _merge

* Exporting
save "trim\annual.dta", replace


*=========================
*     Export Data
*=========================


* Importing
import delimited "raw\shipval.csv", clear

* Renaming vars
rename v1 date
rename v2 exp

* Creating year variable
gen date_var = date(date, "YMD")
gen year = year(date_var)
drop date date_var

* Sum collapsing by year
collapse (sum) exp, by(year)
tsset year
sort year

* Transforming valship to log change in shipments
gen lgexp = log(exp)
drop exp
drop if missing(lgexp)

* Exporting
save "trim\shipvala.dta", replace

* Merging w/ annual.dta 
merge 1:m year using "trim\annual.dta"
sort gvkey year
keep if _merge == 3
drop _merge

* Dropping labels
label drop _all

* Exporting
save "trim\annual.dta", replace

xtdescribe
