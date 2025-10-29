## Lean4 runtime for RISC0

Building:
```
just build
```

Installing:
```
just install
```

Make sure you have the following environment variables set.
- LEAN_RISC0_PATH: installation path for the Lean RISC0 runtime, something like $HOME/.lean-risc0
- RISC0_TOOLCHAIN_PATH: path to RISC0 toolchain, something like $HOME/.risc0/toolchains/v2024.1.5-cpp-x86_64-unknown-linux-gnu/riscv32im-linux-x86_64
