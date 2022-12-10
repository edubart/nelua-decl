local nldecl = require 'nldecl2'

nldecl.generate_bindings_file{
  output_file = 'gmp.nelua',
  include_dirs = {
    '/home/bart/projects/nelua/nelua-decl'
  },
  parse_includes = {
    '<mini-gmp.h>',
  },
  cc = 'gcc',
  include_names = {
    '^gmp',
    '^mp',
  }
}

-- nldecl.generate_bindings_file{
--   output_file = 'mkl.nelua',
--   parse_includes = {
--     '<mkl.h>',
--   },
--   cc = 'gcc',
--   include_dirs = {
--     '/opt/intel/mkl/include'
--   },
--   include_names = {
--     '^mkl',
--     '^MKL',
--     '^cblas',
--     '^CBLAS',
--   }
-- }

nldecl.generate_bindings_file{
  output_file = 'cblas.nelua',
  parse_includes = {
    '<cblas.h>',
  },
  cc = 'gcc',
  include_names = {
    '^cblas',
    '^CBLAS',
  }
}

-- nldecl.generate_bindings_file{
--   output_file = 'cutensor.nelua',
--   parse_includes = {
--     '<cuda.h>',
--     '<cuda_runtime.h>',
--     '<cutensor.h>',
--   },
--   cc = 'gcc',
--   include_dirs = {
--     '/opt/cuda/targets/x86_64-linux/include',
--     '/home/bart/apps/libcutensor-linux-x86_64-1.5.0.3-archive/include'
--   },
--   include_names = {
--     '^cu',
--     '^CU',
--   }
-- }

nldecl.generate_bindings_file{
  output_file = 'cuda.nelua',
  parse_includes = {
    '<cuda_runtime.h>',
  },
  cc = 'gcc',
  include_dirs = {
    '/opt/cuda/targets/x86_64-linux/include',
  },
  include_names = {
    '^cuda',
    '^CUDA',
  }
}

nldecl.generate_bindings_file{
  output_file = 'cudnn.nelua',
  parse_includes = {
    '<cuda_runtime.h>',
    '<cublas_v2.h>',
    '<cudnn_backend.h>',
  },
  cc = 'gcc',
  include_dirs = {
    '/opt/cuda/targets/x86_64-linux/include'
  },
  include_names = {
    '^CUDNN',
    '^cudnn',
    '^CUDA',
    '^cuda',
    '^cublas',
    '^CUBLAS',
  }
}

nldecl.generate_bindings_file{
  output_file = 'omp.nelua',
  parse_includes = {
    '<omp.h>',
  },
  cc = 'clang',
  include_names = {
    '^OMP',
    '^omp',
    '^llvm_omp',
  }
}

nldecl.generate_bindings_file{
  output_file = 'tensorflow.nelua',
  parse_includes = {
    '<tensorflow/c/c_api.h>',
    -- '<tensorflow/c/c_api_experimental.h>',
    '<tensorflow/c/eager/c_api.h>',
    -- '<tensorflow/c/eager/c_api_experimental.h>',
  },
  cc = 'gcc',
  include_dirs = {
    '/usr/include/tensorflow'
  },
  include_names = {
    '^TF_',
    '^TFE_',
  }
}

--[[
nldecl.generate_bindings_file{
  output_file = 'iree.nelua',
  parse_includes = {
    '<iree/base/api.h>',
    '<iree/vm/api.h>',
    '<iree/hal/api.h>',
    '<iree/modules/hal/module.h>',
    '<iree/hal/dylib/registration/driver_module.h>',
    '<iree/hal/vmvx/registration/driver_module.h>',
    '<iree/hal/vulkan/registration/driver_module.h>',
    '<iree/hal/cuda/registration/driver_module.h>',
    '<iree/vm/bytecode_module.h>',
  },
  cc = 'gcc',
  include_dirs = {
    '/home/bart/apps/iree',
  },
  include_names = {
    '^iree',
    '^IREE',
  },
}

nldecl.generate_bindings_file{
  output_file = 'mlir.nelua',
  parse_includes = {
    '<mlir-c/AffineExpr.h>',
    '<mlir-c/AffineMap.h>',
    '<mlir-c/BuiltinAttributes.h>',
    '<mlir-c/BuiltinTypes.h>',
    '<mlir-c/Conversion.h>',
    '<mlir-c/Debug.h>',
    '<mlir-c/Diagnostics.h>',
    '<mlir-c/ExecutionEngine.h>',
    '<mlir-c/IntegerSet.h>',
    '<mlir-c/Interfaces.h>',
    '<mlir-c/IR.h>',
    '<mlir-c/Pass.h>',
    '<mlir-c/Registration.h>',
    '<mlir-c/Support.h>',
    '<mlir-c/Transforms.h>',
    '<mlir-c/IR.h>',
    '<mlir-c/Dialect/Async.h>',
    '<mlir-c/Dialect/Func.h>',
    '<mlir-c/Dialect/GPU.h>',
    '<mlir-c/Dialect/Linalg.h>',
    '<mlir-c/Dialect/LLVM.h>',
    '<mlir-c/Dialect/PDL.h>',
    '<mlir-c/Dialect/Quant.h>',
    '<mlir-c/Dialect/SCF.h>',
    '<mlir-c/Dialect/Shape.h>',
    '<mlir-c/Dialect/SparseTensor.h>',
    '<mlir-c/Dialect/Tensor.h>',
    '<iree-compiler-c/Compiler.h>',
    '<iree-compiler-c/Tools.h>',
    '<iree-dialects-c/Dialects.h>',
  },
  include_dirs = {
    '/home/bart/apps/iree/llvm-external-projects/iree-compiler-api/include',
    '/home/bart/apps/iree/llvm-external-projects/iree-dialects/include',
    '/home/bart/apps/iree/third_party/llvm-project/mlir/include',
    '/home/bart/apps/iree-build/third_party/llvm-project/llvm/tools/mlir/include',
  },
  cc = 'gcc',
  include_names = {
    '^mlir',
    '^MLIR',
    '^iree',
    '^IREE',
  }
}
]]

-- nldecl.generate_bindings_file{
--   output_file = 'dnnl.nelua',
--   parse_includes = {
--     '<oneapi/dnnl/dnnl.h>',
--     '<oneapi/dnnl/dnnl_debug.h>',
--   },
--   include_dirs = {
--     '/home/bart/apps/oneDNN/build/include'
--   },
--   parse_defines = {'_GNU_SOURCE'},
--   cc = 'gcc',
--   opaque_names = {
--     FILE=true,
--   },
--   include_names = {
--     '^dnnl_',
--     '^DNNL_',
--   }
-- }

-- nldecl.generate_bindings_file{
--   output_file = 'cxla.nelua',
--   parse_includes = {
--     '<cxla.h>',
--   },
--   include_dirs = {
--     '/home/bart/projects/nelua/nelua-ml/cxla'
--   },
--   cc = 'gcc',
--   include_names = {
--     '^cxla',
--     '^CXLA',
--   }
-- }

nldecl.generate_bindings_file{
  output_file = 'linux.nelua',
  parse_includes = {
    '<sys/mman.h>',
  },
  cc = 'gcc',
}

nldecl.generate_bindings_file{
  output_file = 'cartesi.nelua',
  parse_includes = {
    '<machine-c-api.h>',
  },
  include_dirs = {
    '/home/bart/projects/cartesi/corp/machine-emulator-sdk/emulator/src'
  },
  include_names = {
    '^cm',
    '^CM',
  },
  cc = 'gcc',
}