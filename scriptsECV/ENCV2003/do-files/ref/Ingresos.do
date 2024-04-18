/* OJO SI TODOS SON MISSING. Ojo!! corregir lo de los =0 de inicio, deberían inicar en missing */

/* Ingreso de los niños*/
gen ingreso_nino=0
replace ingreso_nino=h1002+h1001 if (h06==2 | h06==3 | h06==4) & !(h1002==98 | h1002==99 | h1001==98 | h1001==99)

/* Ingreso en especies: alimentos por pago, vivienda por pago, educación por pago, especie niño*/
gen ingreso_laboral_especie=0
replace ingreso_laboral_especie=ingreso_laboral_especie+l2402 if l2401==1
replace ingreso_laboral_especie=ingreso_laboral_especie+l2502 if l2501==1
replace ingreso_laboral_especie=ingreso_laboral_especie+l2602 if l2601==1
replace ingreso_laboral_especie=ingreso_laboral_especie+h1002 if (h06==2 | h06==3 | h06==4) & !(h1002==98 | h1002==99)

/* ingreso laboral monetario: cuánto ganó el mes pasado, dinero por primas_L32, ganancia neta pora ctivdad o negocio */
/* si es independiente, ingreso por trabajo, ingreso niños monetario. l4802 y l23 no se sobreponen*/
gen ingreso_laboral_monetario=0
replace ingreso_laboral_monetario=ingreso_laboral_monetario+l23
replace ingreso_laboral_monetario=ingreso_laboral_monetario+l3202/12 if l3201==1
replace ingreso_laboral_monetario=ingreso_laboral_monetario+l37 if l17==5 | l17==6 l17==8 
replace ingreso_laboral_monetario=ingreso_laboral_monetario+l4802/12 if l4801==1
replace ingreso_laboral_monetario=ingreso_laboral_monetario+h1001 if (h06==2 | h06==3 | h06==4) & !( h1001==98 | h1001==99)

/* Ingresos laborales subsidios: alimentación, transporte o familiar*/

gen ingreso_laboral_subsidio=0
replace ingreso_laboral_subsidio=ingreso_laboral_subsidio+l2902 if l2901==1
replace ingreso_laboral_subsidio=ingreso_laboral_subsidio+l3002 if l3001==1
replace ingreso_laboral_subsidio=ingreso_laboral_subsidio+l3102 if l3101==1

/* Ingresos de capital: arriendo, cesantías, intereses por préstamo, ganancia neta actividad o negocio*/
gen ingreso_capital=0
replace ingreso_capital=ingreso_capital+l5102 if l5101==1
replace ingreso_capital=ingreso_capital+l5202/12 if l5201==1
replace ingreso_capital=ingreso_capital+l5402/12+l33 if l5401==1
replace ingreso_capital=ingreso_capital+l33

/* Otros Ingresos: pensión, sostenimiento menores, transferencias privadas (incluye remesas), primas_L53*/
gen ingreso_otros=0
replace ingreso_otros=ingreso_otros+l4902 if l4901==1
replace ingreso_otros=ingreso_otros+l5002 if l5001==1
replace ingreso_otros=ingreso_otros+l5503/12 if l5501==1
replace ingreso_otros=ingreso_otros+l5302/12 if l5301==1


