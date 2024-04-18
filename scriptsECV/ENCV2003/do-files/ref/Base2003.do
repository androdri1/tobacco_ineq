macro drop _all
clear all
 glo carpetaMadre "E:\Documents and Settings\Paul Andres\Mis documentos\Trabajos"
* glo carpetaMadre "C:\Documents and Settings\paul rodriguez\Mis documentos\Trabajos"
glo carpetaDatos "$carpetaMadre\Comedores\Old Version (PE)"
glo carpetaResul "$carpetaMadre\Comedores\Paper\Procesamiento\Bases Intermedias"

/* ***********************************************************************************************************
**************************************************************************************************************
**************************** CREACIÓN DE LA BASE DE DATOS PARA COMEDORES COMUNITARIOS ************************
**************************************************************************************************************
*********************************************************************************************************** */

* @DES: Utiliza la información de Persona, condiciones de vida, vivienda y hogar para crea una una única base de datos para manipular.
* la carpeta Datos es la ubicación de las bases originales de la ECVB2007. La caperta resultados es l
* @IN: los 4 archivos de la ECV2007
* @OUT: 4 bases intermedias (comedores2007.dta, comedoresHogar2007.dta, comedoresEsposos2007.dta, comedoresMujeres2007.dta)
*           1 base final para definir las variables para realizar el procedimiento (comedoresFinal2007.dta)
* @PRE: Existencia de las bases iniciales, y los otros dos .do (Esposo-Mujel2007.do y Hogares2007.do)

/* ***********************************************************************************************************
************************* PREPARACIÓN DE LA BASE DE DATOS INICIAL CON VARIABLES CLAVE ************************
*********************************************************************************************************** */

# delimit ;
cd "$carpetaDatos"; 

use "ECV2003\personasL.dta", replace;
merge numero e01 using "ECV2003\trabajoL.dta", unique sort;
drop _merge;
merge numero e01 using "ECV2003\menoresL.dta", unique sort;
drop _merge;
merge numero e01 using "ECV2003\educaL.dta", unique sort;
drop _merge;
cd "$carpetaResul";

# delim cr

* ***********************************************************************************
* ******************* Identificar mamás con hijos en el mismo hogar ***********************
* ***********************************************************************************

