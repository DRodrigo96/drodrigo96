




clear all
set more off

*	¡ADVERTENCIA! Solo modificar "cd". Poner la dirección de la carpeta "Estimaciones y Data".
cd "C:\Users\David\Desktop\Universidad\No Paramétrica\Trabajo Práctico\Estimaciones y Data\\"

global a "1_Do"
global b "2_BD"
global c "3_Temp"
global d "4_Tablas"



/*	

*	¡ADVERTENCIA! Solo correr esta sección si se cuenta con las bases
*	de datos de la ENAHO 2014-2018 indicadas en las instrucciones.


*█		GOBERNABILIDAD Y NIVEL DE EDUCACION

foreach x in 14 15 16 17 18 {
use "$b\\enaho01b-20`x'-1.dta", clear
keep conglome vivienda hogar codperso codinfor ubigeo dominio estrato p2_1_01 p2_2_01 p208_01  p301_01
gen year = 20`x'

*	Years de educacion	
	keep if p208_01 > 17 & ~missing(p208_01)
	recode p301_01 (3 = 2) (5 = 4) (7 = 6) (9 = 6)
	drop if p301_01 == 12 | missing(p301_01)
	
	quietly {
	gen		a_edu = .
	replace a_edu = 0 	 if p301_01 == 1
	replace a_edu = 2 	 if p301_01 == 2	
	replace a_edu = 8 	 if p301_01 == 4	
	replace a_edu = 13 	 if p301_01 == 6	
	replace a_edu = 16 	 if p301_01 == 8	
	replace a_edu = 18 	 if p301_01 == 10
	replace a_edu = 20 	 if p301_01 == 11
}	//
	
	
*	Tolerancia a la corrupcion
	recode p2_1_01 (0 = 1) (1 = 0), gen(t_corrup)
	
*	Etiquetas
	label var a_edu "Años de educación"
	label var t_corrup "Tolerancia a la corrupción"
	label define t_corrup_lab 0 "Intolerante" 1 "Tolerante"
	label values t_corrup t_corrup_lab
	
	
	drop p2_1_01 p301_01
	egen id = concat(year ubigeo dominio estrato conglome vivienda hogar codperso codinfor)
	save "$c\\b_1_20`x'.dta", replace
}	//	

	use "$c\\b_1_2014.dta", clear
	foreach x in 15 16 17 18 {
	append using "$c\\b_1_20`x'.dta"
}	//

save "$c\\b_1_14-18.dta", replace



*█		EMPLEO E INGRESOS	
		
		
foreach x in 14 15 16 17 18 {	
use "$b\\enaho01a-20`x'-500.dta", clear
keep conglome vivienda hogar ubigeo dominio estrato codperso codinfor ocupinf i524e1 i538e1 p208a
gen year = 20`x'

*	Total de ingreso laboral mensual (principal y secundario)
	egen t_ing_a = rowtotal(i524e1 i538e1)
	replace t_ing_a = . if t_ing_a == 0
	*replace t_ing_a = 0 if missing(t_ing_a)
	gen t_ing_m = t_ing_a/12
	
*	Condicion de informal
	recode ocupinf (2 = 0), gen(i_inf)

*	Etiquetas
	label var t_ing_a "Ingreso laboral anual"
	label var t_ing_m "Ingreso laboral mensual"
	label var i_inf	  "Trabajador informal"
	label define i_inf_lab 0 "Formal" 1 "Informal"
	label values i_inf i_inf_lab
	
	
	keep if (p208a > 17 & ~missing(ocupinf) & ~missing(t_ing_m))
	drop i524e1 i538e1 p208a ocupinf
	egen id = concat(year ubigeo dominio estrato conglome vivienda hogar codperso codinfor)
	save "$c\\b_2_20`x'.dta", replace
}	//
	
	use "$c\\b_2_2014.dta", clear
	foreach x in 15 16 17 18 {
	append using "$c\\b_2_20`x'.dta"
}	//

save "$c\\b_2_14-18.dta", replace
	
	
	
*█		CARACTERÍSTICAS DEL HOGAR

foreach x in 14 15 16 17 18 {	
use "$b\\enaho01-20`x'-100.dta", clear
keep conglome vivienda hogar ubigeo dominio estrato nbi1 nbi2 nbi3 nbi4 nbi5 factor07
gen year = 20`x'

*	Necesidades basicas insatisfechas
	forvalues i = 1/5 {
	keep if nbi`i' ~= .
}	//	

	quietly {
	label var nbi1 "Vivienda inadecuada"
	label var nbi2 "Vivienda con hacinamiento" 
	label var nbi3 "Vivienda sin servicios higiénicos"
	label var nbi4 "Hogar con niños sin asistir a la escuela"
	label var nbi5 "Hogar con alta dependencia económica"
}	//	
	
		
	save "$c\\b_3_20`x'.dta", replace
}	//	

	use "$c\\b_3_2014.dta", clear
	foreach x in 15 16 17 18 {
	append using "$c\\b_3_20`x'.dta"
}	//

save "$c\\b_3_14-18.dta", replace


	
*█		BASE DE DATOS COMPLETA

use "$c\\b_1_14-18.dta", clear
quietly {
merge 1:1 id using "$c\\b_2_14-18.dta"
keep if _merge == 3 
drop _merge
merge m:1 year ubigeo dominio estrato conglome vivienda hogar using "$c\\b_3_14-18.dta"
keep if _merge == 3 
drop _merge
save "$c\\b_4_14-18.dta", replace
}	//

*/



use "$c\\b_4_14-18.dta", clear
label drop nbi1 nbi2 nbi3 nbi4 nbi5


