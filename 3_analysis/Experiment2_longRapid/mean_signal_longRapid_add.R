# calculate mean for signal, add rows only (long rapid FFR)

# clear workspace
rm(list = ls(all = TRUE))

setwd("/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/4_readyForAnalysis/")

# read data file
tons<-read.csv("in/Experiment2_longRapid/rep1000_longRapid.csv",header=TRUE)
  
# select subsets
add_tons<-subset(tons,combine=="add") # add rows only
phaseLocked<-subset(add_tons,condition=="phaselocked") # phaseLocked rows only for signal

# change class (integer -> factor)
phaseLocked$sweeps<-as.factor(phaseLocked$sweeps)
phaseLocked$chunk<-as.factor(phaseLocked$chunk)

# create empty matrix (16listeners*15chunks*1file)
zscores<-matrix(nrow=length(levels(phaseLocked$listener))*length(levels(phaseLocked$chunk))*1,
                ncol=10)
# name columns
colnames(zscores)<-c("listener","run","combine","chunks","Freq1","Freq2","Freq3","Freq4","Freq5","rms")

# start counter
row = 1

# compute mean and sd per participant & number of sweeps
for(i in 1:length(levels(phaseLocked$listener))){
  participant<-levels(phaseLocked$listener)[i]
  #select participant's data
  sig<-subset(phaseLocked,listener==participant)
  
  for (j in 1){ # one run
    if (j==1){
      if (i<22){
        fileName<-paste(participant,"-HC-quiet-pos.mat",sep="")
      }
      fileName2<-fileName
      
      run<-"1"
    } 
    
    sigFile<-subset(sig,file==fileName)
    
    for (k in 1:length(levels(sigFile$chunk))){
      chnk<-levels(sigFile$chunk)[k]
      # select chunk
      sig_chnk<-subset(sigFile,chunk==chnk)
      
      
      # calculate mean and sd
      mu<-apply(sig_chnk[,9:14],2,mean,na.rm=TRUE)
      
      
      # save in matrix
      zscores[row,1]<-participant
      zscores[row,2]<-run
      zscores[row,3]<-"add"
      zscores[row,4]<-chnk
      zscores[row,5]<-as.numeric(mu[1])
      zscores[row,6]<-as.numeric(mu[2])
      zscores[row,7]<-as.numeric(mu[3])
      zscores[row,8]<-as.numeric(mu[4])
      zscores[row,9]<-as.numeric(mu[5])
      zscores[row,10]<-as.numeric(mu[6])
      
      row = row+1
    }
  }
}

# save mean noise floor
write.csv(zscores,"out/Experiment2_longRapid/signal_mean_longRapid_add.csv",row.names=FALSE)



