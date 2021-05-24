library(Rcmdr)
library(car)

# clear workspace
rm(list = ls(all = TRUE))

allCHUNKS = c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15")

# read data files
setwd("C:/Users/t.schoof/Documents/Work/Rapid FFR/9minResults/")

signalfile = read.csv("15chunks_4500nReps.csv",header=T)

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
  
  signalfile_listener = signalfile[grep(paste("^",listener,sep=""), signalfile$listener),]
  
  for(z in 1:length(allCHUNKS)){
    
    chunky = allCHUNKS[z]
    
    # select subset - nReps
    signalfile_Reps = signalfile_listener[grep(paste("^",chunky,"$",sep=""), signalfile_listener$chunk),]
    
    # select signal or noisefloor
    signal = signalfile_Reps[grep(paste("^","phaselocked",sep=""), signalfile_Reps$condition),]
    noise = signalfile_Reps[grep(paste("^","random",sep=""), signalfile_Reps$condition),]
    
    # select subset - polarity
    NZadd_orig = noise[grep("^add", noise$combine),]
    SIGadd_orig = signal[grep("^add", signal$combine),]
    NZsub_orig = noise[grep("^sub", noise$combine),]
    SIGsub_orig = signal[grep("^sub", signal$combine),]
    
    # select subset run - not necessary here actually
    NZadd1<-NZadd_orig
    SIGadd1<-SIGadd_orig
    NZsub1<-NZsub_orig
    SIGsub1<-SIGsub_orig
    
    var_name <-colnames(NZadd_orig)
    
    # calculate dprime & SNR
    # calculate dprime
    
    cor.matrix.add<-matrix(nrow=1,ncol=9)
    
    colnames(cor.matrix.add) = c("listener","run","chunk","condition","meanNZ","meanSIG","sdNZ","sdSIG","dprime")
    cor.matrix.sub<-cor.matrix.add
    
    
    for(i in 9:14){
      mnNZadd1 = mean(NZadd1[,i],na.rm=T)
      mnSIGadd1 = mean(SIGadd1[,i],na.rm=T)
      sdNZadd1 = sd(NZadd1[,i],na.rm=T)
      sdSIGadd1 = sd(SIGadd1[,i],na.rm=T)
      
      mnNZsub1 = mean(NZsub1[,i],na.rm=T)
      mnSIGsub1 = mean(SIGsub1[,i],na.rm=T)
      sdNZsub1 = sd(NZsub1[,i],na.rm=T)
      sdSIGsub1 = sd(SIGsub1[,i],na.rm=T)
      
      dprime.add = (mnSIGadd1 - mnNZadd1)/sqrt((sdSIGadd1^2+sdNZadd1^2)/2)
      dprime.sub = (mnSIGsub1 - mnNZsub1)/sqrt((sdSIGsub1^2+sdNZsub1^2)/2)
      
      # save dprime
      cor.matrix.add[1,1]<-listener
      cor.matrix.add[1,2]<-1
      cor.matrix.add[1,3]<-chunky
      cor.matrix.add[1,4]<-"rapid"
      cor.matrix.add[1,5]<-mnNZadd1
      cor.matrix.add[1,6]<-mnSIGadd1
      cor.matrix.add[1,7]<-sdNZadd1
      cor.matrix.add[1,8]<-sdSIGadd1
      cor.matrix.add[1,9]<-dprime.add	
      
      cor.matrix.sub[1,1]<-listener
      cor.matrix.sub[1,2]<-1
      cor.matrix.sub[1,3]<-chunky
      cor.matrix.sub[1,4]<-"rapid"
      cor.matrix.sub[1,5]<-mnNZsub1
      cor.matrix.sub[1,6]<-mnSIGsub1
      cor.matrix.sub[1,7]<-sdNZsub1
      cor.matrix.sub[1,8]<-sdSIGsub1
      cor.matrix.sub[1,9]<-dprime.sub
      
      write.csv(cor.matrix.add,file=paste("C:/Users/t.schoof/Documents/Work/Rapid FFR/9minResults/R output/dprime_",listener,"_rapid_",chunky,"_",var_name[i],"add_Mar2017.csv"))
      write.csv(cor.matrix.sub,file=paste("C:/Users/t.schoof/Documents/Work/Rapid FFR/9minResults/R output/dprime_",listener,"_rapid_",chunky,"_",var_name[i],"sub_Mar2017.csv"))
    }
  }
}


