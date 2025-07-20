## Maximum Performance TinyCore Packages

### Flags

- **`-Ofast`**  
  Enables all `-O3` optimizations plus unsafe math and standard-breaking transforms (e.g., assumes no NaNs or signed overflow).

- **`-fmerge-all-constants`**  
  Deduplicates identical constants (arrays, strings, etc.) across translation units to reduce size and improve cache efficiency.

- **`-fno-semantic-interposition`**  
  Assumes symbols are not replaced at runtime, allowing cross-module inlining and better optimization of function calls and globals.

- **`-ftree-vectorize`**  
  Enables vectorization at the GIMPLE tree level for both loops and straight-line code, using SIMD instructions where possible.

- **`-fipa-pta`**  
  Performs whole-program pointer analysis across functions to improve alias detection and unlock more aggressive optimization.

- **`-funroll-loops`**  
  Fully unrolls loops with constant bounds to remove loop control overhead and increase ILP (instruction-level parallelism).

- **`-floop-nest-optimize`**  
  Enables Pluto-based loop restructuring using ISL to improve cache locality and expose parallelism. Experimental.

---

### Warning

These flags prioritize **performance** over **portability** and **standards compliance**.

## Package Optimization Summary

| Package        | Version  | Flags Changed                          | Notes                                                              |
|----------------|----------|----------------------------------------|--------------------------------------------------------------------|
| MicroPython    | 1.25.0   | + `-flto`                              |                                                                    |
| Wine (Staging) | 10.12    | `-O3`                                  | `-Ofast` causes runtime issues; downgraded to `-O3`.               |

## Supported CPU Architectures
The binaries are currently compiled and available as artifacts for the following processors:
| Level            | Features                                                         | Since                                                  |
|------------------|------------------------------------------------------------------|--------------------------------------------------------|
| **x86-64**       | CMOV, CX8, FPU, FXSR, MMX, OSFXSR, SCE, SSE, SSE2                | AMD64, K8, Prescott                                    |
| **x86-64-v2**    | CMPXCHG16B, LAHF-SAHF, POPCNT, SSE3, SSSE3, SSE4.1, SSE4.2       | Nehalem, Silvermont, Bulldozer, Jaguar, Nano, Eden "C" |
| **x86-64-v3**    | AVX, AVX2, BMI1, BMI2, F16C, FMA, LZCNT, MOVBE, OSXSAVE          | Haswell, Gracemont, Excavator, QEMU 7.2+               |
| **x86-64-v4**    | AVX512F, AVX512BW, AVX512CD, AVX512DQ, AVX512VL                  | Skylake-X, Zen 4                                       |

