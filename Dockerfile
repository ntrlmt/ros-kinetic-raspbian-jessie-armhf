FROM ntrlmt/ros-kinetic-raspbian-jessie-armhf:perception
MAINTAINER ntrlmt

# Install raspi camera node (https://github.com/UbiquityRobotics/raspicam_node.git)
WORKDIR /root/catkin_ws/src
RUN git clone https://github.com/UbiquityRobotics/raspicam_node.git
RUN touch /etc/ros/rosdep/sources.list.d/30-ubiquity.list && \
    echo "yaml https://raw.githubusercontent.com/UbiquityRobotics/rosdep/master/raspberry-pi.yaml" >> /etc/ros/rosdep/sources.list.d/30-ubiquity.list
RUN rosdep update
WORKDIR /root/catkin_ws
RUN rosdep install --from-paths src --ignore-src --rosdistro kinetic -y -r --os=debian:jessie
RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j2

CMD ["/bin/bash"]
