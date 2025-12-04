Fixing Sentencing

- Turn death sentence into a categorical variable and give them 15 years for sentencing:
    https://deathpenaltyinfo.org/death-row/death-row-time-on-death-row
    we decided on 15 years since it seems like a rough median on what we read for the amount of time in prison
    prior to their sentencing carrying out
- Life sentence gets converted to 100 yrs, anything above 100 is also capped to 100 and marked with a categorical variable.
- group by custody date and get a number for how much time they were sentenced
- keep last incarceration and a numerical variable with the total amount of time served to their last sentencing. 
