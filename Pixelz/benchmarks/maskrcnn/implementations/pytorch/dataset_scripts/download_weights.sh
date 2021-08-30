wget https://dl.fbaipublicfiles.com/detectron/ImageNetPretrained/MSRA/R-50.pkl
mkdir -p $DATASET_DIR/coco/models
mv R-50.pkl $DATASET_DIR/coco/models
