// RUN: %dxc -T lib_6_x -fspv-target-env=universal1.5 -fspv-allow-import -Zi %s -spirv | FileCheck %s

// Regression test for two SPIR-V Logical Layout issues that surface
// when a translation unit mixes a body-less Import prototype with one
// or more helper functions that have bodies (which is what the breda
// material-graph stub looks like: a body-less external resolved at
// link time, plus body-having helpers from an inlined header):
//
// 1. The prototype must come first in the function section. A naive
//    insertion-order emit produces `helper_def -> import_decl ->
//    caller_def` which spirv-val rejects with "Function declarations
//    must appear before function definitions".
//
// 2. With `-Zi`, OpLine instructions normally interleave between
//    OpFunction / OpFunctionParameter / OpFunctionEnd. Inside an
//    Import prototype the OpLine between OpFunction and the first
//    OpFunctionParameter trips spirv-val's layout pass into advancing
//    past `FunctionDeclarations` (it classifies OpLine as
//    FunctionDefinitions outside the Types section), and the
//    prototype's own OpFunctionEnd is then flagged as a "declaration
//    after definition" violation.
//
// EmitVisitor's `inImportPrototype` flag suppresses OpLine for every
// instruction inside a body-less prototype's header except OpFunction
// itself. The OpLine before OpFunction is fine — it's processed in
// the Types section.

// CHECK-DAG: OpCapability Linkage
// CHECK-DAG: OpDecorate %external_helper LinkageAttributes "external_helper" Import

// The Import prototype must appear before any function definitions
// AND must contain no OpLine instructions inside its header.
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