*	Departamentos, provincias y ambito
	quietly {

	gen dpto = substr(ubigeo,1,2)
	destring dpto, replace
	#delimit;
	label define dpto_lab 	
	1 "Amazonas" 			
	2 "Ancash" 				
	3 "Apurimac" 			
	4 "Arequipa" 			
	5 "Ayacucho" 			
	6 "Cajamarca" 			
	7 "Callao" 				
	8 "Cusco" 				
	9 "Huancavelica" 		
	10 "Huanuco" 			
	11 "Ica" 				
	12 "Junin" 				
	13 "La Libertad" 		
	14 "Lambayeque" 		
	15 "Lima" 				
	16 "Loreto" 			
	17 "Madre de Dios" 		
	18 "Moquegua" 			
	19 "Pasco" 				
	20 "Piura" 				
	21 "Puno" 				
	22 "San Martin" 		
	23 "Tacna" 				
	24 "Tumbes" 			
	25 "Ucayali";
	#delimit cr
	label values dpto dpto_lab

	gen prov = substr(ubigeo,1,4)
	destring prov, replace

	gen area = 1 if estrato < 6
	replace area = 2 if estrato >= 6
	
*	Etiquetas
	label var dpto "Departamento"
	label var area "Ámbito"
	label define area_lab 1 "Urbana" 2 "Rural" 
	label values area area_lab
}	// 


*	Muestra
	tab year [iw = factor07] 
	tab dpto year [iw = factor07]
	
	preserve
	collapse (count) N = t_corrup [iw = factor07], by(year)
	export excel "$d\\m_total_14-18.xlsx", firstrow(variables) replace
	restore
	
	preserve
	collapse (count) N = t_corrup [iw = factor07], by(dpto year)	
	export excel "$d\\m_dpto_14-18.xlsx", firstrow(variables) replace
	restore

*	Estadisticas descriptivas
*	Variables cuantitativas para el total de muestra
	foreach x in p208_01 a_edu t_ing_a t_ing_m {
	 bysort year: sum `x' [iw = factor07]  
}	//	
	
	preserve
	collapse (mean) p208_01 a_edu t_ing_a t_ing_m [iw = factor07], by(year)
	export excel using "$d\\tabla_1.1_14-18.xlsx", firstrow(variables) replace
	restore
	
	preserve
	collapse (sd) p208_01 a_edu t_ing_a t_ing_m [iw = factor07], by(year)
	export excel using "$d\\tabla_1.2_14-18.xlsx", firstrow(variables) replace
	restore
	
*	Variables cualitativas para el total de muestra
	foreach x in t_corrup i_inf nbi1 nbi2 nbi3 nbi4 nbi5 {
	tab year `x' [iw = factor07]  
}	//

	preserve 
	foreach x in t_corrup i_inf nbi1 nbi2 nbi3 nbi4 nbi5 {
	quietly tab `x', gen(`x'_)
	}
	collapse (sum) t_corrup_* i_inf_* nbi1_* nbi2_* nbi3_* nbi4_* nbi5_*  [iw = factor07], by(year)
	export excel "$d\\tabla_2_14-18.xlsx", firstrow(variables) replace
	restore	
	
	
*	Variables cuantitativas por departamento
	tab   dpto year [iw = factor07]
	table dpto year [iw = factor07], c(mean p208_01 mean a_edu mean t_ing_a mean t_ing_m)
	table dpto year [iw = factor07], c(sd p208_01 sd a_edu sd t_ing_a sd t_ing_m)

	preserve
	collapse (mean) p208_01 a_edu t_ing_a t_ing_m [iw = factor07], by(dpto year)
	export excel using "$d\\tabla_3.1_14-18.xlsx", firstrow(variables) replace
	restore
	
	preserve
	collapse (sd) p208_01 a_edu t_ing_a t_ing_m [iw = factor07], by(dpto year)
	export excel using "$d\\tabla_3.2_14-18.xlsx", firstrow(variables) replace
	restore

	
*	Variables cualitativas por departamento
	foreach x in t_corrup i_inf nbi1 nbi2 nbi3 nbi4 nbi5 {
	bysort year: tab dpto `x' [iw = factor07], row
}	//

	preserve
	foreach x in t_corrup i_inf nbi1 nbi2 nbi3 nbi4 nbi5 {
	quietly tab `x', gen(`x'_)
	}
	collapse (sum) t_corrup_* i_inf_* nbi1_* nbi2_* nbi3_* nbi4_* nbi5_* [iw = factor07], by(dpto year)
	export excel "$d\\tabla_4_14-18.xlsx", firstrow(variables) replace
	restore	

*	Obejtivos secundarios
	foreach x in 14 15 16 17 18 {
	table area [iw = factor07] if year == 20`x', c(count t_corrup mean t_corrup mean i_inf)
	}

	gen nse = .
	sum t_ing_m, d
	replace nse = 1 if t_ing_m < r(p25)
	replace nse = 2 if (t_ing_m >= r(p25) & t_ing_m < r(p50))
	replace nse = 3 if (t_ing_m >= r(p50) & t_ing_m < r(p75))
	replace nse = 4 if t_ing_m >= r(p75)

	foreach x in 14 15 16 17 18 {
	table nse [iw = factor07] if year == 20`x', c(count t_corrup mean t_corrup mean i_inf)
	}

save "$c\\b_5_14-18.dta", replace



*█		MODELO ECONOMÉTRICO (tasas a nivel provincial)
	
	use "$c\\b_5_14-18.dta", clear 
	
	preserve
	collapse (mean) t_corrup i_inf nbi* p208_01 a_edu t_ing_m [iw = factor07], by(year prov)
	npregress kernel t_corrup i_inf p208_01 a_edu t_ing_m nbi*,  vce(bootstrap, reps(100) seed(100))
	restore

* ////////////////////////////////////////////////////////////////////////

