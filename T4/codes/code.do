******************************************************************

// 					   Draft Tarea 4

******************************************************************

clear all
cd "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4"


import excel "PCOPPUSDM.xlsx", sheet("FRED Graph") firstrow cellrange(A11:B263)
gen month = mofd(observation_date)
tsset month, monthly

gen cobre = ln(PCOPPUSDM)
tsline cobre


******************************************************************
// 					   Pregunta 1
******************************************************************


arima PCOPPUSDM, arima(12,0,0)
predict shocks, residuals

tsline shocks
// drop observation_date
keep month shocks cobre


******************************************************************
// 					   Pregunta 2
******************************************************************


save bbdd_tarea, replace


clear all
import excel "Cuadro_21112023014634.xlsx", sheet("Cuadro") firstrow
gen month = mofd(Periodo)
tsset month, monthly
keep month Imacec Imacecnominero

merge 1:1 month using bbdd_tarea
drop _merge

gen ln_imacec = ln(Imacec)
gen ln_imacec_no_minero = ln(Imacecnominero)

gen N = _n
drop if N >= 241
drop N
drop Imacec Imacecnominero

save bbdd_tarea, replace


clear all
import excel "Cuadro_21112023014835.xlsx", sheet("Cuadro") firstrow

gen month = mofd(Period)
tsset month, monthly
rename HeadlineCPICBCslicing inflacion
keep month inflacion

merge 1:1 month using bbdd_tarea
drop _merge
gen N = _n
drop if N >= 241
drop N

save bbdd_tarea, replace
// clear all
// use bbdd_tarea

tsline ln_imacec
tsline ln_imacec_no_minero
tsline inflacion

correlate 


******************************************************************
// 					   Pregunta 3
******************************************************************

// Imacec

local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_`h' = f`h'.ln_imacec
}
cap drop b_shock_imacec u_shock_imacec d_shock_imacec Years Zero
gen Years = _n-1 if _n<=`hmax'
gen Zero =  0    if _n<=`hmax'
gen b_shock_imacec=0
gen u_shock_imacec=0		//Límite superior del IC
gen d_shock_imacec=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_`h' shocks l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_shock_imacec = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_shock_imacec = _b[shocks] + 1.645* _se[shocks]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_shock_imacec = _b[shocks] - 1.645* _se[shocks]  if _n == `h'+1
}
gen b_shock_imacec_level = b_shock_imacec

// Plot sin la línea de cero para chequear visualmente la significancia
twoway ///
(rarea u_shock_imacec d_shock_imacec Years,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_shock_imacec_level Years, legend(off) lcolor(blue) ///
lpattern(solid) lwidth(thick) ///
title("IRF", color(black) size(medsmall)) ///
ytitle("Ln I", size(medsmall)) xtitle("Month", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white)))
// Interpretación cuantitativa: Aumento de 1 unidad en el ln(Precio cobre)
// genera aumento de \Beta unidades en el ln(Imacec)


// Imacec no minero

local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_no_minero_`h' = f`h'.ln_imacec_no_minero
}
cap drop b_shock_imacec_no_minero u_shock_imacec_no_minero d_shock_imacec_no_minero
gen b_shock_imacec_no_minero=0
gen u_shock_imacec_no_minero=0		//Límite superior del IC
gen d_shock_imacec_no_minero=0		//Límite inferior del IC
// Loop for Imacec no minero
forv h = 0/`hmax' {
	 newey ln_imacec_no_minero_`h' shocks l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_shock_imacec_no_minero = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_shock_imacec_no_minero = _b[shocks] + 1.645* _se[shocks]  	  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_shock_imacec_no_minero = _b[shocks] - 1.645* _se[shocks]  	  if _n == `h'+1
}
gen b_shock_imacec_no_minero_level = b_shock_imacec_no_minero

// Plot sin la línea de cero para chequear visualmente la significancia
twoway ///
(rarea u_shock_imacec_no_minero d_shock_imacec_no_minero Years,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_shock_imacec_no_minero_level Years, legend(off) lcolor(blue) ///
lpattern(solid) lwidth(thick) ///
title("IRF", color(black) size(medsmall)) ///
ytitle("Ln I NM", size(medsmall)) xtitle("Month", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white)))
// Interpretación cuantitativa: Aumento de 1 unidad en el ln(Precio cobre)
// genera aumento de \Beta unidades en el ln(Imacec No Minero)



