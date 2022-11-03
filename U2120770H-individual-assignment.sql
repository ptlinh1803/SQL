# Name: Pham Thuy Linh
# Matric no: U2120770H
# Individual Assignment

# ------------------------------------------------------------------------------------------------------------------
# Question 1: What are the unique categories in table <greenhouse_gas_inventory_data_data>?
select distinct category from greenhouse_gas_inventory_data_data;

# ------------------------------------------------------------------------------------------------------------------
# Question 2: What is the sum of emission [value] in the [year] 2010 to 2014 for EU? <greenhouse_gas_inventory_data_data>
select sum(value) as sum_of_emission_EU from greenhouse_gas_inventory_data_data
where year >= 2010 and year <= 2014
and country_or_area = "European Union";

# ------------------------------------------------------------------------------------------------------------------
# Question 3: What are the year, category and value for Australia where emission value is greater than 530000?
select year, category, value from greenhouse_gas_inventory_data_data
where country_or_area = "Australia"
and value > 530000
order by year;

# ------------------------------------------------------------------------------------------------------------------
# Question 4: for each year (2010-2014), display the average [extent] of sea ice, maximum [extent] of sea ice, minimum [extent] of sea ice,
#             and the total amount of emission value


# check the sum of emmision in each year from 2010-2014
# select year, sum(value) from greenhouse_gas_inventory_data_data
# where year >= 2010 and year <= 2014
# group by year
# order by year;

select s.year, avg(cast(extent as double)) as avg_extent, max(cast(extent as double)) as max_extent, min(cast(extent as double)) as min_extent, total_emmission
from seaice s
join (
	select year, sum(value) as total_emmission from greenhouse_gas_inventory_data_data gg
	where year >= 2010 and year <= 2014
	group by year
	) gg
on gg.year = s.year
where s.year >= 2010 and s.year <= 2014
group by s.year
order by s.year;

# ------------------------------------------------------------------------------------------------------------------
# Question 5: For each year (2010-2014), display the average, min & max [extent] of sea ice;  average, min & max [landaveragetemperature]
#             table <seaice> and <globalaveragetemperature>
select s.year, avg(cast(extent as double)) as avg_extent, max(cast(extent as double)) as max_extent, min(cast(extent as double)) as min_extent,
	   avgLandAverageTemperature, minLandAverageTemperature, maxLandAverageTemperature
from seaice s
join (
	select year(cast(recordedDate as date)) as year,
    avg(cast(LandAverageTemperature as double)) as avgLandAverageTemperature, min(cast(LandAverageTemperature as double)) as minLandAverageTemperature,
	max(cast(LandAverageTemperature as double)) as maxLandAverageTemperature
    from globaltemperatures
	group by year
    ) gt
on gt.year = s.year
where s.year >= 2010 and s.year <= 2014
group by s.year
order by s.year;

# ------------------------------------------------------------------------------------------------------------------
# Question 6: for each year (2010 to 2014), display the sum of emmission [value]; (in Australia)
#             average, min. max temperature change [temperaturechangebycountry.value] in Australia
# 			  table <greenhouse_gas_inventory_data_data> and <temperaturechangebycountry>

# assume that the question asks for sum of emission in Australia from 2010-2014
select gg.year, sum(gg.value) as total_emission, 
       avgTemperatureChange, minTemperatureChange, maxTemperatureChange
from greenhouse_gas_inventory_data_data gg
join (
	select year, avg(value) as avgTemperatureChange, min(value) as minTemperatureChange, max(value) as maxTemperatureChange
	from temperaturechangebycountry
	where Area = "Australia"
	group by year
) tc
on tc.year = gg.year
where gg.year >= 2010 and gg.year <= 2014
and gg.country_or_area = "Australia"
group by gg.year
order by gg.year;

# same as above but use convert(value,double)
select gg.year, sum(gg.value) as total_emission, 
       avgTemperatureChange, minTemperatureChange, maxTemperatureChange
from greenhouse_gas_inventory_data_data gg
join (
	select year, avg(convert(value,double)) as avgTemperatureChange, min(convert(value,double)) as minTemperatureChange, max(convert(value,double)) as maxTemperatureChange
	from temperaturechangebycountry
	where Area = "Australia"
	group by year
) tc
on tc.year = gg.year
where gg.year >= 2010 and gg.year <= 2014
and gg.country_or_area = "Australia"
group by gg.year
order by gg.year;

# same as above but filter using monthscode 7001-7012. After monthscode 7012, there are data for quarters of the year, or some weird month's names.
select gg.year, sum(gg.value) as total_emission, 
       avgTemperatureChange, minTemperatureChange, maxTemperatureChange
from greenhouse_gas_inventory_data_data gg
join (
	select year, avg(convert(value,double)) as avgTemperatureChange, min(convert(value,double)) as minTemperatureChange, max(convert(value,double)) as maxTemperatureChange
	from temperaturechangebycountry
	where Area = "Australia"
    and MonthsCode between 7001 and 7012 
	group by year
) tc
on tc.year = gg.year
where gg.year >= 2010 and gg.year <= 2014
and gg.country_or_area = "Australia"
group by gg.year
order by gg.year;

# ------------------------------------------------------------------------------------------------------------------
# Question 7: Display a list of glaciers [name], [investigator], and amount of surveyed on the glacier done by the investigator
#             when the investigator has conducted more than 11 surveys on the glacier
#             sort the output in alphabetical order of [name]
#             table <mass_balance_data>
select name, investigator, count(*) as surveyedAmt
from mass_balance_data
group by name, investigator
having surveyedAmt > 11
order by name;

