// RUN: %dxc -T lib_6_x -fspv-target-env=universal1.5 -fspv-allow-import  %s -spirv | FileCheck %s

// Regression test for SPIR-V Logical Layout (sec. 2.4): when a
// translation unit mixes a body-less Import prototype with one or more
// helper functions that *do* have bodies, the prototype must come
// first in the function section. A naive insertion-order emit produces
// `helper_def -> import_decl -> caller_def` which spirv-val rejects
// with "Function declarations must appear before function definitions".
//
// This case mirrors what the breda material-graph stub looks like: a
// body-less external (resolved at link time) plus a body-having
// helper function from an inlined header, both called from the
// exported `caller`.

// CHECK-DAG: OpCapability Linkage
// CHECK-DAG: OpDecorate %external_helper LinkageAttributes "external_helper" Import

// The Import prototype must appear before any function definitions.
// CHECK: %external_helper = OpFunction %void None
// CHECK-NEXT: OpFunctionParameter
// CHECK-NEXT: OpFunctionEnd
// CHECK: %inline_helper = OpFunction
// CHECK: %caller = OpFunction

float external_helper(float a);

float inline_helper(float a) {
    return a * 2.0;
}

export float caller(float v) {
    return external_helper(v) + inline_helper(v);
}
