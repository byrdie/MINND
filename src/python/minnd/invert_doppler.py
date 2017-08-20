import numpy as np


import h5py



from keras.models import load_model



moses_fn = '../../idl/prep_moses/moses_level_1.h5'

with h5py.File(moses_fn, 'r') as f:
    data = f['data'][()]
    # data = np.rot90(data, k=1, axes=[2,3])
    sz = data.shape

    data = data[6:21,:,::-1,:,:]


    print(sz)

    net = load_model('model.h5')

    # p_shift = np.squeeze(net.predict(test_x, batch_size=256, verbose=1))
    sh = [sz[0], sz[1], sz[2], sz[3]-20, sz[4]]


    data = data.transpose([0, 2, 1, 3, 4])
    rs = data.shape
    print(rs)
    data = data.reshape([rs[0]*rs[1], rs[2], rs[3], rs[4]])

    zero_plus = data[:,0:2,:,:]
    zero_minus = data[:,0:3:2,:,:]
    zero_minus = zero_minus[:,:,::-1]
    data = None
    p_shift_plus =  -np.squeeze(net.predict(zero_plus, batch_size=32, verbose=1))
    p_shift_minus = -np.squeeze(net.predict(zero_minus, batch_size=32, verbose=1))
    p_shift_minus = p_shift_minus[:,::-1]
    zero_plus = None
    zero_minus = None

    p_shift_plus = p_shift_plus.reshape([rs[0],rs[1], rs[3]-20])
    p_shift_minus = p_shift_minus.reshape([rs[0], rs[1], rs[3] - 20])
    p_shift_ave = np.squeeze(np.average([[p_shift_plus], [p_shift_minus]], axis=0))


    np.save('p_shift_plus.npy', p_shift_plus)
    np.save('p_shift_minus.npy', p_shift_minus)
    np.save('p_shift_ave.npy', p_shift_ave)