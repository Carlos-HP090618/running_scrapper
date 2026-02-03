# import the libraries needed
library(tidyverse)
library(rvest)

#For this scraper I am gonna use the library rvest and a browser extension called SelectorGadget 
#which makes it easier to select which part of the website is goint to be scraped
#Here, the men's marathon times are being retrieved


# copy the link of the website to be scraped 
link <- "https://worldathletics.org/en/competitions/world-athletics-championships/tokyo25/results/men/marathon/final/result"

# use the function read_html from the rvest package to read it. Save it as page
page <- read_html(link)

#with the selector gadget select the part of the website to scrap
men_time <- page %>% html_nodes(".ResultsLOC_top3Val__2Dxi- span") %>% 
  html_text() %>% 
  str_replace_all("SB", "") %>%  # Remove all the SB characters from the numbers
  str_trim() #remove all the white spaces

# save the results as a data frame and remove the "
men_marathon_df <- data.frame(time = men_time) %>% # save the times from  men_time in a columns called time
  filter(time != 'DNF') %>%  # remove all the DNF from the dataframe
  mutate(category = 'MALE') # create a columns called category (will be used later)