******************************************************************
// 					   Pregunta 4
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen inflacion_`h' = f`h'.inflacion
}
cap drop b_shock_inflacion u_shock_inflacion d_shock_inflacion
gen b_shock_inflacion=0
gen u_shock_inflacion=0		//Límite superior del IC
gen d_shock_inflacion=0		//Límite inferior del IC
// Loop for Imacec no minero
forv h = 0/`hmax' {
	 newey inflacion_`h' shocks l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_shock_inflacion = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_shock_inflacion = _b[shocks] + 1.645* _se[shocks]  	  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_shock_inflacion = _b[shocks] - 1.645* _se[shocks]  	  if _n == `h'+1
}
gen b_shock_inflacion_level = b_shock_inflacion

// Plot sin la línea de cero para chequear visualmente la significancia
twoway ///
(rarea u_shock_inflacion d_shock_inflacion Years,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_shock_inflacion_level Years, legend(off) lcolor(blue) ///
lpattern(solid) lwidth(thick) ///
title("IRF", color(black) size(medsmall)) ///
ytitle("inflacion", size(medsmall)) xtitle("Month", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white)))
// Interpretación cuantitativa: Aumento de 1 unidad en el ln(Precio cobre)
// genera aumento de \Beta unidades en la inflación


save data_a_pregunta_6, replace
clear all
use data_a_pregunta_6


******************************************************************
// 					   Pregunta 6
******************************************************************

gen dummy_efecto_positivo = 0
replace dummy_efecto_positivo = 1 if shocks > 0
gen interaccion = dummy_efecto_positivo*shocks


// Imacec
******************************************************************
// 					   Test estadístico
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_`h'_modelo_2 = f`h'.ln_imacec 
}
cap drop b_interaccion_imacec u_interaccion_imacec d_interaccion_imacec
gen b_interaccion_imacec=0
gen u_interaccion_imacec=0		//Límite superior del IC
gen d_interaccion_imacec=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_`h'_modelo_2 shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_interaccion_imacec = _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_interaccion_imacec = _b[interaccion] + 1.645* _se[interaccion]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_interaccion_imacec = _b[interaccion] - 1.645* _se[interaccion]  if _n == `h'+1
}
gen b_interaccion_imacec_level = b_interaccion_imacec

// Plot sin la línea de cero para chequear visualmente la significancia
twoway ///
(rarea u_interaccion_imacec d_interaccion_imacec Years,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_interaccion_imacec_level Years, legend(off) lcolor(black) ///
lpattern(solid) lwidth(thick) ///
title("Coeficiente en el término de interacción", color(black) size(medsmall)) ///
ytitle("ln(Imacec)", size(medsmall)) xtitle("", size(medsmall)) ///
graphregion(color(white)) plotregion(lcolor(black)))



******************************************************************
// 				Impulso respuesta efecto positivo
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen PrecioCobre_`h' = f`h'.cobre 
}
cap drop b_PrecioCobre_pos u_PrecioCobre_pos d_PrecioCobre_pos
gen b_PrecioCobre_pos=0
gen u_PrecioCobre_pos=0		//Límite superior del IC
gen d_PrecioCobre_pos=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey PrecioCobre_`h' shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_PrecioCobre_pos = _b[shocks] + _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_PrecioCobre_pos = _b[shocks] + _b[interaccion] + 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_PrecioCobre_pos = _b[shocks] + _b[interaccion] - 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1
}
gen b_PrecioCobre_pos_level = b_PrecioCobre_pos


local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_`h'_pos = f`h'.ln_imacec 
}
cap drop b_pos_imacec u_pos_imacec d_pos_imacec
gen b_pos_imacec=0
gen u_pos_imacec=0		//Límite superior del IC
gen d_pos_imacec=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_`h'_pos shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_pos_imacec = _b[shocks] + _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_pos_imacec = _b[shocks] + _b[interaccion] + 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_pos_imacec = _b[shocks] + _b[interaccion] - 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1
}
gen b_pos_imacec_level = b_pos_imacec


set graphics off
tw (rarea u_pos_imacec d_pos_imacec Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_pos_imacec Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Imacec)") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea u_PrecioCobre_pos d_PrecioCobre_pos Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_PrecioCobre_pos Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)

set graphics on
graph combine  vargk_log_Imacec vargk_PrecioCobre,title("Shock Positivo del Precio del Cobre")  name(LP, replace)


save data_a_pregunta_6_chekpoint2, replace
clear all
use data_a_pregunta_6_chekpoint2


******************************************************************
// 				Impulso respuesta efecto negativo
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen PrecioCobre_`h'_neg = f`h'.cobre 
}
cap drop b_PrecioCobre_neg u_PrecioCobre_neg d_PrecioCobre_neg
gen b_PrecioCobre_neg=0
gen u_PrecioCobre_neg=0		//Límite superior del IC
gen d_PrecioCobre_neg=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey PrecioCobre_`h'_neg shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_PrecioCobre_neg = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_PrecioCobre_neg = _b[shocks] + 1.645* _se[shocks]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_PrecioCobre_neg = _b[shocks] - 1.645* _se[shocks]  if _n == `h'+1
}
gen b_PrecioCobre_neg_level = b_PrecioCobre_neg


