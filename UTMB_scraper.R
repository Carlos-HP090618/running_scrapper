# Load the required packages
library(xml2)
library(dplyr)
library(purrr)
library(httr)


# This scraper is a little more complex since UTMB website used a highly dynamic front-end that pulls data from a separate API service 
# The result is basically lists inside lists, so the map functions from purr have to be used



# 1. Save the link
results_url <- "https://utmb.livetrail.net/classement.php?course=utmb&cat=scratch"

# 2. Use httr::GET() to send the request with a 'friendly' User-Agent header
response <- GET(results_url, 
                add_headers("User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"))

# 3. Read the content of the successful response as XML
xml_data <- content(response, "text", encoding = "UTF-8") %>% 
  read_xml()

# 3. Use XPath to find all runner nodes (the <c> tags)
runner_nodes <- xml_find_all(xml_data, "//c")

# 4. Extract all attributes from these nodes
# The runner data is stored in attributes like nom, prenom, doss, tps, etc.
runner_attributes_list <- map(runner_nodes, xml_attrs)

# 5. Convert the list of attributes into a clean data frame (tibble)
utmb_results_df <- runner_attributes_list %>%
  map_df(~ as.data.frame(as.list(.), stringsAsFactors = FALSE))

# 6. Select and rename the key columns for easy analysis
final_results <- utmb_results_df %>%
  select(
    Overall_Rank = class,
    Bib_Number = doss,
    Last_Name = nom,
    First_Name = prenom,
    Gender = sx,
    Club = club,
    Nationality = pays,
    Category = cat,
    Time = tps,
    Time_Difference = ecart
  ) %>%
  # Convert numeric columns from character if necessary
  mutate(Overall_Rank = as.integer(Overall_Rank))
# 7. The results will be after row 48

results_df <- final_results[48:nrow(final_results), ]