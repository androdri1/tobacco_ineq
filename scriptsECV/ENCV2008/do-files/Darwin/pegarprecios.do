* Pegar precios
clear all
set more off
set mem 1g
version 10

* Seleccione el directorio de trabajo
global pc "C:\Users\Jorge\Desktop"
* global pc "C:\Documents and Settings\jorge perez\Escritorio"

cd "${pc}\enig1994-1995\Base Ingresos y Gastos Stata"
* Base de datos de gastos
use r4.dta, clear
sort numero_orden
* Pegar caracteristicas
preserve
use r0.dta, clear
keep numero_orden ciudad ing_total_ug factor
sort numero_orden
tempfile a
save `a'
restore
merge numero_orden using `a'
drop _merge
* Pegar articulos
preserve
use articulos, clear
sort articulo
save, replace
restore
sort articulo
merge articulo using articulos.dta
drop _merge
* Pegar precios
xtile qing=ing_total_ug, nq(2)
gen estrato=""
replace estrato="Bajo" if qing==1
replace estrato="Medio" if qing==2
gen ciudadm=ciudad
# delimit ;
replace ciudadm="A nivel nacional" if (ciudad=="Armenia" | ciudad=="Florencia" | ciudad=="Ibague" | ciudad=="Popayan"
| ciudad=="Quibdo" | ciudad=="Riohacha" | ciudad=="Santa Marta" | ciudad=="Sincelejo" | ciudad=="Tunja" | ciudad=="Valledupar");
# delimit cr
sort ciudadm estrato rubrom
preserve
use precios94, clear
sort ciudadm estrato rubrom
keep ciudadm estrato rubrom valor_indice valor_defl
tempfile b
save `b'
restore
merge ciudadm estrato rubrom using `b'
drop if _merge==2
drop _merge
save gastos.dta, replace