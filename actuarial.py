# -*- coding: utf-8 -*-
"""
Created on Tue May 16 20:31:10 2017

@author: Ryan
"""

# packages here

import numpy as np
import matplotlib as mp
import pandas as pd

# Import the claims data
path = "C:/Users/Ryan/Documents/PythonProjects/Actuarial/ClaimsExample.csv"

claims = pd.read_csv(path, sep = ",")
claims = pd.DataFrame(claims)

# Check for missing data
claims.isnull().any()

# Extract each of the years for triangle analysis
claims['Policy_Year'] = [int(x[-4:]) for x in claims['Policy_Effective_Date']]
claims['Report_Year'] = [int(x[-4:]) for x in claims['Report_Date']]
claims['Transaction_Year'] = [int(x[-4:]) for x in claims['Transaction_Date']]

# Calculate the lags using year long periods
claims['PY_Lag'] = claims['Transaction_Year'] - claims['Policy_Year']
claims['RY_Lag'] = claims['Transaction_Year'] - claims['Report_Year']

# Sum over the Total value, group by PY_Lag
py_data = claims['Total'].groupby([claims['Policy_Year'],claims['PY_Lag']]).sum().reset_index()

# Convert to a triangle
py_triangle = pd.pivot_table(py_data, index = ["Policy_Year"], columns = ["PY_Lag"], values = ["Total"])

# Same traingle, but cumulative
py_data['cumsum'] = py_data["Total"].groupby(py_data["Policy_Year"]).cumsum()

py_cumu_triangle = pd.pivot_table(py_data, index = ["Policy_Year"], columns = ["PY_Lag"], values = ["cumsum"])
