import time

from array import array

import h5py

from keras.callbacks import TensorBoard

from keras.models import Sequential
from keras.layers import Conv2D
from keras.layers import Dense
from keras.optimizers import SGD
from keras.optimizers import adam
from keras.optimizers import Nadam
from keras.utils import plot_model
from keras import regularizers
from keras.initializers import RandomNormal
from keras.callbacks import EarlyStopping
from keras.callbacks import ReduceLROnPlateau

import matplotlib.pyplot as plt

import numpy as np

test_index = '/minnd/datasets/levelB/test/database.h5'
train_index = '/minnd/datasets/levelB/train/database.h5'


with h5py.File(test_index, 'r') as f, h5py.File(train_index, 'r') as g:
    test_y = f['label']
    test_x = f['data']
    train_y = g['label']
    train_x = g['data']


    # Initialize training visualization callback
    # remote = callbacks.RemoteMonitor(root='http://localhost:9000')
    tb_path = './logs/' + time.asctime(time.localtime())
    cb = TensorBoard(log_dir=tb_path, histogram_freq=0, write_graph=False, write_images=False)
    es = EarlyStopping(monitor='val_loss', min_delta=0.01, patience=20, verbose=1)
    rl = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=10,epsilon=0.02, verbose=1)

    t_sz = train_x.shape

    print(t_sz)

    # Define the network as a feed-forward neural network
    net = Sequential()

    init = RandomNormal(mean=0.0, stddev=2e-3, seed=None)

    # Apply a convolution operation
    net.add(Conv2D(64, (5, 5), dilation_rate=(1, 1), activation='tanh', padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(2e-3), kernel_initializer=init, input_shape=(t_sz[1], None, t_sz[3])))

    # net.add(Conv2D(16, (5, 5), dilation_rate=(1, 1), activation='tanh', padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(1e-2), kernel_initializer=init))

    net.add(Conv2D(256, (7, 7), dilation_rate=(1, 1), activation='tanh', padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(2e-3), kernel_initializer=init))

    net.add(Conv2D(1, (11, 11), dilation_rate=(1, 1), activation=None, padding='valid', data_format='channels_first', kernel_regularizer=regularizers.l2(2e-3), kernel_initializer=init))

    plot_model(model=net, to_file='id.png', show_shapes=True, show_layer_names=True)

    # Build the optimizer
    sgd = SGD(lr=4e-4, decay=1e-4, momentum=0.9, nesterov=True)
    adam = adam(lr=1e-5)
    nadam = Nadam(lr=1e-5)

    # Compile parameters into the model
    net.compile(optimizer=nadam, loss='mse')

    # Train the model
    net.fit(train_x, train_y, batch_size=16, epochs=100, callbacks=[cb], verbose=1, validation_data=(test_x, test_y), shuffle='batch')

    net.save('model.h5')






