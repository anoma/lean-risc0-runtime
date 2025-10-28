build:
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/home/heliax/.lean-risc0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=toolchains/riscv32im-risc0-zkvm-elf.cmake
    cmake --build build -j

install: build
    cmake --install build

clean:
    rm -rf build
