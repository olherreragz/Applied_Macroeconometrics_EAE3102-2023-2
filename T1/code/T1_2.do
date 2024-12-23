
clear all
cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1"

import excel "Series_tarea1_Canvas.xlsx", sheet("Hoja1") 

/////////////////////// SERIE B \\\\\\\\\\\\\\\\\\\\\\\\\\

//egen t = seq(), from(1) to(299)
gen t = _n
order t A B C D E
tsset t

// gráficamos la serie

egen media_B = mean(B)
tsline B media_B // Primer approach de la serie y podemos ver que tiene algun grado de estacionaridad, pero después se va ampliando con el paso del tiempo y no hay como mucha expectativas
// de ergodicidad.

// Ho: La serie es ruido blanco, debo rechazar para que haya predictibilidad pq sé que si es WNoise no se puede predecir H1: la series no es de ruido blanco
wntestq B, lags(80) // Rechazo Ho p < 0.005 por tanto, mi serie no es de ruido blanco y hay predictibilidad


*H0: La serie es de raíz unitaria 
pperron B // Valor p = 0.00 por tanto la serie no es de raiz unitaria! de alguna manera el shock morirá en algún momento


// Box Jenkins
ac B, lags(30) name(ac_B, replace) // podemos ver cierto grado de persistencia, tomando tanto valores + y - podríamos estar en presencia de un ARp
pac B, lags(30) name(pac_B,replace) // Vemos que se ven 3 rezagos significativos , pero luego algunos se salen, alfinal por tanto, podemos ver que hay evidencia de un ARMA

//

reg B L(1/4).B		
gen same_data2 = e(sample)  

forvalue i=1/4 {
	forvalue j=0/4 {
		quietly xi: arima B if same_data2==1, arima (`i',0,`j') iter(150)
		estimates store AR`i'MA`j'
	}
}
estimates stats _all
//ARMA 1,1

predict residuosB, r 

//Solo un rezago sale, es aproximado a una normal
ac residuosB, name(B_res_ac)
pac residuosB, name(B_res_pac)

// H0: La serie es ruido blanco, 0.77>0.05 no rechazo, está bien porque estoy haciendo sobre el residuo
wntestq residuosB, lags(70)

// Test de Breusch-Godfrey (más eficiente)
reg residuosB L(1/30).residuosB 
estat bgodfrey //No hay correcion serial! pq 0.4 > 0.05

////////////////////// SERIE C \\\\\\\\\\\\\\\\

clear all
cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1"
import excel "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1\Series_tarea1_Canvas.xlsx", sheet("Hoja1") 

gen t = _n
order t A B C D E
tsset t

// gráficamos la serie
drop mc
egen mc = mean(C)
tsline C mc
// Primer approach de la serie y podemos ver que no tiene mucha pinta de estacionaridad, y tampoco ergodicidad
// Ho: La serie es ruido blanco, debo rechazar para que haya predictibilidad pq sé que si es WNoise no se puede predecir H1: la series no es de ruido blanco

wntestq C, lags(80) // Rechazo Ho p < 0.005 por tanto, mi serie no es de ruido blanco y hay predictibilidad


*H0: La serie es de raíz unitaria 
pperron C // Valor p = 0.00 por tanto la serie no es de raiz unitaria! de alguna manera el shock morirá en algún momento


// Box Jenkins
ac C, lags(30) name(ac_C, replace) // podemos ver cierto grado de persistencia, tomando tanto valores + y - podríamos estar en presencia de un ARp
pac C, lags(30) name(pac_C,replace) // Vemos que se ven 3 rezagos significativos , pero luego algunos se salen, alfinal por tanto, podemos ver que hay evidencia de un ARMA

//

reg C L(1/5).C	
gen same_data1 = e(sample)  

forvalue i=1/5 {
	forvalue j=0/5 {
		quietly xi: arima C if same_data1==1, arima (`i',0,`j') iter(150)
		estimates store AR`i'MA`j'
	}
}
estimates stats _all
//ARMA 1,1
arima C, arima(1,0,1)
predict residuosC, r 


//Solo un rezago sale, es aproximado a una normal
ac residuosC, name(C_res_ac)
pac residuosC, name(C_res_pac)

// H0: La serie es ruido blanco, 0.3>0.05 no rechazo, está bien porque estoy haciendo sobre el residuo
wntestq residuosC, lags(70)

// Test de Breusch-Godfrey (más eficiente)
reg residuosC L(1/30).residuosC
estat bgodfrey //No hay correcion serial! pq 0.4 > 0.05

////////////////////// SERIE D \\\\\\\\\\\\\\\\

clear all

cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1"
import excel "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1\Series_tarea1_Canvas.xlsx", sheet("Hoja1") 

gen t = _n
order t A B C D E
tsset t

// gráficamos la serie

egen md = mean(D)
tsline D md
// Primer approach de la serie y podemos ver que no tiene mucha pinta de estacionaridad, y tampoco ergodicidad
// Ho: La serie es ruido blanco, debo rechazar para que haya predictibilidad pq sé que si es WNoise no se puede predecir H1: la series no es de ruido blanco

wntestq D, lags(80) // Rechazo Ho p < 0.005 por tanto, mi serie es de ruido blanco y  no hay predictibilidad


/////// SERIE E \\\\\\\\\\
clear all

cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1"
import excel "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1\Series_tarea1_Canvas.xlsx", sheet("Hoja1")


gen t =_n
order t A B C D E
tsset t

// gráficamos la serie

egen mE = mean(E)
tsline D mE

wntestq E, lags(80) 
pperron E

// Estacionalizarla \\

gen E_diff = E - L.E
gen E_diff2 = E_diff - L.E_diff
gen E_diff3 = E_diff2 - L.E_diff2
pperron E_diff3

wntestq E_diff2, lags(80)

ac E_diff3, lags(40) name(ac_m, replace) // podemos ver cierto grado de persistencia, tomando tanto valores + y - podríamos estar en presencia de un ARp
pac E_diff3, lags(30) name(pac_m,replace)



reg E_diff3 L(1/7).E_diff3
gen same_data2= e(sample)  

forvalue i=1/7 {
	forvalue j=0/7 {
		quietly xi: arima E_diff3 if same_data2==1, arima (`i',0,`j') iter(150)
		estimates store AR`i'MA`j'
	}
}

estimates stats _all
// ARMA4,2

arima E_diff3, arima(3,0,5)
predict residuosE_diff3, r 

//Solo un rezago sale, es aproximado a una normal
ac residuosE_diff3, name(E_res_ac)
pac residuosE_diff3, name(E_res_pac)

// H0: La serie es ruido blanco, 0.6>0.05 no rechazo, está bien porque estoy haciendo sobre el residuo
wntestq residuosE_diff3, lags(70)

// Test de Breusch-Godfrey (más eficiente)
reg residuosE_diff3 L(1/30).residuosE_diff3
estat bgodfrey //No hay correcion serial! pq 0.58 > 0.05