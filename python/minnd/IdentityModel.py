
from keras.models import Sequential
from keras.layers import Conv2D
from keras.layers import Conv2DTranspose
from keras.optimizers import SGD

from keras.utils import plot_model

# The IdentityModel simply learns a representation of itself. This is also known as an autoencoder
class IdentityModel:

    net = []

    # Constructor for the IdentityModel class.
    def __init__(self, train):

        t_sz = train.shape

        # Define the network as a feed-forward neural network
        self.net = Sequential()

        # Apply a convolution operation
        self.net.add(Conv2D(64, (15, 15), activation='relu', padding='same',data_format='channels_first', input_shape=(t_sz[1], t_sz[2], t_sz[3])))

        # Apply a deconvolution operation
        self.net.add(Conv2DTranspose(1, (15,15), padding='same', data_format='channels_first'))

        print(self.net.get_output_shape_at(0))
        print(self.net.get_input_shape_at(0))

        plot_model(model=self.net, to_file='id.png', show_shapes=True, show_layer_names=True)

        # Build the optimizer
        # sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)

        # Compile parameters into the model
        self.net.compile(optimizer='rmsprop', loss='mse')

        # Train the model
        self.net.fit(train, train, batch_size=1, epochs=1000)
