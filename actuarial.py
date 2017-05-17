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
claims['Policy_Year'] = [x[-4:] for x in claims['Policy_Effective_Date']]
claims['Report_Year'] = [x[-4:] for x in claims['Report_Date']]
claims['Transaction_Year'] = [x[-4:] for x in claims['Transaction_Date']]