# remove rows with no invesitigator
select name, investigator, count(*) as surveyedAmt
from mass_balance_data
where investigator != ""
group by name, investigator
having surveyedAmt > 11
order by name;

# ------------------------------------------------------------------------------------------------------------------
# Question 8: For each year (2010-2014), display a list of [area], [year], average [value] of temperature change of the ASEAN countries.
#             Include the overall average of temperature change of all the ASEAN countries of each year.
#             Table <temperaturechangebycountry>

#-- create view that has temp change of all countries & avg of asean
create view asean(area, year, avgValueChange)
as 
	(select area, year, avg(convert(value,double)) as avgValueChange
	from temperaturechangebycountry
	where area in (
		"Brunei Darussalam", "Cambodia", "Indonesia", "Myanmar", "Lao People's Democratic Republic", 
		"Malaysia", "Philippines", "Singapore", "Thailand", "Viet Nam")
	and year >= 2010 and year <= 2014
	group by year, area
	order by year
	)
	union
	(
	select "ASEAN" as area, year, avg(convert(value, double)) as avgValueChange
	from temperaturechangebycountry
	where area in (
		"Brunei Darussalam", "Cambodia", "Indonesia", "Myanmar", "Lao People's Democratic Republic", 
		"Malaysia", "Philippines", "Singapore", "Thailand", "Viet Nam")
	and year >= 2010 and year <= 2014
	group by year
	order by year
	);

# sort the view
select * from asean
order by year, area desc;

#same as above but filter monthscode from 7001-7012
create view asean2(area, year, avgValueChange)
as 
	(select area, year, avg(convert(value,double)) as avgValueChange
	from temperaturechangebycountry
	where area in (
		"Brunei Darussalam", "Cambodia", "Indonesia", "Myanmar", "Lao People's Democratic Republic", 
		"Malaysia", "Philippines", "Singapore", "Thailand", "Viet Nam")
	and year >= 2010 and year <= 2014
    and MonthsCode >= 7001 and MonthsCode <= 7012
	group by year, area
	order by year
	)
	union
	(
	select "ASEAN" as area, year, avg(convert(value, double)) as avgValueChange
	from temperaturechangebycountry
	where area in (
		"Brunei Darussalam", "Cambodia", "Indonesia", "Myanmar", "Lao People's Democratic Republic", 
		"Malaysia", "Philippines", "Singapore", "Thailand", "Viet Nam")
	and year >= 2010 and year <= 2014
    and MonthsCode >= 7001 and MonthsCode <= 7012
	group by year
	order by year
	);

# sort the view 2
select * from asean2
order by year, area desc;

# ------------------------------------------------------------------------------------------------------------------
# Question 9: Display a list of [country_or_area], [category], and overall average emission [value] per category, 
#             when the country's emission [value] for the category of the [year] is less than the country's overall average emission [value] for the category.
#             table <greenhouse_gas_inventory_data_data>

select gg1.country_or_area, gg1.category, cat_overallAvgValue, gg2.year, gg2.value as cat_yearValue
from (
	select country_or_area, category, avg(value) as cat_overallAvgValue
	from greenhouse_gas_inventory_data_data
	group by country_or_area, category
	order by category, country_or_area
) gg1 
right outer join greenhouse_gas_inventory_data_data gg2
on gg1.country_or_area = gg2.country_or_area and gg1.category = gg2.category
having cat_yearValue < cat_overallAvgValue;

# ------------------------------------------------------------------------------------------------------------------
# Question 10: For each year (2008 to 2017), display the average [value] of temperature change in "United States of America",
#              the year's average [extent] of [seaice.extent] sea ice, 
#              and the corresponding average [value] of [elevation_change_data.elevation_change_unc] glacier elevation change surveyed by 
#              "Martina Barandun Robert McNabb" in the same year.
#              table <temperaturechangebycountry>, <seaice>, <elevation_change_data>

# join 3 tables
select us.year, avgValue, avgExtent, avgElevationChange
from (
	select year, avg(convert(value,double)) as avgValue
	from temperaturechangebycountry
	where Area = "United States of America"
    # and MonthsCode between 7001 and 7012 
    and year between 2008 and 2017
	group by year
    order by year
) us
join (
	select year, avg(cast(extent as double)) as avgExtent
	from seaice 
	where year between 2008 and 2017
	group by year
	order by year
) si
on us.year = si.year
join (
	select cast((left(survey_date, 4)) as decimal(4,0)) as year, avg(elevation_change_unc) as avgElevationChange
	from elevation_change_data
	where cast((left(survey_date, 4)) as decimal(4,0)) between 2008 and 2017
	and investigator = "Martina Barandun Robert McNabb"
	group by year
	order by year
) ele
on si.year = ele.year;

# if filter MonthsCode from 7001-7012
select us.year, avgValue, avgExtent, avgElevationChange
from (
	select year, avg(convert(value,double)) as avgValue
	from temperaturechangebycountry
	where Area = "United States of America"
    and MonthsCode between 7001 and 7012 
    and year between 2008 and 2017
	group by year
    order by year
) us
join (
	select year, avg(cast(extent as double)) as avgExtent
	from seaice 
	where year between 2008 and 2017
	group by year
	order by year
) si
on us.year = si.year
join (
	select cast((left(survey_date, 4)) as decimal(4,0)) as year, avg(elevation_change_unc) as avgElevationChange
	from elevation_change_data
	where cast((left(survey_date, 4)) as decimal(4,0)) between 2008 and 2017
	and investigator = "Martina Barandun Robert McNabb"
	group by year
	order by year
) ele
on si.year = ele.year;
# END -------------------------------------------------------------------------------------------------------------------------------------------------
           
    
    