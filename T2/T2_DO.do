******************************************************************

// 					   Do-File Tarea 2

******************************************************************

clear all

 cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T2"


import excel "Base1_T2", sheet("Datos") firstrow 
gen fecha_trimestral = qofd(observation_date)
format fecha_trimestral %tq
tsset fecha_trimestral
gen Log_I = log(INVP)

******************************************************************
// 					   Pregunta 1
******************************************************************


// Gráfico crudo
tsline Log_I 

// Gráfico con parámetros estéticos
tsline Log_I, legend(off) ///
	ytitle("Logaritmo de la Inversión privada doméstica") ///
	xtitle("Trimestre") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Evolución del logaritmo de la Inversión privada doméstica, USA") ///
	lcolor(midblue)

//1
pperron Log_I 

******************************************************************
// 					   Pregunta 3
******************************************************************

//3
gen t=_n 
gen t_2=t^2 

arima Log_I t t_2, arima(2,0,0)
outreg2 using reg_3.tex, replace

predict arima_model // tendencia del modelo
estat aroots, plotregion(lcolor(black)) ///
	ytitle("Eje de Nros. Imaginarios") ///
	xtitle("Eje de Nros. Reales")


// Gráfico en crudo
tsline Log_I arima_model, title(Serie It y Modelo Estimado)

// Gráfico con parámetros estéticos
tsline Log_I arima_model, legend(label(1 "Log(Inversión)") label(2 "Valor ajustado")) ///
	ytitle("Log. Inversión privada doméstica") ///
	xtitle("Trimestre") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Ajuste del modelo para el logaritmo de la Inversión, USA")
	
save "usa_investment.dta", replace


******************************************************************
// 					   Pregunta 4
******************************************************************


clear all
 cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T2"
import excel "USREC", sheet("Hoja2")  firstrow clear


gen fecha_trimestral = qofd(observation_date)
replace USREC = 1 if USREC > 0
format fecha_trimestral %tq     
tsset fecha_trimestral, quarterly
save "usa_recessions.dta", replace

merge 1:1 fecha_trimestral using usa_investment
drop _merge

arima Log_I t t_2 USREC, arima(2,0,0)
outreg2 using reg_4.tex, replace
estat aroots 
 

******************************************************************
// 					   Pregunta 5
******************************************************************

 
//5
 
tsfilter hp C_hp = Log_I, smooth(1600) 
sum C_hp
gen C_hp_M=r(mean)
// Gráfico crudo
tsline  C_hp C_hp_M, title(Ciclo HP. y Media)
// Gráfico con parámetros estéticos
tsline  C_hp C_hp_M, legend(off) ///
	xtitle("Trimestre") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Ciclo con Filtro HP y su Media Incondicional") ///
	lcolor(midblue)

// No necesario de agregar en el informe
pperron C_hp

arima Log_I t t_2, arima(2,0,0)
matrix coefs_preg5 = e(b)
matrix list coefs_preg5

// // Check a mano
// predict C_trend, residuals
// pperron C_trend
//
// gen C_trend_check_a_mano = Log_I - coefs_preg5[1,1]*t + coefs_preg5[1,2]*t_2 + coefs_preg5[1,1]
// //
// // sum C_trend
// // gen C_trend_M=r(mean)
// // tsline  C_trend C_trend_check_a_mano
//
// // Check a mano
// tsline  C_trend C_trend_M, title(Ciclo Trend. y Media)
// 

gen C_trend = Log_I - coefs_preg5[1,1]*t + coefs_preg5[1,2]*t_2 + coefs_preg5[1,1]

tsline C_hp C_trend C_hp_M, legend(order(1 "Ciclo con Tendencia estocástica" 2 "Ciclo con Tendencia determinística")) ///
	ytitle("Ciclo Estimado para la Inversión privada doméstica") ///
	xtitle("Trimestre") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Comparación de cilos estimados para la Inversión, USA")

	
// Visualización
tsline Log_I C_hp
tsline Log_I C_trend
 
