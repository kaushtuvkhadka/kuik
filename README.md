# KUik

Qt6/QML app for browsing and streaming movies via the Internet Archive API.

## Build

```cmd
mkdir app
cd app
set PATH=C:\Qt\Tools\mingw1310_64\bin;C:\Qt\6.11.1\mingw_64\bin;C:\Qt\Tools\Ninja;%PATH%
cmake -G "Ninja" -DCMAKE_PREFIX_PATH="C:/Qt/6.11.1/mingw_64" -DCMAKE_C_COMPILER="C:/Qt/Tools/mingw1310_64/bin/gcc.exe" -DCMAKE_CXX_COMPILER="C:/Qt/Tools/mingw1310_64/bin/g++.exe" -DCMAKE_MAKE_PROGRAM="C:/Qt/Tools/Ninja/ninja.exe" -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

## Run

```cmd
kuikapp.exe
```
