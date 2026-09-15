# Ley de Okun en Costa Rica: Modelo VAR y pronóstico de desempleo (2010Q3–2025Q1)

## Descripción

Análisis econométrico de la relación entre el crecimiento del PIB real y la tasa de
desempleo en Costa Rica mediante un **Vector Autoregressive (VAR)** bivariado, con
datos trimestrales desde 2010T3 hasta 2025T1. Adicionalmente, se ajusta un modelo
**ARIMA(1,0,1)** sobre la tasa de desempleo para generar pronósticos de corto plazo.

Proyecto de portafolio — series de tiempo aplicadas a macroeconomía.

## Objetivos

1. Estimar la dinámica conjunta entre crecimiento del PIB real y desempleo.
2. Evaluar la validez de la **Ley de Okun** (relación inversa entre crecimiento y
   desempleo) en el contexto costarricense.
3. Verificar los supuestos del modelo VAR (autocorrelación, homocedasticidad,
   normalidad, estabilidad).
4. Proyectar la tasa de desempleo tres trimestres hacia adelante con un ARIMA.

## Datos

| Variable | Fuente | Frecuencia | Periodo |
|----------|--------|------------|---------|
| Crecimiento PIB real (%) | BCCR / datos trimestrales | Trimestral | 2010T3 – 2025T1 |
| Tasa de desempleo (%) | Encuesta Continua de Empleo (INEC) | Trimestral | 2010T3 – 2025T1 |

Archivo: `data/cr_data_trim.csv`

## Metodología

1. **Exploración visual**: diagrama de dispersión y series temporales.
2. **Funciones de autocorrelación** (ACF/PACF) para ambas series.
3. **Selección de rezagos** con criterios de información (`VARselect`):
   AIC y FPE sugieren 5 rezagos; HQ y Schwarz (BIC) sugieren 1. Se opta por el
   **VAR(1)** por parsimonia y el principio de penalización del sobreajuste.
4. **Estimación VAR(1)** con término constante.
5. **Diagnóstico del modelo**:
   - Autocorrelación: Portmanteau (asintótico), 12 rezagos.
   - Heterocedasticidad: prueba ARCH multivariada.
   - Normalidad: Jarque–Bera multivariado (asimetría y curtosis).
   - Estabilidad: raíces del polinomio característico y OLS-CUSUM.
6. **Pronóstico univariado**: ARIMA(1,0,1) sobre la tasa de desempleo, 3 pasos
   adelante (2025T2–2025T4).

## 📊 Resultados

### 1. Selección de rezagos

| Criterio | Rezagos |
|----------|---------|
| AIC | 5 |
| HQ | 1 |
| SC (BIC) | 1 |
| FPE | 5 |

### 2. VAR(1) — Estimación

**Ecuación del PIB:**
- `gdp.l1` = 0.788 (p &lt; 0.001): persistencia alta del crecimiento.
- `unem.l1` no significativo (p = 0.145).

**Ecuación del desempleo:**
- `unem.l1` = 0.835 (p &lt; 0.001): fuerte persistencia.
- `gdp.l1` no significativo (p = 0.300), signo negativo: consistente con la Ley
  de Okun en dirección, pero débil en rezago.

**Correlación contemporánea de residuos: −0.49** → la relación inversa
crecimiento–desempleo se manifiesta principalmente de forma *contemporánea*.

Bondad de ajuste: R² ajustado de 0.55 (PIB) y 0.73 (desempleo).

### 3. Diagnóstico del VAR

| Prueba | Estadístico | p-valor | Veredicto |
|--------|-------------|---------|-----------|
| Portmanteau (autocorrelación) | χ² = 53.24 | 0.160 | Sin autocorrelación |
| ARCH (heterocedasticidad) | χ² = 112.18 | 0.372 | Homocedástico |
| Jarque–Bera | χ² = 486.16 | &lt; 0.001 | No normalidad |
| Curtosis | χ² = 432.34 | &lt; 0.001 | Colas pesadas |
| Raíces características | 0.818 (ambas) | — | Estable |

### 4. Pronóstico ARIMA(1,0,1) — Desempleo

| Periodo | Pronóstico | IC 95% |
|---------|-----------|--------|
| 2025T2 | 7.89 | [4.47, 11.30] |
| 2025T3 | 8.25 | [3.77, 12.72] |
| 2025T4 | 8.55 | [3.43, 13.67] |

## Discusión

Los resultados del VAR(1) muestran que tanto el crecimiento del PIB como el
desempleo costarricense son **altamente persistentes** (coeficientes autorregresivos
de 0.79 y 0.84, respectivamente). Sin embargo, los efectos *cruzados en rezago* no
resultan estadísticamente significativos: el crecimiento pasado no explica
significativamente el desempleo actual ni viceversa, lo que sugiere que la relación
de Okun opera principalmente de **manera contemporánea**, tal como indica la
correlación de −0.49 entre los residuos de ambas ecuaciones.

El modelo cumple los supuestos de **ausencia de autocorrelación** (p = 0.160) y
**homocedasticidad** (p = 0.372), y es **estable** (raíces = 0.818 &lt; 1; CUSUM dentro
de bandas). No obstante, **falla el supuesto de normalidad** (JB p &lt; 0.001),
impulsado por una curtosis excesiva. Esto es coherente con la estructura de los
datos: el pico de desempleo de ~23% en 2020T2 (choque de la pandemia) actúa como
observación atípica y genera colas pesadas en los residuos. En consecuencia, los
intervalos de confianza basados en normalidad deben interpretarse con cautela, y
sería recomendable robustecer la inferencia con *bootstrap* o incluir una dummy de
quiebre estructural.

El ARIMA(1,0,1) proyecta un **incremento gradual del desempleo** de 7.9% a 8.6%
entre 2025T2 y 2025T4, aunque con intervalos amplios que reflejan la incertidumbre
heredada del choque pandémico y la no normalidad de la serie. Cabe notar que el
componente MA(1) no es estadísticamente significativo (−0.009; e.e. 0.141), por lo
que un AR(1) podría ser una especificación más parsimoniosa.

### Limitaciones y trabajo futuro

- No se verificó estacionariedad formal (ADF/KPSS) ni cointegración (Johansen);
  si ambas series fueran I(1) y cointegradas, un **VECM** sería más adecuado.
- La especificación lineal no capta asimetrías de la Ley de Okun (el desempleo
  responde más ante recesiones que ante expansiones).
- Incluir variables exógenas (tasa de interés, inflación) podría mejorar el ajuste.

## 📦 Reproducibilidad

**Requisitos:** R ≥ 4.0 con los paquetes: `urca`, `vars`, `mFilter`, `tseries`,
`forecast`, `tidyverse`.

```r
source("scripts/okun_var.R")
