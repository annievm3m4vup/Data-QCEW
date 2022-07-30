*** This code is to construct the Bartik IV
* keep if MC==.
* drop MC
********************************************************************************
cls
clear
cd "/Users/annievm3m4vup/Dropbox/2021Fourthyearpaper/Data/Stata"
********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //11
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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

keep if industry_code=="11" //Change the number

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
egen B_iv_11_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_11_mc = . if year==1990 & B_iv_11_mc==0 //Change the number
egen B_iv_11_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_11_mc_5 = . if year==1990 & B_iv_11_mc_5==0 //Change the number

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_11_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_11_mc_5 B_iv_11_mc loc_ind_11_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_11_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //21
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
	replace msa_sc=13 if panelid ==107
	replace msa_sc=25 if panelid ==337
	replace msa_sc=30 if panelid ==399
	replace msa_sc=33 if panelid ==462
	replace msa_sc=39 if panelid ==589	
	replace msa_sc=40 if panelid ==609
	replace msa_sc=63 if panelid ==798
	replace msa_sc=85 if panelid ==903
	replace msa_sc=94 if panelid ==987
	replace msa_sc=95 if panelid ==1008
	replace msa_sc=96 if panelid ==1029
}
* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	

keep if industry_code=="21" //Change the number

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
egen B_iv_21_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_21_mc =. if year==1990 & B_iv_21_mc ==0 //Change the number
egen B_iv_21_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_21_mc_5 =. if year==1990 & B_iv_21_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_21_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_21_mc_5 B_iv_21_mc loc_ind_21_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_21_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //22
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
	replace msa_sc=25 if panelid ==338
	replace msa_sc=48 if panelid ==736
	replace msa_sc=66 if panelid ==862
	replace msa_sc=67 if panelid ==883
	replace msa_sc=91 if panelid ==925
	replace msa_sc=31 if panelid ==421
	replace msa_sc=15 if panelid ==150
	replace msa_sc=19 if panelid ==213
	replace msa_sc=29 if panelid ==379
	replace msa_sc=96 if panelid ==1030

}
* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	

keep if industry_code=="22" //Change the number

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
egen B_iv_22_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_22_mc =. if year==1990 & B_iv_22_mc ==0 //Change the number
egen B_iv_22_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_22_mc_5 =. if year==1990 & B_iv_22_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_22_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_22_mc_5 B_iv_22_mc loc_ind_22_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_22_mc.dta", replace //Change the number
********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //23
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="23" //Change the number

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
egen B_iv_23_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_23_mc =. if year==1990 & B_iv_23_mc ==0 //Change the number
egen B_iv_23_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_23_mc_5 =. if year==1990 & B_iv_23_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_23_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_23_mc_5 B_iv_23_mc loc_ind_23_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_23_mc.dta", replace //Change the number


