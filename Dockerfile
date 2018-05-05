FROM ntrlmt/rpi-raspbian-jessie-armhf-devel:latest
MAINTAINER ntrlmt

# Setup ROS Repositories
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
    apt-get update && \
    apt-get upgrade
# Install Bootstrap Dependencies
RUN apt-get install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall  && \
    rosdep init && rosdep update
# Installation
RUN mkdir -p ~/catkin_ws
WORKDIR /root/catkin_ws
RUN rosinstall_generator ros_comm --rosdistro kinetic --deps --wet-only --tar > kinetic-ros_comm-wet.rosinstall && \
    wstool init src kinetic-ros_comm-wet.rosinstall
## Resolve Dependencies
RUN mkdir -p ~/catkin_ws/external_src && \
    cd ~/catkin_ws/external_src && \
    wget http://sourceforge.net/projects/assimp/files/assimp-3.1/assimp-3.1.1_no_test_models.zip/download -O assimp-3.1.1_no_test_models.zip && \
    unzip assimp-3.1.1_no_test_models.zip && \
    cd assimp-3.1.1 && \
    cmake . && \
    make && \
    sudo make install

WORKDIR /root/catkin_ws/
RUN rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:jessie
## Build
RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j2

WORKDIR /root/catkin_ws/src
RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash; catkin_init_workspace'
WORKDIR /root/catkin_ws/
RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash' && \
    echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc && \
    echo "unset GTK_IM_MODULE" >> ~/.bashrc

CMD ["/bin/bash"]
