
clear all
cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T3\Nueva carpeta"


// Tarea 3 -- P1\\

import excel "Base_Rem.xlsx", sheet("Hoja1") firstrow
save Rem.dta, replace



/////////////// 1 \\\\\\\\\\\\\\\\\\\
rename Remuneracion x_t
replace Periodo = mofd(Periodo) 
format Periodo %tm
tsset Periodo, monthly


sum x_t
gen x_t_mean=r(mean)
tsline x_t x_t_mean, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Serie Ingreso y su media") ///
	lcolor(midblue)
pperron x_t // Tiene Raíz Unitaria --> ergo no es estacionaria

// Code de Plot
tsline x_t x_t_mean, legend(off) ///
	ytitle("Crecimiento porcentual") ///
	xtitle("Mes") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Evolución del Crecimiento (%) del Índice de remuneraciones") ///
	lcolor(midblue)



///////////////// 2 \\\\\\\\\\\\\\\\\\\\
tsfilter hp x_c = x_t, smooth(129000)  // datos mensuales  lambda = 129000

sum x_c
gen x_c_M = r(mean)

// Gráfico con parámetros estéticos
tsline  x_c x_c_M, legend(off) ///
	xtitle("Mensual") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Ciclo con Filtro HP y su Media Incondicional") ///
	lcolor(midblue)

//histogram

gen norm = rnormal(0, 1)
histogram(x_c), norm legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Distribución Ciclo") ///
	lcolor(midblue)

// Code de Plot
histogram x_c, normal normopts(lc(blue)) kdensity kdenopts(lc(red)) legend(off) ///
    ytitle("Densidad del Ciclo") ///
    xtitle("Variación cíclica") ///
    plotregion(lcolor(black)) ///
    ylab(, nogrid) xlab(, nogrid) ///
    title("Histograma del Componente cíclico del Índice")
	
////////////// 3 \\\\\\\\\\\\\\\\\\
 
// Code del plot:

tsline  x_c x_c_M, legend(off) ///
	ytitle("Variación cíclica") ///
	xtitle("Mes") ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Evolución del del Componente cíclico del Índice de Remuneraciones") ///
	lcolor(midblue) // Volatility clustering


pperron x_c // estacionario pvalue: 0.000, Ciclo no es estacionario


/////////////// 4 \\\\\\\\\\\\\\\\\\\
				  
tsappend, add(10) //Agregando parámetros 

arima x_c, arima(4,0,0)
predict x_c_hat 


predict tc_stdv, mse // 
gen tc_Up_95ci = x_c_hat+1.96*(tc_stdv)^0.5
gen tc_Dw_95ci = x_c_hat-1.96*(tc_stdv)^0.5
gen tc_Up_90ci = x_c_hat+1.68*(tc_stdv)^0.5
gen tc_Dw_90ci = x_c_hat-1.68*(tc_stdv)^0.5


drop x_c_M
sum x_c
gen x_c_M = r(mean)

twoway (rarea tc_Up_95ci tc_Dw_95ci Periodo if tin(2023m9,2024m9) ,  yvarlab("95% CI") bcolor(gs12) clw(medthin medthin)) ///
(rarea tc_Up_90ci tc_Dw_90ci Periodo if tin(2023m9,2024m9) , yvarlab("90% CI") bcolor(gs14) clw(medthin medthin)) ///
(tsline x_c_M if tin(1990m1,2024m9), lcolor(midblue)) ///
(line x_c_hat Periodo if tin(2023m9,2024m9) , yvarlab("Forecast") clc("30 90 160") mc(black)  graphregion(color(white)) )  ///
(line x_c Periodo if Periodo>=tm(1990m1) & Periodo<=tm(2023m10), clc("180 80 100") mc(black)  graphregion(color(white))), ///
graphregion(color(white)) xtitle("Meses") ytitle("Variación Porcentual") title("Evolución y Proyección del Ciclo de Remuneraciones") name(forecast,replace) leg(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid)
	
	
twoway (rarea tc_Up_95ci tc_Dw_95ci Periodo if tin(2023m8,2024m6) ,  yvarlab("95% CI") bcolor(gs12) clw(medthin medthin)) ///
(rarea tc_Up_90ci tc_Dw_90ci Periodo if tin(2023m8,2024m6) , yvarlab("90% CI") bcolor(gs14) clw(medthin medthin)) ///
(line x_c_hat Periodo if tin(2023m9,2024m6) , yvarlab("Forecast") clc("30 90 160") mc(black)  graphregion(color(white)) )  ///
(line x_c Periodo if Periodo>=tm(2017m1) & Periodo<=tm(2023m8), clc("180 80 100") mc(black)  graphregion(color(white))), ///
graphregion(color(white)) xtitle("Meses")  ytitle("Variación Porcentual") title("Evolución y Proyección del Ciclo de Remuneraciones") name(forecast,replace) leg(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid)


