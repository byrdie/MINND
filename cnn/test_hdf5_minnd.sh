#!/bin/bash
# Please run this from this directory only

rm output.h5
rm input.h5
rm truth.h5

caffe test -model minnd_test_hdf5.prototxt -weights snapshots/_iter_300000.caffemodel -gpu 0 -iterations 1


