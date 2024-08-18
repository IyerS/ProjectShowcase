# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 14:57:12 2024

@author: Administrator
"""
## Q: Relationship between mailer types and signups. 
## We run a CHi Square test where the two samples/treatments are they Mailer type, Proportion is the % signups

# import needed libraries
import pandas as pd
from scipy.stats import chi2_contingency, chi2
# read raw data
campaign_data = pd.read_excel("grocery_database.xlsx", sheet_name="campaign_data")
# removing "control" mailer type from working data
campaign_data = campaign_data[campaign_data["mailer_type"] != "Control" ]
campaign_data["signup_flag"].value_counts()
# summarize frequecies and extracting as array to feed into scipy models
observed_values = pd.crosstab(campaign_data["mailer_type"], campaign_data["signup_flag"]).values

mailer1_signup_rate = 123 / (252+123)
mailer2_signup_rate = 127 / (209+127)

# state hypothesis and acceptance criteria
null_hypothesis = "There is no relationship between mailer type and signup rate"
alt_hypothesis = "There is a relationship between mailer type and signup rate"
acceptance_criteria = 0.05

# calculate expected frequencies and chi square statistic

chi2_statistic, p_value, dof, expected_values = chi2_contingency(observed_values, correction=False)
print(chi2_statistic, p_value)

critical_value = chi2.ppf(1-acceptance_criteria, dof)

# print chi-square results
if chi2_statistic >= critical_value:
    print(f"As our chi square statistic of {chi2_statistic} is greater than our critical value: {critical_value} we reject our null hypothesis and conclude {alt_hypothesis}")
else:
    print(f"As our chi square statistic of {chi2_statistic} is less than our critical value: {critical_value} we accept our null hypothesis and conclude {null_hypothesis}")
    
# print p value results
if p_value <= acceptance_criteria:
    print(f"As our p_value of {p_value} is less than our acceptance criteria: {acceptance_criteria} we reject our null hypothesis and conclude {alt_hypothesis}")
else:
    print(f"As our p_value of {p_value} is greater than our acceptance criteria: {acceptance_criteria} we accept our null hypothesis and conclude {null_hypothesis}")
    
