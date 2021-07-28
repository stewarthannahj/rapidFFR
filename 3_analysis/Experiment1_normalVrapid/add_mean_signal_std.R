# calculate mean for signal, add rows only (standard FFR)

# clear workspace
rm(list = ls(all = TRUE))

setwd("/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/4_analysis/")

# read data file
tons<-read.csv("in/Experiment1_normalVrapid/rep1000_iterations_std.csv",header=TRUE)

# select subsets
add_tons<-subset(tons,combine=="add") # add rows only
phaseLocked<-subset(add_tons,condition=="phaselocked") # phaseLocked rows only for signal

# change class (integer -> factor)
phaseLocked$sweeps<-as.factor(phaseLocked$sweeps)
phaseLocked$chunk <-as.factor(phaseLocked$chunk)

# create empty matrix (16listeners*15iterations*2polarities)
zscores<-matrix(nrow=length(levels(phaseLocked$listener))*length(levels(phaseLocked$chunk))*2,
                ncol=10)
# name columns
colnames(zscores)<-c("listener","run","combine","chunk","Freq1","Freq2","Freq3","Freq4","Freq5","rms")

# start counter
row = 1

# compute mean and sd per participant & number of sweeps
for(i in 1:length(levels(phaseLocked$listener))){
  participant<-levels(phaseLocked$listener)[i]
  #select participant's data
  sig<-subset(phaseLocked,listener==participant)
  
  for (j in 1:2){ # two runs
    if (j==1){
      if (i<17){
        fileName<-paste(participant,"-normal-pos-1.mat",sep="")
      } 
      fileName2<-fileName
      
      run<-"1"
    } else if (j==2){
      
      if (i<17){
        fileName<-paste(participant,"-normal-pos-2.mat",sep="")
      } 
      fileName2<-fileName
      
      run<-"2"
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
write.csv(zscores,"out/Experiment1_normalVrapid/signal_mean_std_add.csv",row.names=FALSE)



