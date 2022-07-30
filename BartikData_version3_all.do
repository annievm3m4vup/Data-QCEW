*** This code is to construct the Bartik IV
* Analyzing Employment Data for Big Cities
* The base year growth ==.
********************************************************************************
cls
clear
cd "/Users/annievm3m4vup/Dropbox/2021Fourthyearpaper/Data/Stata"
********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear 

foreach i in 11 21 22 23 33 42 45 49 51 52 53 54 55 56 61 62 71 72 81  { //All county
sort year industry_code
local industry_code
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

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	

keep if industry_code==`i' //Change the number

* Industry-Year totals (across locations)
egen nat_ind = total(loc_ind), by(year industry_code)	//national total

sort msa_sc industry_code year
tsset loc_industry_code year, delta(1)
replace nat_ind = nat_ind - loc_ind //Bartik2020, p.26, leave-one-out

* Industry growth rate(Gt)	
gen nat_grwt_ind = ((nat_ind-L.nat_ind)/L.nat_ind) //steve: take the average

* Industry-Local growth rate(Git)	
gen loc_grwt_ind = ((loc_ind-L.loc_ind)/L.loc_ind)

* Take the initial share of 1990
gen sh_ind_loc_1990 = sh_ind_loc if year ==1990
egen int_share_1990 = min(sh_ind_loc_1990), by(msa_sc industry_code)
gen loc_ind_iv = int_share_1990 * nat_grwt_ind 

* Construct the Bartik IV
egen B_iv_`i' = sum(loc_ind_iv), by(msa_sc year)
*replace B_iv_11 =0 if B_iv_11 ==. //Change the number

* Construct the dX_it
gen dX_it_`i' = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_`i'
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_`i' loc_ind_`i' dX_it_`i', by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_`i'.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/BartikData_11.dta", clear
merge 1:1 year msa_sc using "./export/QCEW/BartikData_21.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_22.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_23.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_33.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_42.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_45.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_49.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_51.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_52.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_53.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_54.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_55.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_56.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_61.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_62.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_71.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_72.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_81.dta", nogen 
replace loc_ind_11 = 0 if loc_ind_11==.
replace loc_ind_21 = 0 if loc_ind_21 ==.
replace loc_ind_22 = 0 if loc_ind_22 ==.
replace loc_ind_23 = 0 if loc_ind_23 ==.
replace loc_ind_33 = 0 if loc_ind_33 ==.
replace loc_ind_42 = 0 if loc_ind_42 ==.
replace loc_ind_45 = 0 if loc_ind_45 ==.
replace loc_ind_49 = 0 if loc_ind_49 ==.
replace loc_ind_51 = 0 if loc_ind_51 ==.
replace loc_ind_52 = 0 if loc_ind_52 ==.
replace loc_ind_53 = 0 if loc_ind_53 ==.
replace loc_ind_54 = 0 if loc_ind_54 ==.
replace loc_ind_55 = 0 if loc_ind_55 ==.
replace loc_ind_56 = 0 if loc_ind_56 ==.
replace loc_ind_61 = 0 if loc_ind_61 ==.
replace loc_ind_62 = 0 if loc_ind_62 ==.
replace loc_ind_71 = 0 if loc_ind_71 ==.
replace loc_ind_72 = 0 if loc_ind_72 ==.
replace loc_ind_81 = 0 if loc_ind_81 ==.

replace B_iv_11 = . if B_iv_11==0 //25,33
replace B_iv_21 = . if B_iv_21 ==0 //25,33,48,63
replace B_iv_22 = . if B_iv_22 ==0 //12,19,26,29,48,66,91,96,
replace B_iv_23 = . if B_iv_23 ==0
replace B_iv_33 = . if B_iv_33 ==0
replace B_iv_42 = . if B_iv_42 ==0
replace B_iv_45 = . if B_iv_45 ==0
replace B_iv_49 = . if B_iv_49 ==0
replace B_iv_51 = . if B_iv_51 ==0
replace B_iv_52 = . if B_iv_52 ==0
replace B_iv_53 = . if B_iv_53 ==0
replace B_iv_54 = . if B_iv_54 ==0
replace B_iv_55 = . if B_iv_55 ==0
replace B_iv_56 = . if B_iv_56 ==0
replace B_iv_61 = . if B_iv_61 ==0
replace B_iv_62 = . if B_iv_62 ==0
replace B_iv_71 = . if B_iv_71 ==0
replace B_iv_72 = . if B_iv_72 ==0
replace B_iv_81 = . if B_iv_81 ==0

save "./export/QCEW/BartikData_version3_all.dta", replace

