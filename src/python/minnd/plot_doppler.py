import numpy as np

import matplotlib.pyplot as plt

import h5py

from scroll_stepper import IndexTracker

from keras.models import load_model

test_index = '/minnd/datasets/levelB/test/database.h5'
train_index = '/minnd/datasets/levelB/train/database.h5'


with h5py.File(test_index, 'r') as f, h5py.File(train_index, 'r') as g:
    test_y = f['label']
    test_x = f['data']
    train_y = g['label']
    train_x = g['data']
    inp_orig = f['orig']
    truth_orig = g['orig']

    net = load_model('model.h5')

    print(np.arange(0,21, dtype=np.float32).shape)

    s_sz = truth_orig.shape
    new_s_sz1 = s_sz[1] - 20
    ave = np.average(truth_orig, axis=2, weights=np.arange(0, 21, dtype=np.float32))
    tot = np.sum(truth_orig, axis=2, dtype=np.float32)
    t_shift = ave / tot + 10
    p_shift = np.zeros([s_sz[0], new_s_sz1])

    for i in range(0, new_s_sz1):

        print(i)
        inp = inp_orig[:, :, i:i+21, :]
        p_shift[:, i] = np.squeeze(net.predict(inp, batch_size=512,verbose=0))

    p_shift = p_shift + 10


    pred = net.predict(test_x, batch_size=512, verbose=1)

    shp = test_x.shape
    n = np.arange(0.0, shp[0])
    plt.figure(1)
    plt.plot(n, np.squeeze(pred[0:shp[0]]), n, np.squeeze(test_y[0:shp[0]]))


    fig, ax = plt.subplots(1, 1)
    tracker = IndexTracker(ax, truth_orig, t_shift, p_shift, 0)

    fig.canvas.mpl_connect('scroll_event', tracker.onscroll)


    plt.show()