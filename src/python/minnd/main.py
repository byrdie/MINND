import time

import h5py

from keras.callbacks import TensorBoard

from keras.models import Sequential
from keras.layers import Conv2D
from keras.layers import Dense
from keras.optimizers import SGD
from keras.utils import plot_model
from keras import regularizers

import matplotlib.pyplot as plt

import numpy as np

test_index = '/minnd/datasets/levelB/test/database.h5'
train_index = '/minnd/datasets/levelB/train/database.h5'


with h5py.File(test_index, 'r') as f, h5py.File(train_index, 'r') as g:
    test_y = f['label']
    test_x = f['data']
    train_y = f['label']
    train_x = f['data']

    # Initialize training visualization callback
    # remote = callbacks.RemoteMonitor(root='http://localhost:9000')
    tb_path = './logs/' + time.asctime(time.localtime())
    cb = TensorBoard(log_dir=tb_path, histogram_freq=10, write_graph=True, write_images=True)

    t_sz = train_x.shape

    # Define the network as a feed-forward neural network
    net = Sequential()

    # Apply a convolution operation
    net.add(Conv2D(4, (5, 5), dilation_rate=(1, 1), activation='tanh', padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(1e-2), input_shape=(t_sz[1], t_sz[2], t_sz[3])))

    net.add(Conv2D(8, (7, 7), dilation_rate=(1, 1), activation='tanh', padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(1e-2)))

    net.add(Conv2D(1, (11, 11), dilation_rate=(1, 1), activation=None, padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(1e-2)))
    # net.add(Dense())

    plot_model(model=net, to_file='id.png', show_shapes=True, show_layer_names=True)

    # Build the optimizer
    sgd = SGD(lr=1e-3, decay=1e-6, momentum=0.9, nesterov=True)

    # Compile parameters into the model
    net.compile(optimizer=sgd, loss='mse')

    # Train the model
    net.fit(train_x, train_y, batch_size=2048, epochs=100, callbacks=[cb], verbose=1, validation_data=(train_x, train_y), shuffle='batch')

    pred = net.predict(test_x, batch_size=2048, verbose=1)

    n = np.arange(0.0,10000.0)
    plt.plot(n, np.squeeze(pred[0:10000]), n, np.squeeze(test_y[0:10000]))
    plt.show()