/////////// 5 Informe \\\\\\\\\\\\\

// code oscar con variables definidas en el otro do-file

// gen tendencia_remuneraciones_hp = Remuneraciones - Remuneraciones_ciclo_hp
// gen ultimo_valor_tendencia_mas_ciclo = 9.915571 + remuneracion_ciclo_hat if tin(2023m9,2024m9)

// drop Remuneraciones_mean
// sum Remuneraciones
// gen Remuneraciones_mean=r(mean)
//
// twoway (tsline Remuneraciones Remuneraciones_mean tendencia_remuneraciones_hp, ///
// 	ytitle("Crecimiento porcentual") ///
// 	xtitle("Mes") ///
// 	plotregion(lcolor(black)) ///
// 	ylab(, nogrid) xlab(, nogrid) ///
// 	title("Evolución del Crecimiento (%) del Índice de remuneraciones") ///
// 	lcolor(midblue)) (tsline ultimo_valor_tendencia_mas_ciclo if tin(2023m9,2024m9)), ///
// 	legend(label(1 "Índice de Remuneraciones") label(2 "Media Incondicional") label(3 "Tendencia de Filtro HP") label(4 "Proyección del ciclo") position(6))
//
// twoway (tsline Remuneraciones Remuneraciones_mean tendencia_remuneraciones_hp if tin(2019m6,2024m9), ///
// 	ytitle("Crecimiento porcentual") ///
// 	xtitle("Mes") ///
// 	plotregion(lcolor(black)) ///
// 	ylab(, nogrid) xlab(, nogrid) ///
// 	title("Evolución del Crecimiento (%) del Índice de remuneraciones") ///
// 	lcolor(midblue)) (tsline ultimo_valor_tendencia_mas_ciclo if tin(2023m9,2024m9)), ///
// 	legend(label(1 "Índice de Remuneraciones") label(2 "Media Incondicional") label(3 "Tendencia de Filtro HP") label(4 "Proyección del ciclo") position(6))



/////////          6          \\\\\\\\\


///////////////// Recursive \\\\\\\\\\\\\\\\\\\

// Código incorrecto:
//
// gen Rec = . // Modelo AR(4)
// forvalues i = 253/500 {
//   newey x_c L1.x_c L2.x_c L3.x_c L4.x_c if _n>=1 & _n<`i', lag(6)
//   replace Rec = _b[_cons] + _b[L1.x_c]*L1.x_c + _b[L2.x_c]*L2.x_c + _b[L3.x_c]*L3.x_c + _b[L4.x_c]*L4.x_c in `i'
// }
//
//
//
// //Y con dos periodos hacia adelante:
//
// gen Rec_2 = .
// forvalues i = 252/500 {
//   local j=`i'+1
//   newey x_c L1.x_c L2.x_c L3.x_c L4.x_c if _n>=1 & _n<`i', lag(6)
//   replace Rec_2 = _b[_cons] + _b[L1.x_c]*L1.x_c + _b[L2.x_c]*L2.x_c + _b[L3.x_c]*L3.x_c + _b[L4.x_c]*L4.x_c in `j'
// }
//
// drop Rec Rec_2


// Código correcto:
// (usa la predicción para t+1 en t+2)
// (y corrige los lags: x_t es el lag x_t-2 en predicción para x t + 2)
// (entre otras correcciones)

gen Rec = . // Modelo AR(4)
gen Rec_2 = .


