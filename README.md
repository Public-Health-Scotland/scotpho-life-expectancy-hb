# scotpho-life-expectancy-hb

This code produces the shiny app chart in the Deaths and life expectancy > Data > NHS Boards section of the ScotPHO website.

Data is sourced from:
•	LE by NHS Board: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2FLife-Expectancy
•	HLE by NHS Board: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fhealthy-life-expectancy

To update the shiny app:

1. Run extract_data.R to extract the data from the SG opendata platform. 
2. Check the output saved here: 
\\stats\ScotPHO\Life Expectancy\HLE ScotPHO Web Section\Scotland
3. Run the shiny app locally to check it has updated as expected
3. Deploy app

