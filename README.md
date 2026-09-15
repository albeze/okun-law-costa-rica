# Ley de Okun en Costa Rica: un VAR para el PIB y el desempleo, 2010T3-2025T1

Este repositorio contiene un análisis econométrico de la relación entre el
crecimiento del PIB real y la tasa de desempleo en Costa Rica, con datos
trimestrales entre el tercer trimestre de 2010 y el primero de 2025. Se estima
un modelo vectorial autorregresivo (VAR) bivariado y se contrastan dos
especificaciones: una con constante y otra con una variable exógena que captura
el choque de la pandemia de COVID-19. Como complemento, se ajusta un modelo
ARIMA sobre la tasa de desempleo para producir un pronóstico de tres trimestres.

## Datos

| Variable | Periodo | Frecuencia |
|---|---|---|
| Crecimiento del PIB real (%) | 2010T3 - 2025T1 | Trimestral |
| Tasa de desempleo (%) | 2010T3 - 2025T1 | Trimestral |

Fuente: bases trimestrales de Costa Rica (archivo `cr_data_trim.csv`).

## Metodología

El trabajo sigue este orden:

1. Pruebas de raíz unitaria de Dickey-Fuller aumentada (ADF) y KPSS para cada
   serie, con constante y selección de rezagos por AIC.
2. Test de cointegración de Johansen (traza) para decidir entre VAR en niveles
   o VECM.
3. Selección del orden de rezago del VAR con los criterios AIC, Hannan-Quinn,
   Schwarz y FPE.
4. Estimación de un VAR(1) con constante.
5. Diagnóstico del VAR: prueba de Portmanteau para autocorrelación, prueba ARCH
   para heteroscedasticidad, prueba de Jarque-Bera multivariada para normalidad,
   y evaluación de estabilidad mediante raíces del polinomio característico y
   estadístico CUSUM.
6. Reestimación del VAR incluyendo una dummy exógena con valor 1 en 2020T1 y
   2020T2.
7. Pruebas de causalidad de Granger y de causalidad instantánea.
8. Comparación de especificaciones ARIMA para el desempleo mediante
   `auto.arima` y criterio de AIC.

## Resultados

### Estacionariedad y cointegración

| Serie | ADF (tau2) | Crítico 5% | KPSS | Crítico 5% |
|---|---|---|---|---|
| PIB real | -2.500 | -2.89 | 0.323 | 0.463 |
| Desempleo | -1.735 | -2.89 | 0.442 | 0.463 |

El ADF no rechaza la hipótesis de raíz unitaria en ninguna serie. El KPSS, en
cambio, no rechaza la estacionariedad en ninguna de las dos al 5% (aunque el
desempleo queda cerca del límite). El test de Johansen arroja un estadístico de
traza de 18.30 para r = 0, inferior al valor crítico al 5% de 19.96, por lo que
no hay evidencia de cointegración.

### Selección del orden de rezago

| Criterio | Rezagos |
|---|---|
| AIC | 5 |
| Hannan-Quinn | 1 |
| Schwarz (BIC) | 1 |
| FPE | 5 |

Se adopta p = 1, que es lo que sugieren los criterios consistentes y lo que
permite mantener la parsimonia en una muestra de 59 observaciones.

### VAR(1) con constante

Ecuación del PIB:

| Variable | Coeficiente | p-valor |
|---|---|---|
| PIB rezago 1 | 0.788 | &lt; 0.001 |
| Desempleo rezago 1 | 0.198 | 0.145 |
| Constante | -0.781 | 0.676 |

Ecuación del desempleo:

| Variable | Coeficiente | p-valor |
|---|---|---|
| PIB rezago 1 | -0.055 | 0.300 |
| Desempleo rezago 1 | 0.835 | &lt; 0.001 |
| Constante | 2.166 | 0.039 |

R cuadrado ajustado: 0.55 en la ecuación del PIB y 0.73 en la del desempleo.
La correlación entre los residuos de ambas ecuaciones es -0.49.

### Diagnóstico del VAR(1)

| Prueba | Estadístico | p-valor | Resultado |
|---|---|---|---|
| Portmanteau (12 rezagos) | Chi2 = 53.24 | 0.160 | Sin autocorrelación |
| ARCH multivariado | Chi2 = 112.18 | 0.372 | Homoscedasticidad |
| Jarque-Bera | Chi2 = 486.16 | &lt; 0.001 | No normalidad |
| Asimetría | Chi2 = 53.82 | 2.1e-12 | Asimetría presente |
| Curtosis | Chi2 = 432.34 | &lt; 0.001 | Colas pesadas |
| Raíces características | 0.818 | - | Estable |

### VAR(1) con dummy de COVID-19

La dummy exógena resulta significativa en ambas ecuaciones y con los signos
esperados: -9.62 en la ecuación del PIB y 6.28 en la del desempleo.

| Variable | Coef. PIB | p-valor | Coef. desempleo | p-valor |
|---|---|---|---|---|
| PIB rezago 1 | 0.788 | &lt; 0.001 | -0.055 | 0.172 |
| Desempleo rezago 1 | 0.240 | 0.037 | 0.808 | &lt; 0.001 |
| Dummy COVID | -9.624 | &lt; 0.001 | 6.277 | &lt; 0.001 |

