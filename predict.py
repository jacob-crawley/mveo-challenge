import argparse
import glob
import os

import numpy as np
import kornia.augmentation as K
from sklearn.metrics import accuracy_score, confusion_matrix, jaccard_score
import rasterio
import torch
from omegaconf import OmegaConf
from tqdm import tqdm
from torchmetrics.classification import MulticlassAccuracy, MulticlassJaccardIndex, MulticlassConfusionMatrix
from einops import rearrange

from torchgeo.trainers import SemanticSegmentationTask
from datamodule import DFC2022DataModule
import torch.nn.functional as F


def write_mask(mask, path, output_dir):
    with rasterio.open(path) as src:
        profile = src.profile
    profile["count"] = 1
    profile["dtype"] = "uint8"
    region = os.path.dirname(path).split(os.sep)[-2]
    filename = os.path.basename(os.path.splitext(path)[0])
    output_path = os.path.join(output_dir, region, f"{filename}_prediction.tif")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with rasterio.open(output_path, "w", **profile) as dst:
        dst.write(mask, 1)

@torch.no_grad()
def predict_torch_metrics(config_file, log_dir, device, write_masks):
    general_config = OmegaConf.load(config_file)

    # Load checkpoint and config
    trained_params = OmegaConf.load(os.path.join(log_dir, "hparams.yaml"))
    ckpt = glob.glob(os.path.join(log_dir, "checkpoints", "*.ckpt"))[0]

    # Load model
    task = SemanticSegmentationTask.load_from_checkpoint(ckpt)
    task = task.to(device)
    task.eval()

    # Load datamodule and dataloader
    datamodule = DFC2022DataModule(**general_config.datamodule)
    datamodule.setup()
    dataloader = datamodule.val_dataloader()  # batch size is 1

    pad = K.PadTo(size=(2048, 2048), pad_mode="constant", pad_value=0.0)

    indices = torch.Tensor([1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14]).int().to(device)  # 12 classes

    jaccard = torch.zeros(trained_params.num_classes).to(device)
    jaccard_metric = MulticlassJaccardIndex(num_classes=trained_params.num_classes,
                                            ignore_index=trained_params.ignore_index, average="none").to(device)
    accuracy = []
    accuracy_metric = MulticlassAccuracy(num_classes=trained_params.num_classes,
                                         ignore_index=trained_params.ignore_index,
                                         multidim_average="global",
                                         average="micro").to(device)

    confusion_matrix = None
    confusion_matrix_metric = MulticlassConfusionMatrix(num_classes=trained_params.num_classes,
                                                        ignore_index=trained_params.ignore_index).to(device)
    
    preds_min = 0.0
    preds_max = 0.0

    for i, batch in tqdm(enumerate(dataloader), total=len(dataloader)):
        x = batch["image"].to(device)
        h, w = x.shape[-2:]
        x = pad(x)
        preds = task(x)
        preds = preds[0, :, :h, :w]
        mask = preds.argmax(dim=0).cpu().numpy()
        preds = rearrange(preds, "c h w -> (h w) c")
        target = batch["mask"].to(device)

        target = target.view(preds.shape[0], -1)       
        
        if preds.shape[1] != target.shape[1]:
            preds = preds[:, : target.shape[1]]

        # Normalise the predictions
        if preds.min() < preds_min: 
            preds_min = preds.min()

        if preds.max() > preds_max:
            preds_max = preds.max()

        normalized_preds = (preds - preds_min) / (preds_max - preds_min)

        # Scale the normalized predictions to the range [0, 15]
        scaled_preds = (normalized_preds * 15).long() 

        preds = scaled_preds
        
        jaccard += jaccard_metric(preds, target)  # adding the IoU per class
        if confusion_matrix is None:
            confusion_matrix = confusion_matrix_metric(preds, target)
        else:
            confusion_matrix += confusion_matrix_metric(preds, target)

        accuracy.append(accuracy_metric(preds, target).item())

        if write_masks:
            # Write prediction masks
            filename = datamodule.val_dataset.files[i]["image"]
            write_mask(mask, filename, "/fastdata/acc19jc/mveo-challenge/mask_outputs")


    ave_jac = jaccard / len(dataloader)  # average IoU per class
    ave_jac_specific_classes = torch.index_select(ave_jac, 0, indices)  # get the 12 classes
   
    print("Average Jaccard Per Class = {}".format(ave_jac))
    print(ave_jac_specific_classes)
    print("Overall Average = {}".format(torch.mean(ave_jac_specific_classes)))  # calculate the final average
    print("Standard Deviation (Jaccard) = {}".format(torch.std(ave_jac_specific_classes)))

    print("Mean Accuracy = {}, Accuracy Standard Dev. = {}".format(np.mean(accuracy), np.std(accuracy)))
    print("Confusion Matrix:\n")
    print(confusion_matrix)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config_file", type=str, required=True, help="Path to config.yaml file")
    parser.add_argument("--log_dir", type=str, required=True,
                        help="Path to log directory containing config.yaml and checkpoint")
    parser.add_argument("--device", type=str, default="cuda", choices=["cuda", "cpu"])
    args = parser.parse_args()

    print("Running on Training log: {}\n".format(args.log_dir))

    # Change the last argument depending on if you want to see the predicted outputs 
    # (make a dir called mask_outputs first!)
    predict_torch_metrics(args.config_file, args.log_dir, args.device, True)


       