# RDMA Driver and Commands for Mellanox NIC

- [Install Driver](#install-driver)
- [Install RDMA-Core (Optional, but Required for SoftRoCE Running on Linux OS)](#install-rdma-core)
- [RDMA Related Command](#rdma-related-command)
- [Usual Command Cases](#usual-command-cases)

## install driver

1. install iso or tgz

[Mellanox officiall driver site, click here.](https://developer.nvidia.com/networking/infiniband-software), download OFED for Linux, WinOF2 for Windows.

2. mount or unzip

Mount or unzip, if the downloaded file is iso using mount, while file is tgz using unzip, here is the mount command

```
sudo mount -o ro,loop MLNX_OFED_LINUX-5.0-2.1.8.0-ubuntu20.04-x86_64.iso /mnt
```

3. install

```
cd /mnt 
sudo ./mlnxofedinstall
```

4. restart

```
sudo /etc/init.d/openibd restart sudo /etc/init.d/opensmd restart
```

5. check NIC status

```
sudo hca_self_test.ofed
```

if there is no failed text, then install driver successfully

## install rdma-core
optional but required for SoftRoCE runnning on Linux OS:
```
sudo apt-get install libibverbs1 ibverbs-utils librdmacm1 libibumad3 ibverbs-providers rdma-core
sudo apt-get install iproute2
sudo apt-get install perftest  # for ib_write_bw, ib_write_lat, ib_read_bw, ib_read_lat
sudo modprobe rdma_rxe  # load rxe kernel module
sudo rdma link add rxe_0 type rxe netdev ens33 # rxe_0 is the name of rxe device, ens33 is the name of network card
rdma link # check rxe device status
```



## RDMA related command

```
Command	                         operation	                     
ibv_devinfo	                     show device info briefly	
ibv_devinfo -v	                 show device info in detail
ibv_devinfo -d  mlx4_0           output certain NIC device info briefly
ibv_devinfo -d  mlx4_0 -v        output certain NIC device info in detail
	
ibv_devices	                     list device	
ibvdev2netdev	                 show relationship betwwen device and network card	  

show_gids	                     show gid list	                      
show_drop	                     show port packet drop situation

ibstatus	                     query or modify network operating mode：Ethernet or IB
ibv_asyncwatch	                 monitor InfiniBand asynchronous event
ibstat 或 ibsysstat	            query InfiniBand device status or IB address system status

iblinkinfo.pl or iblinkinfo      Displays link information about all links in an optical fiber network	
sminfo or sminfo –help;          query IB SMInfo attribute	
hca_self_test.ofed	             RDMA network card self test
/etc/infiniband/info	         Mellanox OFED installed information	        
cat /etc/infiniband/openib.conf	 See the list of auto-loaded modules

lspci | grep Mellanox	         check whether Mellanox network card is installed and version
lspci | grep -i eth              display installed network card

rpm -qa|grep rdma-core           display rdma-core version
sudo /sbin/connectx_port_config -s  see current operating mode
sudo /sbin/connectx_port_config  switch current operating mode

/etc/init.d/openibd status       verify whether RDMA kernel module is loaded
lsmod                            see which modules are loaded
ofed_info                        show ofed package info
```

## Usual command cases

```
1. display GID
show_gids

2. show ofed package info 
ofed_info

3. check whether network card is installed
lspci | grep Mellanox

4. see netword card operating status
[root@rdma63 tcpdump]# ibv_devices
    device                 node GUID
    ------              ----------------
    mlx5_1              98039b03009a4296
    mlx5_0              98039b03009a2b3a


[root@rdma63 tcpdump]# ibv_devinfo mlx5_0
hca_id: mlx5_0
        transport:                      InfiniBand (0)
        fw_ver:                         16.29.1016
        node_guid:                      9803:9b03:009a:2b3a
        sys_image_guid:                 9803:9b03:009a:2b3a
        vendor_id:                      0x02c9
        vendor_part_id:                 4119
        hw_ver:                         0x0
        board_id:                       MT_0000000010
        phys_port_cnt:                  1
        Device ports:
                port:   1
                        state:                  PORT_ACTIVE (4)
                        max_mtu:                4096 (5)
                        active_mtu:             1024 (3)
                        sm_lid:                 0
                        port_lid:               0
                        port_lmc:               0x00
                        link_layer:             Ethernet

5. if want to see detail info of all devices
ibv_devinfo -v

6. see network card mapping relationship 
[root@rdma64 ibdump-master]# ibdev2netdev
mlx5_0 port 1 ==> eth18-0 (Up)
mlx5_1 port 1 ==> ib3b-0 (Up)

switch operating mode(IB / Ethernet)
[root@rdma64 ibdump-master]# ibstatus
Infiniband device 'mlx5_0' port 1 status:
        default gid:     fe80:0000:0000:0000:063f:72ff:fefb:8d7c
        base lid:        0x0
        sm lid:          0x0
        state:           4: ACTIVE
        phys state:      5: LinkUp
        rate:            25 Gb/sec (1X EDR)
        link_layer:      Ethernet
        
As you can see, the network card is now in Ethernet mode, if you want to switch to infiniband mode

[root@rdma64 ibdump-master]# sudo /sbin/connectx_port_config

Use the following command to verify:
[root@rdma64 ibdump-master]# sudo /sbin/connectx_port_config -s

```

