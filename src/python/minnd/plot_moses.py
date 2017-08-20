import numpy as np


import h5py


from moses_animate import ani_frame

import matplotlib.pyplot as plt

from plot_velocity import plot_doppler_inten

from plot_moses_region import plot_moses_region


moses_fn = '../../idl/prep_moses/moses_level_1.h5'

with h5py.File(moses_fn, 'r') as f:
    data = f['data'][()]
    # data = np.rot90(data, k=1, axes=[2,3])
    sz = data.shape

    data = data[6:21,:,::-1,:,:]

    zero = np.squeeze(data[:, 0, :, 10:-10, 10])
    plus = np.squeeze(data[:, 1, :, 10:-10, 10])
    minus = np.squeeze(data[:, 2, :, 10:-10, 10])

    zero_o = zero
    plus_o = plus
    minus_o = minus

    zero = np.sqrt(zero)
    plus = np.sqrt(plus)
    minus = np.sqrt(minus)


    p0 = 'movies/'
    p1_full = p0 + 'full/'
    p1_fox = p0 + 'fox/'
    p1_ar1 = p0 + 'ar1/'
    p1_ar2 = p0 + 'ar2/'
    p1_ar3 = p0 + 'ar3/'
    p1_ar4 = p0 + 'ar4/'
    p1_ar5 = p0 + 'ar5/'
    p1_ar6 = p0 + 'ar6/'



    p_shift_plus = np.load('p_shift_plus.npy')
    p_shift_minus = np.load('p_shift_minus.npy')
    p_shift_ave = np.load('p_shift_ave.npy')




    fox_x_min = 1490
    fox_x_max = 1550
    fox_y_min = 210
    fox_y_max = 270
    fox_region = [[fox_x_min, fox_x_max],[fox_y_min, fox_y_max]]


    ar1_x_min = 700
    ar1_x_max = 800
    ar1_y_min = 370
    ar1_y_max = 470
    ar1_region = [[ar1_x_min, ar1_x_max], [ar1_y_min, ar1_y_max]]



    ar2_x_min = 1175
    ar2_x_max = 1325
    ar2_y_min = 125
    ar2_y_max = 275
    ar2_region = [[ar2_x_min, ar2_x_max], [ar2_y_min, ar2_y_max]]


    ar3_x_min = 725
    ar3_x_max = 825
    ar3_y_min = 500
    ar3_y_max = 600
    ar3_region = [[ar3_x_min, ar3_x_max], [ar3_y_min, ar3_y_max]]


    ar4_x_min = 1670
    ar4_x_max = 1760
    ar4_y_min = 540
    ar4_y_max = 630
    ar4_region = [[ar4_x_min, ar4_x_max], [ar4_y_min, ar4_y_max]]

    ar5_x_min = 500
    ar5_x_max = 600
    ar5_y_min = 550
    ar5_y_max = 650
    ar5_region = [[ar5_x_min, ar5_x_max], [ar5_y_min, ar5_y_max]]

    ar6_x_min = 1100
    ar6_x_max = 1300
    ar6_y_min = 500
    ar6_y_max = 700
    ar6_region = [[ar6_x_min, ar6_x_max], [ar6_y_min, ar6_y_max]]

    labels = ['Fox', '1', '2', '3', '4', '5', '6']
    # labels = ['Fox', '1', '2']
    # plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, path=p1_full, outline=[fox_region,ar1_region,ar2_region], label=labels, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, path=p1_full, outline=[fox_region,ar1_region,ar2_region,ar3_region,ar4_region, ar5_region, ar6_region], label=labels, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=fox_region, path=p1_fox, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=ar1_region, path=p1_ar1, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=ar2_region, path=p1_ar2, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=ar3_region, path=p1_ar3, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=ar4_region, path=p1_ar4, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=ar5_region, path=p1_ar5, x_ax=True, y_ax=True)
    plot_moses_region(zero, plus, minus, p_shift_plus, p_shift_minus, p_shift_ave, region=ar6_region, path=p1_ar6, x_ax=True, y_ax=True)

    # plt.show()


