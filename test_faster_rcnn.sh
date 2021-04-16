#!/bin/bash

set -x
set -e

export PYTHONUNBUFFERED="True"

GPU_ID=$1
DATASET=$2
NET=$3
OUTPUT_DIR=$5

array=( $@ )
len=${#array[@]}
EXTRA_ARGS=${array[@]:3:$len}
EXTRA_ARGS_SLUG=${EXTRA_ARGS// /_}

case ${DATASET} in
  casia)
    TRAIN_IMDB="casia_train_all_single"
    TEST_IMDB="casia_test_all_single"
    ITERS=110000
    ANCHORS="[8,16,32,64]"
    RATIOS="[0.5,1,2]"
    ;;
  columbia)
    TRAIN_IMDB="dist_train_all_single"
    TEST_IMDB="dist_test_all_single"
    ITERS=90000
    ANCHORS="[8,16,32,64]"
    RATIOS="[0.5,1,2]"
    ;;
  cover)
    TRAIN_IMDB="dist_cover_train_single"
    TEST_IMDB="dist_cover_test_single"
    ITERS=25000
    ANCHORS="[8,16,32,64]"
    RATIOS="[0.5,1,2]"
    ;;
  NIST)
    TRAIN_IMDB="dist_NIST_train_new_2"
    TEST_IMDB="dist_NIST_test_new_2"
    ITERS=60000
    ANCHORS="[8,16,32,64]"
    RATIOS="[0.5,1,2]"
    ;;
  coco)
    TRAIN_IMDB="coco_train_filter_single"
    TEST_IMDB="coco_test_filter_single"
    ITERS=110000
    ANCHORS="[8,16,32,64]"
    RATIOS="[0.5,1,2]"
    ;;
  *)
    echo "No dataset given"
    exit
    ;;
esac

LOG="./logs/test_${NET}_${TRAIN_IMDB}_${EXTRA_ARGS_SLUG}.txt.`date +'%Y-%m-%d_%H-%M-%S'`"
exec &> >(tee -a "$LOG")
echo Logging output to "$LOG"

set +x
if [[ ! -z  ${EXTRA_ARGS_SLUG}  ]]; then
  NET_FINAL=output/${OUTPUT_DIR}/${TRAIN_IMDB}/${EXTRA_ARGS_SLUG}/res101_mask_faster_rcnn_iter_${ITERS}.ckpt
else
  NET_FINAL=output/${NET}/${TRAIN_IMDB}/defaultNIST_flip_0001_bilinear_new/${NET}_faster_rcnn_iter_${ITERS}.ckpt
fi
set -x

if [[ ! -z  ${EXTRA_ARGS_SLUG}  ]]; then
    python3 ./tools/test_net.py \
    --imdb ${TEST_IMDB} \
    --model ${NET_FINAL} \
    --cfg ./cfgs/${NET}.yml \
    --tag ${EXTRA_ARGS_SLUG} \
    --net ${NET} \
    --set ANCHOR_SCALES ${ANCHORS} ANCHOR_RATIOS ${RATIOS} ${EXTRA_ARGS}
else
    python3 ./tools/test_net.py \
    --imdb ${TEST_IMDB} \
    --model ${NET_FINAL} \
    --cfg ./cfgs/${NET}.yml \
    --net ${NET} \
    --set ANCHOR_SCALES ${ANCHORS} ANCHOR_RATIOS ${RATIOS} ${EXTRA_ARGS}
fi

