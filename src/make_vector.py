#! python
#coding: utf-8
import sys

def ind_to_feature_id(n):
  return n + 1

def feature_id_to_ind(n):
  return n - 1

argvs = sys.argv
argc = len(argvs)
label = 0
vocab_file=""

if (argc != 3):
  print "set class num"
  sys.exit(1)
else:
  vocab_file=str(argvs[1])
  label = int(argvs[2]) #分類クラス +1, -1


def is_doc_info(knp_line):
  return knp_line[0] == '#'

def is_chunk(knp_line):
  return knp_line[0] == '*'

def is_basic_phrase(knp_line):
  return knp_line[0] == '+'

def is_EOS(knp_line):
  return knp_line == "EOS"

def is_token(knp_line):
  return (not is_doc_info(knp_line)) and (not is_chunk(knp_line)) and (not is_basic_phrase(knp_line)) and (not is_EOS(knp_line))

vocab_hash = {}
vocab_hash["UNK"] = 1 #素性番号は1以上

for line in open(vocab_file, 'r'):
  line = line.rstrip()
  vocab_hash[line] = len(vocab_hash) + 1

tmp_vector = []
for knp_line in sys.stdin:
  knp_line = knp_line.rstrip()

  if is_doc_info(knp_line):
    tmp_vector = []
    for i in xrange(0, len(vocab_hash)):
      tmp_vector.append(0)

  if is_token(knp_line):
    token = knp_line.split(' ')[2]
    num = 1
    if token in vocab_hash:
      num = vocab_hash[token]
    else:
      pass
    tmp_vector[feature_id_to_ind(num)] = 1 #素性番号は1以上の値、配列のインデックスは0以上の値であるため、1ズレる

  if is_EOS(knp_line):
    sys.stdout.write(str(label))
    sys.stdout.write(' ')
    for i,v in enumerate(tmp_vector):
      if v != 0:
        sys.stdout.write(str(ind_to_feature_id(i)) + ':' + str(v) + ' ')

    print
