import numpy as np

import matplotlib.pyplot as plt

def plot_valid(test_orig, t_shift, p_shift, index, xmin, xmax, y_ax = False, x_ax = False):

    test_orig = np.transpose(test_orig, [0, 2, 1])

    plt.figure()

    ts = test_orig.shape

    fig = plt.imshow(test_orig[index, :, xmin:xmax], cmap='gray')
    if y_ax == False:
        fig.axes.get_xaxis().set_visible(False)
    if x_ax == False:
        fig.axes.get_yaxis().set_visible(False)
    xn = np.arange(0, xmax-xmin)
    print(p_shift.shape)

    plt.plot(xn, np.squeeze(p_shift[index, xmin-10:xmax-10]), xn, np.squeeze(t_shift[index,0, xmin-10:xmax-10,0]))

    str_ind = format(index, '04')
    plt.savefig('validation/doppler_' + str_ind + '.png', bbox_inches='tight', pad_inches=0)
    plt.close()

