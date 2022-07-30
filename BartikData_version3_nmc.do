*** This code is to construct the Bartik IV
* keep if MC==.
* drop MC
********************************************************************************
cls
clear
cd "/Users/annievm3m4vup/Dropbox/2021Fourthyearpaper/Data/Stata"
********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear 

foreach i in 11 21 22 23 33 42 45 49 51 52 53 54 55 56 61 62 71 72 81 { 
sort year industry_code
local industry_code
keep if MC==.
drop MC
collapse (sum) annual_avg_emplvl_county annual_avg_emplvl_countyMainInd (first) ///
name_bigcity fips_place BC govs_id national_annual_avg_emplvl ///
NationalEmpInImpInd national_ratio industry_title, by(year msa_sc industry_code)

rename national_annual_avg_emplvl Nat_tot_emp
rename NationalEmpInImpInd Nat_ind_emp
rename annual_avg_emplvl_county MSA_tot_emp
rename annual_avg_emplvl_countyMainInd MSA_ind_emp

replace MSA_ind_emp = 1090 if msa_sc==43 & industry_code=="61" & year == 2001
rename name_bigcity name
format name %12s
replace industry_code="33" if industry_code=="31-33"
replace industry_code="45" if industry_code=="44-45"
replace industry_code="49" if industry_code=="48-49"

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)
**
egen panelid = group(msa_sc industry_code)
egen timeid  = group(year)
xtset panelid timeid
sort panelid timeid
tsfill, full
{
	replace loc_ind = 0 if loc_ind==.
	replace year = timeid + 1989 if year==.
	replace msa_sc=25 if panelid ==336
	replace msa_sc=30 if panelid ==398
	replace msa_sc=33 if panelid ==461
	replace msa_sc=39 if panelid ==587
	replace msa_sc=40 if panelid ==608
	replace msa_sc=85 if panelid ==902
	replace msa_sc=95 if panelid ==1007
	replace msa_sc=96 if panelid ==1028
}

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	

keep if industry_code=="`i'" //Change the number

* Industry-Year totals (across locations)
egen nat_ind = total(loc_ind), by(year industry_code)	//national total

sort msa_sc industry_code year
tsset loc_industry_code year, delta(1)
replace nat_ind = nat_ind - loc_ind //Bartik2020, p.26, leave-one-out

* Industry growth rate(Gt)	
gen nat_grwt_ind = ((nat_ind-L.nat_ind)/L.nat_ind) //steve: take the average
gen nat_grwt_ind_5 = ((nat_ind-L4.nat_ind)/L4.nat_ind)

* Industry-Local growth rate(Git)	
gen loc_grwt_ind = ((loc_ind-L.loc_ind)/L.loc_ind)

* Take the initial share of 1990
gen sh_ind_loc_1990 = sh_ind_loc if year ==1990
egen int_share_1990 = min(sh_ind_loc_1990), by(msa_sc industry_code)
gen loc_ind_iv = int_share_1990 * nat_grwt_ind
gen loc_ind_iv_5 = int_share_1990 * nat_grwt_ind_5


* Construct the Bartik IV
egen B_iv_`i'_nmc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_`i'_nmc = . if year==1990 & B_iv_`i'_nmc==0 //Change the number
egen B_iv_`i'_nmc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_`i'_nmc_5 = . if year==1990 & B_iv_`i'_nmc_5==0 //Change the number

rename loc_ind loc_ind_`i'_nmc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_`i'_nmc_5 B_iv_`i'_nmc loc_ind_`i'_nmc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_`i'_nmc.dta", replace //Change the number


********************************************************************************
use "./export/QCEW/BartikData_11_nmc.dta", clear
merge 1:1 year msa_sc using "./export/QCEW/BartikData_21_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_22_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_23_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_33_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_42_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_45_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_49_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_51_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_52_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_53_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_54_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_55_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_56_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_61_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_62_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_71_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_72_nmc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_81_nmc.dta", nogen 
replace loc_ind_11_nmc = 0 if loc_ind_11_nmc==.
replace loc_ind_21_nmc = 0 if loc_ind_21_nmc ==.
replace loc_ind_22_nmc = 0 if loc_ind_22_nmc ==.
replace loc_ind_23_nmc = 0 if loc_ind_23_nmc ==.
replace loc_ind_33_nmc = 0 if loc_ind_33_nmc ==.
replace loc_ind_42_nmc = 0 if loc_ind_42_nmc ==.
replace loc_ind_45_nmc = 0 if loc_ind_45_nmc ==.
replace loc_ind_49_nmc = 0 if loc_ind_49_nmc ==.
replace loc_ind_51_nmc = 0 if loc_ind_51_nmc ==.
replace loc_ind_52_nmc = 0 if loc_ind_52_nmc ==.
replace loc_ind_53_nmc = 0 if loc_ind_53_nmc ==.
replace loc_ind_54_nmc = 0 if loc_ind_54_nmc ==.
replace loc_ind_55_nmc = 0 if loc_ind_55_nmc ==.
replace loc_ind_56_nmc = 0 if loc_ind_56_nmc ==.
replace loc_ind_61_nmc = 0 if loc_ind_61_nmc ==.
replace loc_ind_62_nmc = 0 if loc_ind_62_nmc ==.
replace loc_ind_71_nmc = 0 if loc_ind_71_nmc ==.
replace loc_ind_72_nmc = 0 if loc_ind_72_nmc ==.
replace loc_ind_81_nmc = 0 if loc_ind_81_nmc ==.


save "./export/QCEW/BartikData_version3_nmc.dta", replace
