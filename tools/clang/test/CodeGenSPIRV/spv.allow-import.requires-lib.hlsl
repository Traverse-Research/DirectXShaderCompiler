// RUN: not %dxc -T cs_6_0 -E main -fspv-target-env=universal1.5 -fspv-allow-import  %s -spirv  2>&1 | FileCheck %s

// CHECK: error: -fspv-allow-import requires a lib_* target profile

[numthreads(1,1,1)]
void main() {}
