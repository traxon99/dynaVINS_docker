FROM ros:melodic-perception

# Set noninteractive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Install core tools + Ceres
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libgoogle-glog-dev \
    libatlas-base-dev \
    libsuitesparse-dev \
    libceres-dev \
    python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# Create a catkin workspace
WORKDIR /root/vins_ws
RUN mkdir -p src

# Clone repositories
WORKDIR /root/vins_ws/src
RUN git clone https://github.com/HKUST-Aerial-Robotics/VINS-Fusion.git
RUN git clone https://github.com/url-kaist/dynaVINS.git

# Copy camera_models package to workspace root (from VINS-Fusion)
RUN cp -r VINS-Fusion/camera_models ./camera_models

# Copy required support files into DynaVINS
RUN cp VINS-Fusion/support_files/brief_k10L6.bin dynaVINS/support_files/ && \
    cp VINS-Fusion/support_files/brief_pattern.yml dynaVINS/support_files/

RUN mv VINS-Fusion/ ../../

# Build workspace
WORKDIR /root/vins_ws
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && catkin_make"

# Source setup for convenience
RUN echo "source /root/vins_ws/devel/setup.bash" >> /root/.bashrc

CMD ["/bin/bash"]
