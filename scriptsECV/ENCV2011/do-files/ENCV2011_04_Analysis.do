glo project="D:\Dropbox\Dropbox\Tobacco-health-inequalities\data\ENCV2011" // Mathieu
*glo project="C:\Users\androdri\Dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2011" // Paul
glo project="C:\Users\paul.rodriguez\Dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2011" // Paul
glo project="C:\Users\Usuario\Dropbox\Tobacco-health-inequalities\data\ENCV2011" // Susana
*glo project="C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities\data\ENCV2011" // Susana
glo project = "C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities"

///////////////////////////////////////////////////////////////////////////////

use  "$project\data\ENCV2011\derived\ENCV2011_tabaco.dta", clear

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
rename FEX_C fex
rename DIRECTORIO idhogar1
rename P1_DEPARTAMENTO depto 
rename P6020 e03
gen year=2011

save "$project\data\ENCVdoc\ENCV2011_tob.dta", replace

svyset idhogar1 [pw=fex], strata(depto)


* Income concentration? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
conindex persingr , rankvar(persingr) svy truezero graph // .57 index, persingr = incomeHH/hheq, hheq = max{1 + (0.5*(numadu-1)) + (0.3*numnin),1}
conindex incomeHH , rankvar(incomeHH) svy truezero graph // .55 index
conindex persgast , rankvar(persgast) svy truezero graph // .54 index --- for expenditures!!!
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+


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
