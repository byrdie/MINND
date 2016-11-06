# MINND
Neural network for performing inversion of MOSES data. MOSES is a slitless EUV spectrograph, designed to capture spatial-spectral images of the sun in EUV wavelenghts.

# Installation Instructions

These instructions were tested using Linux Mint 18, using an nvidia GTX980 graphics card

Caffe has several dependencies, install the graphics card drivers only if you need to do GPU training. Otherwise you can use the CPU.

## Installing the GPU dependencies (nvidia GPU only)
### Installing the nvidia Drivers
Use the Linux Mint driver manager to install the latest nvidia drivers. The current version is nvidia-367.

### Installing the CUDA libraries

Download the latest [drivers](https://developer.nvidia.com/cuda-downloads). Select the buttons that describe your target platform. We used the Ubunut 16.04 .deb file. Once downloaded, enter the following commands to install the drivers
```
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64.deb
sudo apt-get update
sudo apt-get install cuda
```

add the following lines to your `.bashrc` file to complete the installation

```
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_ROOT=/usr/local/cuda
```

### Testing the CUDA libraries
Navigate to the CUDA samples directory

`cd /usr/local/cuda-8.0/samples/`

Use the `deviceQuery` and `bandwidthTest` programs to test if CUDA and the drivers installed correctly. Here are the instructions on how to compile and run `deviceQuery`
```
cd 1_Utilities/deviceQuery
sudo make
./deviceQuery
```
If you would like to test OpenGL, for example on the `Mandelbrot` sample, you have to provide the location of the OpenGL libraries since Linux Mint is not a supported distribution.
```
cd /usr/local/cuda-8.0/samples/2_Graphics/Mandelbrot
sudo make GLPATH=/usr/lib/
./Mandelbrot
```
### Installing the cuDNN Libraries

The cuDNN libraries provides more graphics acceleration to Caffe.

Download them [here](https://developer.nvidia.com/rdp/cudnn-download) using your nvidia developer account.

Select the cuDNN 5.1 Library for Linux, and extract it. Open and copy `*.h to $CUDA_ROOT/includes` and `*.so* to $CUDA_ROOT/lib64`.

## Installing Caffe

### Installing dependencies
Thre requried depencies for Caffe can be found at the following [webpage](http://caffe.berkeleyvision.org/install_apt.html)
These dependencies should be downloaded from the `apt-get` repositories before attempting to compile Caffe
```
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler libboost-all-dev libopenblas-dev libgflags-dev libgoogle-glog-dev liblmdb-dev
```

### Installing Caffe
Download the latest version of Caffe from the [git repository](https://github.com/BVLC/caffe)

`git clone https://github.com/BVLC/caffe.git`

#### Prepare `Makefile.config`

Navigate into the cloned directory and modify the file `Makefile.config.example`.
```
cd caffe`
xdg-open Makefile.config.example
```
If using cuDNN, then uncomment the line `xdg-open Makefile.config.example`.

For Linux Mint 18 support, modify `INCLUDE_DIRS` in `Makefile.config`

`INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial/`

Next, select the OpenBLAS library by chaning the line
`BLAS := atlas`
to
`BLAS := open`

and save the file as `Makefile.config`.

#### Prepare the `Makefile`

Modify the Makefile to work in Linux Mint by changing the line

`LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_hl hdf5`

to

`LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_serial_hl hdf5_serial`

We are finally ready to compile Caffe.

#### Compile Caffe

Compile Caffe using `make`:
```
make all -j8
make test -j8
make runtest -j8
```
