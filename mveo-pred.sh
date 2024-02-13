#!/bin/bash
#SBATCH --account=dcs-res
#SBATCH --partition=dcs-gpu 
#SBATCH --comment=train_test
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --mem=120G
#SBATCH --time=120:00:00
#SBATCH --mail-user=jcrawley2@sheffield.ac.uk
#SBATCH --mail-type=ALL 
module load Anaconda3/5.3.0
source activate /fastdata/acc19jc
python predict.py --log_dir checkpoints/version_0/ --predict_on val --output_directory outputs --device cuda
