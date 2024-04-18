macro drop _all
clear all
 glo carpetaMadre "E:\Documents and Settings\Paul Andres\Mis documentos\Trabajos"
* glo carpetaMadre "C:\Documents and Settings\paul rodriguez\Mis documentos\Trabajos"
glo carpetaDatos "$carpetaMadre\Comedores\Old Version (PE)"
glo carpetaResul "$carpetaMadre\Comedores\Paper\Procesamiento\Bases Intermedias"
cd "$carpetaResul"
/* ***********************************************************************************************************
**************************************************************************************************************
********** CONSTRUCCIÓN DE LAS VARIABLES A NIVEL DE PERSONAS: MUJER Y SU ESPOSO SI EXISTE ********************
**************************************************************************************************************
*********************************************************************************************************** */
# delimit ;
 
 
/* ***********************************************************************************************************
********************* Esposos jefe o conyugue y la misma vive en el hogar ************************************
*********************************************************************************************************** */

/* Oferta Laboral de Mujeres. Datos a nivel de mujer */
use "comedores2003.dta";
/* Esposos jefe o conyugue y la misma vive en el hogar. Ojo con los homosexuales! ¿serán muchos? */
keep if  e03==1 & (e04==1 | e04==2) &  e0701==1;

		rename e02 esposo_edad;
		gen esposo_edadsqr = esposo_edad^2;
		
	/* Trabaja */
		gen esposo_trabaja = cond(l01==1,1,0);
		gen esposo_des = cond(l01==2 & esposo_edad>=12,1,0);
		gen esposo_pei = cond((l01==3 | l01==4 | l01==5 | l01==6) & esposo_edad>=12,1,0);
		gen esposo_nopea = cond(esposo_edad<12,1,0);
		
	/* Nivel Educativo Max. Problemas con títulos superiores,e s imposible saber la diferencia entre un maest/PhD*/
		gen esposo_estudia      = cond( i02==1,1,0);
		gen esposo_ningun_est      = cond(( i02==2 &   i0401==1),1,0);
		gen esposo_preescolar   = cond((i02==2 & i0401==2) | (i02==1 & i0701==2),1,0);
		gen esposo_primaria     = cond((i02==2 & i0401==3) | (i02==1 & i0701==3),1,0);
		gen esposo_bachillerato = cond((i02==2 & i0401==4) | (i02==1 & i0701>3),1,0);
		gen esposo_tecn_tecnl   = cond((i02==2 & i0401==5) | (i02==1 &  i08>2),1,0);
		gen esposo_univer_incom = cond((i02==2 & i0401==6) | (i02==1 & i0701==5),1,0);
		gen esposo_univer_compl = cond((i02==2 & i0401==7),1,0);
		gen esposo_posgra_incom = cond((i02==2 & i0401==8) | (i02==1 & i0701==6),1,0);
		gen esposo_posgra_comp  = cond((i02==2 & i0401==9) | (i02==1 & i08>=7),1,0);
		
	/* Años de educación: Preescolar a 0. Si de bachillerato son más de 11 años, deja 11. Suma adicionales sin problema. 
		No tiene en cuenta otros estudios terciarios. Si estudia posgrado, le imputamos 5 años de pregrado (no sé si estudió medicina o no)
		OJO: Hay carreras con más de 5 años de pregrado, son no hacer inferencias mal. Debería ser más bien, % completo de la carrera... pero no tengo esa info
	*/
		drop if i0402==99 | i0702==99;
		gen esposo_anos_est = 	cond(i02==2,
									cond( i0401==3 | i0401==4 ,  cond(i0402>11,11,i0402) , cond(i0401>4,11,0))+
									cond( i0401>4 & i0401<8, i0402, cond(i0401>7,5,0))+
									cond( i0401>7, i0402, 0)
								, cond(i02==1,
									cond( i0701==2 | i0701==3 ,   cond(i0702>11,11,i0702) , cond(i0701>3,11,0))+
									cond( i0701>3 & i0701<6, i0702, cond(i0701==6,5,0))+
									cond( i0701==6, i0702, 0)
								,.));		
	
	/* 	Ingreso Laboral */
		/* il_especie il_monetario il_subsidios*/
		rename il_especie esposo_il_especie;
		rename il_monetario esposo_il_monetario;
		rename il_subsidios esposo_il_subsidios;
	
	/* Condicion Salud */
	/* Con  un cambio de nombre se puede, pero bueno. La pregunta de quién paga es muy mala  */
	/* (para saber si es beneficiario */
		gen esposo_cronica=cond(f10==1 | f10==2,1,0);

		/* gen esposo_limitacion=cond(f10_limit_perm_afecta==1,1,0); */
		gen esposo_segsocial=cond(f01!=10,1,0);
		gen esposo_psalud30d=cond(f11==1,1,0);
	
	/* Area actividad economica */
			
		gen esposo_sec_agropecuario    = cond(l16>=01 & l16<=05,1,0);
		gen esposo_sec_minas	       = cond(l16>=10 & l16<=14,1,0);
		gen esposo_sec_industria       = cond(l16>=15 & l16<=37,1,0);
		gen esposo_sec_const_infraest  = cond(l16>=40 & l16<=45,1,0);
		gen esposo_sec_comercio        = cond(l16==50 & l16<=52,1,0);
		gen esposo_sec_turismo_restau  = cond(l16==55,1,0);
		gen esposo_sec_trans_comunic   = cond(l16>=60 & l16<=64,1,0);
		gen esposo_sec_financiero      = cond(l16>=65 & l16<=67,1,0);
		gen esposo_sec_inmob_empre_alq = cond(l16>=70 & l16<=74,1,0);
		gen esposo_sec_gobierno        = cond(l16==75,1,0);
		gen esposo_sec_educacion       = cond(l16==80,1,0);
		gen esposo_sec_salud		   = cond(l16==85,1,0);
		gen esposo_sec_otras_socl      = cond(l16>=90 & l16<=93,1,0);
		gen esposo_sec_otros_servicios = cond(l16>=95 & l16<=99,1,0);
		
	/* Tanto estacional como ocasional */
	/*	gen esposo_trabtemp=cond((f22_enfer_30dias==2 |  f22_enfer_30dias==3),1,0); */
	/*	rename j10_tiempo_trab_emp esposo_contlaboralm; */
			
	/* Oferta Laboral */
		rename  l40 esposo_hr_trab;
		rename  l4301 esposo_otro_trab;
	
	/*	informal */
	
		rename informal esposo_informal;
		rename informalf esposo_informalf;
	
	/* grupo etnico */
	
	 xi i.e08, noomit;
	 	  
	  gen esposo_etnia = _Ie08_1 + _Ie08_2 + _Ie08_3;
	  rename _Ie08_5 afro;
	  

