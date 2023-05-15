https://mlir.llvm.org/docs/Dialects/LLVM/

Provides "dialects" for many instruction sets, mapping to:
- LLVM
- CUDA (via gpu and nvgpu dialects?)
- SPIR-V

Metal dialect seems to be community driven

Benefits:
- Community driven (less work for compiler devs)
Cons:
- Pretty early in implementation? Dialects are completely implemented

Example codegen: 
- https://github.com/llvm/llvm-project/blob/309fdbb49bc3780f7248440cc8467c486ab1dcca/mlir/examples/toy/Ch4/mlir/MLIRGen.cpp#L55
- https://github.com/llvm/llvm-project/blob/309fdbb49bc3780f7248440cc8467c486ab1dcca/mlir/examples/toy/Ch4/mlir/MLIRGen.cpp#L114-L115