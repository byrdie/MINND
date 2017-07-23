
from keras.models import Sequential
from keras.layers import Conv2D
from keras.layers import Conv2DTranspose
from keras.layers import AveragePooling2D
from keras.layers import UpSampling2D
from keras.layers import Conv3D
from keras.optimizers import SGD
from keras.utils import plot_model
from keras.callbacks import TensorBoard
from keras.losses import mean_squared_error

from shutil import rmtree
from os import  mkdir
import time

# The IdentityModel simply learns a representation of itself. This is also known as an autoencoder
class IdentityModel:

    net = []

    # Constructor for the IdentityModel class.
    def __init__(self, train):

        # Initialize training visualization callback
        # remote = callbacks.RemoteMonitor(root='http://localhost:9000')
        tb_path = './logs/' + time.asctime(time.localtime())
        cb = TensorBoard(log_dir=tb_path, histogram_freq=10, write_graph=True, write_images=True)

        t_sz = train.shape

        # Define the network as a feed-forward neural network
        self.net = Sequential()

        # Apply a convolution operation
        self.net.add(Conv2D(16, (7, 7), dilation_rate=(1,1), activation='relu', padding='valid', data_format='channels_first', input_shape=(t_sz[1], t_sz[2], t_sz[3])))

        # self.net.add(AveragePooling2D(pool_size=(4,4), padding='valid', data_format='channels_first'))

        self.net.add(Conv2D(32, (11, 11), dilation_rate=(1,1), activation='relu', padding='valid', data_format='channels_first'))

        # Apply a deconvolution operation
        self.net.add(Conv2DTranspose(16, (11, 11), dilation_rate=(1,1), activation='relu', padding='valid', data_format='channels_first'))


        # self.net.add(UpSampling2D(size=(4, 4) , data_format='channels_first'))

        self.net.add(Conv2DTranspose(1, (7, 7), dilation_rate=(1,1), activation='relu', padding='valid', data_format='channels_first'))


        plot_model(model=self.net, to_file='id.png', show_shapes=True, show_layer_names=True)

        # Build the optimizer
        sgd = SGD(lr=5e-6, decay=1e-10, momentum=0.9, nesterov=True)

        # Compile parameters into the model
        self.net.compile(optimizer=sgd, loss='mse')


        # Train the model
        self.net.fit(train, train, batch_size=2, epochs=1000, callbacks=[cb], validation_split=0.2, verbose=1, shuffle=True)


# def log_mean_squared_error(y_true, )
