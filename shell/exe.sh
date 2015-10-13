#!/bin/zsh

set -eu

#前提
#  rawディレクトリにtrue_[1..].txt、false_[1..].txtが入っていること。(中身は平文)
#  それらの行数はほぼ同じであること
#  rawフォルダ内のファイル数によってクロスバリデーションの分割数が決まる
#  正例ファイル、負例ファイルの数が共に5ならば、5分割のクロスバリデーション
#  ファイルのインデックスが1から始まるようにするのは、シェルのコードを簡略化するため
#  0から始めると、ループが{0..$[$CROSS_NUM - 1]}のようになり煩雑

# KNPで構文解析
# for f in raw/*.txt; do
#   lv $f | juman | knp -tab > knp/$f:t:r".knp"
# done

num=`ls raw/true_*.txt | wc -l | grep -o "[0-9]\+"`
readonly CROSS_NUM=$num #クロスバリデーションの分割数
unset num

#vocabファイルを作るために、トレーニングデータをまとめる
#$iをテストデータとする
for i in {1..$CROSS_NUM}; do
  ls knp | grep -v "_"$i".knp$" | xargs -L1 -P1 -I% cat knp/% > training_data_knp/train_$i.knp
done

#vocabファイルの生成
for i in {1..$CROSS_NUM}; do
  local train_data_knp=training_data_knp/train_$i.knp
  ./shell/make_vocab.sh $train_data_knp > vocab/$train_data_knp:r:t".vocab"
done

#featureファイルの生成

#ストップ。ここ考える必要あり
#「true_0とfalse_0がテストデータのときのtrue_1.txt(未知語がある)」と、
#「true_1とfalse_1がテストデータのときのtrue_1.txt(未知語がない)」は
#素性列が異なるのでは?
#つまり、true_1.featureやfalse_1.featureを個別に作って後でcatでつなげるという方法は全くの誤り

#featureファイルの生成
for i in {1..$CROSS_NUM}; do
  vocab_file=vocab/train_$i.vocab

  #テストデータのfeature
  cat /dev/null > feature/test_$i.feature
  lv knp/true_$i.knp  | python src/make_vector.py $vocab_file +1 >> feature/test_$i.feature
  lv knp/false_$i.knp | python src/make_vector.py $vocab_file -1 >> feature/test_$i.feature

  #訓練データのfeature
  cat /dev/null > feature/train_$i.feature
  for j in {1..$CROSS_NUM}; do
    if [ $i -ne $j ]; then
      lv knp/true_$j.knp  | python src/make_vector.py $vocab_file +1 >> feature/train_$i.feature
      lv knp/false_$j.knp | python src/make_vector.py $vocab_file -1 >> feature/train_$i.feature
    fi
  done
done


LIBLINEAR_PATH=~/local/src/liblinear-1.94/

#学習、モデルの保存
for i in {1..$CROSS_NUM};do
  $LIBLINEAR_PATH/train feature/train_$i.feature model/train_$i.model > output/train_$i.txt
done

#テスト
for i in {1..$CROSS_NUM}; do
  $LIBLINEAR_PATH/predict feature/test_$i.feature model/train_$i.model output/result_$i.txt > output/test_$i.txt
done
