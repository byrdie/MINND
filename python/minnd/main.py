
import matplotlib.pyplot as plt

from AIA_Obs import AIA_Obs
from IdentityModel import IdentityModel

# AIA data parameters
t_start = '2015/08/27 17:40:00'
t_end = '2015/08/27 17:44:00'
wavl = 171
data_dir = '../../datasets'
index_file = '../../datasets/aia_moses2_data.txt'


# Call AIA Observation constructor
# AIA_Obs(t_start = t_start, t_end = t_end, wavl_min = wavl, wavl_max = wavl, data_dir = data_dir)
aia = AIA_Obs(index_file = index_file)

# aia.cube.plot()

# plt.show()

train = aia.cube.as_array()




sz = train.shape
train = train.reshape(sz[2], 1, sz[0], sz[1])


mod = IdentityModel(train)

test = aia.cube.maps[0]

plt.figure(1)
test.plot()


tdata = test.data
tsz = tdata.shape
tdata = tdata.reshape(1, 1, sz[0], sz[1])
tdata = mod.net.predict(tdata)
test.data = tdata.reshape(sz[0], sz[1])


plt.figure(2)
test.plot()
plt.show()