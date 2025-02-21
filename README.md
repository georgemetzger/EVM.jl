# EVM

EVM (Earned Value Management) is a Julia package for forecasting construction costs. 

It currently has one function, `forecast`, which takes, four arguments: 
`start date` - Anticipated start date.
`cost` - Total projected cost.
`days` - Total projected project length in days.
`rate` - Percentage rate of construction management (income).


```julia
forecast("10/1/2025", 50000000, 1080, 0.056)
```

<img src="https://github.com/georgemetzger/EVM.jl/blob/img/evm_forecast.png?raw=true" width = 700></br>

 There are four variables with default values that can be changed to adjust the shape of the S-curve and smooth out the costs as needed for budget planning:

`cost_fraction = 0.4` - The fraction of total cost expected to be spent at 50% completion. This is set to the typical spend for ground infrastructure.
`peakedness_fraction = 0.8` - The maximum annual cost.
`start_buffer = 90` - Time lag for project start from anticipated start date.
`end_buffer = 120` - Time lag for project completion from anticipated end date.
