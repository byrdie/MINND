import numpy as np

import matplotlib.pyplot as plt
from matplotlib import colors


import h5py

from scroll_stepper import IndexTracker

from keras.models import load_model

from scipy.stats.stats import pearsonr

from plot_valid import plot_valid


test_index = '/minnd/datasets/levelB/test/database.h5'
train_index = '/minnd/datasets/levelB/train/database.h5'

moses_pix = 29

with h5py.File(test_index, 'r') as f, h5py.File(train_index, 'r') as g:
    test_y = f['label']
    test_x = f['data']
    train_y = g['label']
    train_x = g['data']
    test_orig = f['orig'][()]
    train_orig = g['orig']





    net = load_model('model.h5')


    p_shift = np.squeeze(net.predict(test_x, batch_size=16, verbose=1))

    t_shift = test_y[:, :, :, :]

    print(test_orig.shape, p_shift.shape, t_shift.shape)
    hist_x = test_orig[:,10:-10,:]
    hist_x = np.average(hist_x, axis=2)
    hist_x = hist_x.flatten()
    s1 = hist_x.shape
    # inten = hist_x > 0
    # inten = hist_x > 9.5
    inten = hist_x > 18.2
    hist_x = hist_x[inten]
    s2 = hist_x.shape
    print(float(s2[0])/float(s1[0]))
    hist_p = p_shift.flatten()[inten]
    hist_t = t_shift.flatten()[inten]
    hist_p = hist_p * moses_pix
    hist_t = hist_t * moses_pix

    rms = np.sqrt(np.mean(np.square(hist_p - hist_t)))
    print('rms=', rms)


    p_s = p_shift
    t_s = t_shift

    p_shift = p_shift + 10
    t_shift = t_shift + 10



    n = np.arange(start=-5*moses_pix, stop=5*moses_pix, step=1, dtype=np.float32)
    plt.figure(1)
    # plt.scatter(test_y[:], pred[:], marker='.')

    plt.hist2d(hist_t, hist_p, bins=200, norm=colors.SymLogNorm(linthresh=1), range=[[-4*moses_pix,4*moses_pix],[-4*moses_pix,4*moses_pix]], cmap='hot')
    plt.colorbar()
    plt.plot(n, n)
    plt.xlabel('True velocity (km/s)')
    plt.ylabel('Recovered velocity (km/s)')
    plt.savefig('validation/linearity.pdf', bbox_inches='tight')
    corr = pearsonr(hist_t, hist_p)
    print('Correlation coefficient', corr)

    squeeze = 5
    p_s = p_s + squeeze
    t_s = t_s + squeeze
    # p_s = p_s * moses_pix
    # t_s = t_s * moses_pix
    ind = [1182, 1225, 1263, 1298, 1343, 1407, 1436, 1797]
    mins = [50, 50, 50, 50, 60, 25, 25, 50]
    maxs = [100, 100, 100, 100, 110, 75, 75, 100]
    y_axes = [True, True, True, True, True, True, True, True]
    x_axes = [False, False, False, False, True, False, False, False]
    if(len(ind) == len(mins) and len(ind) == len(maxs)):
        for i in range(0, len(ind)):
            plot_valid(test_orig[:,:,squeeze:-squeeze], t_s, p_s, ind[i], mins[i], maxs[i])




    fig, ax = plt.subplots(1, 1)
    tracker = IndexTracker(ax, test_orig, t_shift, p_shift, 0)

    fig.canvas.mpl_connect('scroll_event', tracker.onscroll)


    # plt.show()