********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //33
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="33" //Change the number

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
egen B_iv_33_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_33_mc =. if year==1990 & B_iv_33_mc ==0 //Change the number
egen B_iv_33_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_33_mc_5 =. if year==1990 & B_iv_33_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_33_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_33_mc_5 B_iv_33_mc loc_ind_33_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_33_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //42
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="42" //Change the number

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
egen B_iv_42_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_42_mc =. if year==1990 & B_iv_42_mc ==0 //Change the number
egen B_iv_42_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_42_mc_5 =. if year==1990 & B_iv_42_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_42_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_42_mc_5 B_iv_42_mc loc_ind_42_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_42_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //45
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="45" //Change the number

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
egen B_iv_45_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_45_mc =. if year==1990 & B_iv_45_mc ==0 //Change the number
egen B_iv_45_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_45_mc_5 =. if year==1990 & B_iv_45_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_45_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_45_mc_5 B_iv_45_mc loc_ind_45_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_45_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //49
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="49" //Change the number

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
egen B_iv_49_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_49_mc =. if year==1990 & B_iv_49_mc ==0 //Change the number
egen B_iv_49_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_49_mc_5 =. if year==1990 & B_iv_49_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_49_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_49_mc_5 B_iv_49_mc loc_ind_49_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_49_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //51
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="51" //Change the number

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
egen B_iv_51_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_51_mc =. if year==1990 & B_iv_51_mc ==0 //Change the number
egen B_iv_51_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_51_mc_5 =. if year==1990 & B_iv_51_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_51_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_51_mc_5 B_iv_51_mc loc_ind_51_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_51_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //52
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="52" //Change the number

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
egen B_iv_52_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_52_mc =. if year==1990 & B_iv_52_mc ==0 //Change the number
egen B_iv_52_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_52_mc_5 =. if year==1990 & B_iv_52_mc_5 ==0 

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_52_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_52_mc_5 B_iv_52_mc loc_ind_52_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_52_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //53
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="53" //Change the number

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
egen B_iv_53_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_53_mc =. if year==1990 & B_iv_53_mc ==0 //Change the number
egen B_iv_53_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_53_mc_5 =. if year==1990 & B_iv_53_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_53_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_53_mc_5 B_iv_53_mc loc_ind_53_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_53_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //54
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


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
	replace msa_sc=44 if panelid ==682
	

}
* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="54" //Change the number

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
egen B_iv_54_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_54_mc =. if year==1990 & B_iv_54_mc ==0 //Change the number
egen B_iv_54_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_54_mc_5 =. if year==1990 & B_iv_54_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_54_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_54_mc_5 B_iv_54_mc loc_ind_54_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_54_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //55
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


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
	replace msa_sc=35 if panelid ==515
	replace msa_sc=44 if panelid ==683
	replace msa_sc=67 if panelid ==893
	replace msa_sc=96 if panelid ==1040
	replace msa_sc=46 if panelid ==725
	replace msa_sc=39 if panelid ==599
	replace msa_sc=33 if panelid ==473
	replace msa_sc=41 if panelid ==641
	replace msa_sc=91 if panelid ==935
	replace msa_sc=6 if panelid ==55
	replace msa_sc=42 if panelid ==662
	replace msa_sc=66 if panelid ==872
	replace msa_sc=93 if panelid ==977


}
* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="55" //Change the number

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
egen B_iv_55_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_55_mc =. if year==1990 & B_iv_55_mc ==0 //Change the number
egen B_iv_55_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_55_mc_5 =. if year==1990 & B_iv_55_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_55_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_55_mc_5 B_iv_55_mc loc_ind_55_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_55_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //56
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="56" //Change the number

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
egen B_iv_56_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_56_mc =. if year==1990 & B_iv_56_mc ==0 //Change the number
egen B_iv_56_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_56_mc_5 =. if year==1990 & B_iv_56_mc_5 ==0 

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_56_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_56_mc_5 B_iv_56_mc loc_ind_56_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_56_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //61
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


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
	replace msa_sc=96 if panelid ==1042
}
* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="61" //Change the number

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
egen B_iv_61_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_61_mc =. if year==1990 & B_iv_61_mc ==0 //Change the number
egen B_iv_61_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_61_mc_5 =. if year==1990 & B_iv_61_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_61_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_61_mc_5 B_iv_61_mc loc_ind_61_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_61_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //62
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"

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
	replace msa_sc=67 if panelid ==896
	replace msa_sc=96 if panelid ==1043
	
}
* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="62" //Change the number

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
egen B_iv_62_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_62_mc =. if year==1990 & B_iv_62_mc ==0 //Change the number
egen B_iv_62_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_62_mc_5 =. if year==1990 & B_iv_62_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_62_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_62_mc_5 B_iv_62_mc loc_ind_62_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_62_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //71
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="71" //Change the number

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
egen B_iv_71_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_71_mc =. if year==1990 & B_iv_71_mc ==0 //Change the number
egen B_iv_71_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_71_mc_5 =. if year==1990 & B_iv_71_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_71_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_71_mc_5 B_iv_71_mc loc_ind_71_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_71_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //72
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"

* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="72" //Change the number

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
egen B_iv_72_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_72_mc =. if year==1990 & B_iv_72_mc ==0 //Change the number
egen B_iv_72_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_72_mc_5 =. if year==1990 & B_iv_72_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_72_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_72_mc_5 B_iv_72_mc loc_ind_72_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_72_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/1990to2017Data.dta", clear //81
{ //All county
sort year industry_code
local industry_code
keep if MC==1
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
//drop if industry_code=="11" | industry_code=="21" | industry_code=="22"


* Location-Industry groupings
egen double loc_industry_code = group(msa_sc industry_code)

* Sum the employment of industry at 2 digits at each location and each year	
bysort industry_code msa_sc year: egen loc_ind = sum(MSA_ind_emp)

* Sum all industries at each location by year and sum by type (1 or 0)
bysort year msa_sc: egen loc_all_ind = sum(loc_ind)

* Calculate the share of employment in an industry by Location-Year		
gen sh_ind_loc = loc_ind/loc_all_ind	
keep if industry_code=="81" //Change the number

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
egen B_iv_81_mc = sum(loc_ind_iv), by(msa_sc year) //Change the number
replace B_iv_81_mc=. if year==1990 & B_iv_81_mc ==0 //Change the number
egen B_iv_81_mc_5 = sum(loc_ind_iv_5), by(msa_sc year) //Change the number
replace B_iv_81_mc_5=. if year==1990 & B_iv_81_mc_5 ==0

* Construct the dX_it
gen dX_it = ((loc_all_ind-L.loc_all_ind)/L.loc_all_ind)
rename loc_ind loc_ind_81_mc
////////////////////////////////////////////////////////////////////////////////
collapse (mean)  B_iv_81_mc_5 B_iv_81_mc loc_ind_81_mc, by(msa_sc year) //Change the number
}
save "./export/QCEW/BartikData_81_mc.dta", replace //Change the number

********************************************************************************
use "./export/QCEW/BartikData_11_mc.dta", clear
merge 1:1 year msa_sc using "./export/QCEW/BartikData_21_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_22_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_23_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_33_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_42_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_45_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_49_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_51_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_52_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_53_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_54_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_55_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_56_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_61_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_62_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_71_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_72_mc.dta", nogen 
merge 1:1 year msa_sc using "./export/QCEW/BartikData_81_mc.dta", nogen 
replace loc_ind_11_mc = 0 if loc_ind_11_mc==.
replace loc_ind_21_mc = 0 if loc_ind_21_mc ==.
replace loc_ind_22_mc = 0 if loc_ind_22_mc ==.
replace loc_ind_23_mc = 0 if loc_ind_23_mc ==.
replace loc_ind_33_mc = 0 if loc_ind_33_mc ==.
replace loc_ind_42_mc = 0 if loc_ind_42_mc ==.
replace loc_ind_45_mc = 0 if loc_ind_45_mc ==.
replace loc_ind_49_mc = 0 if loc_ind_49_mc ==.
replace loc_ind_51_mc = 0 if loc_ind_51_mc ==.
replace loc_ind_52_mc = 0 if loc_ind_52_mc ==.
replace loc_ind_53_mc = 0 if loc_ind_53_mc ==.
replace loc_ind_54_mc = 0 if loc_ind_54_mc ==.
replace loc_ind_55_mc = 0 if loc_ind_55_mc ==.
replace loc_ind_56_mc = 0 if loc_ind_56_mc ==.
replace loc_ind_61_mc = 0 if loc_ind_61_mc ==.
replace loc_ind_62_mc = 0 if loc_ind_62_mc ==.
replace loc_ind_71_mc = 0 if loc_ind_71_mc ==.
replace loc_ind_72_mc = 0 if loc_ind_72_mc ==.
replace loc_ind_81_mc = 0 if loc_ind_81_mc ==.

//drop if msa_sc==18 | msa_sc==63| msa_sc==1 | msa_sc==2| msa_sc==4| msa_sc==7| msa_sc==9| msa_sc==12| msa_sc==26| msa_sc==43| msa_sc==61| msa_sc==71|msa_sc==72|msa_sc==98


save "./export/QCEW/BartikData_version3_mc.dta", replace