forvalues i = 253/500 {
	quietly newey x_c L1.x_c L2.x_c L3.x_c L4.x_c if _n>=1 & _n<`i', lag(4) //cada periodo vamos agregando 1 nuevo dato

	quietly replace Rec = _b[_cons] + _b[L1.x_c]*x_c + _b[L2.x_c]*L1.x_c + _b[L3.x_c]*L2.x_c + _b[L4.x_c]*L3.x_c in `i'
	
	quietly replace Rec_2 = _b[_cons] + _b[L1.x_c]*Rec + _b[L2.x_c]*x_c + _b[L3.x_c]*L1.x_c + _b[L4.x_c]*L2.x_c  in `i'

}


// Se corre porque en t predecimos para t+1, así que Rec hay que correrlo 1 para adelante para evaluarlo contra t+1 (y no contra t)
// (en la ayudantía no definen el salto tau, y lo que se hace es equivalente a hacerlo con tau)

gen step1 = L.Rec
gen step2 = L2.Rec_2


//Generamos errores de predicción y graficamos\\
gen R_error = x_c- step1
gen zero =.
replace zero = 0 if zero ==.

tsline R_error zero if _n>=253 & _n<=500,  name(Error_R, replace) ///
    plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Error de predicción a un periodo") ///
	lcolor(midblue) leg(off)
	
	
		
gen R2_error = x_c- step2
tsline R2_error zero if _n>=253 & _n<=500, name(Error_R2, replace) /// 
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Error de predicción a dos periodos") ///
	lcolor(midblue) leg(off)
	
graph combine Error_R Error_R2
	
	

tsline x_c Rec if _n>=253 & _n<=500, legend(off) name(R_F1, replace) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Forecast 1 periodo hacia adelante") ///
	lcolor(midblue) leg(off)
	

tsline x_c Rec_2 if _n>=253 & _n<=502, legend(off) name(R_F2, replace) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Forecast 2 periodos hacia adelante") ///
	lcolor(midblue) leg(off)
	
graph combine R_F1 R_F2
	
	



///////////             Rolling         \\\\\\\\\\\\\\\\\

// //1 periodo hacia adelante
//
// gen Roll = .
// forvalues i = 253/500 {
//   local j = `i' - 252
//   newey x_c L1.x_c L2.x_c L3.x_c L4.x_c if _n >= `j' & _n < `i', lag(6)
//   replace Roll = _b[_cons] + _b[L1.x_c]*L1.x_c + _b[L2.x_c]*L2.x_c + _b[L3.x_c]*L3.x_c + _b[L4.x_c]*L4.x_c in `i' if `i' > 252
// }
//
//
//
// //2 periodos hacia adelante
// gen Roll_2 = .
// forvalues i = 253/500 {
//     scalar p`i' = `i' + 1
//     local j = `i' - 251 // 
//     quietly newey x_c L1.x_c L2.x_c L3.x_c L4.x_c if _n >= `j' & _n < `i', lag(6)
//     replace Roll_2 = _b[_cons] + _b[L1.x_c]*L1.x_c + _b[L2.x_c]*L2.x_c + _b[L3.x_c]*L3.x_c + _b[L4.x_c]*L4.x_c in `=p`i''
// }


// Misma corrección:

// 1 y 2 periodos hacia adelante

gen Roll = .
gen Roll_2 = .
forvalues i = 253/500 {
  local j = `i' - 252
  newey x_c L1.x_c L2.x_c L3.x_c L4.x_c if _n >= `j' & _n < `i', lag(6)
  replace Roll = _b[_cons] + _b[L1.x_c]*x_c + _b[L2.x_c]*L1.x_c + _b[L3.x_c]*L2.x_c + _b[L4.x_c]*L3.x_c in `i' if `i' > 252
  replace Roll_2 = _b[_cons] + _b[L1.x_c]*Roll + _b[L2.x_c]*x_c + _b[L3.x_c]*L1.x_c + _b[L4.x_c]*L2.x_c in `i' if `i' > 252
}


gen step1_roll = L.Roll
gen step2_roll = L2.Roll_2



//Generamos errores de predicción y graficamos\\
gen Roll_error = x_c- step1_roll


tsline Roll_error zero if _n>=253 & _n<=500,  name(Error_Roll, replace) ///
    plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Error de predicción a un periodo") ///
	lcolor(midblue) leg(off)

		
gen Roll_error2 = x_c- step2_roll
tsline Roll_error2 zero if _n>=253 & _n<=500, name(Error_Roll2, replace) /// 
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Error de predicción a dos periodos") ///
	lcolor(midblue) leg(off)
	
graph combine Error_Roll Error_Roll2
	
	

tsline x_c Roll if _n>=253 & _n<=500, legend(off) name(Roll_F1, replace) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Forecast 1 periodo hacia adelante") ///
	lcolor(midblue) leg(off)
	

tsline x_c Roll_2 if _n>=253 & _n<=502, legend(off) name(Roll_F2, replace) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Forecast 2 periodos hacia adelante") ///
	lcolor(midblue) leg(off)
	
graph combine Roll_F1 Roll_F2

	
summarize R_error
summarize Roll_error



//Test de Sesgo
newey Roll_error, lag(6)
newey Roll_error2, lag(6)

//Test Racionalidad

newey Roll_error x_c_hat, lag(6)
newey Roll_error2 x_c_hat, lag(6)




/// 7 \\\

// Tipo de Cambio como proxy de Omega \\

preserve

import excel "TC.xlsx", sheet("Cuadro") firstrow clear 
replace Periodo = mofd(Periodo)
format Periodo %tm     
tsset Periodo, monthly 

tempfile REC
save `REC'

restore
merge 1:1 Periodo using `REC', nogenerate


newey Roll_error Dólarobservado, lag(6)
newey Roll_error2 Dólarobservado, lag(6)



// Proxy IMACEC \\

preserve

import excel "IMACEC.xlsx", sheet("Hoja1") firstrow clear 
replace Periodo = mofd(Periodo)
format Periodo %tm     
tsset Periodo, monthly 

tempfile REC
save `REC'

restore
merge 1:1 Periodo using `REC', nogenerate


newey Roll_error IMACEC, lag(6)
newey Roll_error2 IMACEC, lag(6)

// Proxy IMACEC \\

preserve

import excel "IMACEC.xlsx", sheet("Hoja1") firstrow clear 
replace Periodo = mofd(Periodo)
format Periodo %tm     
tsset Periodo, monthly 

tempfile REC
save `REC'

restore
merge 1:1 Periodo using `REC', nogenerate


newey Roll_error IMACEC, lag(6)
newey Roll_error2 IMACEC, lag(6)




// 8 \\

// gen Roll_3 = .
// forvalues i = 253/500 {
//   local j = `i' - 252
//   newey x_c L1.x_c  if _n >= `j' & _n < `i', lag(6)
//   replace Roll_3 = _b[_cons] + _b[L1.x_c]*L1.x_c  in `i' if `i' > 252
// }

// Misma corrección para pryección en t + 1: se usa el dato de xt como el rezago

gen Roll_3 = .
forvalues i = 253/500 {
  local j = `i' - 252
  newey x_c L1.x_c  if _n >= `j' & _n < `i', lag(6)
  replace Roll_3 = _b[_cons] + _b[L1.x_c]*x_c  in `i' if `i' > 252
}

// Se corre para hacer la resta correcta:
// El valor predicho en la celda anterior es el que corresponde a este periodo

gen step1_AR1 = L.Roll_3


gen Roll_error3 = x_c - step1_AR1
gen Roll_error3_cuad = (Roll_error3)^2 
gen Roll_error_cuad=(Roll_error)^2
gen deltaL = Roll_error_cuad - Roll_error3_cuad



//Comprobamos que diferencia sea estacionaria
pperron deltaL


//Test de Dibold & Mariano
reg deltaL

// Corrección: newey
newey deltaL, lag(6)


********************************************************************************************

clear all
cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T3\Nueva carpeta"

// Tarea 3 -- P2\\

// Seteamos los datos
import excel using "S&P", sheet ("Hoja2") clear firstrow
format Date %td
tset Date


bcal create SP500, from (Date) center(2004jan05) replace
generate b_date =bofd("SP500", Date)
format b_date %tbSP500
tset b_date 
format b_date %tbSP500
tset b_date 
drop Date


 //////////////// 1 \\\\\\\\\\\\\\

gen ret_SP =log(Price)-log(L1.Price)
sum ret_SP
gen SP_M= r(mean)


tsline ret_SP SP_M, ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Retornos S&P500") ///
	lcolor(midblue) ytitle("Retornos porcentuales") ///
	xtitle(Fecha) leg(off)


pperron ret_SP

qui ac ret_SP,lags(30) name(AC, replace) plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("AC: Retorno S&P500") xtitle("Rezago") ytitle("Autocorrelación") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)

