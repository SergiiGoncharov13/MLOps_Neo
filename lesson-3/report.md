# Comparison of Docker images

## Table
| Image         | Size    | Layers| Comments |
|---------------|---------|-------|-----------|
| `ml_infer:fat` | 1.15GB | 12    | Has all build tools, extra packages|
| `ml_infer:slim`| 893MB  | 16    | Only necessary dependencies|

## Conclusions
- Slim image is smaller.
- Compilers and build-essential have been removed.
- Optimization options:
  - Use of `torch.jit.freeze`, `optimize_for_inference`.
  - Use of ONNX + ONNXRuntime.
```
