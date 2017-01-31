#!/bin/bash
# Please run this from this directory only

caffe train --solver=minnd_solver.prototxt 2>&1 | tee train_test_minnd_out.txt


