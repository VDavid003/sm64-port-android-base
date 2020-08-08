#!/bin/sh

pushd app/jni/SDL

wget https://www.libsdl.org/release/SDL2-2.0.12.zip
unzip -q SDL2-2.0.12.zip
mv SDL2-2.0.12/src src
mv SDL2-2.0.12/include include
ln -s . include/SDL2
rm SDL2-2.0.12.zip
rm -r SDL2-2.0.12

popd