qui pac ret_SP,lags(30) name(PAC,replace) plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("PAC: Retorno S&P500")  xtitle("Rezago") ytitle("Autocorrelación Parcial") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)
	
graph combine AC PAC





//  La serie  tiene pinta de ARMA(p,q)
reg ret_SP L(1/5).ret_SP
gen same_data = e(sample)
forvalue i=0/5 {
	forvalue j=0/5 {
		quietly xi: arima ret_SP if same_data==1, arima (`i',0,`j') iter(150)
		estimates store AR`i'MA`j'
	}
}
estimates stats _all 



arima ret_SP if same_data==1, arima(2,0,3)  
estat aroots
predict u_hat, resid


qui ac u_hat,lags(30) name(AC_r, replace) plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("AC: Residuo")  xtitle("Rezago") ytitle("Autocorrelación") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)

qui pac u_hat,lags(30) name(PAC_r,replace) plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("PAC: Residuo")  xtitle("Rezago") ytitle("Autocorrelación Parcial") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)
	
graph combine AC_r PAC_r

gen u_hat2 = u_hat^2


qui ac u_hat2,lags(30) name(AC_r2, replace) plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("AC: Residuo2")  xtitle("Rezago") ytitle("Autocorrelación")  ///
	note("") ///
	lcolor(red) ///
	mcolor(red)

