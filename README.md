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
| MicroPython    | 1.25.0   | `-flto`                                                                            |
| Wine (Staging) | 10.12    |  `-Ofast` broke runtime: `-O3` <br>`x86-64-v4`  broke compilation: `Ignored`       |

## Supported CPU Architectures
The binaries are currently compiled and available as artifacts for the following processors:
| Level               | Enabled SIMD extensions                                          | Since                                                  |
|---------------------|------------------------------------------------------------------|--------------------------------------------------------|
| **x86-64**          | MMX, SSE, SSE2                                                   | AMD64, K8, Prescott                                    |
| **x86-64-v2**       | SSE3, SSE4                                                       | Nehalem, Silvermont, Bulldozer, Jaguar, Nano, Eden "C" |
| **x86-64-v3**       | AVX, AVX2, FMA                                                   | Haswell, Gracemont, Excavator, QEMU 7.2+               |
| **x86-64-v4**       | AVX512                                                           | Skylake-X, Zen 4                                       |

### A deeper look at flags
### **`-Ofast`**  

Original loop:
```c
float sum = 0.0f;
for (int i = 0; i < n; i++) {
    if (a[i] > 0.0f)
        sum += a[i];
}
```

`-O3` (not vectorized: unsupported control flow in loop)

```c
float sum = 0.0f;
for (int i = 0; i < n; i++) {
    if (a[i] > 0.0f) {
        sum += a[i];  // Branch for each element
    }
}
```

`-Ofast` (optimized: loop vectorized)

```c
// Process 4 elements at once
float sum = 0.0f;
for (int i = 0; i < n; i += 4) {
    // Load 4 values
    float v0 = a[i], v1 = a[i+1], v2 = a[i+2], v3 = a[i+3];
    
    // Create masks (1.0f if positive, 0.0f if not)
    float m0 = (v0 > 0.0f) ? 1.0f : 0.0f;
    float m1 = (v1 > 0.0f) ? 1.0f : 0.0f;
    float m2 = (v2 > 0.0f) ? 1.0f : 0.0f;
    float m3 = (v3 > 0.0f) ? 1.0f : 0.0f;
    
    // Apply masks and accumulate
    sum += (v0 * m0) + (v1 * m1) + (v2 * m2) + (v3 * m3);
}
```

### Potential problems with `-Ofast`

```c
float a[] = {1.0f, -0.0f, NAN, INFINITY, 2.0f};
```

**With `-O3`:**
```
sum = 1.0f + 0.0f + 0.0f + INFINITY = INFINITY
```

**With `-Ofast`:**
```
sum = 1.0f + (-0.0f) + NAN + INFINITY = NAN  // Different result!
```

### Issues:
- **NaN handling**: May propagate differently
- **Signed zero**: `-0.0f` vs `+0.0f` distinction lost
- **Infinity**: Operations may produce unexpected results
- **Precision**: Floating-point associativity changes can affect accuracy
