《RDMA杂谈》专栏目前是国内RDMA科普文章中质量最好的刊栏了，作者从RDMA技术的背景、基础资源知识、模拟程序的安装、内存地址基础、Buffer 工作机制等角度由浅入深地介绍了 RDMA。本说明旨在从一个普通读者的角度，记录阅读《RDMA杂谈》之后的思考和问题，通过这些问题，读者可以思考并检验一下对 RDMA 的理解程度，毕竟阅读之后要有一定的思考才能内化为自己的理解。



接下来将按照《RDMA杂谈》的专栏的介绍顺序

# 问题 Q

## 概述

1. RDMA 优势是什么？
2. RDMA 具体实现协议有哪些？
3. RDMA 社区的两个子仓库是什么？分别有什么作用
4. 目前硬件厂商有哪些？



## 基本元素

| 缩写 | 全称                           |
| ---- | ------------------------------ |
| WQ   | Work Queue                     |
| WQE  | Work Queue Entry/Element       |
| QP   | Queue pair                     |
| SQ   | Send Queue                     |
| RQ   | Receive Queue                  |
| SRQ  | Shared Receive Queue           |
| CQ   | Completion Queue               |
| CQE  | Completion Queue Entry/Element |
| WR   | Work Request                   |
| WC   | Work Completion                |

1. WQ和WQE， CQ和CQE是容器和元素的关系，那能否描述WQE从软件下发到硬件的流程（无需考虑 Buffer）
2. 描述一个完整 Send/Recv 流程

## RDMA 操作类型

