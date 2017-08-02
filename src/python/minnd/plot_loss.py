import numpy as np

import matplotlib.pyplot as plt

import h5py

test_index = '/minnd/datasets/levelB/test/database.h5'
train_index = '/minnd/datasets/levelB/train/database.h5'


with h5py.File(test_index, 'r') as f, h5py.File(train_index, 'r') as g:
    test_y = f['label']
    test_x = f['data']
    train_y = f['label']
    train_x = f['data']

    pred = np.fromfile('pred.bin', dtype=np.float32)

    print(pred[0])

    n = np.arange(0.0, 30000.0)
    plt.figure(1)
    plt.plot(n, np.squeeze(pred[0:30000]), n, np.squeeze(test_y[0:30000]))

    plt.show()