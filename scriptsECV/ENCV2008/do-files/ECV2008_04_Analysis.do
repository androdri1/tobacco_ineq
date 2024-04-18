glo project="D:\Dropbox\Dropbox\Tobacco-health-inequalities\data\ENCV2008" // Mathieu
glo project="C:\Users\androdri\Dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2008" // Paul
glo project="C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities\data\ENCV2008" //Susana's folder
glo project="C:\Users\Usuario\Dropbox\Tobacco-health-inequalities" //Susana's folder

///////////////////////////////////////////////////////////////////////////////

use  "$project\data\ENCV2008\derived\ENCV2008_tabaco.dta", clear

gen tabexpper = tabacoExpenses/totalExpenses
replace tabacoExpenses=0 if totalExpenses!=. & tabacoExpenses==.
replace tabexpper=0 if totalExpenses!=. & tabexpper==.
gen tabac01 =0
replace tabac01=1 if tabacoExpenses>0
recode edad (10/19 =1 "10 a 19") (20/29=2 "20 a 29") (30/39=3 "30 a 39") (40/49=4 "40 a 49") (50/59=5 "50 a 59") (60/105=6 "60+"), gen(edadg)
replace edadg=. if edad<10
xtile quintile=persgast, n(5)
gen lngast=ln(persgast)
xtile decile=persgast, n(10)
rename FACTOR_EXPANSION fex
rename DIRECTORIO idhogar1
rename P6020 e03
rename P1_DEPARTAMENTO depto
gen year=2008

save "$project\data\ENCVdoc\ENCV2008_tob.dta", replace


*merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA using  "$project\original\dbfp_encv_551_1.sav.dta" , nogen keepusing(FEX_C)
*merge m:1 DIRECTORIO using  "$project\original\dbfp_encv_550_1.sav.dta" , nogen keepusing(P1_DEPARTAMENTO REGION)

svyset idhogar1 [pw=fex], strata(depto)

svy: logit tabac01 female ib2.edadg i.quintile educ_uptoSec educ_tert if edad>19, or
svy: reg tabexpper female ib2.edadg i.quintile educ_uptoSec educ_tert if edad>19
svy: reg tabacoExpenses female i.edadg i.quintile educ_uptoSec educ_tert

conindex tabac01, rankvar(persgast) svy truezero graph
conindex tabexpper, rankvar(persgast) svy truezero graph
conindex tabacoExpenses, rankvar(persgast) svy truezero graph

lorenz e persgast, svy g
conindex persgast, rankvar(persgast) svy truezero graph

lpoly tabexpper lngast
histogram tabexpper if tabexpper!=0

scatter tabexpper lngast
graph bar (mean) tabexpper [aweight = fex], over(quintile) cw blabel(bar)

gen numcig=tabacoExpenses/121
replace numcig=numcig/numadu
replace numcig=6000 if numcig>6000 & numcig<30000

conindex numcig, rankvar(persgast) svy truezero graph
conindex numcig, rankvar(persingr) svy truezero graph

svy: mean numcig
