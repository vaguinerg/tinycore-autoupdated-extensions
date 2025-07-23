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

| Package        | Version  | Notes                                                                              |
|----------------|----------|------------------------------------------------------------------------------------|
| MicroPython    | 1.25.0   |                                                                                    |
| Wine (Staging) | 10.12    |  `-Ofast` broken: `-O3` <br>`x86-64-v4`  broken: `Ignored`                         |
| OpenTTD        | Main     |  `x86-64-v4`  broken: `Ignored`                                                    |

## Supported CPU Architectures
The binaries are currently compiled and available as artifacts for the following processors:
| Level               | Enabled SIMD extensions                                          | Since                                                  |
|---------------------|------------------------------------------------------------------|--------------------------------------------------------|
| **x86-64**          | MMX, SSE, SSE2                                                   | AMD64, K8, Prescott                                    |
| **x86-64-v2**       | SSE3, SSE4                                                       | Nehalem, Silvermont, Bulldozer, Jaguar, Nano, Eden "C" |
| **x86-64-v3**       | AVX, AVX2, FMA                                                   | Haswell, Gracemont, Excavator, QEMU 7.2+               |
| **x86-64-v4**       | AVX512                                                           | Skylake-X, Zen 4                                       |


## Aditional CPU Architectures
Feel free to send a pr with [your cpu type](https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html)
| Arch              | Features                                                                                                                 |
|-------------------|--------------------------------------------------------------------------------------------------------------------------|
| **alderlake**     | MOVBE, MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2, POPCNT, AES, PREFETCHW, PCLMUL, RDRND, XSAVE, XSAVEC, XSAVES,<br>XSAVEOPT, FSGSBASE, PTWRITE, RDPID, SGX, GFNI-SSE, CLWB, MOVDIRI, MOVDIR64B, WAITPKG, ADCX, AVX, AVX2, BMI, BMI2, F16C,<br>FMA, LZCNT, PCONFIG, PKU, VAES, VPCLMULQDQ, SERIALIZE, HRESET, KL, WIDEKL, AVX-VNNI, UINTR, VXIFMA, AVXVNNIINT8,<br> AVXNECONVERT and CMPCCXADD  |
