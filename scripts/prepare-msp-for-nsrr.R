#-------------------------------------------------------------------#
#      Convert SPSS file to csv and prep for NSRR MSPF dataset      #
#      Date Created: 29-01-23      Author: Meg Tully                # 
#-------------------------------------------------------------------#

ver <- "0.1.0.pre"

library(haven)
demo <- read_sav("//rfawin/BWH-SLEEPEPI-NSRR-STAGING/20221018-dipietro-fhr/NSSRDEMOVARIABLES.SAV")

colnames(demo) <- tolower(colnames(demo))
demo$visit = 1

#add leading 0's where needed
demo$id[nchar(demo$id)==1] <- paste("00",demo$id[nchar(demo$id)==1],sep="")
demo$id[nchar(demo$id)==2] <- paste("0",demo$id[nchar(demo$id)==2],sep="")

# create fileid variable to match EDF
demo$fileid <- paste("msp-S",demo$id,sep="")

#reorder
demo<-demo[,c("id","fileid",colnames(demo)[2:25])]

#write first dataset
setwd(paste("C:/Users/mkt27/msp-data-dictionary/csvs/",ver, sep=""))
write.csv(demo, paste("msp-dataset-",ver,".csv",sep=""), row.names = F)

#now harmonized
demo2 <- data.frame(id = demo$id,
                    fileid = demo$fileid,
                    nsrr_age = demo$mat_age,
                    nsrr_age_gt89 = "no",
                    nsrr_race = NA,
                    nsrr_sex = "female",
                    nsrr_current_smoker = "no")
for(i in 1:length(demo$id)){
  if(demo$mat_race[i]==2){
    demo2$nsrr_race[i] <- "black or african american"}
  if(demo$mat_race[i]==1){
    demo2$nsrr_race[i] <- "white"}
  if(demo$mat_race[i]==3){
    demo2$nsrr_race[i] <- "asian"}
}

demo2$visit = 1

write.csv(demo2, paste("msp-dataset-harmonized-",ver,".csv",sep=""), row.names = F)