tabstat C_trend C_hp, statistics(sd)


******************************************************************
// 					   Pregunta 6
******************************************************************


// 6 
pperron C_trend
pperron C_hp


******************************************************************
// 					   Pregunta 7
******************************************************************

wntestq C_hp, lags(68)


//7  
ac C_hp, lags(30) name(ac_HP, replace)
pac C_hp, lags(30) name(pac_HP,replace)

// Box Jenkins con parámetros estéticos
ac C_hp, lags(50) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	xtitle("Rezago") ///
	title("Autocorrelación del ciclo con tendencia estocástica") ///
	ytitle("") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)

pac C_hp, lags(30) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	xtitle("Rezago") ///
	title("Autocorrelación parcial del ciclo con tendencia estocástica") ///
	ytitle("") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)
// ARMA 4,3
	

arima C_hp, arima(4,0,3)
predict resids_hp_arma_4_3, r //calculo del residuo
predict hp_arma_4_3_hat, xb

// Pa cachar
wntestq resids_hp_arma_4_3, lags(8)

// Pal informe
// Test de Breusch-Godfrey (más eficiente)
reg resids_hp_arma_4_3 L(1/68).resids_hp_arma_4_3  			//Muchos rezagos por si acas
estat bgodfrey //No hay correcion serial entre los errores!

// Pa cachar
tsline resids_hp_arma_4_3


reg C_hp L(1/5).C_hp  
gen same_data = e(sample) 


forvalue i=1/5 {
	forvalue j=0/5 {
		quietly xi: arima C_hp if same_data==1, arima (`i',0,`j') iter(150)
		estimates store AR`i'MA`j'
	}
}
estimates stats _all

// ARMA 2,5

arima C_hp, arima(2,0,5)
predict residuals, r 

wntestq residuals, lags(70)
reg residuals L(1/68).residuals
estat bgodfrey


******************************************************************
// 					   Pregunta 8
******************************************************************



// Es un indice donde la UMICHIGAN HACEN ciertss pregunts como:
// Como cree que esta su familia financieramente hoy (bn/mal) luego otra pregunta como cree q estarán en el futuro(expectations)
// después pregunta como cree que estará la economia en general en los proxi 12 meses y depsués otra relacionada pero en los isguients años
//luego mediante una fórmula genera el indice
//Es un índice que ante mi opinión es bueno pero mejorable en el sentido que hay espacio a otras preguntas, quizás si esta empleado o no o si 
// considera y piensa q tendrá un trabajo estable durante los siguientes años



******************************************************************
// 					   Pregunta 9
******************************************************************



///9
preserve
   import excel "UMCSENT", sheet("Hoja1") firstrow clear 
  gen fecha_trimestral = qofd(observation_date)

format fecha_trimestral %tq     
 tsset fecha_trimestral, quarterly

 tempfile REC
  save `REC'
   restore
 merge 1:1 fecha_trimestral using `REC', nogenerate

gen L_Sent = log(UMCSENT) if t >= 52


 pperron L_Sent if t >= 52
 

 
arima C_hp L_Sent if t>=52, arima(2,0,5)
outreg2 using reg_9.tex, replace 


//10
gen USREC_L_HP = USREC*L1.C_hp

newey C_hp L1.C_hp USREC (USREC#cL1.C_hp), lag(7)
outreg2 using reg_10.tex, replace

gen DiffI = D.Log_I
newey DiffI L1.DiffI USREC (USREC#cL1.DiffI), lag(7)
outreg2 using reg_10_2.tex, replace


//11

preserve
   import excel "TB3MS", sheet("Hoja1") firstrow clear 
  gen fecha_trimestral = qofd(observation_date)

format fecha_trimestral %tq     
 tsset fecha_trimestral, quarterly

 tempfile REC
  save `REC'
   restore
 merge 1:1 fecha_trimestral using `REC', nogenerate
 
 
newey DiffI L1.DiffI USREC (USREC#cL1.DiffI) TB3MS , lag(7)
outreg2 using reg_11.tex, replace
