###############
## LIBRARIES ##
###############

install.packages("tidyverse")
install.packages("quantmod")
library(tidyverse)
library(rvest)
library(quantmod)
library(httr)
library(tibble)

####################
## Kaggle Dataset ##
####################

## Read csv ##
df1 <- read.csv("netflix_titles.csv", head = T, sep = ',', encoding = "UTF-8")

## Fix Duration and Cast columns ##
ds_netflix_titles <- df1 %>%
  separate(duration, into = c("duration_num", "duration_type"), sep = " ") %>%
  separate_rows(cast, sep = ", ")

## Export file ##
write.csv(ds_netflix_titles, "ds_netflix_titles.csv", sep = '; ')

##########################
## Wikipedia html Table ##
##########################

## URL Wikipedia
oscars_url <- "https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films"

##Getting Oscars' Table ##
##ds_oscars <- read_html(oscars_url) %>%
##  html_node("table") %>%
##  html_table()

##Getting Oscars' Table - Using X-Patch##
ds_oscars <- read_html(oscars_url) %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table') %>%
  html_table() %>%
  select(title = Film, Awards)

## Export file ##
write.csv2(ds_oscars, "ds_oscars.csv", sep = "; ")

##################
## IMDB Ratting ##
##################

## URL IMDB ##

IMDB_url <- "https://www.imdb.com/chart/top/"

## Using X-Path ##
ds_imdb <- read_html(IMDB_url) %>%
  html_node(xpath = '//*[@id="main"]/div/span/div/div/div[3]/table') %>%
  html_table()

## Getting movies' name ##
ds_imdb_titles <- read_html(IMDB_url) %>%
  html_nodes(".titleColumn a") %>%
  html_text()

## Getting the Imdb rating ##
ds_imdb_rating <- read_html(IMDB_url) %>%
  html_nodes(".ratingColumn.imdbRating strong") %>%
  html_text()

## Creating Imdb table ##
ds_imdb <- as_tibble(cbind(title = ds_imdb_titles, rating = ds_imdb_rating))

## Export file ##
write.csv2(ds_imdb, "ds_imdb.csv", sep = "; ")


####################################
## Yahoo Finance - Netflix Stocks ##
####################################

## Getting the stock historical data ##
getSymbols("NFLX", src = "yahoo")

## Fix rownames and selecting Close and Volume columns ##
ds_stocks <- as.data.frame(NFLX) %>%
  rownames_to_column(var = "date")  %>%
  select(date, price = NFLX.Close, volume = NFLX.Volume)

## Export file ##
write.csv2(ds_stoks, "ds_stoks.csv", sep = ";")

