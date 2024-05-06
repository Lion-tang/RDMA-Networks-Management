# Remu: RDMA emulator

Remu is an emulator for RDMA (Remote Direct Memory Access) applications. It is designed to be used with the [Rust RDMA library],
which is a wrapper around the [libibverbs] library. The emulator is written in Rust and uses the [Capstone] disassembly framework.

## Environment

1. first, run `preparation.sh` to install dependencies and build the emulator

2. then, edit `./test/run.sh`

```
LINK_DEV=eth0 # edit your network interface to use for the link
```

> if you have run `./test/run.sh` before, you need comment following lines in `./test/run.sh`
>
> ```
> docker network create -d macvlan --subnet=$CONTAINER_NET --ip-range=$CONTAINER_NET -o macvlan_mode=bridge -o parent=$LINK_DEV $DOCKER_NETWORK
> sudo ip link add $LINK_DEV_NAME link $LINK_DEV type macvlan mode bridge
> sudo ip addr add $LINK_DEV_IP dev $LINK_DEV_NAME
> sudo ip link set $LINK_DEV_NAME up
> sudo ip route add ${CONTAINER_NET} dev $LINK_DEV_NAME
> ```

3. run `./test/run.sh` to start the emulator

## Usage

edit or add or delete `src/case/success/*.yaml` to define your own test case