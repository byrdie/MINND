#! /bin/bash

rm -rf /minnd/datasets/levelC/train/truth/
rm -rf /minnd/datasets/levelC/train/input/
rm -rf /minnd/datasets/levelC/test/truth/
rm -rf /minnd/datasets/levelC/test/input/

convert_imageset / /minnd/datasets/levelB/train/truth/index.txt /minnd/datasets/levelC/train/truth/
convert_imageset / /minnd/datasets/levelB/train/input/index.txt /minnd/datasets/levelC/train/input/
convert_imageset / /minnd/datasets/levelB/test/truth/index.txt /minnd/datasets/levelC/test/truth/
convert_imageset / /minnd/datasets/levelB/test/input/index.txt /minnd/datasets/levelC/test/input/
