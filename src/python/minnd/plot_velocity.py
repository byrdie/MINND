import numpy as np

import matplotlib.pyplot as plt


import matplotlib.animation as animation
from pylab import tight_layout

import matplotlib.patches as patches



def plot_doppler_inten(intensity, velocity, path, outline = None, label='', y_ax = False, x_ax = False):
    mspix = 0.6

    vmax = np.nanmax(np.abs(velocity))
    # vmax = 1
    intensity_max = np.nanmax(intensity)
    # intensity_max = 5000
    print(vmax, intensity_max)


    gamma = 0.6     # Intensity contrast index
    vgamma = 1.0   # Velocity contrast index
    bg_ratio = 3.0  # Controls use of green channel to brighten the blues
    g_offset = (1 - 1 / bg_ratio)/2     # Controls use of green channel to provide neutral gray at v=0
    c_ratio = 1.0  # Contrast ratio
    c_offset = 1 - 1 / c_ratio

    # Calculate velocity-intensity image
    velnorm = (velocity / vmax)   # Normalized velocity signal
    rv = (1 + np.sign(velnorm) * np.abs(velnorm) ** vgamma) / 2
    bv = (1 - np.sign(velnorm) * np.abs(velnorm) ** vgamma) / 2
    gv = g_offset + bv / bg_ratio
    rgbi = (intensity / intensity_max) ** gamma
    rgbi = c_offset + rgbi / c_ratio

    X = np.zeros(np.concatenate([intensity.shape, [3]]), dtype=np.float32)
    X[:, :, :, 0] = rgbi * rv
    X[:, :, :, 1] = rgbi * gv
    X[:, :, :, 2] = rgbi * bv


    sz = X.shape

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.set_aspect('auto')
    if y_ax == False:
        fig.axes.get_xaxis().set_visible(False)
    if x_ax == False:
        fig.axes.get_yaxis().set_visible(False)

    if outline != None:
        for i in range(0, len(outline)):
            region = outline[i]
            xmin = region[0][0]
            xmax = region[0][1]
            ymin = region[1][0]
            ymax = region[1][1]

            p = patches.Rectangle((xmin * mspix, ymin * mspix), xmax * mspix-xmin * mspix, ymax* mspix-ymin* mspix, fill=False, color='y', lw=1.0)
            ax.add_patch(p)
            ax.text((xmax+10) * mspix, (ymax+10) *mspix, label[i], horizontalalignment='left', verticalalignment='bottom', color='y', fontsize=15)

    mspix = 0.6
    im = ax.imshow(X[0, :, :, :], extent=[0, sz[2] * mspix, sz[1] * mspix, 0])

    fig.set_size_inches([8, 4.5])

    tight_layout()

    def update_img(n):
        tmp = X[n, :, :]
        im.set_data(tmp)
        fp = path + 'fig_' + format(n, '02') + '.png'
        plt.savefig(fp, bbox_inches='tight')
        print(fp)
        return im

    # legend(loc=0)
    ani = animation.FuncAnimation(fig, update_img, frames=sz[0])

    writer = animation.writers['ffmpeg'](fps=5)

    mp = path + 'movie.mp4'
    ani.save(mp, writer=writer, dpi=256)
    print(mp)

    plt.close()



    # make legend
    nsteps = 512
    moses_pix = 29  # km/s/pix
    vels = np.arange(-vmax, vmax, 2 * vmax / nsteps, dtype=np.float32)
    vels = np.reshape(vels, [nsteps,1])
    vels = np.tile(vels, [1, nsteps])

    ints = np.arange(0, intensity_max, intensity_max / nsteps, dtype=np.float32)
    ints = np.reshape(ints, [1, nsteps])
    ints = np.tile(ints, [nsteps,1])

    # Calculate velocity-intensity legend
    velnorm = (vels / vmax)   # Normalized velocity signal
    rv = (1 + np.sign(velnorm) * np.abs(velnorm) ** vgamma) / 2
    bv = (1 - np.sign(velnorm) * np.abs(velnorm) ** vgamma) / 2
    gv = g_offset + bv / bg_ratio
    rgbi = (ints / intensity_max) ** gamma
    rgbi = c_offset + rgbi / c_ratio

    legend = np.zeros(np.concatenate([ints.shape, [3]]), dtype=np.float32)
    legend[:, :, 0] = rgbi * rv
    legend[:, :, 1] = rgbi * gv
    legend[:, :, 2] = rgbi * bv

    fig = plt.figure()
    # fig.set_size_inches([4, 0.5])
    plt.imshow(legend, extent=[0, intensity_max,-vmax * moses_pix, vmax * moses_pix],aspect=1e1)
    plt.gca().tick_params(left='off', right='on', labelleft='off', labelright='on')
    # plt.xlabel('velocity (km/s)')
    plt.savefig(path + 'legend.pdf', bbox_inches='tight')

    plt.close()


