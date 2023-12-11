ME_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ME_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
ME="$ME_PATH/$ME_NAME"
CUDA_VISIBLE_DEVICES=0
DATA_ID=snips
EP=30
SLOT_LOSS_COEF=1.0
WDECAY=0.01
MODEL_DIR="${DATA_ID}_models/ep$EP-CAE-Wloss${SLOT_LOSS_COEF}WdecCRF2"

git diff > $ME_PATH/code.diff 

cd libs/JointBERT

mkdir $MODEL_DIR

cp $ME $MODEL_DIR
mv $ME_PATH/code.diff $MODEL_DIR/code.diff

CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES \
# python3 main.py --task ${DATA_ID}\  _slotby2task \
python3 main.py --task ${DATA_ID}\
                  --model_type bertseqlabelby2task \
                  --model_dir $MODEL_DIR \
                  --do_train --do_eval --weight_decay $WDECAY --slot_loss_coef $SLOT_LOSS_COEF  --use_crf \
                  --num_train_epochs $EP |& tee $MODEL_DIR/train.log

python3 err_analyze.py --model_dir $MODEL_DIR --mode test 
python3 err_analyze.py --model_dir $MODEL_DIR --mode dev 
