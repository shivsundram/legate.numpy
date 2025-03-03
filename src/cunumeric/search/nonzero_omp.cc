/* Copyright 2021 NVIDIA Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include "cunumeric/search/nonzero.h"
#include "cunumeric/search/nonzero_template.inl"

#include <omp.h>

namespace cunumeric {

using namespace Legion;
using namespace legate;

template <LegateTypeCode CODE, int32_t DIM>
struct NonzeroImplBody<VariantKind::OMP, CODE, DIM> {
  using VAL = legate_type_of<CODE>;

  size_t operator()(const AccessorRO<VAL, DIM>& in,
                    const Pitches<DIM - 1>& pitches,
                    const Rect<DIM>& rect,
                    const size_t volume,
                    std::vector<Buffer<int64_t>>& results)
  {
    const auto max_threads = omp_get_max_threads();

    int64_t size     = 0;
    int64_t* offsets = static_cast<int64_t*>(alloca(max_threads * sizeof(int64_t)));

    {
      int64_t* sizes = static_cast<int64_t*>(alloca(max_threads * sizeof(int64_t)));
      for (auto idx = 0; idx < max_threads; ++idx) sizes[idx] = 0;
#pragma omp parallel
      {
        const int tid = omp_get_thread_num();
#pragma omp for schedule(static)
        for (size_t idx = 0; idx < volume; ++idx) {
          auto point = pitches.unflatten(idx, rect.lo);
          sizes[tid] += in[point] != VAL(0);
        }
      }

      for (auto idx = 0; idx < max_threads; ++idx) size += sizes[idx];

      offsets[0] = 0;
      for (auto idx = 1; idx < max_threads; ++idx) offsets[idx] = offsets[idx - 1] + sizes[idx - 1];
    }

    for (auto& result : results) result = create_buffer<int64_t>(size, Memory::Kind::SYSTEM_MEM);

#pragma omp parallel
    {
      const int tid   = omp_get_thread_num();
      int64_t out_idx = offsets[tid];
#pragma omp for schedule(static)
      for (size_t idx = 0; idx < volume; ++idx) {
        auto point = pitches.unflatten(idx, rect.lo);
        if (in[point] == VAL(0)) continue;
        for (int32_t dim = 0; dim < DIM; ++dim) results[dim][out_idx] = point[dim];
        ++out_idx;
      }
    }

    return size;
  }
};

/*static*/ void NonzeroTask::omp_variant(TaskContext& context)
{
  nonzero_template<VariantKind::OMP>(context);
}

}  // namespace cunumeric
