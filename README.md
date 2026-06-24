# Life in D
Port of [Life game](https://github.com/contextfreecode/life) to D and Parin engine.

## Downloading
Artifacts are available in Releases files.

## Building
To install:

```sh
dub run parin:setup
```

To run native version:

```sh
dub run --build=release
```

To run web version:

```sh
dub run parin:web --build=release
```

For native Linux X86_64 cross-compilation use (you will need to install Zig):
```sh
CC="zig cc -target x86_64-linux-gnu" \
CXX="zig c++ -target x86_64-linux-gnu" \
dub build -c=manual_linux --arch=x86_64-unknown-linux-gnu --force
```

# Resources
This game was created with [Parin](https://github.com/Kapendev/parin).
