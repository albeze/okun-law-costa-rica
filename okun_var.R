library(urca)
library(vars)
library(mFilter)
library(tseries)
library(forecast)
library(tidyverse)

options(vsc.dev.args = list(width=2000, height=1500, pointsize=12, res=300))

ruta <- "/Users/alfonsoberriosz/Documents/Personal/Proyectos/R/Time Series/Bases/cr_data_trim.csv"
okun <- read.csv(ruta, dec=",", sep=";")

ggplot(data = okun) + geom_point(mapping = aes(x=unem, y=real_gdp_growth))

gdp <- ts(okun$real_gdp_growth, start=c(2010,3), end=c(2025,1), frequency=4)
unem <- ts(okun$unem, start=c(2010,3), end=c(2025,1), frequency = 4)
#gdp <- ts(okun$real_gdp_growth, start=c(1999,3), frequency=3)
#unem <- ts(okun$unem, start=c(1999,3), frequency = 3)

adf_gdp  <- ur.df(gdp,  type = "drift", lags = 4, selectlags = "AIC")
adf_unem <- ur.df(unem, type = "drift", lags = 4, selectlags = "AIC")
summary(adf_gdp); summary(adf_unem)

# KPSS: H0 = estacionaria (prueba complementaria)
kpss_gdp  <- ur.kpss(gdp,  use.lag = trunc(3*sqrt(length(gdp))/13))
kpss_unem <- ur.kpss(unem, use.lag = trunc(3*sqrt(length(unem))/13))
summary(kpss_gdp); summary(kpss_unem)

# Cointegración de Johansen (si ambas son I(1))
jo <- ca.jo(okun.bv, type = "trace", K = 2, ecdet = "const")
summary(jo)

autoplot(cbind(gdp, unem))

acf(gdp)
pacf(gdp)

acf(unem)
pacf(unem)

okun.bv <- cbind(gdp, unem)

lagselect <- VARselect(okun.bv, lag.max = 5, type="const")
lagselect$selection

ModeloOkun1 <- VAR(okun.bv, p=1, type="const", season=NULL, exog=NULL)
summary(ModeloOkun1) 

#Prueba de autocorrelación (P-valores > 0.05 indican ausencia de autocorrelación)
Serial1 <- serial.test(ModeloOkun1, lags.pt = 12, type="PT.asymptotic")
Serial1

#Prueba de heteroscedasticidad (P-val > 0,05 indican homocedasticidad)
Arch1 <- arch.test(ModeloOkun1, lags.multi = 12, multivariate.only = TRUE)
Arch1

#Prueba de residuos normales / Kurtosis (P-val > 0,05 indican residuos con dist.
# normal y kurtosis)

Norml <- normality.test(ModeloOkun1, multivariate.only = TRUE)
Norml

Stability1 <- stability(ModeloOkun1, type = "OLS-CUSUM")
plot(Stability1)

# ---- Dummy COVID: 1 en 2020T1 y 2020T2 (impacto y rebote) ----
d_covid <- ts(0, start = c(2010,3), end = c(2025,1), frequency = 4)
window(d_covid, start = c(2020,1), end = c(2020,2)) <- 1

# VAR con dummy como regresor exógeno
ModeloOkun2 <- VAR(okun.bv, p = 1, type = "const", exog = d_covid)
summary(ModeloOkun2)

# Re-diagnóstico
normality.test(ModeloOkun2, multivariate.only = TRUE)
serial.test(ModeloOkun2, lags.pt = 12, type = "PT.asymptotic")
arch.test(ModeloOkun2, lags.multi = 12, multivariate.only = TRUE)

# Comparación formal
AIC(ModeloOkun1, ModeloOkun2)

arma11 <- arima(unem, order = c(1,0,1))
summary(arma11)

forecast(arma11, 3)
plot(forecast(arma11, 3)) 

# ---- Causalidad de Granger ----
causality(ModeloOkun1, cause = "gdp")   # ¿PIB Granger-causa desempleo?
causality(ModeloOkun1, cause = "unem")  # ¿desempleo Granger-causa PIB?

# ---- Selección automática y comparación ----
arma_auto <- auto.arima(unem, seasonal = FALSE, stepwise = FALSE, approximation = FALSE)
summary(arma_auto)

arma10 <- Arima(unem, order = c(1,0,0))
AIC(arma11, arma10)

# Pronóstico del modelo seleccionado
set.seed(123)
plot(forecast(arma_auto, h = 3))
