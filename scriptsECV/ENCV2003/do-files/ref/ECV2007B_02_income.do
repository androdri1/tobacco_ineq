* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.10
* Goal: produce a dataset for ECV2003 that has total expenditures, tabaco expenditures

glo dropbox "C:\Users\paul.rodriguez\Dropbox"
glo dropbox "C:\Users\PaulAndrÃ©s\Dropbox"
glo dropbox "C:\Users\androdri\Dropbox"

********************************************************************************
* Define individual level info
********************************************************************************
use "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2003\original\trabajoL.dta", clear


/* OJO SI TODOS SON MISSING. Ojo!! corregir lo de los =0 de inicio, deberían inicar en missing */

/* Ingreso de los niños*/
gen ingreso_nino=0
replace ingreso_nino=h1002+h1001 if (h06==2 | h06==3 | h06==4) & !(h1002==98 | h1002==99 | h1001==98 | h1001==99)

/* Ingreso en especies: alimentos por pago, vivienda por pago, educación por pago, especie niño*/
gen il_inkindVal=.
replace il_inkindVal=il_inkindVal+l2402 if l2401==1 & il_inkindVal!=.
replace il_inkindVal=             l2402 if l2401==1 & il_inkindVal==.
replace il_inkindVal=il_inkindVal+l2502 if l2501==1 & il_inkindVal!=.
replace il_inkindVal=             l2502 if l2501==1 & il_inkindVal==.
replace il_inkindVal=il_inkindVal+l2602 if l2601==1 & il_inkindVal!=.
replace il_inkindVal=             l2602 if l2601==1 & il_inkindVal==.
replace il_inkindVal=il_inkindVal+h1002 if (h06==2 | h06==3 | h06==4) & !(h1002==98 | h1002==99) & il_inkindVal!=.
replace il_inkindVal=             h1002 if (h06==2 | h06==3 | h06==4) & !(h1002==98 | h1002==99) & il_inkindVal==.


/* ingreso laboral monetario: cuánto ganó el mes pasado, dinero por primas_L32, ganancia neta pora ctivdad o negocio */
/* si es independiente, ingreso por trabajo, ingreso niños monetario. l4802 y l23 no se sobreponen*/
gen il_monetary=.
replace il_monetary=il_monetary+l23 if l23!=. & il_monetary!=.
replace il_monetary=            l23 if l23!=. & il_monetary==.
replace il_monetary=il_monetary+l3202/12 if l3201==1 & l3202!=. & il_monetary!=.
replace il_monetary=            l3202/12 if l3201==1 & l3202!=. & il_monetary==.
replace il_monetary=il_monetary+l37 if (l17==5 | l17==6 l17==8 ) & l37!=. & il_monetary!=.
replace il_monetary=            l37 if (l17==5 | l17==6 l17==8 ) & l37!=. & il_monetary==.
replace il_monetary=il_monetary+l4802/12 if l4801==1 & l4802!=. & il_monetary!=.
replace il_monetary=            l4802/12 if l4801==1 & l4802!=. & il_monetary==.
replace il_monetary=il_monetary+h1001 if ( (h06==2 | h06==3 | h06==4) & !( h1001==98 | h1001==99) ) &  h1001!=. & il_monetary!=.
replace il_monetary=            h1001 if ( (h06==2 | h06==3 | h06==4) & !( h1001==98 | h1001==99) ) &  h1001!=. & il_monetary==.

/* Ingresos laborales subsidios: alimentación, transporte o familiar*/
replace il_monetary=il_monetary+l2902 if l2901==1 & l2902!=. & il_monetary!=.
replace il_monetary=           +l2902 if l2901==1 & l2902!=. & il_monetary==.
replace il_monetary=il_monetary+l3002 if l3001==1 & l3002!=. & il_monetary!=.
replace il_monetary=            l3002 if l3001==1 & l3002!=. & il_monetary==.
replace il_monetary=il_monetary+l3102 if l3101==1 & l3102!=. & il_monetary!=.
replace il_monetary=            l3102 if l3101==1 & l3102!=. & il_monetary==.

/* Ingresos de capital: arriendo, cesantías, intereses por préstamo, ganancia neta actividad o negocio*/
gen i_capital=.
replace i_capital=i_capital+l5102 if l5101==1 & l5102!=. & i_capital!=.
replace i_capital=          l5102 if l5101==1 & l5102!=. & i_capital==.
replace i_capital=i_capital+l5202/12 if l5201==1 & l5202!=. & i_capital!=.
replace i_capital=          l5202/12 if l5201==1 & l5202!=. & i_capital==.
replace i_capital=i_capital+l5402/12+l33 if l5401==1 & l5402!=. & i_capital!=.
replace i_capital=          l5402/12+l33 if l5401==1 & l5402!=. & i_capital==.
replace i_capital=i_capital+l33 if l33!=. & i_capital!=.
replace i_capital=          l33 if l33!=. & i_capital==.

/* Otros Ingresos: pensión, sostenimiento menores, transferencias privadas (incluye remesas), primas_L53*/
gen i_other_st=.
replace i_other_st=i_other_st+l4902 if l4901==1 & l4902!=. & i_other_st!=.
replace i_other_st=           l4902 if l4901==1 & l4902!=. & i_other_st==.
replace i_other_st=i_other_st+l5002 if l5001==1 & l5002!=. & i_other_st!=.
replace i_other_st=           l5002 if l5001==1 & l5002!=. & i_other_st==.
replace i_other_st=i_other_st+l5503/12 if l5501==1 & l5503!=. & i_other_st!=.
replace i_other_st=           l5503/12 if l5501==1 & l5503!=. & i_other_st==.
replace i_other_st=i_other_st+l5302/12 if l5301==1 & l5302!=. & i_other_st!=.
replace i_other_st=           l5302/12 if l5301==1 & l5302!=. & i_other_st==.

************************************************************************
label var il_inkind "Labour income: In-kind"
label var il_monetary "Labour income: Monetary"
label var i_lab "Labour income: total"
label var i_capital "Capital income"
label var i_other_st "Private transfers"

* Total income ***********************************************************************

egen incomePer= rowtotal(i_lab i_capital i_other_st) , missing
label var incomePer "Total individual income (monthly)"

xxxxxxx
////////////////////////////////////////////////////////////////////////////////

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FACTOR_EXPANSION incomePer
saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2008\derived/ENCV2008_incomePersona.dta" ,replace

rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA

collapse (sum) incomeHH=incomePer, by(DIRECTORIO SECUENCIA_ENCUESTA)
label var incomeHH "Total household income (monthly)"

saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2008\derived/ENCV2008_incomeHogar.dta" ,replace
