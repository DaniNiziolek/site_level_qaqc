#  Produce a table of percent data completeness 


# my df, variables ####
DF <- read.csv("reach-level streams data.csv") # BigDF_og
DF$Start_Date<-as.POSIXct(DF$Start_Date,format="%m/%d/%Y")


Variables <- c("Nitrogen_tot","Phosphorus_tot","Sodium_diss","Potassium_diss","Calcium_diss","Magnesium_diss",
               "sulfate_diss","Chlorine_diss","Org_carbon_diss","Water_temp","Air_temp","Slope","Temp","SC","DO",
               "ORP","Turb","DOsat","TDS","pH","Ht","Dist","Ht_avg","Dist_avg","SedMean1","SedMed1","LSUB_DMM",
               "MeanPer","PercentPool","PercentFast","RiparianCover","habCover","Riparian_Disturbance","ABF_15_0103",                   
               "ABF_15_0306","ABF_15_0608","ABF_15_08","ABF_515_0103","ABF_515_0306","ABF_515_0608","ABF_515_08",
               "ABF_155_0103","ABF_155_0306","ABF_155_0608","ABF_155_08","c1t_awd","c2t_awd","c3t_awd","c4t_awd",
               "c5t_awd","c1v_awd","c2v_awd","c3v_awd","c4v_awd","c5v_awd","BF_15_0306","BF_15_0103","BF_15_0608",
               "BF_15_08","BF_515_0103","BF_515_0306","BF_515_0608","BF_515_08","BF_155_0103","BF_155_0306",
               "BF_155_0608","BF_155_08","c1t_wd","c2t_wd","c3t_wd","c4t_wd","c5t_wd","c1v_wd","c2v_wd","c3v_wd",
               "c4v_wd","c5v_wd","LRBS_TST","Total.Taxa.Richness","Invert_Divers","HBI",
               "EPA.West.Wide.Invertebrate.MMI","OoverE0.5","OoverE0.1")
# reps should be representative variables for their category - one from each group to display in the table
Reps <- c("Nitrogen_tot","Potassium_diss","Org_carbon_diss","Slope","ORP","Turb","Ht_avg","SedMean1","MeanPer","PercentPool",
          "habCover","ABF_515_0306","BF_515_0306","HBI")
Reps.names <- c("Nutrients","Ions","DOC","Slope","Manta*","Turb*","Legacy trees","Sediment","Ebed","Channel morph",
                "Cover","Above-bank /nwood","In-bank /nwood","Macros")
##### 


# libraries
require()
# knitr and kable pkgs are down in the html output chunk
# no sense loading them if someone wants to only save the csv
# I am not positive what all packages are in use here, need to figure out

#   Build the table     ####
# tally up n(missing values) in each column (columns listed in Variables)
SumIsNA <- function(x){sum(is.na(x))}
#also define DF <- User's_Input_Data; change Reach_Name to SamplUnits <- DF$sample_unit_ID_col

DF[,c(3:ncol(DF))]<-apply(DF[,c(3:ncol(DF))],2,as.numeric)
#this was only needed once but it did produce a table of incorrect values without error
# so I'm leaving it in, also it doesn't break anything if it's unnecessary 

which(DF$Site_Duplicate == 0 & DF$Ten_Duplicate == 0)

n_NA_obs <- DF %>%
  dplyr::mutate(Year = substr(Start_Date,1,4))%>%
  dplyr::filter(Site_Duplicate == 0 & Ten_Duplicate == 0)%>%
  dplyr::select(Year,Reach_Name,tidyselect::any_of(Variables)) %>%
  dplyr::group_by(Year) %>% # variable Year will be created in code from Start_Date, can leave like this
  dplyr::summarize(dplyr::across(Variables,SumIsNA),
                   N = length(unique(substr(Reach_Name,1,8)))) #subsets out the _# ID'ers for multiple resamples to avoid double counting

# calculate % completion from # missing
PercFun <- function(cols){(({n_NA_obs$N} - cols)/{n_NA_obs$N})*100}

CompletionRate_tbl <- n_NA_obs %>%
  dplyr::select(everything())%>%
  dplyr::mutate(across(Variables,PercFun))

# save table to csv ####
write.csv(CompletionRate_tbl,paste(CSVoutput,".csv",sep=""))


# make the table pretty, save_html ####
library(knitr)
library(kableExtra)
library(formattable)

RuleMissings<- function(x) {
  ifelse(x < 95.0,
         cell_spec(x, "html", color = "red", bold=T),
         cell_spec(x, "html", color = "black"))}

Compl<-CompletionRate_tbl %>%
  dplyr::mutate(across(Reps,RuleMissings)) %>%
  dplyr::select(Year,N,all_of(Reps)) %>%
  knitr::kable("html", escape = F, row.names=FALSE,align=c(rep("r",3),"c"),
               col.names = c("Year","Reaches",Reps.names)) %>% 
  #turns it into kable object so column_spec can take it
  #kableExtra::column_spec(c(1,2,3), width = "1cm") %>% #set width of column two (wraps header text)
  #kableExtra::column_spec(4:ncol(), width = "1.5cm") %>%
  kableExtra::kable_styling("hover", full_width = F) #makes the table space out nicely

# png("data completeness rate 2011_21.png")
# print(Compl)
# dev.off()

# stackexchange solution suggestion for getting around save_html not playing nice with kable
readr::write_file(Compl, "Missing_tbl.html")

#####
rm(Compl)