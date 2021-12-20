#!/bin/env bash

# get all generations first
# squash two lines into 1 separated by space and shuffle
if [ ! -e sample_01_shuf_1.fasta ]
then
    echo 'Sorting 1'
    cat {1..7}/sample_01_1.fasta | paste -d ' ' - - | shuf > sample_01_shuf_1.fasta &
fi

if [ ! -e sample_01_shuf_2.fasta ]
then
    echo 'Sorting 2'
    cat {1..7}/sample_01_1.fasta | paste -d ' ' - - | shuf > sample_01_shuf_2.fasta
fi

wait

mkdir -p train test

# train set
# select millions of reads and turn 1 line into 2
for i in $(seq 10 10 80) ; do
    if [ ! -e "train/${i}_million_reads_1.fasta" ] ; then
        echo "making ${i} million reads 1"
        head -q -n $((i * 1000000)) sample_01_shuf_1.fasta | tr ' ' '\n' > "train/${i}_million_reads_1.fasta" &
    fi

    if [ ! -e "train/${i}_million_reads_2.fasta" ] ; then
        echo "making ${i} million reads 2"
        head -q -n $((i * 1000000)) sample_01_shuf_2.fasta | tr ' ' '\n' > "train/${i}_million_reads_2.fasta" &
    fi
done

wait


# test set
if [ ! -e "test/test_1.fasta" ] ; then
    echo "making test 1"
    tail -q -n 4000000 sample_01_shuf_1.fasta | tr ' ' '\n' > "test/test_1.fasta" &
fi

if [ ! -e "test/test_2.fasta" ] ; then
    echo "making test 2"
    tail -q -n 4000000 sample_01_shuf_2.fasta | tr ' ' '\n' > "test/test_2.fasta" &
fi

wait
echo 'DONE'
