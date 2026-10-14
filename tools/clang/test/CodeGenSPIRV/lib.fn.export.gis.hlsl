// RUN: %dxc -T lib_6_6 -fspv-target-env=universal1.5 -Gis %s -spirv | FileCheck %s --check-prefix=EXPORT
// RUN: %dxc -T lib_6_6 -fspv-target-env=universal1.5 -Gis -fspv-allow-import %s -spirv | FileCheck %s --check-prefix=EXPORT
// RUN: %dxc -T lib_6_6 -fspv-target-env=universal1.5 -Gis -DWITH_ENTRIES %s -spirv | FileCheck %s --check-prefix=ENTRIES

// -Gis on a library whose functions are all `export`ed (no entry points) used
// to crash: SignedZeroInfNanPreserve was attached to a null entry function.
// The exported arithmetic must still be IEEE-strict (NoContraction), and
// SignedZeroInfNanPreserve is only emitted when there is an entry point to
// carry it.

// EXPORT-NOT: OpCapability SignedZeroInfNanPreserve
// EXPORT-NOT: OpEntryPoint
// EXPORT-NOT: OpExecutionMode
// EXPORT-DAG: OpDecorate %scale LinkageAttributes "scale" Export
// EXPORT-DAG: OpDecorate [[mul:%[0-9]+]] NoContraction
// EXPORT:     [[mul]] = OpFMul %float

// With several entry points, every one of them gets the execution mode, not
// just the last one translated.
// ENTRIES:     OpCapability SignedZeroInfNanPreserve
// ENTRIES-DAG: OpExecutionMode %first SignedZeroInfNanPreserve 32
// ENTRIES-DAG: OpExecutionMode %second SignedZeroInfNanPreserve 32

export float scale(float x) { return x * 2.0; }

#ifdef WITH_ENTRIES
RWStructuredBuffer<float> buf;

[shader("compute")] [numthreads(1, 1, 1)]
void first() { buf[0] = scale(buf[0]); }

[shader("compute")] [numthreads(1, 1, 1)]
void second() { buf[1] = scale(buf[1]); }
#endif
