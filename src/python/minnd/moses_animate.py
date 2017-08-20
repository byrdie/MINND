import matplotlib.animation as animation
import numpy as np
from pylab import *

import matplotlib.patches as patches




dpi = 256

def ani_frame(X, path, vmin=None, vmax=None, outline = None, label=''):
    sz = X.shape

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.set_aspect('auto')
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)

    if(vmin == None and vmax == None):
        im = ax.imshow(X[0, :, :], cmap='gray')
    else:
        im = ax.imshow(X[0, :, :], cmap='bwr', vmin=vmin, vmax=vmax)
        # cbar = fig.colorbar(im, fraction=0.046, pad=0.04)

    if outline != None:
        for i in range(0, len(outline)):
            region = outline[i]
            xmin = region[0][0]
            xmax = region[0][1]
            ymin = region[1][0]
            ymax = region[1][1]

            p = patches.Rectangle((xmin, ymin), xmax-xmin, ymax-ymin, fill=False, color='y', lw=2.0)
            ax.add_patch(p)
            ax.text(xmax+10, ymax+10, label[i], horizontalalignment='left', verticalalignment='bottom', color='y', fontsize=25)


    # im.set_clim([0,1])
    fig.set_size_inches([8,4.5])


    tight_layout()


    def update_img(n):
        tmp = X[n,:,:]
        im.set_data(tmp)
        fp = path + 'fig_' + format(n, '02') + '.png'
        plt.savefig(fp, bbox_inches='tight')
        print(fp)
        return im

    #legend(loc=0)
    ani = animation.FuncAnimation(fig,update_img,frames=sz[0])

    writer = animation.writers['ffmpeg'](fps=5)

    mp = path + 'movie.mp4'
    ani.save(mp, writer=writer,dpi=dpi)
    print(mp)

    plt.close()