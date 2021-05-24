#!/bin/bash -l

# Batch script to run a multi-threaded Matlab job on Legion or Myriad with the upgraded
# software stack under SGE. R2021a

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=4:00:0

# 3. Request 2 gigabyte of RAM per core. 
#$ -l mem=8G

# 4. Request 15 gigabyte of TMPDIR space (default is 10 GB)
#$ -l tmpfs=15G

# 5. Select 8 threads the maximum possible on Myriad is 36.
#$ -pe smp 8

# 6. Reserve one Matlab licence - this stops your job starting and failing when no
#    licences are available.
#$ -l matlab=1

# 7. Set the name of the job.
#$ -N Matlab_spectralNZfloor

# 9. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucjuhj0/Scratch/spectralNZfloor

# 10. Run Matlab job

module purge
module load gcc-libs/4.9.2
module load xorg-utils/X11R7.7
module load matlab/full/r2016b/9.1

cd /home/ucjuhj0/ffr/scripts/2_preprocessing/

# /usr/bin/time --verbose matlab -r -nodisplay -nojvm run_spectralNZfloor

echo ""
echo "Running matlab -nosplash -nodisplay < run_spectralNZfloor.m ..."
echo ""
/usr/bin/time --verbose matlab -nosplash -nodesktop -nodisplay < run_spectralNZfloor.m

#  End of job script


