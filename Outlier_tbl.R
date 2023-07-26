# Outlier tables. 
#data includes resamples and originals

# table 1: Rate (%) and Number of Outliers in each Variable Cluster

# table 2: Number of Outliers in Each Park and Year


#############
#
#  TABLE 1 
#
#############
#  count up number of non-NA values for each parameter (see also Total_reaches_visited) ####
NObs.vars <- FullDF %>% 
  select_if(is.numeric) %>%
  summarize_all(~ sum(!is.na(.)))
# playing
NObs.vars2 <- FullDF %>% 
  group_by(substr(Reach_Name,1,4),substr(Start_Date,1,4))%>%
  summarize_all(~ sum(!is.na(.)))

# create new DF with one column, summing total n of records for each variable group ####

NObs.tbl <- as.data.frame(rbind(sum(NObs.vars[,c("Nitrogen_tot","Phosphorus_tot")]),
                                sum(NObs.vars[,c("Sodium_diss","Potassium_diss","Calcium_diss",
                                                 "Magnesium_diss","sulfate_diss","Chlorine_diss")]),
                                sum(NObs.vars[,c("Org_carbon_diss")]),
                                
                                sum(NObs.vars[,c("Temp","SC","DO","ORP","Turb","DOsat","pH")]),
                                sum(NObs.vars[,c("Slope")]),
                                
                                sum(NObs.vars[,c("SedMean1","SedMed1")]),
                                sum(NObs.vars[,c("MeanPer")]),
                                sum(NObs.vars[,c("PercentPool","PercentFast")]),
                                
                                sum(NObs.vars[,c("RiparianCover","habCover","Riparian_Disturbance")]),
                                sum(NObs.vars[,c("Ht_avg","Dist_avg")]),
                                sum(NObs.vars[,c("ABF_15_0103","ABF_15_0306","ABF_15_0608","ABF_15_08","ABF_515_0103","ABF_515_0306","ABF_515_0608","ABF_515_08","ABF_155_0103","ABF_155_0306","ABF_155_0608","ABF_155_08")]),
                                sum(NObs.vars[,c("BF_15_0306", "BF_15_0103","BF_15_0608","BF_15_08","BF_515_0103","BF_515_0306","BF_515_0608","BF_515_08","BF_155_0103","BF_155_0306","BF_155_0608","BF_155_08")]),
                                sum(NObs.vars[,c("LRBS_TST")]),
                                sum(NObs.vars[,c("Total.Taxa.Richness","Invert_Divers","HBI","EPA.West.Wide.Invertebrate.MMI","OoverE0.5","OoverE0.1")])))

NObs.tbl$names <- c("Nutrients","Ions","DOC","CChem","Slope","Sediment","EBed","Channel","Veg","LTrees","AB wood","IB wood","RBS","Macros")
names(NObs.tbl) <- c("Num.records", "VitalSign")
#####



# I want to revisit this, do we actually need these to be jumbled together? Should I just separate out the Kable section?
# could do it that way, leave all the different outlier combo tables in and insert a stop point to instruct people 
# that they have options and can change the DF kable makes a table with if they're willing to mess with par()

# Tiny aside to create table of outlier flags, will use for finishing NObs.tbl ####
# count up number of outliers 
# this is kind of messier than I want, not sure how to get upper and lower outliers counted up in the same swoop... probably I need to learn ifelses
FN.u <- function(x){x = ifelse(x > mean(x,na.rm=T) + 3*sd(x,na.rm=T), yes = 1, no = 0)}
FN.l <- function(x){x = ifelse(x < mean(x,na.rm=T) - 3*sd(x,na.rm=T), yes = 1, no = 0)}

FullDF$Ten_Duplicate <- as.factor(FullDF$Ten_Duplicate)
FullDF$Site_Duplicate <- as.factor(FullDF$Site_Duplicate) # make sure the Dup columns don't get wiped out
Outliers.u <- FullDF%>%
  mutate_if(is.numeric,FN.u)
Outliers.l <- FullDF%>%
  mutate_if(is.numeric,FN.l)

# combine upper and lower outlier DFs to single frame
Outliers.df<-bind_rows(Outliers.u,Outliers.l) %>%
  #mutate_if(is.numeric, tidyr::replace_na, 0) %>% #in case of having NAs
  group_by(Reach_Name,Start_Date,Ten_Duplicate,Site_Duplicate) %>%
  summarise_if(is.numeric, sum, na.rm = TRUE)
# add ID columns for various functions and drop unneeded columns (they make the summing weird at steps w unspecified var lists)
Outliers.df$ID <- paste(substr(Outliers.df$Start_Date,1,4),substr(Outliers.df$Reach_Name,1,4),sep="_")
Outliers.df <- Outliers.df[,c(!names(Outliers.df) %in% 
                                c("X","N_Trans_ltrees","Ht","Dist","LSUB_DMM","Year","Water_temp","Air_temp","c1t_awd","c2t_awd","c3t_awd","c4t_awd","c5t_awd","c1v_awd","c2v_awd",                       
                                  "c3v_awd","c4v_awd","c5v_awd","c1t_wd","c2t_wd","c3t_wd","c4t_wd",
                                  "c5t_wd","c1v_wd","c2v_wd","c3v_wd","c4v_wd","c5v_wd"))]









#############
#
#  TABLE 2 
#
#############