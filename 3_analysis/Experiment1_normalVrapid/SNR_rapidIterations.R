library(Rcmdr)
library(car)

# clear workspace
rm(list = ls(all = TRUE))

# iterations
ALLnReps= c("500", "1000", "1500","2000", "2500","3000", "3500","4000", "4500","5000","5500","6000","6500","7000","7500")
ALLnReps_nz= c("500", "1000", "1500","2000", "2500","3000", "3500","4000", "4500","5000","5500","6000","6500","7000","7500")
ALLnReps_sig = c("496", "996", "1496","1996", "2496","2996", "3496","3996", "4496","4996","5496","5996","6496","6996","7496")

# read data files
setwd("/Volumes/UCL_DR_HJS/projects/rapidFFR/1_data/4_analysis/")

# read data file
signalfile1<-read.csv("in/Experiment1_normalVrapid/rep1000_rapidIterations_pt1.csv",header=TRUE)
signalfile2<-read.csv("in/Experiment1_normalVrapid/rep1000_rapidIterations_pt2.csv",header=TRUE)

#signalfile = read.csv("500_to_7500nReps_once_rapid.csv",header=T) # changed from 500_to_7500nReps_rapid.csv

signalfile <- rbind(signalfile1, signalfile2)

for (h in 1:16){
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
  
  # look in column 'listener' in file of everyone & get lines for listener h only
  signalfile_listener = signalfile[grep(paste("^",listener,sep=""), signalfile$listener),]
  
  # z is number of iterations in ALLnReps (defn line 9 above, length(AllnReps_nz) = length(AllnReps_sig))
  for(z in 1:length(ALLnReps_nz)){
    
    # current iteration in for loop
    nReps = ALLnReps[z]
    nReps_nz = ALLnReps_nz[z]
    nReps_sig = ALLnReps_sig[z]
    
    # select signal or noisefloor
    # look in column 'condition' for listener h and get random (noise) OR phaselocked (signal) only
    noise_listener = signalfile_listener[grep(paste("^","random",sep=""), signalfile_listener$condition),]
    signal_listener = signalfile_listener[grep(paste("^","phaselocked",sep=""), signalfile_listener$condition),]
    
    # select subset - nReps
    # look in column 'sweeps' for listener h and get iteration z only
    noise = noise_listener[grep(paste("^",nReps_nz,"$",sep=""), noise_listener$sweeps),]
    signal = signal_listener[grep(paste("^",nReps_sig,"$",sep=""), signal_listener$sweeps),]
    
    # select subset - polarity
    # look in column 'combine' for add OR sub only
    # should have # of rows = # of permutations i.e. 100 for TS, 1000 for HJS
    NZadd_orig = noise[grep("^add", noise$combine),]
    SIGadd_orig = signal[grep("^add", signal$combine),]
    NZsub_orig = noise[grep("^sub", noise$combine),]
    SIGsub_orig = signal[grep("^sub", signal$combine),]
    
    # select subset run - not necessary here actually
    # just copying, nothing changes...
    NZadd1<-NZadd_orig
    SIGadd1<-SIGadd_orig
    NZsub1<-NZsub_orig
    SIGsub1<-SIGsub_orig
    
    var_name <-colnames(NZadd_orig)
    
    # calculate dprime & SNR
    # calculate dprime
    # make new add matrix
    cor.matrix.add<-matrix(nrow=1,ncol=10)
    # name columns
    colnames(cor.matrix.add) = c("listener","run","iteration","condition","meanNZ","meanSIG","sdNZ","sdSIG","dprime","snr")
    # copy empty add matrix for sub
    cor.matrix.sub<-cor.matrix.add
    
    # get M and SD across F1, F2, F3, F4, F5, rms (i.e. columns 9:14)
    for(i in 9:14){
      # add files only
      mnNZadd1 = mean(NZadd1[,i],na.rm=T)
      mnSIGadd1 = mean(SIGadd1[,i],na.rm=T)
      sdNZadd1 = sd(NZadd1[,i],na.rm=T)
      sdSIGadd1 = sd(SIGadd1[,i],na.rm=T)
      
      # sub files only
      mnNZsub1 = mean(NZsub1[,i],na.rm=T)
      mnSIGsub1 = mean(SIGsub1[,i],na.rm=T)
      sdNZsub1 = sd(NZsub1[,i],na.rm=T)
      sdSIGsub1 = sd(SIGsub1[,i],na.rm=T)
      
      # calculate dprime
      dprime.add = (mnSIGadd1 - mnNZadd1)/sqrt((sdSIGadd1^2+sdNZadd1^2)/2)
      dprime.sub = (mnSIGsub1 - mnNZsub1)/sqrt((sdSIGsub1^2+sdNZsub1^2)/2)
      
      # calculate snr
      snr.add = 20*log10(mnSIGadd1/mnNZadd1)
      snr.sub = 20*log10(mnSIGsub1/mnNZsub1)
      
      # save M, SD and dprime to file per listener per iteration
      cor.matrix.add[1,1]<-listener
      cor.matrix.add[1,2]<-1
      cor.matrix.add[1,3]<-nReps
      cor.matrix.add[1,4]<-"rapid"
      cor.matrix.add[1,5]<-mnNZadd1
      cor.matrix.add[1,6]<-mnSIGadd1
      cor.matrix.add[1,7]<-sdNZadd1
      cor.matrix.add[1,8]<-sdSIGadd1
      cor.matrix.add[1,9]<-dprime.add	
      cor.matrix.add[1,10]<-snr.add
      
      cor.matrix.sub[1,1]<-listener
      cor.matrix.sub[1,2]<-1
      cor.matrix.sub[1,3]<-nReps
      cor.matrix.sub[1,4]<-"rapid"
      cor.matrix.sub[1,5]<-mnNZsub1
      cor.matrix.sub[1,6]<-mnSIGsub1
      cor.matrix.sub[1,7]<-sdNZsub1
      cor.matrix.sub[1,8]<-sdSIGsub1
      cor.matrix.sub[1,9]<-dprime.sub
      cor.matrix.sub[1,10]<-snr.sub
      
      write.csv(cor.matrix.add,file=paste("out/Experiment1_normalVrapid/Routput_rapidIterations/snr_",listener,"_rapid_",nReps,"_",var_name[i],"add_28July21.csv"))
      write.csv(cor.matrix.sub,file=paste("out/Experiment1_normalVrapid/Routput_rapidIterations/snr_",listener,"_rapid_",nReps,"_",var_name[i],"sub_28July21.csv"))
    }
  }
}


