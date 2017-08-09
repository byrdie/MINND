from __future__ import print_function

import numpy as np
import matplotlib.pyplot as plt


class IndexTracker(object):
    def __init__(self, ax, X, t_com, p_com, ind):
        self.ax = ax
        ax.set_title('use scroll wheel to navigate images')

        X = np.transpose(X, [0,2,1])

        self.X = X
        self.t_com = t_com
        self.p_com = p_com
        self.slices, self.rows, self.cols = X.shape
        self.ind = ind

        self.im = ax.imshow(self.X[self.ind, :, :], cmap='gray')
        ax.plot(np.arange(10, self.cols - 10), self.p_com[self.ind,:], np.arange(0, self.cols), self.t_com[self.ind])
        self.update()

    def onscroll(self, event):
        if event.button == 'up':
            self.ind = (self.ind + 1) % self.slices
        else:
            self.ind = (self.ind - 1) % self.slices
        self.update()

    def update(self):
        self.ax.clear()
        self.ax.imshow(self.X[self.ind, :, :], cmap='gray')
        self.ax.plot(np.arange(10, self.cols - 10), self.p_com[self.ind,:], np.arange(0, self.cols), self.t_com[self.ind,:])
        # self.ax.plot(np.arange(10, self.cols - 10), self.p_com[self.ind, :])
        self.ax.set_ylabel('slice %s' % self.ind)
        self.im.axes.figure.canvas.draw()

