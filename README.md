# mvprmatlab
Matlab functions for various computer vision and machine learning purposes

**Machine Vision and Pattern Recognition (MVPR) Matlab Toolbox**

This Toolbox contains "helper" functions that can be useful in many computer vision and pattern recognition / machine learning projects.

# Installation
Certain functions of this toolbox have special requirements, for example, need to install other external packages. These details are explained in this section.

## MVPR_FEATURE_EXTRACT (_NEW)

The local feature detection and description requires installation of VLFeat Toolbox from [http://www.vlfeat.org/](http://www.vlfeat.org/). After installation the VLFeat functions are available by:
```
>> addpath <VLFEATDID>/toolbox
>> vl_setup
```

In addition, certain fast detectors and descriptors require installation of OpenCV library and compiling the provided executables. These are described next.

**OpenCV (local user install)**
OpenCV library is fastly developing and thus always outdated. Therefore, we recommend building it locally
and not installing it system wide. Detailed description is given at the [opencv.org](http://opencv.org). Read Documentation -> Turorials -> Introduction -> Installation in Linux. You should just download the latest
source package, put it somewhere (e.g. /home/<USER>/Work/external/) and then

```
$ cd <OPENCV_EXTRACTION_DIR>
$ mkdir build ; cd build
$ ccmake ..
[EDIT CMAKE_INSTALL_PREFIX to point <OPENCV_EXTRACTION_DIR>/build/install & configure & exit]
$ cmake ..
$ make 
$ make install
```
