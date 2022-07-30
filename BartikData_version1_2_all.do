*** This code is to construct the Bartik IV
* Analyzing Employment Data for Big Cities 1
* The base year growth ==.
********************************************************************************
cls
clear
cd "/Users/annievm3m4vup/Dropbox/2021Fourthyearpaper/Data/Stata"
********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear
{ //All county
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
drop if industry_code=="92" 

gen industry_type = 0  //Dummy: local industry
replace industry_type = 1 if industry_code=="21" | industry_code=="33" |industry_code=="42" |industry_code=="51" |industry_code=="52" |industry_code=="54" |industry_code=="55" |industry_code=="56" |industry_code=="62"  //Dummy: national industry

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)
bysort year msa_sc: egen loc_ind_0 = sum(loc_ind) if industry_type==0
bysort year msa_sc: egen loc_ind_1 = sum(loc_ind) if industry_type==1
bysort year msa_sc: replace loc_ind_0 = loc_all_ind - loc_ind_1 if loc_ind_0==.
bysort year msa_sc: replace loc_ind_1 = loc_all_ind - loc_ind_0 if loc_ind_1==.

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	

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
egen B_iv = sum(loc_ind_iv), by(msa_sc year)
replace B_iv =. if year==1990 & B_iv ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)

////////////////////////////////////////////////////////////////////////////////
* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc_0 = loc_ind_0/loc_all_ind	
gen sh_ind_loc_1 = loc_ind_1/loc_all_ind
	
* Industry-Local growth rate(Git)	
gen loc_grwt_ind_0 = ((loc_ind_0-L.loc_ind_0)/L.loc_ind_0)
gen loc_grwt_ind_1 = ((loc_ind_1-L.loc_ind_1)/L.loc_ind_1)

* Take the initial share of 1990
gen sh_ind_loc_1990_0 = sh_ind_loc_0 if year ==1990
gen sh_ind_loc_1990_1 = sh_ind_loc_1 if year ==1990
egen int_share_1990_0 = min(sh_ind_loc_1990_0), by(msa_sc industry_code)
egen int_share_1990_1 = min(sh_ind_loc_1990_1), by(msa_sc industry_code)
gen loc_ind_iv_0 = int_share_1990_0 * nat_grwt_ind
gen loc_ind_iv_1 = int_share_1990_1 * nat_grwt_ind

* Construct the Bartik IV
egen B_iv_tp0 = sum(loc_ind_iv_0), by(msa_sc year)
egen B_iv_tp1 = sum(loc_ind_iv_1), by(msa_sc year)
replace B_iv_tp0 =. if year==1990 & B_iv_tp0 ==0
replace B_iv_tp1 =. if year==1990 & B_iv_tp1 ==0

* Construct the dX_it
gen dX_it_tp0 = ((loc_ind_0-L.loc_ind_0)/L.loc_ind_0)
gen dX_it_tp1 = ((loc_ind_1-L.loc_ind_1)/L.loc_ind_1)
////////////////////////////////////////////////////////////////////////////////
collapse (mean) dX_it dX_it_tp0 dX_it_tp1 B_iv B_iv_tp0 B_iv_tp1 loc_all_ind loc_ind_0 loc_ind_1, by(msa_sc year)
}
save "./export/QCEW/BartikData_version12_all.dta", replace
save "/Users/annievm3m4vup/Dropbox/2022Fifthyearpaper/Data/Final/Stata/BartikData_version12_all.dta", replace

//msa_sc == 1,2,4,7,9,12,26,43,61,71,72,98
