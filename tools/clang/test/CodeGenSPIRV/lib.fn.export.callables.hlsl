// RUN: %dxc -T lib_6_x -fspv-target-env=universal1.5  %s -spirv | FileCheck %s

// Library with multiple exported callable functions and no entry point: a
// SPIR-V module suitable for spirv-link consumption. Mirrors the
// material-graph "node" shape: every callable takes a struct as its first
// in-parameter, returns through an `out` parameter, and ranges over scalar
// and vector floats plus a few common intrinsics.

// CHECK-DAG: OpCapability Shader
// CHECK-DAG: OpCapability Linkage

// No entry points should be emitted for an export-only library.
// CHECK-NOT: OpEntryPoint

// CHECK-DAG: OpDecorate %add_f1 LinkageAttributes "add_f1" Export
// CHECK-DAG: OpDecorate %add_f4 LinkageAttributes "add_f4" Export
// CHECK-DAG: OpDecorate %dot_f3 LinkageAttributes "dot_f3" Export
// CHECK-DAG: OpDecorate %normalize_f3 LinkageAttributes "normalize_f3" Export
// CHECK-DAG: OpDecorate %saturate_f1 LinkageAttributes "saturate_f1" Export
// CHECK-DAG: OpDecorate %lerp_f4 LinkageAttributes "lerp_f4" Export

struct ShadingContext {
  uint3 dispatch_thread_id;
  uint  num_invocations;
};

export void add_f1(in ShadingContext ctx, in float  a, in float  b, out float  result) { result = a + b; }
export void add_f4(in ShadingContext ctx, in float4 a, in float4 b, out float4 result) { result = a + b; }

export void dot_f3(in ShadingContext ctx, in float3 a, in float3 b, out float result) { result = dot(a, b); }

export void normalize_f3(in ShadingContext ctx, in float3 a, out float3 result) { result = normalize(a); }

export void saturate_f1(in ShadingContext ctx, in float a, out float result) { result = saturate(a); }

export void lerp_f4(in ShadingContext ctx, in float4 a, in float4 b, in float t, out float4 result) {
  result = lerp(a, b, t);
}
