# clear workspace
rm(list = ls(all = TRUE))

# set wd
setwd("/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/4_analysis/")

# set row counter
row = 1

# chunks
chunks= c("1", "2", "3","4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15")
var_name <- c("Freq1","Freq2","Freq3", "Freq4", "Freq5", "rms")

# make empty matrix (number of Ps*chunks*varName options)
lineData.add<-matrix(nrow=(21*length(chunks)*length(var_name)),ncol=11)
# name columns
colnames(lineData.add) = c("listener","run","chunk","condition", "var_name", "meanNZ","meanSIG","sdNZ","sdSIG","dprime","snr")
# copy empty add matrix for sub
lineData.sub<-lineData.add

for (h in 1:21){
  if(h==1){
    listener = "L01"
  }
  else if(h==2){
    listener = "L02"
  }
  else if(h==3){
    listener = "L03"
  }
  else if(h==4){
    listener = "L05"
  }
  else if(h==5){
    listener = "L06"
  }
  else if(h==6){
    listener = "L07"
  }
  else if(h==7){
    listener = "L08"
  }
  else if(h==8){
    listener = "L09"
  }
  else if(h==9){
    listener = "L11"
  }
  else if(h==10){
    listener = "L12"
  }
  else if(h==11){
    listener = "L13"
  }
  else if(h==12){
    listener = "L14"
  }
  else if(h==13){
    listener = "L15"
  }
  else if(h==14){
    listener = "L16"
  }
  else if(h==15){
    listener = "L04"
  }
  else if(h==16){
    listener = "L10"
  }
  else if(h==17){
    listener = "L17"
  }
  else if(h==18){
    listener = "L18"
  }
  else if(h==19){
    listener = "L19"
  }
  else if(h==20){
    listener = "L20"
  }
  else if(h==21){
    listener = "L21"
  }
  
  for(i in 1:6){
    var = var_name[i]
    
    for(z in 1:length(chunks)){
      chunk = chunks[z]

      dataName_add <- paste("out/Experiment2_longRapid/Routput_longRapid/snr_",listener,"_longRapid_",chunk,"_",var_name[i],"add_28July21.csv")
      dataName_sub <- paste("out/Experiment2_longRapid/Routput_longRapid/snr_",listener,"_longRapid_",chunk,"_",var_name[i],"sub_28July21.csv")
      data_add<-read.csv(dataName_add, header=TRUE)
      data_sub<-read.csv(dataName_sub, header=TRUE)
      
      lineData.add[row,1] <- listener
      lineData.add[row,2] <- "add"
      lineData.add[row,3] <- as.numeric(data_add[4])
      lineData.add[row,4] <- "longRapid"
      lineData.add[row,5] <- var_name[i]
      lineData.add[row,6] <- as.numeric(data_add[6])
      lineData.add[row,7] <- as.numeric(data_add[7])
      lineData.add[row,8] <- as.numeric(data_add[8])
      lineData.add[row,9] <- as.numeric(data_add[9])
      lineData.add[row,10] <- as.numeric(data_add[10])
      lineData.add[row,11] <- as.numeric(data_add[11])
      
      lineData.sub[row,1] <- listener
      lineData.sub[row,2] <- "sub"
      lineData.sub[row,3] <- as.numeric(data_sub[4])
      lineData.sub[row,4] <- "longRapid"
      lineData.sub[row,5] <- var_name[i]
      lineData.sub[row,6] <- as.numeric(data_sub[6])
      lineData.sub[row,7] <- as.numeric(data_sub[7])
      lineData.sub[row,8] <- as.numeric(data_sub[8])
      lineData.sub[row,9] <- as.numeric(data_sub[9])
      lineData.sub[row,10] <- as.numeric(data_sub[10])
      lineData.sub[row,11] <- as.numeric(data_sub[11])
      
      # update row counter
      row = row + 1
      
    }
  }
}

# save to data file      
write.csv(lineData.add,file=paste("out/Experiment2_longRapid/snr_longRapid_concat_add.csv"))
write.csv(lineData.sub,file=paste("out/Experiment2_longRapid/snr_longRapid_concat_sub.csv"))

  
  
  
  
  