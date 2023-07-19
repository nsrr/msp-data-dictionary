#-------------------------------------------------------------------#
#      Convert SPSS file to csv and prep for NSRR MSP dataset       #
#      Date Created: 29-01-23      Author: Meg Tully                # 
#-------------------------------------------------------------------#

ver <- "0.1.2.pre2"

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

data_extracted <- read.csv("//erisonefs.partners.org/nsrr/datasets/msp/polysomnography/extracted.csv")
data_extracted$fileid <- NA
for(i in 1:length(data_extracted$file)){data_extracted$fileid[i] <- strsplit(data_extracted$file[i], "[.]")[[1]][1]}
data_extracted$file <- NULL

data <- full_join(data,data_extracted, by="fileid")

data <- data[!is.na(data$mat_race),]

#now create harmonized dataset

#demographics:
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
data2$nsrr_effsp_f1	<- data$se
data2$nsrr_ttldursp_f1 <- data$tst
data2$nsrr_pctdursp_s3_f1	<- data$tstdeep
data2$nsrr_pctdursp_sr_f1	<- data$tstrem

data2$nsrr_begtimsp_f1 <- data$stonsetp
data2$nsrr_endtimsp_f1 <- data$stoffsetp
data2$nsrr_begtimbd_f1 <- data$stloutp
data2$nsrr_endtimbd_f1 <- data$stlonp

data2$visit = 1

for(i in 1:length(data2$id)){
  for(j in 1:length(data2[1,])){
    if(is.na(data2[i,j])){
      data2[i,j] <- '.'
    }
  }
}

write.csv(data2, paste("//rfawin.partners.org/bwh-sleepepi-nsrr-staging/20221018-dipietro-fhr/nsrr-prep/_releases/",ver,
"/msp-harmonized-dataset-",ver,".csv",sep=""), row.names = F)

#write first dataset
setwd(paste("//rfawin.partners.org/bwh-sleepepi-nsrr-staging/20221018-dipietro-fhr/nsrr-prep/_releases/",ver, sep=""))
write.csv(data, paste("msp-dataset-",ver,".csv",sep=""), row.names = F, na="")