1. 有几种操作类型？
2. [基本元素](#基本元素)最后描述了Send/Recv流程，Write/Read的具体流程读者可以类比，但由于Write/Read是单端操作，和Send/Recv双端操作存在差异。具体在操作类型的流程上，差异是什么？

## RDMA 传输模式（服务类型）

1. 有几种常见的传输模式？
2. 几种传输模式支持的操作类型是怎样的？

## 建链（TCP）

1. 建链是什么？
2. 有哪些建链方式？
3. 为什么要建链？
4. 怎么建链？

## Protection Domain(PD)

1. PD是什么？
2. 为什么要用PD？
3. 怎么使用PD？

## Memory Region(MR)

1. MR是什么？
2. 为什么要使用MR？
3. 怎么使用MR？

## Queue Pair(QP)

1. 了解QP之前先了解什么是QPC?
2. QP是什么？
3. 为什么要使用QP?
4. 怎么使用QP？

## Completion Queue(CQ)

1. 什么是CQ？
2. CQE是什么？
3. 为什么要使用CQ？
4. 怎么使用CQ？

## Address Handle



## Memory Window(MW)



# 回答 A

## 概述

1. 【内核bypass】 和【CPU卸载】，相比于传统以太网，RDMA技术同时做到了**更高带宽**和**更低时延**

2. Infiniband, RoCE(v1,v2), iWarp
3. Rdma-core【用户态核心代码】，perftest【强大的测试RDMA性能工具】
4. Mellanox【IB领头羊】，华为鲲鹏【国内领先地位】



## 基本元素

1. 以WQ和WQE为例，软件(APP)发起 WR，用户驱动转化为 WQE后放入WQ中，硬件从WQ中取出WQE工作

2. >1. 接收端APP以WQE的形式下发一次RECV任务到RQ。
    >2. 发送端APP以WQE的形式下发一次SEND任务到SQ。
    >3. 发送端硬件从SQ中拿到任务书，从内存中拿到待发送数据，组装数据包。
    >4. 发送端网卡将数据包通过物理链路发送给接收端网卡。
    >5. 接收端收到数据，进行校验后回复ACK报文给发送端。
    >6. 接收端硬件从RQ中取出一个任务书（WQE）。
    >7. 接收端硬件将数据放到WQE中指定的位置，然后生成“任务报告”CQE，放置到CQ中。
    >8. 接收端APP取得任务完成信息。
    >9. 发送端网卡收到ACK后，生成CQE，放置到CQ中。
    >10. 发送端APP取得任务完成信息。



## 操作类型

1. Send, Recv, Write, Read

2. Send/Recv 组合的操作类型流程接收端会产生WQE和CQE， Write/Read 接收端不会产生WQE和CQE，事实上，WQE由软件产生，CQE由硬件产生，都存储在DDR内存，详情参考【QP Buffer】

## 传输模式（服务类型）

1. 服务稳定性（Reliability）和连接类型（Conection）两两组合形成RC/RD/UC/UD。

|                  | 可靠（Reliable）        | 不可靠（Unreliable）     |
| ---------------- | ----------------------- | ------------------------ |
| 连接(Conection)  | RC(Reliable Connection) | UC(Unreliable Conection) |
| 数据报(Datagram) | RD(Reliable Datagram)   | UD(Unreliable Datagram)  |

2. 事实上，目前RD还没有硬件支持，Atomic是全新的一种操作类型，但是并不常见，了解即可

|      | Send | Receive | Write | Read | Atomic |
| ---- | ---- | ------- | ----- | ---- | ------ |
| RC   | ✅    | ✅       | ✅     | ✅    | ✅      |
| RD   | ✅    | ✅       | ✅     | ✅    | ✅      |
| UC   | ✅    | ✅       | ✅     | -    | -      |
| UD   | ✅    | ✅       | -     | -    | -      |



## 建链（TCP）

1. RDMA建链指的是控制链，也就是说发送数据前的必要信息的准备。
2. 建链工作可以由TCP，也可以由CM(comunication message protocol)完成，甚至两个机器如果就在面对面，可以靠人吼一声把必要信息填上也行。
3. 由于RDMA涉及对远端内存直接操作，因此需要知道远端诸如内存之类的必要信息，所以在通信前控制链路一定要拿到这些信息才能启动后续的数据链路。
4. 建链传输的内容如下（没有写LID(Local Identifier)，这个只是IB链路层地址，RoCEv2不需要，值为0）：

| content | full name         | RC Send | RC Write/Read | UD Send |
| ------- | ----------------- | ------- | ------------- | ------- |
| GID     | Global Identifier | ✅       | ✅             | ✅       |
| QPN     | Queue Pair Number | ✅       | ✅             | ✅       |
| VA      | Virtual Address   |         | ✅             |         |
| r_key   | Remote key        |         | ✅             |         |
| Q_key   | Queue key         |         |               | ✅       |

## Protection Domain(PD)

1. PD实际是一组资源集合（容器），例如一个PD包含了MR1,MR2, QP1,QP2。QP3并不能使用MR1，因为不在一个PD集合内。注意PD中MR和QP没有绑定关系，就是说MR1可以给QP1的WQE用，也可以给QP2的WQE用。另外注意，PD是**本地概念**，仅存在于节点内部，也就是说PD对远程节点来说是**不可见的**。但是MR是对远程节点可见的。
2. 使用PD能够对资源做到隔离，目前现代攻击里面大多都是针对一个PD内多种资源的越权访问，因此最安全的情景是，一个PD，一个MR，一个QP。
3. 使用`ibv_alloc_pd()`，IB协议中规定：**每个节点都至少要有一个PD，每个QP都必须属于一个PD，每个MR也必须属于一个PD。**

## Memory Region(MR)

1. MR其实是驱动注册的一块内存区域，用于收发数据的。下发一个WQE，其中包含的sge用于指定该WQE使用的内存地址，该地址应该在MR范围内。
2. 1. 让硬件知道VA to PA 的转换。CPU的VA直接给硬件硬件是看不懂的，硬件会创建一个他看得懂的VA to PA 映射表
    2. MR约束硬件访问内存的范围
    3. **Pin**住这块内存，保持虚拟地址到物理地址的映射关系。防止换页后，硬件不知道物理页更换，继续对换页后的物理内存操作
3. `ibv_reg_mr()` 注册MR，需要指定所属PD

## Queue Pair(QP)

1. QPC是QP的上下文（Queue Pair Context），**主要给硬件看，用来同步软硬之间同步的QP信息**，方便硬件直接操作内存，比如QP Buffer 的DMA地址，本地QPN，max_send_wr, max_recv_wr, max_send_sge, max_recv_sge 这些信息
2. QP是工作队列，每个QP有个编号QPN（一般最大2^24个), 一个QP分为WQ,CQ, WQ细分为SQ和RQ
3. 本人理解类似于TCP多个端口一样，RDMA每个QP就标识一个RDMA服务，并且以QP为单位进行读、写、以及即将介绍的任务完成(CQ)更方便管理
4. `ibv_create_qp(pd, qp_attr)`，创建QP后需要将QP修改为可工作状态
    1. RST(Reset)，create之后就处于这个状态，这个状态的QP什么都做不了
    2. INIT(initialized)，可以Post Receive WR，收到消息不会被处理，会被默认丢弃。如果用户下发Post Send WR，会报错。这个阶段指定QP访问的**Flags**
    3. RTR(Ready to Receive)在INIT基础上可以处理接收到的消息，将WQE数据搬到Recv sge指定的内存位置，即RQ可以正常工作，这个时候需要指定 **DestQPN, PSN, DestLID, DestGID**。这个状态SQ仍然不能工作
    4. 在RTR基础上，SQ可以正常工作，即用户可以Post Send WR，这个时候需要指定 **timeout, retry_cnt, rnr_retry**

## Completion Queue(CQ)



## Address Handle



## Memory Window(MW)

