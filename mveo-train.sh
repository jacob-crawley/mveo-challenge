#!/bin/bash
#SBATCH --account=dcs-res
#SBATCH --partition=gpu 
#SBATCH --comment=train_test
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=120G
#SBATCH --time=120:00:00
#SBATCH --mail-user=jcrawley2@sheffield.ac.uk
#SBATCH --mail-type=ALL 
#SBATCH --output=train_%j.out
module load Anaconda3/5.3.0
source activate /fastdata/acc19jc
python /fastdata/acc19jc/mveo-challenge/train.py --config_file /fastdata/acc19jc/mveo-challenge/config.yaml
