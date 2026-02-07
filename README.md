# msdfgen-odin

Odin bindings for [msdfgen](https://github.com/Chlumsky/msdfgen), with a local bridge layer for:

- Core C API usage.
- TTF glyph loading (FreeType) and PNG output via `msdfgen-ext`.

`lib/msdfgen` should be treated as a clean git submodule. Local bridge code lives in `bridge/`.

## Dependencies (Linux)

- CMake 3.15+
- C++ compiler (`g++`/`clang++`)
- Odin compiler
- FreeType development package
- libpng development package

Example installs:

```bash
# Debian/Ubuntu
sudo apt-get install -y cmake g++ pkg-config libfreetype6-dev libpng-dev

# Fedora
sudo dnf install -y cmake gcc-c++ pkgconf-pkg-config freetype-devel libpng-devel

# Arch
sudo pacman -S --needed cmake gcc pkgconf freetype libpng
```

## Build

```bash
git clone --recursive <your-repo-url>
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

## Verify

```bash
odin check . -no-entry-point -vet -vet-style
odin check example -no-entry-point
odin test .
```

## Run Example

```bash
odin run example
```

The example loads a system TTF font, generates MSDF for glyph `'A'`, and writes `example-msdf-A.png`.

## Use From Another Odin Project

```odin
import msdf "msdf:."
```

```bash
odin run /path/to/your_program -collection:msdf=/absolute/path/to/msdf-gen-odin
```
