# 2012-2020-High-Resolution-WSR-for-Water-Quality-and-Quantity
Code for assessing water scarcity risk under combined water quantity and water quality constraints

## Overview
The framework integrates water quality forecasting with economic risk propagation and consists of three main components:

1. **BOD forecasting**
   Monthly biochemical oxygen demand (BOD) is forecast independently at each location using a univariate ARIMA model.

2. **Quality–quantity constrained water scarcity**
   Forecasted BOD is used to construct dilution water requirements, which are combined with water withdrawal, water availability, and environmental flow requirements to calculate potential water scarcity volume (PWSV). PWSV is further allocated to economic sectors to derive local water scarcity risk (LWSR).

3. **MRIO-based risk propagation and vulnerability**
   Sector-level LWSR is propagated through interregional supply chains using a Ghosh-based MRIO model to obtain virtual water scarcity risk (VWSR). Import vulnerability is quantified using a Herfindahl–Hirschman Index (HHI).


