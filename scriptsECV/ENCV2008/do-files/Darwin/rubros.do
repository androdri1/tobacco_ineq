* Codifica los artículos de acuerdo a los grupos de gasto -ENIG 1994
clear all
set more off
set mem 500m

* Seleccione el directorio de trabajo
global pc "C:\Users\Jorge\Desktop"
* global pc "C:\Documents and Settings\jorge perez\Escritorio"

cd "${pc}\enig1994-1995\Base Ingresos y Gastos Stata"
use articulos.dta, clear


* palimentos pbebidas_tabaco pvestuario pserv_vivienda pmuebles psalud ptransporte precreacion peducacion pservicios_otros
# delimit ;
recode articulo 
(1000/1914 =1 "alimentos")
(1920/1933 =2 "bebidas_tabaco")
(2000/2911 =3 "vestuario")
(3110/3113 3116/3314 4437/4536 4538/4550 4554 4556/4618 7224 7225 = 4 "serv_vivienda")
(4111/4436 4555 7119/7123 = 5 "muebles")
(5001/5511 = 6 "salud")
(6216 6310/6420  = 7 "transporte")
(7111/7118 7124/7140 7143/7223 7226/7316   = 8 "recreacion")
(7401/7525 = 9 "educacion") 
(3114 3115 4537 4551/4554 5512/6215 6217/6230 7141 7142 8111/9312 =10 "servicios_otros"),
gen (rubro);
# delimit cr
decode rubro, gen(rubrostr)
* Para pegar con la base de precios, se necesita otro rubro
gen rubrom=rubro
replace rubrom=4 if (rubro==5 | rubro==8)
save articulos, replace
