FROM ubuntu:18.04

RUN apt-get update && \
  apt-get install -y \
    android-sdk \
    binutils \
    bsdmainutils \
    build-essential \
    git \
    libaudiofile-dev \
    libglew-dev \
    libsdl2-dev \
    libusb-1.0-0-dev \
    libzstd-dev \
    python3 \
    wget

ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH=${ANDROID_HOME}/tools/bin:${PATH}

# extract per https://stackoverflow.com/a/61176718/7290888
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip && \
  echo '89f308315e041c93a37a79e0627c47f21d5c5edbe5e80ea8dc0aac8a649e0e92  commandlinetools-linux-6609375_latest.zip' \
  | sha256sum commandlinetools-linux-6609375_latest.zip && \
  unzip -o commandlinetools-linux-6609375_latest.zip -d ${ANDROID_HOME}/cmdline-tools && \
  rm commandlinetools-linux-6609375_latest.zip

RUN yes| ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager --licenses && \
  ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager --install ndk-bundle

RUN mkdir -p /sm64/app/jni/SDL/

RUN wget https://www.libsdl.org/release/SDL2-2.0.12.zip && \
  echo '476e84d6fcbc499cd1f4a2d3fd05a924abc165b5d0e0d53522c9604fe5a021aa  SDL2-2.0.12.zip' \
  | sha256sum SDL2-2.0.12.zip && \
  unzip -o SDL2-2.0.12.zip "SDL2-2.0.12/src/*" "SDL2-2.0.12/include/*" && \
  rm SDL2-2.0.12.zip && \
  ln -nsf . /SDL2-2.0.12/include/SDL2

WORKDIR /sm64

CMD "./entrypoint.sh"
