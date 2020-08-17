#!/bin/bash

pushd app/jni/SDL

wget https://www.libsdl.org/release/SDL2-2.0.12.zip
unzip -q SDL2-2.0.12.zip
mv SDL2-2.0.12/src src
mv SDL2-2.0.12/include include

#MSYS2's symlinks seem to just copy the folder which isn't really a good thing recursively. Native symlinks are broken for me so let's just use Windows's implementation
if [[ -n "$WINDIR" ]]; then
    cmd <<< "mklink /D include\SDL2 ."
else
    ln -s . include/SDL2
fi

rm SDL2-2.0.12.zip
rm -r SDL2-2.0.12

popd
