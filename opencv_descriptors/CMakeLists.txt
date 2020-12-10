CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

#SET(BUILD_SHARED_LIBRARIES false)
#SET(CMAKE_EXE_LINKER_FLAGS "-static")

FIND_PACKAGE(OpenCV COMPONENTS highgui nonfree features2d imgproc flann core video calib3d REQUIRED)
#FIND_PACKAGE(OpenCV REQUIRED)
if(NOT OpenCV_LIBS)
	message(SEND_ERROR "Failed to find OpenCV")
else ()
	message(STATUS "OpenCV version: " ${OpenCV_VERSION} )
endif()
	
FIND_PACKAGE(Boost COMPONENTS program_options regex system thread filesystem REQUIRED)

# Add custom directories
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/src/library/
		    ${CMAKE_BINARY_DIR}/include/
		    ${Boost_INCLUDE_DIR})
LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/lib/)

# Set sources
SET(SOURCES 
	    main.cc)

# Define executable and linker parameters
ADD_EXECUTABLE(opencv_descriptors ${SOURCES})

TARGET_LINK_LIBRARIES(opencv_descriptors ${OpenCV_LIBS} ${Boost_LIBRARIES})