local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_`h'_neg = f`h'.ln_imacec 
}
cap drop b_neg_imacec u_neg_imacec d_neg_imacec
gen b_neg_imacec=0
gen u_neg_imacec=0		//Límite superior del IC
gen d_neg_imacec=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_`h'_neg shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_neg_imacec = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_neg_imacec = _b[shocks] + 1.645* _se[shocks]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_neg_imacec = _b[shocks] - 1.645* _se[shocks]  if _n == `h'+1
}
gen b_neg_imacec_level = b_neg_imacec

set graphics off
tw (rarea u_neg_imacec d_neg_imacec Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_neg_imacec Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Imacec)") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea u_PrecioCobre_neg d_PrecioCobre_neg Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_PrecioCobre_neg Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)

set graphics on
graph combine  vargk_log_Imacec vargk_PrecioCobre,title("Shock Negativo del Precio del Cobre")  name(LP, replace)





// Imacec No Minero
******************************************************************
// 					   Test estadístico
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_NM_`h'_modelo_2 = f`h'.ln_imacec_no_minero
}
cap drop b_interaccion_imacec_NM u_interaccion_imacec_NM d_interaccion_imacec_NM
gen b_interaccion_imacec_NM=0
gen u_interaccion_imacec_NM=0		//Límite superior del IC
gen d_interaccion_imacec_NM=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_NM_`h'_modelo_2 shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_interaccion_imacec_NM = _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_interaccion_imacec_NM = _b[interaccion] + 1.645* _se[interaccion]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_interaccion_imacec_NM = _b[interaccion] - 1.645* _se[interaccion]  if _n == `h'+1
}
gen b_interaccion_imacec_NM_level = b_interaccion_imacec_NM

// Plot sin la línea de cero para chequear visualmente la significancia
twoway ///
(rarea u_interaccion_imacec_NM d_interaccion_imacec_NM Years,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_interaccion_imacec_NM_level Years, legend(off) lcolor(black) ///
lpattern(solid) lwidth(thick) ///
title("Coeficiente en el término de interacción", color(black) size(medsmall)) ///
ytitle("ln(Imacec No Minero)", size(medsmall)) xtitle("", size(medsmall)) ///
graphregion(color(white)) plotregion(lcolor(black)))



******************************************************************
// 				Impulso respuesta efecto positivo
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_NM_`h'_pos = f`h'.ln_imacec_no_minero 
}
cap drop b_pos_imacec_NM u_pos_imacec_NM d_pos_imacec_NM
gen b_pos_imacec_NM=0
gen u_pos_imacec_NM=0		//Límite superior del IC
gen d_pos_imacec_NM=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_NM_`h'_pos shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_pos_imacec_NM = _b[shocks] + _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_pos_imacec_NM = _b[shocks] + _b[interaccion] + 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_pos_imacec_NM = _b[shocks] + _b[interaccion] - 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1
}
gen b_pos_imacec_NM_level = b_pos_imacec_NM


set graphics off
tw (rarea u_pos_imacec_NM d_pos_imacec_NM Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_pos_imacec_NM Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Imacec No Minero)") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea u_PrecioCobre_pos d_PrecioCobre_pos Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_PrecioCobre_pos Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)

set graphics on
graph combine  vargk_log_Imacec vargk_PrecioCobre,title("Shock Positivo del Precio del Cobre")  name(LP, replace)



******************************************************************
// 				Impulso respuesta efecto negativo
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen ln_imacec_NM_`h'_neg = f`h'.ln_imacec_no_minero 
}
cap drop b_neg_imacec_NM u_neg_imacec_NM d_neg_imacec_NM
gen b_neg_imacec_NM=0
gen u_neg_imacec_NM=0		//Límite superior del IC
gen d_neg_imacec_NM=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey ln_imacec_NM_`h'_neg shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_neg_imacec_NM = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_neg_imacec_NM = _b[shocks] + 1.645*_se[shocks]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_neg_imacec_NM = _b[shocks] - 1.645*_se[shocks]  if _n == `h'+1
}
gen b_neg_imacec_NM_level = b_neg_imacec_NM

