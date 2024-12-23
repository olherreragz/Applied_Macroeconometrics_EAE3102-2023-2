clear all
// cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T5"
cd "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 5\avance raul\T5\T5"

import excel data, sheet("Sheet2") firstrow

gen Periodo = mofd(DATE)
format Periodo %tm     
tsset  Periodo, monthly

gen Imacec2 = ln(Imacec)
gen TCO2 = ln(TCO)

tsline IPC2, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Inflación")  ytitle("") xtitle("Fecha") ///
	lcolor(midblue)
tsline TCO2, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("ln(Tipo de Cambio USD,CLP)")  ytitle("") xtitle("Fecha") ///
	lcolor(midblue)
tsline Imacec2, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("ln(Imacec)")  ytitle("") xtitle("Fecha") ///
	lcolor(midblue)
tsline FEDF, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Tasa de Interés de la Reserva Federal de Estados Unidos")  ytitle("") xtitle("Fecha") ///
	lcolor(midblue)
tsline DGS102, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Tasa de interés a 10 años en Estados Unidos")  ytitle("") xtitle("Fecha") ///
	lcolor(midblue)


varsoc DGS102 FEDF Imacec2 IPC2 TCO2, maxlag(8) 


* Definir restricciones
constraint define 1 [DGS102]L1.IPC2=0
constraint define 2 [DGS102]L2.IPC2=0
constraint define 3 [DGS102]L1.TCO2=0
constraint define 4 [DGS102]L2.TCO2=0
constraint define 5 [DGS102]L1.Imacec2=0
constraint define 6 [DGS102]L2.Imacec2=0

constraint define 7 [FEDF]L1.IPC2=0
constraint define 8 [FEDF]L2.IPC2=0
constraint define 9 [FEDF]L1.TCO2=0
constraint define 10 [FEDF]L2.TCO2=0
constraint define 11 [FEDF]L1.Imacec2=0
constraint define 12 [FEDF]L2.Imacec2=0

* Especificar el modelo VAR y estimar
var DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/12)

predict r_DG, residuals equation(DGS102)
sum r_DG
reg r_DG L1.r_DG L2.r_DG
estat bgodfrey, lags(1/2)

var DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/12)

predict r_FF, residuals equation(FEDF)
sum r_FF
reg r_FF L1.r_FF L2.r_FF
estat bgodfrey, lags(1/2)

var DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/12)

// drop r_INFL
predict r_INFL, residuals equation(IPC2)
sum r_INFL
reg r_INFL L1.r_INFL L2.r_INFL
estat bgodfrey, lags(1/2)

var DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/12)

predict r_TC, residuals equation(TCO2)
sum r_TC
reg r_TC L1.r_TC L2.r_TC
estat bgodfrey, lags(1/2)

var DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/12)

predict r_YCHI, residuals equation(Imacec2)
sum r_YCHI
reg r_YCHI L1.r_YCHI L2.r_YCHI
estat bgodfrey, lags(1/2)


tsline r_DG r_FF

var DGS102 FEDF Imacec2 IPC2 TCO2, lags(1 2) constraints(1/12)
varstable

// ______________________________________________
//
// 					Pregunta 4
// ______________________________________________


var DGS102 FEDF Imacec2 IPC2 TCO2, lags(1 2) constraints(1/12)
irf create irf_P4, step(24) bs rep(50) set(irf_P4, replace)

*3a 

irf graph oirf, impulse(DGS102) response(DGS102 FEDF Imacec2 IPC2 TCO2) level(90) name(EPU_shock_P4, replace)
irf graph oirf, impulse(DGS102) response(DGS102 FEDF Imacec2 IPC2 TCO2) level(90) individual iname(irfr, replace)



// ______________________________________________
//
// 					Pregunta 5
// ______________________________________________
//


irf table fevd, noci 
irf graph fevd, impulse(DGS102) response(DGS102 FEDF Imacec2 IPC2 TCO2) level(90) name(EPUFEVD, replace)
irf table fevd, impulse(DGS102) response(DGS102 FEDF Imacec2 IPC2 TCO2) noci

// ______________________________________________
//
// 					Pregunta 6
// ______________________________________________
//


preserve
import excel "VIXX", sheet("FRED Graph") firstrow clear 
replace Periodo = mofd(Periodo)

format Periodo %tm     
tsset  Periodo, monthly

tempfile REC
save `REC'
restore
merge 1:1 Periodo using `REC', nogenerate


gen l_VIX = ln(VIXCLS)
varsoc l_VIX DGS102 FEDF Imacec2 IPC2 TCO2, maxlag(8) 
// 2 lags


constraint define 1 [l_VIX]L1.IPC2=0
constraint define 2 [l_VIX]L2.IPC2=0
constraint define 3 [l_VIX]L1.TCO2=0
constraint define 4 [l_VIX]L2.TCO2=0
constraint define 5 [l_VIX]L1.Imacec2=0
constraint define 6 [l_VIX]L2.Imacec2=0


constraint define 7 [DGS102]L1.IPC2=0
constraint define 8 [DGS102]L2.IPC2=0
constraint define 9 [DGS102]L1.TCO2=0
constraint define 10 [DGS102]L2.TCO2=0
constraint define 11 [DGS102]L1.Imacec2=0
constraint define 12 [DGS102]L2.Imacec2=0


constraint define 13 [FEDF]L1.IPC2=0
constraint define 14 [FEDF]L2.IPC2=0
constraint define 15 [FEDF]L1.TCO2=0
constraint define 16 [FEDF]L2.TCO2=0
constraint define 17 [FEDF]L1.Imacec2=0
constraint define 18 [FEDF]L2.Imacec2=0


var l_VIX DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/18)


irf create irf_P7, step(24) bs rep(50) set(irf_P7, replace)

irf graph oirf, impulse(DGS102) response(l_VIX DGS102 FEDF Imacec2 IPC2 TCO2) level(90) name(EPU_shock_P4, replace)
irf graph oirf, impulse(DGS102) response(l_VIX DGS102 FEDF Imacec2 IPC2 TCO2) level(90) individual iname(irfr, replace)


// De aquí para abajo, no se pide en el enunciado

predict r_VX, residuals equation(VIXCLS)
sum r_VX
reg r_VX L1.r_VX L2.r_VX
estat bgodfrey, lags(1/2)

var VIXCLS DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/18)

predict r_FF, residuals equation(FEDF)
sum r_FF
reg r_FF L1.r_FF L2.r_FF
estat bgodfrey, lags(1/2)


var VIXCLS DGS102 FEDF IPC2 TCO2 Imacec2, lags(1 2) constraints(1/18)

predict r_DG, residuals equation(DGS102)
sum r_DG
reg r_DG L1.r_DG L2.r_DG
estat bgodfrey, lags(1/2)


