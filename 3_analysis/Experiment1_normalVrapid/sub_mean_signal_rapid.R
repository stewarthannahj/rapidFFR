# calculate mean for signal, sub rows only (rapid FFR)

# clear workspace
rm(list = ls(all = TRUE))

setwd("/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/4_analysis/")


# read data file
tons1<-read.csv("in/Experiment1_normalVrapid/rep1000_iterations_rapid_pt1.csv",header=TRUE)
tons2<-read.csv("in/Experiment1_normalVrapid/rep1000_iterations_rapid_pt2.csv",header=TRUE)

tons <- rbind(tons1, tons2)

# select subsets
sub_tons<-subset(tons,combine=="sub") # sub rows only
phaselocked<-subset(sub_tons,condition=="phaselocked") # phaselocked rows only for signal

# change class (integer -> factor)
phaselocked$sweeps<-as.factor(phaselocked$sweeps)

# create empty matrix (16listeners*15iterations*2polarities)
zscores<-matrix(nrow=length(levels(phaselocked$listener))*length(levels(phaselocked$sweeps))*2,
                ncol=10)
# name columns
colnames(zscores)<-c("listener","run","combine","iteration","Freq1","Freq2","Freq3","Freq4","Freq5","rms")

# start counter
row = 1

# compute mean and sd per participant & number of sweeps
for(i in 1:length(levels(phaselocked$listener))){
  participant<-levels(phaselocked$listener)[i]
  #select participant's data
  sig<-subset(phaselocked,listener==participant)
  
  for (j in 1:2){ # two runs
    if (j==1){
      if (i<7){
        fileName<-paste(participant,"-rapid-pos-1.mat",sep="")
      } else if (i==12){
        fileName<-paste(participant,"-rapid-pos-1.mat",sep="")
      } else {
        fileName<-paste(participant,"-HC-rapid-pos-1.mat",sep="")
      }
      fileName2<-fileName
      
      run<-"1"
    } else if (j==2){
      
      if (i<7){
        fileName<-paste(participant,"-rapid-pos-2.mat",sep="")
      } else if (i==12){
        fileName<-paste(participant,"-rapid-pos-2.mat",sep="")
      } else {
        fileName<-paste(participant,"-HC-rapid-pos-2.mat",sep="")
      }
      fileName2<-fileName
      
      run<-"2"
    }
    
    sigFile<-subset(sig,file==fileName)
    
    for (k in 1:length(levels(sigFile$sweeps))){
      swps<-levels(sigFile$sweeps)[k]
      # select sweeps
      sig_swps<-subset(sigFile,sweeps==swps)
      
      
      # calculate mean and sd
      mu<-apply(sig_swps[,9:14],2,mean,na.rm=TRUE)
      
      
      # save in matrix
      zscores[row,1]<-participant
      zscores[row,2]<-run
      zscores[row,3]<-"sub"
      zscores[row,4]<-swps
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
write.csv(zscores,"out/Experiment1_normalVrapid/signal_mean_rapid_sub.csv",row.names=FALSE)



