# paraphrase_classifier

hoge.sh 語彙データを作る
make_vector.py 入力をベクトル化

流れ
学習データの語彙をリスト化
学習データをベクトル化
テスト


ディレクトリ構成
raw / true_[1..4].txt  正例ファイル(動詞部を置き換える)
raw / false_[1..4].txt 負例ファイル(動詞部を置き換えるものではない)
knp / true_[1..4].txt  KNPにかけた
knp / false_[1..4].txt KNPにかけた
training_data_knp / train_[%d].knp true_[%d]とfalse_[%d]をテストデータとするときの残りのデータを集めたもの。vocabファイルの生成に使う
feature / train_1.feature true_[2..4], false_[2..4]を合わせた訓練データ
feature / test_1.feature train_1の語彙を使ってテストするための評価データ
vocab / train_[1..5].vocab 語彙ファイル。train_1.vocabはtest_1の訓練のために使う(!?)

shell / シェルスクリプト
src   /  Python

model … liblinearで学習したときにできるアレ

output / result_[1..5].txt 判定結果
output / train_[1..5].txt 学習時の出力
output / train_[1..5].txt テスト時の出力
