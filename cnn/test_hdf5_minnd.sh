#!/bin/bash
# Please run this from this directory only

rm test1.h5 test2.h5 test3.h5 test4.h5
rm output.h5
rm input.h5
rm truth.h5

caffe test -model minnd_test_hdf5.prototxt -weights snapshots/_iter_3000.caffemodel -gpu 0 -iterations 1


