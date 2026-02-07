# msdfgen-odin

Odin bindings for [msdfgen](https://github.com/Chlumsky/msdfgen), with a local bridge layer for:

- Core C API usage.
- TTF glyph loading (FreeType) and PNG output via `msdfgen-ext`.

`lib/msdfgen` is an unmodified git submodule to keep it isolated.
Bridge code between msdfgen and the odin bindings lives in `bridge/`.

## Dependencies (Linux)

- CMake 3.15+
- C++ compiler (`g++`/`clang++`)
- Odin compiler
- FreeType development package
- libpng development package

Dependency installs:

```bash
# Debian/Ubuntu
sudo apt-get install -y cmake g++ pkg-config libfreetype6-dev libpng-dev

# Fedora
sudo dnf install -y cmake gcc-c++ pkgconf-pkg-config freetype-devel libpng-devel

# Arch
sudo pacman -S --needed cmake gcc pkgconf freetype libpng
```

## Build

The underlying `msdfgen` library and the C bridge code need to be built with CMake. Several optional dependencies are excluded. 

```bash
git clone --recursive https://github.com/NANDquark/msdf-gen-odin
cd msdf-gen-odin
git submodule update --init --recursive

cmake -S . -B build \
  -DMSDFGEN_CORE_ONLY=OFF \
  -DMSDFGEN_USE_VCPKG=OFF \
  -DMSDFGEN_DISABLE_SVG=ON \
  -DMSDFGEN_USE_SKIA=OFF \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

## Run Demo

The demo loads a TTF font, generates MSDF for glyph `'A'`, and writes `demo-msdf-A.png`.

```bash
odin run demo
```
