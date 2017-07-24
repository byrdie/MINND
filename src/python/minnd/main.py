import time

import h5py

from keras.callbacks import TensorBoard

from keras.models import Sequential
from keras.layers import Conv2D
from keras.optimizers import SGD
from keras.utils import plot_model

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
    net.add(Conv2D(16, (5, 5), dilation_rate=(1, 1), activation='relu', padding='valid', data_format='channels_first', input_shape=(t_sz[1], t_sz[2], t_sz[3])))

    net.add(Conv2D(4, (7, 7), dilation_rate=(1, 1), activation='relu', padding='valid', data_format='channels_first'))

    net.add(Conv2D(1, (11, 11), dilation_rate=(1, 1), activation='relu', padding='valid', data_format='channels_first'))

    plot_model(model=net, to_file='id.png', show_shapes=True, show_layer_names=True)

    # Build the optimizer
    sgd = SGD(lr=0.01, decay=1e-10, momentum=0.9, nesterov=True)

    # Compile parameters into the model
    net.compile(optimizer=sgd, loss='mse')

    # Train the model
    net.fit(train_x, train_y, batch_size=64, epochs=32, callbacks=[cb], validation_data=(test_x, test_y), verbose=1, shuffle='batch')

    pred = net.predict(test_x, batch_size=32, verbose=1)


    print(pred[0:4])

    print('_______________________')

    print(test_y[0:4])