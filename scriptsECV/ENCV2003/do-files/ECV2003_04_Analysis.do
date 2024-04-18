*glo project="D:\Dropbox\Dropbox\Tobacco-health-inequalities" // Mathieu folder
*glo project="C:\Users\paul.rodriguez\Dropbox\tabaco\Tobacco-health-inequalities" // Paul folder
glo project="C:\Users\Usuario\Dropbox\Tobacco-health-inequalities" //Susana's folder
*glo project="C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities" //Susana's folder


////////////////////////////////////////////////////////////////////////////////
use  "$project\data\ENCV2003\derived\ECV2003_tabaco.dta", clear

gen tabexpper = tabacoExpenses/totalExpenses
replace tabacoExpenses=0 if totalExpenses!=. & tabacoExpenses==.
replace tabexpper=0 if totalExpenses!=. & tabexpper==.
gen tabac01 =0
replace tabac01=1 if tabacoExpenses>0
recode age (10/19 =1 "10 a 19") (20/29=2 "20 a 29") (30/39=3 "30 a 39") (40/49=4 "40 a 49") (50/59=5 "50 a 59") (60/105=6 "60+"), gen(edadg)
replace edadg=. if edad<10
xtile quintile=persgast, n(5)
gen lngast=ln(persgast)
xtile decile=persgast, n(10)
rename numero idhogar1
rename region depto
gen year=2003

save "$project\data\ENCVdoc\ENCV2003_tob.dta", replace

*merge m:1 DIRECTORIO using  "$project\data\ENCV2003\original\dbfp_encv_550_1.sav.dta" , nogen keepusing(P1_DEPARTAMENTO REGION)

svyset idhogar1 [pw=fex], strata(depto)

svy: logit tabac01 female ib2.edadg i.quintile educ_uptoSec educ_tert if edad>19, or
svy: reg tabexpper female ib2.edadg i.quintile educ_uptoSec educ_tert if edad>19
svy: reg tabacoExpenses female i.edadg i.quintile educ_uptoSec educ_tert

conindex tabac01, rankvar(persgast) svy truezero graph
conindex tabexpper, rankvar(persgast) svy truezero graph
conindex tabacoExpenses, rankvar(persgast) svy truezero graph xtitle("Rank of HH Consumption") ytitle("Cumulative share of Cigarettes consumed") 

lorenz e persgast, svy g
conindex persgast, rankvar(persgast) svy truezero graph

lpoly tabexpper lngast
histogram tabexpper if tabexpper!=0

scatter tabexpper lngast
graph bar (mean) tabexpper [aweight = fex], over(quintile) cw blabel(bar)
graph bar (mean) tabexpper [aweight = fex], over(decile) cw blabel(bar)

gen numcig=tabacoExpenses/82
replace numcig=numcig/numadu
replace numcig=6000 if numcig>6000 & numcig<30000

conindex numcig, rankvar(persgast) svy truezero graph
conindex numcig, rankvar(persingr) svy truezero graph

svy: mean numcig
