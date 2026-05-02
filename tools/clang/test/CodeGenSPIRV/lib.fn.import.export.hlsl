// RUN: %dxc -T lib_6_x -fspv-target-env=universal1.5 -fspv-allow-import  %s -spirv | FileCheck %s

// Library target with both Export and Import linkage in the same module:
// `caller` is exported and forwards through an undefined `helper` which
// must be Import-linked.

// CHECK-DAG: OpCapability Linkage
// CHECK-DAG: OpDecorate %caller LinkageAttributes "caller" Export
// CHECK-DAG: OpDecorate %helper LinkageAttributes "helper" Import

// No entry points should be emitted.
// CHECK-NOT: OpEntryPoint

float helper(float x);

export float caller(float v) {
  return helper(v);
}
