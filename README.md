# sm64ex Android Port
This is a port of the reconstructed Super Mario 64 source code to Android using SDL2 with OpenGL ES 2.0.

It has cross-platform Touch Controls, Audio works, it saves the game to the app's internal storage and you can play it with an external keyboard or controller as well (tested on PS3 controller).

# Build instructions

## Prerequisites

The exact toolchain this project is pinned to. Using something else is the most common
cause of build failures, so check this list first.

| Tool | Version | Notes |
| --- | --- | --- |
| JDK | **11** | Gradle 7.1 (see `gradle/wrapper/gradle-wrapper.properties`) cannot run on JDK 17+. Building on JDK 17 fails immediately with `Unsupported class file major version 61`. |
| Gradle | 7.1 | Provided by `gradlew`; do not substitute a different version. |
| Android Gradle Plugin | 4.2.1 | Pinned in `build.gradle`. |
| Android SDK Platform | **android-26** | `compileSdkVersion 26`. Install with `sdkmanager "platforms;android-26"`. |
| Android Build Tools | **30.0.3** | `sdkmanager "build-tools;30.0.3"`. |
| Android NDK | **21.4.7075529** | `sdkmanager "ndk;21.4.7075529"`. Required by `externalNativeBuild { ndkBuild }`. |
| SDL2 | 2.0.12 | Fetched by `./getSDL.sh`. |

Point the build at your SDK by creating `local.properties` in the repository root:

```properties
sdk.dir=/path/to/Android/Sdk
ndk.dir=/path/to/Android/Sdk/ndk/21.4.7075529
```

`local.properties` is machine-specific and is git-ignored.

### Host build dependencies

The `make` step below compiles some host-side files and needs SDL2 development headers,
a C compiler, `python3`, and the Khronos GLES2 headers:

```sh
# Debian/Ubuntu
sudo apt-get install build-essential python3 libsdl2-dev libgles2-mesa-dev
```

### Build time note

The default `abiFilters` builds **four ABIs** (`armeabi-v7a`, `arm64-v8a`, `x86`,
`x86_64`), so the whole game is compiled four times. Expect the build to take a long
time (tens of minutes) even on a fast machine.

If you only need one device, edit `abiFilters` in `app/build.gradle` to just that ABI,
for example:

```gradle
abiFilters 'arm64-v8a'
```

This is also a large speedup and is the recommended setup for modern phones.

## Linux

**Install dependencies:**

This depends on your distro, but if you can build the PC port and you have Android SDK/NDK and you are able to build Android apps using gradle, you should be fine.

**Clone the repository:**
```sh
git clone --recursive https://github.com/VDavid003/sm64-port-android-base --branch sm64ex
cd sm64-port-android-base
```

If you already have a checkout, make sure the `app/jni/src` submodule is populated:
```sh
git submodule update --init --recursive
```
The Android build cannot work with an empty `app/jni/src`. If that directory contains
only `baserom.us.z64` and no C sources, the submodule was never checked out.

**Copy in your baserom:**
```sh
cp /path/to/your/baserom.z64 ./app/jni/src/baserom.us.z64
```

Note: the baserom is provided by you and is never committed to this repository.

If `git submodule update --init` fails with
`destination path ... already exists and is not an empty directory`, that is because
`baserom.us.z64` was placed in `app/jni/src` before initialising the submodule. Move the
ROM somewhere safe, initialise the submodule, then copy the ROM back in.

**Get SDL sources:**
```sh
./getSDL.sh
```

**Perform native build twice:**
```sh
# if you have more cores available, you can increase the --jobs parameter
cd app/jni/src
make --jobs 4
make --jobs 4
cd ../../..
```

Why twice? The first `make` generates asset C files (textures, sounds, demo data) from
the baserom, and the second `make` compiles the objects that consume them. Running the
Android build after only one pass produces link errors about missing symbols such as
`gfx_..._skybox` or missing `sound_data` symbols.

Note that this `make` step does **not** build the Android binary, it only generates the
assets that the NDK build later compiles. It is normal for the final host
`build/us_pc/sm64.us.f3dex2e` link step to fail if you do not have a native SDL2
development library installed; the generated assets are still produced and the Android
build is unaffected.

If the generated skybox C files get cleaned up as intermediate files, restore them before
running Gradle:
```sh
cd app/jni/src
make $(ls textures/skyboxes/*.png | xargs -n1 basename | sed 's/\.png$//' \
  | sed 's#^#build/us_pc/bin/#;s#$#_skybox.c#')
cd ../../..
```

**Perform Android build:**
```sh
./gradlew assembleDebug
```

**Enjoy your apk:**
```sh
ls -al ./app/build/outputs/apk/debug/app-debug.apk
```

## Windows

**Install dependencies:**

You'll need everything you need to make Windows builds (not just vanilla sm64 ones, but sm64ex ones), and to be able to build Android apps using `gradlew.bat`. This includes Java JDK (with the JDK being JAVA_HOME) and Android SDK/NDK. Every commmand is executed in MSYS2 unless otherwise noted.

