module EVM

using DataFrames, Dates

export forecast

# Functions
function ccf(t)
	α = cost_fraction < 0.5 ? ((1-peakedness_fraction)*(cost_fraction-0.1875))/0.625 : (peakedness_fraction*(cost_fraction-0.8125)+(cost_fraction-0.1875))/0.625
	β = cost_fraction< 0.5 ? peakedness_fraction*(cost_fraction-0.1875)/0.3125 : peakedness_fraction*(0.8125-cost_fraction)/0.3125
	return 10*t^2*(1-t)^2*(α+β*t)+t^4*(5-4*t)
end

function calculate_dates(start_date, days)
	start_date = Date(start_date, "mm/dd/yyyy")
	months = 0
	days = days + end_buffer
	if days % 30 == 0
		months = days/30
	else
		months = days/30+1
	end
	index = 1
	next_date = start_date + Dates.Month(start_buffer/30)
	dates = Date[next_date]
	while index < months
		next_date = next_date + Dates.Month(1)
		push!(dates, next_date)
		index += 1
	end
	return dates
end

function calculate_fy(dates)
	fiscal_years = String[]
	for i in eachindex(dates)
		if Dates.month(dates[i]) > 9
			fy = Dates.year(dates[i]) + 1
		else
			fy = Dates.year(dates[i])
		end
		fy_adjusted = string(fy)
		push!(fiscal_years, fy_adjusted)
		i += 1
	end
	return fiscal_years
end

function calculate_time(days)
	time_vector = collect(30:30:(days+end_buffer))
	percent_complete = Float64[]
	for i in eachindex(time_vector)
		current_value = time_vector[i] / (days+end_buffer)
		if time_vector[i] == time_vector[end] && current_value != 1.0
			push!(percent_complete, current_value)
			push!(percent_complete, 1.0)
		else
			push!(percent_complete, current_value)
			i += 1
		end
	end
	return percent_complete
end

function forecast(start_date, cost, days, rate)
	dates = calculate_dates(start_date, days)
	time_percentage = calculate_time(days)
	fiscal_year = calculate_fy(dates)
	ccf_values = ccf.(time_percentage)
	running_expenditures = ccf_values*cost
	expenditures = Float64[]
	for i in eachindex(ccf_values)
		if i == 1
			adjusted_payment = ccf_values[i] * cost
		else
			payment = ccf_values[i] * cost
			adjusted_payment = payment - ccf_values[i-1] * cost
		end
		push!(expenditures, adjusted_payment)
		i += 1
	end
	income = rate .* expenditures
	total_expenditures = ccf_values*cost
	df = DataFrame(date = dates, fiscal_year = fiscal_year, percent_complete = round.(ccf_values, digits = 3), income = round.(income, digits = 2), running_expenditures = round.(running_expenditures, digits = 2), expenditures = round.(expenditures, digits = 2))
	return df
end

end
