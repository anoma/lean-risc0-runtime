build:
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=toolchains/riscv32im-risc0-zkvm-elf.cmake
    cmake --build build -j

clean:
    rm -rf build