R cuadrado ajustado: 0.68 en la ecuación del PIB y 0.85 en la del desempleo.
La correlación de residuos baja de -0.49 a -0.20.

El diagnóstico muestra una mejora parcial: el estadístico de Jarque-Bera cae
de 486.16 a 168.33 y la curtosis de 432.34 a 148.01, pero aparece
autocorrelación residual (Portmanteau p = 0.042). La prueba ARCH sigue sin
detectar heteroscedasticidad (p = 0.189). La comparación por AIC favorece
claramente la especificación con dummy: 485.1 contra 521.9.

### Causalidad

La prueba de Granger no rechaza la nula en ninguna dirección: el PIB no
Granger-causa el desempleo (F = 1.10, p = 0.298) y el desempleo no
Granger-causa el PIB (F = 2.19, p = 0.142). En cambio, la prueba de
causalidad instantánea rechaza la ausencia de relación contemporánea
(Chi2 = 11.29, p &lt; 0.001).

### Pronóstico del desempleo

La selección automática con `auto.arima` y la comparación de AIC favorecen un
AR(1) sobre el ARIMA(1,0,1):

| Modelo | AIC |
|---|---|
| AR(1) | 240.21 |
| ARMA(1,1) | 242.21 |

El coeficiente autorregresivo del AR(1) es 0.856 y significativo. Los
pronósticos a tres trimestres apuntan a un desempleo creciente dentro de bandas
muy amplias:

| Trimestre | Pronóstico | Intervalo al 95% |
|---|---|---|
| 2025T2 | 7.89 | [4.47, 11.30] |
| 2025T3 | 8.25 | [3.77, 12.72] |
| 2025T4 | 8.55 | [3.43, 13.67] |

## Discusión

El primer resultado sólido es que ambas series son muy persistentes: cada una
explica en gran medida su propio comportamiento rezagado, con coeficientes de
0.79 y 0.84. Los efectos cruzados en rezago, en cambio, son débiles en el VAR
original.

La ambigüedad entre el ADF y el KPSS mes relevante. El ADF no rechaza la raíz
unitaria, mientras que el KPSS no rechaza la estacionariedad al 5%. Este
conflicto es común en muestras pequeñas con alta persistencia. Para remediarlo
se aplicó el test de Johansen que al no encontrar cointegración (18.30 &lt; 19.96 al 5%),
la especificación en niveles del VAR queda justificada, aunque los resultados
deben leerse con la cautela que impone una muestra de solo 59 observaciones.

La evidencia más clara a favor de una relación de Okun es contemporánea. La
prueba de causalidad instantánea rechaza la nula (p &lt; 0.001), y la correlación 
entre residuos es de -0.49 en el modelo base. En una economía
pequeña y abierta como la tica, resulta razonable que el crecimiento y
el desempleo se muevan juntos dentro del mismo trimestre, en lugar de hacerlo
con rezagos. La prueba de Granger confirma la intuición de que no hay predicción
de una variable sobre la otra en el tiempo.

Sobre el modelo con dummy, el balance es favorable pero no limpio. El ajuste
mejora de forma sustancial: el AIC cae en casi 37 puntos, el R cuadrado
ajustado sube a 0.85 en la ecuación del desempleo, y la curtosis de los
residuos se reduce a un tercio. Sin embargo, aparece autocorrelación residual.
Esto indica que la dummy de dos trimestres absorbe bien el pico pandémico pero
no captura toda la dinámica del periodo. Una extensión natural sería probar una
dummy más larga o combinarla con un orden de rezago mayor.

El pronóstico del ARIMA no parece muy robusto. Los intervalos son muy amplios,
lo cual es esperable en una serie corta que incluye un choque extremo como el de
2020. La selección automática y el criterio de AIC favorecen un AR(1) sobre el
ARMA(1,1), dado que el coeficiente de medias móviles del segundo modelo no es
significativo.

## Limitaciones y trabajo futuro

- Extender o afinar la dummy de COVID para resolver la autocorrelación
  residual del segundo modelo.
- Explorar asimetrías: la respuesta del desempleo ante contracciones del PIB
  suele ser más fuerte que ante expansiones.
- Incorporar variables exógenas, como la tasa de interés o la inflación.
- Aumentar la muestra si los datos históricos lo permiten, para reducir la
  incertidumbre de las pruebas de raíz unitaria.

## Reproducibilidad

Requisitos: R con los paquetes urca, vars, mFilter, tseries, forecast y
tidyverse.

```r
source("scripts/okun_var.R")
```
### Disclaimer
Este documento es una herramienta de estudio para la materia Econometría II de la Licenciatura en Economía en la Universidad Nacional de La Plata. La idea surgió de un [video del Dr. Justin Eloriaga](https://www.youtube.com/watch?v=dXWy5nleaSg). Para pulir la redacción y algunos tests adicionales hice uso de Kimi AI. Los datos fueron recabados, limpiados y analizados por mí.

