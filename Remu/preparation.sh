# 停止脚本在遇到错误时继续运行
set -e
set -x

# Git 子模块更新
git submodule update --remote --recursive

# 检出 Scapy 代码
git clone https://github.com/secdev/scapy.git ./scapy

# 准备环境
sudo apt update
sudo apt install -y protobuf-compiler  net-tools librdmacm-dev ibverbs-utils rdmacm-utils perftest python3.10
python3 -m pip install grpcio grpcio-tools scapy black
pip install --upgrade protobuf
cargo install --version 2.25.0 protobuf-codegen
cargo install grpcio-compiler
./rdma-env-setup/scripts/setup.sh

# 编译
black --check $(find ./src -name "*.py")
./build_proto.sh
cargo build
docker build -t grpc-python3 ./test

# 运行
./test/run.sh
