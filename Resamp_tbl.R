# table of resample rate (%) by year and constituent


# from the ReadMe:
# write.csv (unformatted) and save_html (formatted) output options for a table 
# of // Resample Rate of both Site-Wide and Parameter-Specific Duplicates //
# Both site and ten duplicates (whole site repeat measures and single or several 
# variable repeat measured) are included in calculations

#   Need to establish common naming schema for DFs variables and functions across these scripts 


FullDF <- read.csv("N:/Working/Niziolek/reach-level streams data (incl. resamps).csv")%>%
  mutate(Dup = rowSums(.[,c("Ten_Duplicate","Site_Duplicate")]),
         Year = substr(.$Start_Date,1,4)) # Year already exists from the Macros DF, but need NAs filled in

#  The below has been incorporated into the saved FullDF and doesn't need run for resamples #######
# # coping with multiple resamples at single reaches 
# duplicatingRows <- DF[c(which(DF$Site_Duplicate == 0 & DF$Ten_Duplicate == 0 & DF$Reach_Name == "CRLAWQ14" & DF$Year == 2021)),]
# duplicatingRows$Reach_Name <- "CRLAWQ14_1"
# # now change ONE of the duplicates' names
# DF[c(which(DF$Ten_Duplicate == 1 & DF$Reach_Name == "CRLAWQ14" & DF$Year == 2021)),]$Reach_Name <- "CRLAWQ14_1"
# # merge and clear duplicatingRows
# rsDF <- rbind(DF,duplicatingRows)
# rm(duplicatingRows)
# duplicatingRows <- DF[c(which(DF$Site_Duplicate == 0 & DF$Ten_Duplicate == 0 & DF$Reach_Name == "LAVOWQ27" & FullDF$Year == 2017)),]
# duplicatingRows$Reach_Name <- "LAVOWQ27_1"
# # now change ONE of the duplicates' names
# DF[c(which(DF$Ten_Duplicate == 1 & DF$Reach_Name == "LAVOWQ27" & DF$Year == 2017)),]$Reach_Name <- "LAVOWQ27_1"
# # merge and clear duplicatingRows
# DF.resamples <- rbind(rsDF,duplicatingRows)
# rm(duplicatingRows,rsDF)


# widen and subset to resampled reaches, export to csv ####
DF$Start_Date<-as.POSIXct(DF$Start_Date,format="%m/%d/%Y")
ResampDF <- DF%>%
  mutate(Dup=Site_Duplicate+Ten_Duplicate)%>%
  maditr::dcast(Reach_Name+Year~Dup,
                value.var = names(FullDF[,c(3,6:91)]))
ResampDF <- ResampDF[c(which(!is.na(ResampDF$Start_Date_1))),]


SumIsNotNA <- function(x){sum(!is.na(x))}

ResampDF1 <- ResampDF%>%
  mutate(Date.diff = difftime(Start_Date_1,Start_Date_0,units="day"),
         Date_resamp = Start_Date_1,
         Date_og = Start_Date_0)%>%
  select(-contains("_0"))

N_resamp_obs <- ResampDF1 %>%
  dplyr::group_by(Year) %>% # variable Year will be created in code from Start_Date, can leave like this
  dplyr::summarize(dplyr::across(everything(),SumIsNotNA))

N_resamp_obs <- merge(n_NA_obs[,c("Year","N")],N_resamp_obs,by="Year")

N_resamp_obs <- ResampDF%>%
  mutate(Date.diff = difftime(Start_Date_1,Start_Date_0,units="day"),
         Date_resamp = Start_Date_1,
         Date_og = Start_Date_0)%>%
  select(-contains("_0"))%>%
  dplyr::group_by(Year) %>% # variable Year will be created in code from Start_Date, can leave like this
  dplyr::summarize(dplyr::across(everything(),SumIsNotNA))




# calculate % completion from # missing
PercFun <- function(cols){((cols)/{N_resamp_obs$N})*100}

# set variables to summarize, i.e. pick the representative from each group that'll be printed (and renamed) in the table
Reps <- c("Nitrogen_tot","Potassium_diss","Org_carbon_diss","Slope","ORP","Turb","Ht_avg","SedMean1","MeanPer",
          "PercentPool","habCover","c1v_awd","c1v_wd","HBI")
Reps.names <- c("Nutrients","Ions","DOC","Slope","Manta*","Turb*","Legacy trees","Sediment","Ebed",
                "Channel morph","Cover","Above-bank wood","In-bank wood","Macros")

# reset resamp df names to drop "_1" suffix
names(N_resamp_obs)<-gsub(pattern = "\\_1$", replacement = "", x = names(N_resamp_obs))

ResampRate_tbl <- N_resamp_obs %>%
  dplyr::select(Year,N,all_of(Reps))%>%
  dplyr::mutate(across(Reps,PercFun))
# QUESTION FOR SARAH - this percent function needs to be used with two tables, can't figure out how
# to set it so the DF in the pipe is the DF N and cols pull from. This works find for cols but does not work for N

names(ResampRate_tbl) <- c("Year","N",print(Reps.names))

write.csv(ResampRate_tbl,"resample rates, all parameter summary.csv")



############################

#  Need a kable table!

############################

