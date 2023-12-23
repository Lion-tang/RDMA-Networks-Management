# RDMA Networks Management: Unveiling Vulnerabilities, Cryptographic Enhancement
RDMA emulator(Remu) is an emulator for RDMA (Remote Direct Memory Access) applications. It is designed to be used with the [Rust RDMA library], which is a wrapper around the [libibverbs] library. Remu fabricates packets by Python [Scapy] library. The emulator is written in Rust/Python and uses the [Capstone] disassembly framework.

Privacy enhanced technology for secure RDMA(PETSRDMA) is a framework operating in SmartNIC that provides a secure RDMA connection. It provides various cryptographic primitives to protect RDMA connections. The full list of supported security codes is available at `security/security.hpp`.

RDMA_Driver_And_Commands.md is a summary of RDMA related commands and steps required in installing driver for Mellanox NIC RDMA.

RDMA_Talks.md is a summary of RDMA related questions, involving all kinds of RDMA resources. It is a good start point for RDMA beginners. And tring to answer the questions will help beginners to understand RDMA better. For more details, please refer to IB Specification and RDMA Aware Programming User Manual.