keep numero e01 esposo_*;

/* Guardado el archivo*/
save "comedoresEsposos2003.dta", replace;

clear all;
use "comedores2003.dta";

/* ***********************************************************************************************************
********************* Oferta Laboral de Mujeres. Mujeres Cabeza o Conyugue ***********************************
*********************************************************************************************************** */

keep if  e03==2 & e02>=12;

		gen mujercabeza = (e04==1 | e04==2);

		rename e02 mujer_edad;
		gen mujer_edadsqr = mujer_edad^2;
		gen mujer_jefe = cond(e04==1,1,0);
		
	/* Estado Civil*/
		gen mujer_esposo = cond(e06==1 | e06==2,1,0);
		
	/* Trabaja. Keep if trabaja?? */
		gen mujer_trabaja = cond(l01==1,1,0);
		gen mujer_des = cond(l01==2 & mujer_edad==12,1,0);
		gen mujer_pei = cond((l01==3 | l01==4 | l01==5 | l01==6) & mujer_edad>=12,1,0);
		gen mujer_nopea = cond(mujer_edad<12,1,0);		

	/* Nivel Educativo Max*/
		gen mujer_estudia      = cond( i02==1,1,0);
		gen mujer_ningun_est      = cond(( i02==2 &   i0401==1),1,0);
		gen mujer_preescolar   = cond(( i02==2 &   i0401==2) | ( i02==1 & i0701==2),1,0);
		gen mujer_primaria     = cond(( i02==2 &   i0401==3) | ( i02==1 & i0701==3),1,0);
		gen mujer_bachillerato = cond(( i02==2 &   i0401==4) | ( i02==1 & i0701>3),1,0);
		gen mujer_tecn_tecnl   = cond(( i02==2 &   i0401==5) | ( i02==1 &  i08>2),1,0);		
		gen mujer_univer_incom = cond(( i02==2 &   i0401==6) | ( i02==1 & i0701==5),1,0);
		gen mujer_univer_compl = cond(( i02==2 &   i0401==7) ,1,0);
		gen mujer_posgra_incom = cond(( i02==2 &   i0401==8) | ( i02==1 & i0701==6),1,0);
		gen mujer_posgra_comp  = cond((i02==2 & i0401==9) | (i02==1 & i08>=7),1,0);
	
	/* Años de educación: Preescolar a 0. Si de bachillerato son más de 11 años, deja 11. Suma adicionales sin problema. 
		No tiene en cuenta otros estudios terciarios. Si estudia posgrado, le imputamos 5 años de pregrado (no sé si estudió medicina o no)
		OJO: Hay carreras con más de 5 años de pregrado, son no hacer inferencias mal. Debería ser más bien, % completo de la carrera... pero no tengo esa info
	*/
		drop if i0402==99 | i0702==99;
		gen mujer_anos_est = 	cond(i02==2,
									cond( i0401==3 | i0401==4 ,  cond(i0402>11,11,i0402) , cond(i0401>4,11,0))+
									cond( i0401>4 & i0401<8, i0402, cond(i0401>7,5,0))+
									cond( i0401>7, i0402, 0)
								, cond(i02==1,
									cond( i0701==2 | i0701==3 ,   cond(i0702>11,11,i0702) , cond(i0701>3,11,0))+
									cond( i0701>3 & i0701<6, i0702, cond(i0701==6,5,0))+
									cond( i0701==6, i0702, 0)
								,.));		
	
	
	/* 	Ingreso Laboral */
		/* il_especie il_monetario il_subsidios*/
		rename il_especie mujer_il_especie;
		rename il_monetario mujer_il_monetario;
		rename il_subsidios mujer_il_subsidios;
	
	/* Condicion Salud */
	/* Con  un cambio de nombre se puede, pero bueno. La pregunta de quién paga es muy mala  */
	/* (para saber si es beneficiario */
		gen mujer_cronica=cond(f10==1 | f10==2,1,0);
		/* gen mujer_limitacion=cond(f10_limit_perm_afecta==1,1,0);*/
		gen mujer_segsocial=cond(f01!=10,1,0);		 
		gen mujer_psalud30d=cond(f11==1,1,0);		 
	
	/* Area actividad economica */
		
		gen mujer_sec_agropecuario    = cond(l16>=01 & l16<=05,1,0);
		gen mujer_sec_minas	          = cond(l16>=10 & l16<=14,1,0);
		gen mujer_sec_industria       = cond(l16>=15 & l16<=37,1,0);
		gen mujer_sec_const_infraest  = cond(l16>=40 & l16<=45,1,0);
		gen mujer_sec_comercio        = cond(l16>=50 & l16<=52,1,0);
		gen mujer_sec_turismo_restau  = cond(l16==55,1,0);
		gen mujer_sec_trans_comunic   = cond(l16>=60 & l16<=64,1,0);
		gen mujer_sec_financiero      = cond(l16>=65 & l16<=67,1,0);
		gen mujer_sec_inmob_empre_alq = cond(l16>=70 & l16<=74,1,0);
		gen mujer_sec_gobierno        = cond(l16==75,1,0);
		gen mujer_sec_educacion       = cond(l16==80,1,0);
		gen mujer_sec_salud		      = cond(l16==85,1,0);
		gen mujer_sec_otras_socl      = cond(l16>=90 & l16<=93,1,0);
		gen mujer_sec_otros_servicios = cond(l16>=95 & l16<=99,1,0);
		
	/* Tanto estacional como ocasional */
	/*	gen mujer_trabtemp=cond((f22_enfer_30dias==2 |  f22_enfer_30dias==3),1,0); */
	/*	rename j10_tiempo_trab_emp mujer_contlaboralm; */
			
	/* Oferta Laboral */
		rename  l40 mujer_hr_trab;
		rename   l4301 mujer_otro_trab;
	
	/*	informal */
	
		rename informal mujer_informal;
		rename informalf mujer_informalf;
	
	/* grupo etnico */
	
	 xi i.e08, noomit;
	 	  
	  gen mujer_etnia = _Ie08_1 + _Ie08_2 + _Ie08_3 +_Ie08_4;
	  rename _Ie08_5 afro;
	  

keep numero e01 mujer_* id_loc mujercabeza esmama;

save "comedoresMujeres2003.dta", replace;