**Clone the repository:**
```sh
git clone --recursive https://github.com/VDavid003/sm64-port-android-base --branch sm64ex
```

**Copy in your baserom:**
Use the file explorer, or whatever you want, just put it in `app/jni/src`, and name it like you'd do on the PC port.
```sh
cp /path/to/your/baserom.z64 ./app/jni/src/baserom.us.z64
```

**Get SDL sources:**
```sh
./getSDL.sh
```

**Perform native build twice:**
```sh
# if you have more cores available, you can increase the --jobs parameter
cd app/jni/src
make --jobs 4
make --jobs 4
cd ../../..
```

Why twice? The first `make` generates asset C files (textures, sounds, demo data) from
the baserom, and the second `make` compiles the objects that consume them. Running the
Android build after only one pass produces link errors about missing symbols such as
`gfx_..._skybox` or missing `sound_data` symbols.

Note that this `make` step does **not** build the Android binary, it only generates the
assets that the NDK build later compiles. It is normal for the final host
`build/us_pc/sm64.us.f3dex2e` link step to fail if you do not have a native SDL2
development library installed; the generated assets are still produced and the Android
build is unaffected.

If the generated skybox C files get cleaned up as intermediate files, restore them before
running Gradle:
```sh
cd app/jni/src
make $(ls textures/skyboxes/*.png | xargs -n1 basename | sed 's/\.png$//' \
  | sed 's#^#build/us_pc/bin/#;s#$#_skybox.c#')
cd ../../..
```

**Perform Android build:**
Do this in a normal Command Prompt!
```
gradlew.bat assembleDebug
```

## Docker

**Clone the repository:**
```sh
git clone --recursive https://github.com/VDavid003/sm64-port-android-base --branch sm64ex
```

**Create the build image:**
```sh
# navigate into newly cloned repo
cd sm64-port-android-base
# build the docker image
docker build . -t sm64_android
```
**Copy in your baserom:**
```sh
cp /path/to/your/baserom.z64 ./app/jni/src/baserom.us.z64
```

**Setup symlinks for SDL:**
```sh
docker run --rm -v $(pwd):/sm64 sm64_android sh -c "ln -nsf /SDL2-2.0.12/src /sm64/app/jni/SDL/src"
docker run --rm -v $(pwd):/sm64 sm64_android sh -c "ln -nsf /SDL2-2.0.12/include /sm64/app/jni/SDL/include"
```

**Perform native build twice:**
```sh
# if you have more cores available, you can increase the --jobs parameter
docker run --rm -v $(pwd):/sm64 sm64_android sh -c "cd /sm64/app/jni/src && make --jobs 4"
docker run --rm -v $(pwd):/sm64 sm64_android sh -c "cd /sm64/app/jni/src && make --jobs 4"
```

**Perform Android build:**
```sh
docker run --rm -v $(pwd):/sm64 sm64_android sh -c "./gradlew assembleDebug"
```

**Enjoy your apk:**
```sh
ls -al ./app/build/outputs/apk/debug/app-debug.apk
```

# Configuration
If you want to customize the build with build options, you should make the native build with those options first (put them after the make command like on normal repos), then before performing the Android build, edit `app/jni/src/Android.mk` and enable the options you'd like.

## EXTERNAL_DATA option
If you use `EXTERNAL_DATA`, you'll find a zip named `base.zip` in `app/jni/src/build/<version>_pc/res`.

You should take this zip and put it in `Internal Storage/Android/data/com.vdavid003.sm64port/files`

# Troubleshooting

### `Unsupported class file major version 61`
You are running Gradle on JDK 17 or newer. Gradle 7.1 requires JDK 11.
```sh
export JAVA_HOME=/path/to/jdk-11
./gradlew assembleDebug
```

### `Failed to install the following SDK components` / `platforms;android-26` missing
The build needs SDK Platform 26 and Build Tools 30.0.3. Install them with `sdkmanager`
and confirm `local.properties` points at your SDK.

### `NDK not configured` or `No version of NDK matched`
Install the expected NDK and set `ndk.dir` in `local.properties`:
```sh
sdkmanager "ndk;21.4.7075529"
```

### `GLES2/gl2platform.h: No such file or directory` during `make`
Install the Khronos GLES2 headers: `sudo apt-get install libgles2-mesa-dev`.

### `'stderr' undeclared` during `make`
Some host-side files relied on `SDL.h` transitively including `<stdio.h>`, which recent
header versions do not. Ensure `libsdl2-dev` is installed.

### `make` fails linking `build/us_pc/sm64.us.f3dex2e`
This is the host-only PC executable and is not needed for the Android build, as long as
the generated assets under `app/jni/src/build/us_pc` exist.

### Build is very slow
By default the project builds four ABIs. Restrict `abiFilters` in `app/build.gradle` to
just your device's ABI to cut build time dramatically.