qui pac u_hat2,lags(30) name(PAC_r2,replace) plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("PAC: Residuo2")  xtitle("Rezago") ytitle("Autocorrelación Parcial") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)
	
graph combine AC_r2 PAC_r2


reg u_hat L(1/30).u_hat	
estat bgodfrey // La serie no tiene autocorrelacion serial


// 2



newey u_hat2 l(1/2).u_hat2, lag(2) // acá lo paso con el residuo al cuadrado
test L1.u_hat2==0, accumulate //Rechaza la hipótesis nula, hay un ARCH




//////////////////3 \\\\\\\\\\\\\\\\\\

//ARCH(1)
//arch ret_SP, ar(1/2) ma(1/3) arch(1)
//estat ic // -31056.86   ** Lo dejo comentado, porque sino no correrería todo de una
//ARCH(2)
arch ret_SP, ar(1/2) ma(1/3) arch(2)
estat ic // -31340.23
//GARCH(1,1)
arch ret_SP, ar(1/2) ma(1/3) arch(1) g(1)
estat ic //  -32655.6
//GARCH(1,2)
arch ret_SP, ar(1/2) ma(1/3)  arch(1) g(1/2)
estat ic //-32653.35
//GARCH(2,1)
arch ret_SP, ar(1/2) ma(1/3) arch(1/2) g(1)
estat ic // -32655.35
//GARCH(2,2)
//arch ret_SP, ar(1/2) ma(1/3) arch(1/2)  g(1/2)
//estat ic // no converge



////////////// 4 \\\\\\\\\\\\\\\\\\\\\\

arch ret_SP, ar(1/2) ma(1/3) arch(1) g(1)
predict garch_re, residual
predict garch_var, var
gen se_garch = garch_re/sqrt(garch_var)

gen se2_garch = (garch_re^2)/garch_var

qui ac se2_garch, lags (20) name(Ac2, replace)  plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("AC: Residuo al Cuadrado, GARCH")  xtitle("Rezago") ytitle("Autocorrelación") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)
	
qui pac se2_garch, lags (20) name(Pac2, replace)   plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("PAC: Residuo al Cuadrado, GARCH")  xtitle("Rezago") ytitle("Autocorrelación Parcial") ///
	note("") ///
	lcolor(red) ///
	mcolor(red)

graph combine Ac2 Pac2

newey se_garch L(1/2).se_garch, lag(2)
test L1.se_garch==0, accumulate


///////////////////////// 5 \\\\\\\\\\\\\\\\\\\\\\\\\\\\


tsline garch_var, ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Varianza S&P500") ///
	lcolor(midblue)

