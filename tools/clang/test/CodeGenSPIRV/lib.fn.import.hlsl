// RUN: %dxc -T lib_6_x -E main -fspv-target-env=universal1.5 -fspv-allow-import  %s -spirv | FileCheck %s

// Calls to undefined external functions in a library target compile to a
// body-less OpFunction prototype decorated with Import linkage, so the
// resulting SPIR-V module can be linked against a separately compiled
// definition.

// CHECK-DAG: OpCapability Linkage

// The Import prototype must be referenced as the callee of OpFunctionCall.
// CHECK-DAG: OpDecorate %external_helper LinkageAttributes "external_helper" Import

// CHECK: OpFunctionCall %void %external_helper

// The prototype itself must have parameters but no entry block.
// CHECK: %external_helper = OpFunction %void None
// CHECK-NEXT: OpFunctionParameter
// CHECK-NEXT: OpFunctionParameter
// CHECK-NEXT: OpFunctionEnd

void external_helper(float a, out float result);

[shader("compute")]
[numthreads(1, 1, 1)]
void main(uint3 dtid : SV_DispatchThreadID)
{
    float result;
    external_helper(1.0, result);
}
