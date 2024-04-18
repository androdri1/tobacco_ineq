* Deflacta precios para pegar a la ENIG 94-95
* Los precios se van a tomar base 1998
* Enero 2007=100
* Y a toda la encuesta se le asigna el índice de diciembre de 1994

clear all
set more off
set mem 500m

* Seleccione el directorio de trabajo
global pc "C:\Users\Jorge\Desktop"
* global pc "C:\Documents and Settings\jorge perez\Escritorio"

cd "${pc}\enig1994-1995\Base Ingresos y Gastos Stata"
use r0.dta, clear

cap drop ano mes ciudad ciudadnum
gen ano=1994
gen mes=12
# delimit;
recode departamento (11 = 1 "Bogotá")
(18=2	"Florencia")
(41=3	"Neiva")
(15=4	"Tunja")
(50=5	"Villavicencio")
(5=6	"Medellin")
(23=7	"Monteria")
(27=8	"Quibdo")
(76=9	"Cali")
(52=10	"Pasto")
(19=11	"Popayan")
(8=12	"Barranquilla")
(13=13	"Cartagena")
(44=14	"Riohacha")
(47=15	"Santa Marta")
(70=16	"Sincelejo")
(20=17	"Valledupar")
(68=19	"Bucaramanga")
(54=20	"Cucuta")
(17=21	"Manizales")
(63=22	"Armenia")
(73=23	"Ibague")
(66=24	"Pereira"), gen(ciudadnum);
# delimit cr
decode ciudadnum, gen(ciudad)
save, replace
use factor, clear
sort numero_orden
save, replace
use r0, clear
sort numero_orden
merge numero_orden using factor
drop _merge
save, replace
********************
* Trabajo con la  base de precios
use "$pc\EIG08\Precios\1998\precios98completo.dta", clear
* Quita los espacios
replace grupo=subinstr(grupo," ","",.)
replace estrato=subinstr(estrato," ","",.)
bysort ano mes ciudad estrato grupo: gen base2007=valor_indice if (ano==2007 & mes==01)
preserve
tempfile base
drop if missing(base2007)
keep ciudad estrato grupo base2007
sort ciudad estrato grupo
save `base'
restore
drop base2007
sort ciudad estrato grupo
merge ciudad estrato grupo using `base'
drop _merge
* Chequeo
assert base2007==valor if (ano==2007 & mes==01)
* Generar indice deflactado
gen valor_defl=(valor_indice/base2007)
* Para enig solo se necesitan los de diciembre de 1994
keep if (ano==1994 & mes==12)
cd "${pc}\enig1994-1995\Base Ingresos y Gastos Stata"
* Generar nombres que coincidan con grupos eig
gen rubrom=.
replace rubrom=1 if grupo=="Alimentos"
replace rubrom=9 if grupo=="Educación"
replace rubrom=10 if grupo=="Gastosvarios"
replace rubrom=6 if grupo=="Salud"
replace rubrom=7 if grupo=="Transporte"
replace rubrom=3 if grupo=="Vestuario"
replace rubrom=4 if grupo=="Vivienda"
replace rubrom=2 if grupo=="Aniveltotal"
replace ciudad="Bogotá" if ciudad=="Bogota"
gen ciudadm=ciudad
save precios94.dta, replace	

	
	
