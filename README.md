# llama-cpp-intel-npu

Initial Attempt to leverage native AI capabilities in the Intel Untra Core 7 chipset

```bash
cat << EOF > /etc/yum.repos.d/oneAPI.repo
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

dnf install -y lspci clinfo intel-opencl g++ cmake git tar libcurl-devel intel-oneapi-base-toolkit

git clone https://github.com/ggerganov/llama.cpp.git -b b4523
cd llama.cpp
mkdir -p build
cd build
source /opt/intel/oneapi/setvars.sh
cmake .. -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DLLAMA_CURL=ON -DGGML_CCACHE=OFF -DGGML_NATIVE=ON 
cmake --build . --config Release -j -v
cmake --install .

firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib64:/usr/local/lib/

llama-server --model granite-code:3b --host 0.0.0.0 --n-gpu-layers 999 --flash-attn --ctx-size 32768
```

# Notes - 

--offload-new-driver

```bash
tee > /etc/yum.repos.d/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

dnf install intel-oneapi-base-toolkit

dnf install -y libgudev-devel g++ cmake git kernel-devel lspci clinfo intel-level-zero oneapi-level-zero oneapi-level-zero-devel intel-igc-devel.x86_64 intel-gmmlib-devel ninja-build  intel-opencl-clang-devel libcurl-devel intel-opencl mesa-dri-drivers mesa-vulkan-drivers mesa-vdpau-drivers mesa-libEGL mesa-libgbm mesa-libGL mesa-libxatracker libvpl-tools libva libva-utils intel-gmmlib intel-ocloc intel-metee intel-metee-devel

lspci -nn |grep  -Ei 'VGA|DISPLAY'
lspci -nn |grep  -i accel

git clone https://github.com/intel/linux-npu-driver.git
cd linux-npu-driver/
git submodule update --init --recursive
cmake -B build -S .
cmake --build build --parallel $(nproc)
cmake --install build --prefix /usr
rmmod intel_vpu
modprobe intel_vpu

git clone https://github.com/intel/compute-runtime.git -b releases/24.52

mkdir compute-runtime/build
cd compute-runtime/build
cmake -DCMAKE_BUILD_TYPE=Release -DNEO_SKIP_UNIT_TESTS=1 ../
make -j`nproc`
make install

git clone https://github.com/ggerganov/llama.cpp.git -b b4502
cd llama.cpp
mkdir -p build
cd build
source /opt/intel/oneapi/setvars.sh
cmake .. -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DGGML_SYCL_F16=ON -DLLAMA_CURL=ON -DGGML_CCACHE=OFF 
cmake --build . --config Release -j -v

firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

./bin/llama-server --model granite-code:3b --model-url ollama://granite-code:3b --host 0.0.0.0
```

```
intel-media libmfxgen1 libvpl2 level-zero intel-level-zero-gpu mesa-libxatracker libvpl-tools intel-metrics-discovery intel-metrics-library intel-igc-core intel-igc-cm libmetee intel-gsc

cmake -B build -DGGML_NATIVE=OFF -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DLLAMA_CURL=ON -DGGML_CCACHE=OFF

-DBUILD_SHARED_LIBS=OFF

-DGGML_NATIVE=OFF -DBUILD_SHARED_LIBS=OFF

-DGGML_SYCL_DEVICE_ARCH=mtl_h -DCXX_FLAGS="--offload-new-driver"

-- Installing: /etc/OpenCL/vendors/intel.icd
-- Installing: /usr/local/bin/ocloc-24.52.1
-- Installing: /usr/local/lib64/libocloc.so
-- Installing: /usr/local/include/ocloc_api.h
-- Installing: /usr/local/lib64/intel-opencl/libigdrcl.so
```
