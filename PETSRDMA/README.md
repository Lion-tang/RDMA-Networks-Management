# PETSRDMA
privacy enhanced technology for secure RDMA. 

## Required hardware and software
 * Two SmartNICs running linux (e.g. ConnectX or BroadCom with OS and ability to execute arbitrary code).
 * rdma-core: RDMA Core Userspace Libraries 
 * openssl: a general-purpose cryptography library.
 
## Building
The whole project can be compiled using a single `Makefile`.
The makefile should be  manually configured by changing the absolute path to openssl.
sRDMA depends on [openssl 1.1.1f](https://www.openssl.org/source/old/1.1.1/openssl-1.1.1f.tar.gz)

### SmartNICs
The code for smartnics is located in `nic*`.


## Running the benchmarks
Refer to the bash scripts `./SCRIPT.sh --help`. 
To run all the experiments from the paper, one can use `./all_tests.sh`.
Please change IP addresses of hosts and nics in shell scripts to match your setup.

### Security codes
PETSRDMA supports various security codes to protect RDMA connections. The full list of supported security codes is available at
`security/security.hpp`.

## PETSRDMA connection logic
Each script launches applications in the following order:
 * smartnic1
 * smartnic2
 * host2
 * host1

The connection logic is as follows:
host1 <---> smartnic1 <---> smartnic2 <---> host2