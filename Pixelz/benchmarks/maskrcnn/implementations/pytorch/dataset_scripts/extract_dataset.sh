mkdir -p $DATASET_DIR/coco
mv train2017.zip $DATASET_DIR/coco
mv val2017.zip $DATASET_DIR/coco
mv annotations_trainval2017.zip $DATASET_DIR/coco

cd $DATASET_DIR/coco
unzip annotations_trainval2017.zip
unzip train2017.zip
unzip val2017.zip