set graphics off
tw (rarea u_neg_imacec_NM d_neg_imacec_NM Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_neg_imacec_NM Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Imacec No Minero)") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea u_PrecioCobre_neg d_PrecioCobre_neg Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_PrecioCobre_neg Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)

set graphics on
graph combine  vargk_log_Imacec vargk_PrecioCobre,title("Shock Negativo del Precio del Cobre")  name(LP, replace)


// checkpoint
save data_a_pregunta_6_chekpoint3, replace
clear all
use data_a_pregunta_6_chekpoint3




// Inflación
******************************************************************
// 					   Test estadístico
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen inflacion`h'_modelo_2 = f`h'.inflacion
}
cap drop b_interaccion_inflacion u_interaccion_inflacion d_interaccion_inflacion
gen b_interaccion_inflacion=0
gen u_interaccion_inflacion=0		//Límite superior del IC
gen d_interaccion_inflacion=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey inflacion`h'_modelo_2 shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_interaccion_inflacion = _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_interaccion_inflacion = _b[interaccion] + 1.645* _se[interaccion]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_interaccion_inflacion = _b[interaccion] - 1.645* _se[interaccion]  if _n == `h'+1
}
gen b_interaccion_inflacion_level = b_interaccion_inflacion

// Plot sin la línea de cero para chequear visualmente la significancia
twoway ///
(rarea u_interaccion_inflacion d_interaccion_inflacion Years,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_interaccion_inflacion_level Years, legend(off) lcolor(black) ///
lpattern(solid) lwidth(thick) ///
title("Coeficiente en el término de interacción", color(black) size(medsmall)) ///
ytitle("Inflación", size(medsmall)) xtitle("", size(medsmall)) ///
graphregion(color(white)) plotregion(lcolor(black)))



******************************************************************
// 				Impulso respuesta efecto positivo
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen inflacion_`h'_pos = f`h'.inflacion 
}
cap drop b_pos_inflacion u_pos_inflacion d_pos_inflacion
gen b_pos_inflacion=0
gen u_pos_inflacion=0		//Límite superior del IC
gen d_pos_inflacion=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey inflacion_`h'_pos shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_pos_inflacion = _b[shocks] + _b[interaccion]                    	  if _n == `h'+1 // Desde h == 1
	replace u_pos_inflacion = _b[shocks] + _b[interaccion] + 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_pos_inflacion = _b[shocks] + _b[interaccion] - 1.645*sqrt(_se[shocks]^2 + _se[interaccion]^2)  if _n == `h'+1
}
gen b_pos_inflacion_level = b_pos_inflacion


set graphics off
tw (rarea u_pos_inflacion d_pos_inflacion Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_pos_inflacion Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("Inflación") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea u_PrecioCobre_pos d_PrecioCobre_pos Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_PrecioCobre_pos Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)

set graphics on
graph combine  vargk_log_Imacec vargk_PrecioCobre,title("Shock Positivo del Precio del Cobre")  name(LP, replace)



******************************************************************
// 				Impulso respuesta efecto negativo
******************************************************************

local hmax = 18
forvalues h = 0/`hmax' {
	gen inflacion_`h'_neg = f`h'.inflacion 
}
cap drop b_neg_inflacion u_neg_inflacion d_neg_inflacion
gen b_neg_inflacion=0
gen u_neg_inflacion=0		//Límite superior del IC
gen d_neg_inflacion=0		//Límite inferior del IC
// Loop for Imacec
forv h = 0/`hmax' {
	 newey inflacion_`h'_neg shocks interaccion l(1/12).ln_imacec l(1/12).ln_imacec_no_minero l(1/12).inflacion, lag(`h')
	 
	replace b_neg_inflacion = _b[shocks]                    	  if _n == `h'+1 // Desde h == 1
	replace u_neg_inflacion = _b[shocks] + 1.645*_se[shocks]  if _n == `h'+1 //t_{0.9} = 1.645
	replace d_neg_inflacion = _b[shocks] - 1.645*_se[shocks]  if _n == `h'+1
}
gen b_neg_inflacion_level = b_neg_inflacion

set graphics off
tw (rarea u_neg_inflacion d_neg_inflacion Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_neg_inflacion Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("Inflación") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea u_PrecioCobre_neg d_PrecioCobre_neg Years, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b_PrecioCobre_neg Years, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if Years<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)

set graphics on
graph combine  vargk_log_Imacec vargk_PrecioCobre,title("Shock Negativo del Precio del Cobre")  name(LP, replace)






