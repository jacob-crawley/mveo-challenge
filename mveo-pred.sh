#!/bin/bash
#SBATCH --account=dcs-res
#SBATCH --partition=dcs-gpu 
#SBATCH --comment=train_test
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --mem=10G
#SBATCH --time=2:00:00
#SBATCH --mail-user=jcrawley2@sheffield.ac.uk
#SBATCH --mail-type=ALL 
#SBATCH --output=pred.%j.out
module load Anaconda3/5.3.0
source activate /fastdata/acc19jc
python predict.py --config_file /fastdata/acc19jc/mveo-challenge/config.yaml --log_dir lightning_logs/version_3500776/ --device cuda
