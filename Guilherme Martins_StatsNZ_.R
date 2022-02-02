#Installing packages

install.packages("tidyverse")
library(tidyverse)
library(scales)

#Importing the dataset

Income <- read_delim("C:/Users/Guilherme/OneDrive/Portfolio/Job Interview/Stats NZ/Income.txt", 
                       delim = "\t", escape_double = FALSE, 
                       trim_ws = TRUE)

Occupations <- read_delim("C:/Users/Guilherme/OneDrive/Portfolio/Job Interview/Stats NZ/Occupations.txt", 
                          delim = "\t", escape_double = FALSE, 
                          trim_ws = TRUE)

#Cleaning the Dataset Occupation.txt

##Cleaning column "Sex"

Income$Sex[Income$Sex == 11] <- 1
Income$Sex[Income$Sex == 12] <- 2
Occupations$Sex[Occupations$Sex == 12] <- 2
Occupations$Sex[Occupations$Sex == 11] <- 1

##Cleaning column "Occupation"

Occupations$Occupation[Occupations$Occupation == "Married to Jim"] <- ""
Occupations$Occupation[Occupations$Occupation == "I look after my mother Sarah who is unwell"] <- ""

#Cleaning the Dataset Income.txt

Income <- Income %>%
  mutate(Income=ifelse(Transaction_Date == "2017-01-01" & Income > 2500000, 0,Income))

Income <- Income %>%
  mutate(Income=ifelse(Transaction_Date == "2015-01-01" & Income == 2000000, 0,Income))

Income <- Income %>%
  mutate(Income, Rounded_Incomes=round(Income, -4))

#Joining the tables

Income_Occupations <- Income %>%
  full_join(Occupations,by="ID")

#Finding Relationships

Age <- mutate(Income_Occupations, Age=round((Transaction_Date.x - Birth_Date.x)/365,0))

Age$Age <- as.numeric(as.difftime(Age$Age))

Age <- Age %>%
  select(Sex.x, Age, Rounded_Incomes)

Age <- mutate(Age, Age_Group=(round(Age, -1)))

Age$Sex.x[Age$Sex.x == 1] <- "Male"
Age$Sex.x[Age$Sex.x == 2] <- "Female"

AVG_IncBySex <- Income_Occupations %>%
  select(Sex.x, Rounded_Incomes) %>%
  na.omit() %>%
  group_by(Sex.x) %>%
  summarise(Avg_IncSex = mean(Rounded_Incomes))

AVG_IncByAge <- Age %>%
  select(Sex.x, Age_Group, Rounded_Incomes) %>%
  na.omit() %>%
  group_by(Age_Group, Sex.x) %>%
  summarise(Avg_IncAge = mean(Rounded_Incomes))


#Plot

ggplot(data=AVG_IncByAge,aes(x=Sex.x, y=Avg_IncAge)) + geom_point(aes(color=Sex.x)) + scale_y_continuous(name = "Average Income", labels = comma) + facet_wrap(~Age_Group) + labs(title = "Average Income per Age Group by Sex")



