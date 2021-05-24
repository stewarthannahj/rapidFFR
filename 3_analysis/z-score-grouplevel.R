# calculate z-scores on a group level

setwd("C:/Users/t.schoof/Documents/work/Rapid FFR")


for (jj in 1:2){ # rapid & standard FFR
  
  if (jj==1){
    # read data file
    sig<-read.csv("7500nReps/500_to_7500nReps_once.csv",header=TRUE)
    nzFile<-read.csv("nzfloor_mean_rapid.csv",header=TRUE)
  } else if (jj==2){
    # read data file
    sig<-read.csv("sig_standard.csv",header=TRUE)
    nz<-read.csv("nzfloor_standard.csv",header=TRUE)
  }
  
  # select subsets
  sigFile<-subset(sig,combine=="add")
  
  # change class
  sigFile$sweeps<-as.factor(sigFile$sweeps)
  nzFile$sweeps<-as.factor(nzFile$sweeps)
  
  # create empty matrix
  zscores<-matrix(nrow=16,
                  ncol=10)
  colnames(zscores)<-c("listener","run","combine","sweeps","Freq1","Freq2","Freq3","Freq4","Freq5","rms")
  
  # start counter
  row = 1
  
  for (k in 1:length(levels(nzFile$sweeps))){
    swps<-levels(nzFile$sweeps)[k]
    # select sweeps
    nz_swps<-subset(nzFile,sweeps==swps)
    if(jj==1){
      sig_swps<-subset(sigFile,sweeps==(as.numeric(swps)-4))
    } else if (jj==2){
      sig_swps<-subset(sigFile,sweeps==swps)
    }
    
    # calculate mean and sd
    mu<-apply(nz_swps[,5:10],2,mean,na.rm=TRUE)
    sigma<-apply(nz_swps[,5:10],2,sd,na.rm=TRUE)
    
    # calculate z-score
    x<-sig_swps[9:14]
    z=(x-mu)/sigma
    
    # save in matrix
    zscores[row,1]<-participant
    zscores[row,2]<-run
    zscores[row,3]<-"add"
    zscores[row,4]<-swps
    zscores[row,5]<-as.numeric(z[1])
    zscores[row,6]<-as.numeric(z[2])
    zscores[row,7]<-as.numeric(z[3])
    zscores[row,8]<-as.numeric(z[4])
    zscores[row,9]<-as.numeric(z[5])
    zscores[row,10]<-as.numeric(z[6])
    
    row = row+1
  }
  
  # save zscores
  if (jj==1){
    write.csv(zscores,"zscores_rapid.csv",row.names=FALSE)
  } else if (jj==2){
    write.csv(zscores,"zscores_standard.csv",row.names=FALSE)
  }
}