tab e1902, gen(om_)
glo max=r(r)
foreach x of varlist om_* {
	egen x_`x'=max(`x') , by(numero)
	drop `x'
}

tab e01 , gen(or_)

forval i = 1(1)$max { 
	gen esmama_`i'= (or_`i')*(x_om_`i' )
}

egen esmama=rowtotal(esmama_*)
drop esmama_* or_* x_om_*


* ***************************************************************************************************************

# delim ;



/* OJO SI TODOS SON MISSING. Ojo!! corregir lo de los =0 de inicio, deberían inicar en missing */
/* Ingreso en especies: alimentos por pago, vivienda por pago, educación por pago, especie niño*/

gen il_especie =.;
gen il_monetario =.;
gen il_subsidios =.;
gen i_capital =.;
gen i_capital_SD =.; /* Ingreso de Capital sin doble contabilidad */
gen i_otros =.;
gen i_otros_st =.;
gen i_transfmon =.;

label var il_especie "Ingreso Laboral Especie";
label var il_monetario "Ingreso Laboral Monetario";
label var il_subsidios "Ingreso Laboral Subisidios";
label var i_capital "Ingreso Capital";
label var i_otros "Otros Ingresos";
label var i_otros_st "Otros Ingresos sin Transferencias Pub/Priv";
label var i_transfmon "Transferencias Púb/Priv Monetarias";

/* Lo único son los 99's...*/	

replace il_especie = 0 if ((l17==1 | l17==2 | l17==4 | l17==3) & (l01==1) & ( l2401==1 |  l2501==1 | l2601==1 | l2701==1 | l2801==1)) | (h09==1 & h0501==1);
replace il_especie = il_especie + cond(l2401==1, l2402,0) 
								+ cond(l2501==1,l2502,0)
								+ cond(l2601==1 ,l2602,0)
								+ cond(l2701==1,l2702,0)
								+ cond(l2801==1,l2802,0)
								+ cond(h09==1 & h0501==1,h1002,0);

replace il_subsidios = 0 if (l17==1 | l17==2 | l17==4 | l17==3) & (l01==1) & (l2901==1 | l3001==1 | l3101==1);
replace il_subsidios = il_subsidios + cond(l2901==1,l2902,0)
									+ cond(l3001==1,l3002,0)
									+ cond(l3101==1,l3102,0);

replace il_monetario = 0 if 
  ((l17==5 | l17==6 | l17==8) & (l01==1)  & l33<.) 
| (l4301==1  & (l01==1) & l4302 <.) 
| ((l02==1 | l03==1 | l04==1) & (l01==2 | l01==3 | l01==4 | l01==5) & l23<.) 
| (l4801==1 & (l01==2 | l01==3 | l01==4 | l01==5 | l01==6))
| (l3201==1)
| ((l17==1 | l17==2 | l17==4 | l17==3) & l01==1 & l23<. ); 

replace il_monetario = il_monetario + l33 if (l17==5 | l17==6 | l17==8) & (l01==1) &  l33<.;
replace il_monetario = il_monetario + l4302 if  l4301==1  & (l01==1) & l4302 <.;
replace il_monetario = il_monetario + l23 if (l02==1 | l03==1 | l04==1) & (l01==2 | l01==3 | l01==4 | l01==5) & l23<.;
replace il_monetario = il_monetario + l4802 if l4801==1 & (l01==2 | l01==3 | l01==4 | l01==5 | l01==6);
replace il_monetario = il_monetario + l3202/12 if l3201==1;
replace il_monetario = il_monetario + l23 if (l17==1 | l17==2 | l17==4 | l17==3) & l01==1 & l23<.;
replace il_monetario = il_monetario + h1001 if (h09==1 & h0501==1);

replace i_capital = 0 if (l5101==1 | l5201==1 | l5401==1) | 
((l17==5 | l17==6 | l17==7 | l17==8) & (l01==1) &  l33<.);
replace i_capital = i_capital       + cond(((l17==5 | l17==6 | l17==7 | l17==8) & (l01==1) &  l33<.),l33,0)
									+ cond(l5101==1,l5102,0)
									+ cond(l5201==1,l5202/12,0)
									+ cond(l5401==1,l5402/12,0);

replace i_capital_SD = 0 if ((l5101==1 | l5201==1 | l5401==1));
replace i_capital_SD = i_capital_SD + cond((l17==7 & l01==1 &  l33<.),l33,0)
									+ cond(l5101==1,l5102,0)
									+ cond(l5201==1,l5202/12,0)
									+ cond(l5401==1,l5402/12,0);
						
replace i_otros = 0 if ( l4901==1 | l5001==1 | l5301==1 | l5501==1);
replace i_otros = i_otros + cond( l4901==1,l4902,0)
						  + cond(l5001==1,l5002,0)
						  + cond(l5301==1,l5302,0)
						  + cond(l5501==1, l5503,0);		
					/*    + cond(l5601==1, l5602,0);		*/

replace i_otros_st = 0 if ( l4901==1 | l5001==1 | l5301==1 | l5501==1);
replace i_otros_st = i_otros_st + cond( l4901==1,l4902,0)
						  + cond(l5001==1,l5002,0)
						  + cond(l5301==1,l5302,0);	
					/*    + cond(l5601==1, l5602,0);		*/						  

replace i_transfmon = 0 if (l5501==1 );
replace i_transfmon = i_transfmon  + cond(l5501==1, l5503,0);							  
			  

/* Elaboración del ingresos evitando "." No obstante, ¿no estarán contabilizando doble las ayudas?*/

egen ingreso = rowtotal(il_especie il_monetario il_subsidios i_capital_SD i_otros) if ((l01==1 & (l17==1 | l17==2 | l17==4 | l17==3) & l23<.) | (l01==1 & (l17==6 | l17==7 | l17==3 | l17==7) & l33<.) | (l01==2 | l01==3 | l01==4 | l01==5 | l01==6)), missing;
egen ingreso_st = rowtotal(il_especie il_monetario il_subsidios i_capital_SD i_otros_st) if ((l01==1 & (l17==1 | l17==2 | l17==4 | l17==3) & l23<.) | (l01==1 & (l17==6 | l17==7 | l17==3 | l17==7) & l33<.) | (l01==2 | l01==3 | l01==4 | l01==5 | l01==6)), missing;

/* Transferencias */

gen t_almts_ie=.;
gen t_becas_sub=.;

label var t_almts_ie "Transferencias en Alimentos Ins. Educ";
label var t_becas_sub "Transferencias en Becas y Sub. Educ";

/* Se multiplican por 15 por un bicho (días hábiles y así) del programa Santiago Grillo */
replace t_almts_ie = 0 if (g01==1 & (g1201==1 | g1301==1)) | (i02==1 &  i1201==1 & (i0701==1 | i0701==2 | i0701==3));
replace t_almts_ie= t_almts_ie + cond(g1201==1,(g1202 - g1203)*15,0)
						  + cond(g1301==1,(g1302 - g1303)*15,0)
						  + cond((i02==1 & (i0701==1 | i0701==2 | i0701==3) &  i1201==1),(i1202-i1203)*15,0);
						  
replace t_becas_sub = 0 if (i02==1) & (i23==1 & (i2401==1 | i2401==2 | i2401==3 |  i2401==4));
replace t_becas_sub = t_becas_sub + cond((i23==1 & i2401==1),i2402,0)
								  + cond((i23==1 & i2401==2),i2402/2,0)
								  + cond((i23==1 & i2401==3),i2402/6,0)
								  + cond((i23==1 & i2401==4),i2402/12,0);

egen transferencias = rowtotal(t_almts_ie t_becas_sub), missing;								  
egen transferencias_conm = rowtotal(t_almts_ie t_becas_sub i_transfmon), missing;
							  
						  
/* ******************************************************************************************************/

/* ECVB 2003 */
/* Oferta Laboral de Mujeres. Datos a nivel de hogar */

/* Cuentas por rango de edad pero excluye a los que sean empleados o no parientes */
gen ed0    = cond((e02<1) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
gen ed12   = cond((e02==1 | e02==2) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
gen ed34   = cond((e02==3 | e02==4) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
gen ed56   = cond((e02==5 | e02==6) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
gen ed611  = cond((e02>=6 & e02<=11) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
gen ed1215 = cond((e02>=12 & e02<=15) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
gen ed1617 = cond((e02==16 | e02==17) & !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);

/* Cuentas por rango de edad SÓLO HIJOS*/
gen eh0    = cond((e02<1) & (e04==3),1,0);
gen eh12   = cond((e02==1 | e02==2) & (e04==3),1,0);
gen eh34   = cond((e02==3 | e02==4) & (e04==3),1,0);
gen eh56   = cond((e02==5 | e02==6) & (e04==3),1,0);
gen eh611  = cond((e02>=6 & e02<=11) & (e04==3),1,0);
gen eh1215 = cond((e02>=12 & e02<=15) & (e04==3),1,0);
gen eh1617 = cond((e02==16 | e02==17) & (e04==3),1,0);

/* Cuenta a los familiares del jefe de hogar */
gen es_familia = cond( !(e04==15 | e04==16 | e04==17 | e04==18 |e04==19),1,0);
label var es_familia "Pariente Jfe";

/* Cuenta al núcleo familiar del jefe de hogar */
gen es_nucleo_f = cond( e04==1 | e04==2 | e04==3,1,0);
label var es_nucleo_f "Jfe, Conyugue o Hijo";

/* Subsidio*/
	/* Los monetarios ya están incluidos, también los que son en especies (ingresos)... */
	/* sólo queda Salud*/

	/* Sisbén 1-2 u otro (según régimen de salud).  e15_carnet_sisben no dice nada en últimas*/
gen sisben12   = cond( f03==5,1,0);
	
/* Ocupación*/
	/* Incluye a los niños de 10 a 12 años que trabajan... que son 3 */
gen es_ocp = cond(l01==1,1,0);
gen es_des = cond(l01==2 & e02>=12,1,0);
gen es_pei = cond((l01==3 | l01==4 | l01==5 | l01==6) & e02>=12,1,0);
gen es_nopea = cond(e02<12,1,0);

/* Informalidad */
/* (DANE). Según ésta Entidad, el SI esta compuesto */
/* por 1) los trabajadores familiares sin remuneración l17==9, los empleados domésticos l17==4 y los */
/* independientes distintos de profesionales y técnicos y 2) los asalariados del sector privado y */
/* los patronos vinculados a empresas de diez o menos trabajadores. */
	/* 1) Trabajador familiar o de empresa no remunerado; empleado doméstico*/
		/* if l17==9 | l17==10 | l17==4;  */
	/* 2) Si es idependiente: si terminó de estudiar, sólo los que tienen nivel inferior a técnico; */
	/* si no ha terminado, no debe estar en posgrado ni debe tener un diploma técnico */
		/* if (l17==6 | l17==7 | j11_cargo==9) & ( (i0401_niv_educ_aprob<5 & i02==2) | (!(i0701==6) & i02==2))*/
	/* 3) Si es asalariado privado o empleador en una empresa de 1 a 10 empleados */
		/* if (l17==1 | l17==7) & ( j25_pers_emp>0 & j25_pers_emp<=4)*/

gen informal=cond( (l17==9 | l17==10 | l17==4)|
				   ((l17==1 | l17==7) & ( l36>0 & l36<=3))|
				   ((l17==6 | l17==7 | l17== 3 |l17==8 | l17==5) & ( (i0401<5 & i02==2) |
  				      (!(i0701==6) & i02==1))) 
					,1,0);
gen informalf=cond( ((l17==9 & e04!=15) | l17==10 | (l17==4 & e04!=15))|((l17==1 | l17==7) & ( l36>0 & l36<=3))|((l17==6 | l17==7 | l17== 3 |l17==8 | l17==5) & ( (i0401<5 & i02==2) | (!(i0701==6) & i02==2))) ,1,0);

/* Servicio Doméstico. Aquí hay un problema: están los internos, pero me imagino que no los externos (1 día)*/
gen servdom=cond(e04==15,1,0);

/* Edad menor de la casa*/
gen e02_familia = cond(!(e04==15 | e04==16 | e04==17 | e04==18 |e04==19) ,e02,.);
gen e02_nucleo = cond((e04==3),e02,.);

label var e02_familia "Edad si es pariente Jfe";
label var e02_nucleo "Edad si es Jfe, Cnyge o Hijo";

/* Con quién se queda el hijo*/
xi i.g01, noomit;
gen  m5_otro=max(_Ig01_4,_Ig01_5,_Ig01_6,_Ig01_9);

gen m5_jardi=_Ig01_1;
gen m5_papasc=_Ig01_2; 
gen m5_papast=_Ig01_3; 
gen m5_remc=_Ig01_6;

/* drop if _Ig08_perm__99==1;  ????? Será? */
 
/* Cambio de ciudad */
/* gen cambciudad=cond(e14<=2,1,0); */

/* Vive en qué localidad*/
xi i.localidad, noomit;
renpfix _I "";
rename localidad id_loc;

/* COLLAPSE de Hogares */
	
/* Problema grave con las transferencias: si las ayudas van pa todos y lo recuentan? i_otros */	
drop if region!=5; /* Sólo	Bogotá*/
save "comedores2003.dta", replace;

/* ***********************************************************************************************************
**************************************************************************************************************
**************************** BASES DE DATOS CON VARIABLES POR HOGAR Y POR PERSONAS ***************************
**************************************************************************************************************
*********************************************************************************************************** */

# delim  cr
do "Hogares2003.do"
do "Esposo-Mujel2003.do"
# delim  cr

merge n:1 numero using "comedoresEsposos2003.dta", gen(merge_mujer_esposo)
merge n:1 numero using "comedoresHogar2003.dta"
drop if _merge!=3
drop _merge
gen ano=2003

gen mamaJefe= mujercabeza*esmama

* destring id_viv, replace

save "comedoresFinal2003.dta", replace

