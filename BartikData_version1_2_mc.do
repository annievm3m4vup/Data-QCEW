*** This code is to construct the Bartik IV
* Analyzing Employment Data for Big Cities 1
* The base year growth ==.
********************************************************************************
cls
clear
cd "/Users/annievm3m4vup/Dropbox/2021Fourthyearpaper/Data/Stata"
********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear
{ //Main county
sort year industry_code
local industry_code
keep if MC==1
drop MC
collapse (sum) annual_avg_emplvl_county annual_avg_emplvl_countyMainInd (first) ///
name_bigcity fips_place BC govs_id national_annual_avg_emplvl ///
NationalEmpInImpInd national_ratio industry_title, by(year msa_sc industry_code)

rename NationalEmpInImpInd Nat_ind_emp
rename annual_avg_emplvl_countyMainInd Cnty_ind_emp
replace Cnty_ind_emp = 1090 if msa_sc==43 & industry_code=="61" & year == 2001
rename name_bigcity name
format name %12s
drop if industry_code=="92" 

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
collapse (sum)  loc_ind = Cnty_ind_emp loc_industry_code, by(industry_code msa_sc  year)
* Sum all industries at each location by year
egen loc_all_ind = total(loc_ind), by(year msa_sc)	

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	

* Industry-Year totals (across locations)
egen nat_ind = total(loc_ind), by(year industry_code)	//national total

sort msa_sc industry_code year
tsset loc_industry_code year, delta(1)
replace nat_ind = nat_ind - loc_ind            //Bartik2020, p.26, leave-one-out

* Industry growth rate(Gt)	
gen nat_grwt_ind = ((nat_ind-L.nat_ind)/L.nat_ind)     //steve: take the average

* Industry-Local growth rate(Git)	
gen loc_grwt_ind = ((loc_ind-L.loc_ind)/L.loc_ind)

* Take the initial share of 1990
gen sh_ind_loc_1990 = sh_ind_loc if year ==1990
egen int_share_1990 = min(sh_ind_loc_1990), by(msa_sc industry_code)
gen loc_ind_iv = int_share_1990 * nat_grwt_ind

* Construct the Bartik IV
egen B_iv_mc = sum(loc_ind_iv), by(msa_sc year)
replace B_iv_mc =. if year==1990 & B_iv_mc ==0 //check

* Construct the dX_it
gen dX_it_mc = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_all_ind loc_all_ind_mc
collapse (mean)  B_iv_mc dX_it_mc loc_all_ind_mc, by(msa_sc year)
}
save "./export/QCEW/BartikData_version12_mc.dta", replace
save "/Users/annievm3m4vup/Dropbox/2022Fifthyearpaper/Data/Final/Stata/BartikData_version12_mc.dta", replace
