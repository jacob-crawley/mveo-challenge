import os
import argparse

# import pytorch_lightning as pl
import lightning.pytorch as pl
from omegaconf import OmegaConf

from torchgeo.trainers import SemanticSegmentationTask
from datamodule import DFC2022DataModule

class CustomValidationLogger(pl.Callback):
    def on_validation_epoch_end(self, trainer, pl_module):
        # Retrieve the validation loss
        val_loss = trainer.callback_metrics['val_loss']
        print(f"Validation loss at end of epoch: {val_loss:.4f}")

        # Retrieve additional loss metrics (e.g., IoU, F1-score, etc.)
        additional_metrics = trainer.callback_metrics
        for metric_name, metric_value in additional_metrics.items():
            print(f"{metric_name} at end of epoch: {metric_value:.4f}")

def main(_config):
    pl.seed_everything(0)

    task = SemanticSegmentationTask(**_config.learning)
    datamodule = DFC2022DataModule(**_config.datamodule)
    trainer = pl.Trainer(**_config.trainer)

    # Add a callback to log the loss at the end of each epoch
    trainer.callbacks.append(pl.callbacks.ModelCheckpoint(monitor='val_loss'))

    # Add custom callback for validation loss and additional metrics logging
    #trainer.callbacks.append(pl.callbacks.EarlyStopping(monitor='val_loss', patience=6))
    trainer.callbacks.append(CustomValidationLogger())

    trainer.fit(model=task, datamodule=datamodule)

    # Retrieve the final loss after training
    final_loss = trainer.callback_metrics['val_loss']
    print(f"Final validation loss: {final_loss:.4f}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config_file", type=str, required=True, help="Path to config.yaml file")
    args = parser.parse_args()

    _config = OmegaConf.load(args.config_file)

    main(_config)
