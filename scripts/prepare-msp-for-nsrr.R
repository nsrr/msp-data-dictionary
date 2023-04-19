#-------------------------------------------------------------------#
#      Convert SPSS file to csv and prep for NSRR MSP dataset       #
#      Date Created: 29-01-23      Author: Meg Tully                # 
#-------------------------------------------------------------------#

ver <- "0.1.0.pre"

library(haven)
data <- read_sav("//rfawin/BWH-SLEEPEPI-NSRR-STAGING/20221018-dipietro-fhr/NSSRdemoVARIABLES.SAV")

colnames(data) <- tolower(colnames(data))
data$visit = 1

#add leading 0's where needed
data$id[nchar(data$id)==1] <- paste("00",data$id[nchar(data$id)==1],sep="")
data$id[nchar(data$id)==2] <- paste("0",data$id[nchar(data$id)==2],sep="")

# create fileid variable to match EDF
data$fileid <- paste("msp-S",data$id,sep="")

#reorder
data<-data[,c("id","fileid",colnames(data)[2:25])]

#write first dataset
setwd(paste("C:/Users/mkt27/msp-data-dictionary/csvs/",ver, sep=""))
write.csv(data, paste("msp-dataset-",ver,".csv",sep=""), row.names = F)

#now create harmonized dataset

#datagraphics:
data2 <- data.frame(id = data$id,
                    fileid = data$fileid,
                    nsrr_age = data$mat_age,
                    nsrr_age_gt89 = "no",
                    nsrr_race = NA,
                    nsrr_sex = "female",
                    nsrr_current_smoker = "no")

for(i in 1:length(data$id)){
  if(data$mat_race[i]==2){
    data2$nsrr_race[i] <- "black or african american"}
  if(data$mat_race[i]==1){
    data2$nsrr_race[i] <- "white"}
  if(data$mat_race[i]==3){
    data2$nsrr_race[i] <- "asian"}}

# PSG harmonized variables

data2$nsrr_ahi_hp3u <- data$ahi1
data2$nsrr_ahi_hp3r_aasm15 <- data$ahi2
data2$nsrr_ttleffbd	<- data$se
data2$nsrr_ttldursp_f1 <- data$tst
data2$nsrr_pctdursp_s3_f1	<- data$tstdeep
data2$nsrr_pctdursp_sr_f1	<- data$tstrem

data2$visit = 1

write.csv(data2, paste("msp-dataset-harmonized-",ver,".csv",sep=""), row.names = F)
