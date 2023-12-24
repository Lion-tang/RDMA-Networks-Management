- [问题 Q](#问题-q)
    - [概述](#q-概述)
    - [基本元素](#q-基本元素)
    - [操作类型](#q-操作类型)
    - [传输模式](#q-传输模式)
    - [TCP建链](#q-tcp建链)
    - [Protection Domain](#q-protection-domain)
    - [Memory Region](#q-memory-region)
    - [Queue Pair](#q-queue-pair)
    - [Completion Queue](#q-completion-queue)
    - [Address Handle](#q-address-handle)
    - [Memory Window](#q-memory-window)
    - [QP Buffer](#q-qp-buffer)
- [回答 A](#回答-a)
    - [概述](#a-概述)
    - [基本元素](#a-基本元素)
    - [操作类型](#a-操作类型)
    - [传输模式](#a-传输模式)
    - [TCP建链](#a-tcp建链)
    - [Protection Domain](#a-protection-domain)
    - [Memory Region](#a-memory-region)
    - [Queue Pair](#a-queue-pair)
    - [Completion Queue](#a-completion-queue)
    - [Address Handle](#a-address-handle)
    - [Memory Window](#a-memory-window)
    - [QP Buffer](#a-qp-buffer)

《RDMA杂谈》专栏目前是RDMA科普文章中质量最好的刊栏了，作者从RDMA技术的背景、基础资源知识、模拟程序的安装、内存地址基础、Buffer 工作机制等角度由浅入深地介绍了 RDMA。本说明旨在从一个普通读者的角度，记录阅读《RDMA杂谈》之后的思考和问题，通过这些问题，读者可以思考并检验一下对 RDMA 的理解程度，毕竟阅读之后要有一定的思考才能内化为自己的理解。



接下来将按照《RDMA杂谈》的专栏的介绍顺序



# 问题 Q

## Q 概述

1. RDMA 优势是什么？
2. RDMA 具体实现协议有哪些？
3. RDMA 社区的两个子仓库是什么？分别有什么作用
4. 目前硬件厂商有哪些？



## Q 基本元素

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

## Q 操作类型

1. 有几种操作类型？
2. [基本元素](#基本元素)最后描述了Send/Recv流程，Write/Read的具体流程读者可以类比，但由于Write/Read是单端操作，和Send/Recv双端操作存在差异。具体在操作类型的流程上，差异是什么？

## Q 传输模式

1. 有几种常见的传输模式？
2. 几种传输模式支持的操作类型是怎样的？

## Q TCP建链

1. 建链是什么？
2. 有哪些建链方式？
3. 为什么要建链？
4. 怎么建链？

## Q Protection Domain

1. PD是什么？
2. 为什么要用PD？
3. 怎么使用PD？

## Q Memory Region

1. MR是什么？
2. 为什么要使用MR？
3. 怎么使用MR？

## Q Queue Pair

1. 了解QP之前先了解什么是QPC?
2. QP是什么？
3. 为什么要使用QP?
4. 怎么使用QP？

## Q Completion Queue

1. 什么是CQ？
2. WQ和CQ之间的对应关系是什么？一对一还是一对多，还是多对多？
3. CQE是什么？
4. CQC是什么？
5. 为什么要使用CQ？
6. 怎么使用CQ？
7. 能否不产生CQE？
8. CQ 错误类型有哪些？
9. CQ的处理方式有哪些？

## Q Address Handle

1. AH 是什么？
2. 为什么要使用AH？
3. 怎么使用AH？

## Q Memory Window

1. MW是什么？
2. 为什么要使用MW?
3. 使用MW时，对MR有什么权限要求？
4. MW有几种类型？
5. 怎么使用MW?
6. MW如何回收rkey？

## Q Memory Basis

1. MMIO 是什么？
2. 外设如何DMA访问内存？如果启用IO虚拟地址后，外设又是如何访问内存的？

## Q QP Buffer

1. QPC等信息是存在RNIC中还是内存？
2. RNIC 如何创建一个自己看得懂的 QPC？（控制路径） 
3. RNIC 如何从内存中 DMA 取出一个 WQE？（数据路径）

# 回答 A

## A 概述

1. 【内核bypass】 和【CPU卸载】，相比于传统以太网，RDMA技术同时做到了**更高带宽**和**更低时延**

2. Infiniband, RoCE(v1,v2), iWarp
3. Rdma-core【用户态核心代码】，perftest【强大的测试RDMA性能工具】
4. Mellanox【IB领头羊】，华为鲲鹏【国内领先地位】



## A 基本元素

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



## A 操作类型

1. Send, Recv, Write, Read

2. Send/Recv 组合的操作类型流程接收端会产生WQE和CQE， Write/Read 接收端不会产生WQE和CQE，事实上，WQE由软件产生，CQE由硬件产生，都存储在DDR内存，详情参考【QP Buffer】

## A 传输模式（服务类型）

1. 服务稳定性（Reliability）和连接类型（Conection）两两组合形成RC/RD/UC/UD。连接类型服务会收到 ACK, 无连接类型不会收到ACK

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



## A TCP建链

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

## A Protection Domain

1. PD实际是一组资源集合（容器），例如一个PD包含了MR1,MR2, QP1,QP2。QP3并不能使用MR1，因为不在一个PD集合内。注意PD中MR和QP没有绑定关系，就是说MR1可以给QP1的WQE用，也可以给QP2的WQE用。另外注意，PD是**本地概念**，仅存在于节点内部，也就是说PD对远程节点来说是**不可见的**。但是MR是对远程节点可见的。
2. 使用PD能够对资源做到隔离，目前现代攻击里面大多都是针对一个PD内多种资源的越权访问，因此最安全的情景是，一个PD，一个MR，一个QP。
3. 使用`ibv_alloc_pd()`，IB协议中规定：**每个节点都至少要有一个PD，每个QP都必须属于一个PD，每个MR也必须属于一个PD。**

## A Memory Region

1. MR其实是驱动注册的一块内存区域，用于收发数据的。下发一个WQE，其中包含的sge用于指定该WQE使用的内存地址，该地址应该在MR范围内。
2. 1. 让硬件知道VA to PA 的转换。CPU的VA直接给硬件硬件是看不懂的，硬件会创建一个他看得懂的VA to PA 映射表
     2. MR约束硬件访问内存的范围
     3. **Pin**住这块内存，保持虚拟地址到物理地址的映射关系。防止换页后，硬件不知道物理页更换，继续对换页后的物理内存操作
3. `ibv_reg_mr()` 注册MR，需要指定所属PD

## A Queue Pair

1. QPC是QP的上下文（Queue Pair Context），**主要给硬件看，用来同步软硬之间同步的QP信息**，方便硬件直接操作内存，比如QP Buffer 的DMA地址，本地QPN，max_send_wr, max_recv_wr, max_send_sge, max_recv_sge 这些信息
2. QP是工作队列，每个QP有个编号QPN（一般最大2^24个)。QP0和QP1用于特殊保留用途，QP0用于子网管理接口SMI。QP1用于通用服务接口GSI，其中最常用的服务就是CM建链。一个QP分为WQ,CQ, WQ细分为SQ和RQ
3. 本人理解类似于TCP多个端口一样，RDMA每个QP就标识一个RDMA服务，并且以QP为单位进行读、写、以及即将介绍的任务完成(CQ)更方便管理
4. `ibv_create_qp(pd, qp_attr)`，创建QP后需要将QP修改为可工作状态
    1. RST(Reset)，create之后就处于这个状态，这个状态的QP什么都做不了
    2. INIT(initialized)，可以Post Receive WR，收到消息不会被处理，会被默认丢弃。如果用户下发Post Send WR，会报错。这个阶段指定QP访问的**Flags**
    3. RTR(Ready to Receive)在INIT基础上可以处理接收到的消息，将WQE数据搬到Recv sge指定的内存位置，即RQ可以正常工作，这个时候需要指定 **DestQPN, PSN, DestLID, DestGID**。这个状态SQ仍然不能工作
    4. RTS(Ready to Send)，在RTR基础上，SQ可以正常工作，即用户可以Post Send WR，这个时候需要指定 **timeout, retry_cnt, rnr_retry**
    5. SQD(Send Queue Drain)，SQ排空状态，把现有SQ队列所有没处理的WQE全部处理掉，APP可以下发新的WQE，但是得等到旧的WQE全处理后才会被处理
    6. SQE(Send Queue Error)，SQ错误状态，仅限RTS和SQD发生Send WR Completion Error才会转变到SQE
    7. ERR，错误状态，INIT, RTR,RTS, SQD发生处理错误或者SQE 产生Receive WR Completion Error or Async Error 会进入该状态。如果QP进入该状态，QP会停止处理所有WQE, 已经处理到一半的WQE也会停止。上层需要在修复错误后将QP重新切换到RTS初始状态。

## A Completion Queue

1. Completion Queue(CQ) 可以看作任务完成队列，通常一个QP包含一个SQ, RQ, CQ，也就是说一个QP中SQ和RQ的CQ是同一个

2. 一对多的关系。**每个WQ都必须关联一个CQ，而每个CQ可以关联多个SQ和RQ**。**同一个WQ中的WQE，其对应的CQE间是保序的**，**不同WQ中的WQE，其对应的CQE间是不保序的**

3. Completion Queue Entry/Element(CQE) ，每一个 WQE完成后会产生一个对应的 CQE 放到CQ中，用户态驱动将CQE解析并转换为 WC 告知APP

4. CQC类似于QPC，是放在内存中记录CQ DMA地址、容量、CQN（CQN类似于QPN）的数据。用于给硬件看的。

5. 事实上CQ是用于说明WQ完成的情况，以此来判断WQ是否正常执行。每一个CQE包含了WQE指定的QPN, WR ID。WR 操作类型，opcode。本次任务执行成功/失败，如果失败，那原因是什么，即status和错误码。

6. `wr.send_flags = IBV_SEND_SIGNALED` 则声明WR将产生WC。

7. 处理WQ的完成情况是需要消耗资源的。首先是RNIC需要产生CQE，其次是poll CQ，最后读取WC并检查其状态。减少WC的处理是能够减少APP CPU使用情况的。RDMA用户态支持声明不产生CQE，名为Unsignal Completion Queue。具体使用方法有两步。1.创建QP时，确保QP的 `ibv_qp_init_attr.sq_sig_all = 0`，这一个属性确保QP支持Unsignal Completion。2. 每一次post Send WR时，`wr.send_flags = 0` ，WC将不会产生（如果Send WR Error，还是会产生WC，并且是Send WR Completion Error)。

8. 三种错误类型，**立即错误**（immediate error）、**完成错误**（Completion Error）以及**异步错误**（Asynchronous Errors)。举例子说明：

    1. 立即错误。用户在Post Send时传入了非法的操作码，比如想在UD的时候使用RDMA WRITE操作。结果：产生**立即错误**（有的厂商在这种情况会产生完成错误）一般这种情况下，驱动程序会直接退出post send流程，并返回错误码给上层用户。注意此时WQE还没有下发到硬件就返回了
    2. 完成错误。用户下发了一个WQE，操作类型为SEND，但是长时间没有收到对方的ACK。结果：产生**完成错误**，因为WQE已经到达了硬件，所以硬件会产生对应的CQE，CQE中包含超时未响应的错误详情
    3. 异步错误。用户态下发了多个WQE，所以硬件会产生多个CQE，但是软件一直没有从CQ中取走CQE，导致CQ溢出。结果：产生**异步错误**，因为软件一直没取CQE，所以自然不会从CQE中得到信息。此时IB框架会调用软件注册的事件处理函数，来通知用户处理当前的错误。

    可以看出错误检测的基本原则是WQE下发前的错误，那就是**立即错误**， 如果是ACK异常或者WQE下发之后的错误就是**完成错误**，如果是溢出等错误，则是**异步错误**。

    几种常见的**完成错误**：

    - RC服务类型的SQ完成错误

- Local Protection Error
        本地保护域错误。本地WQE中指定的数据内存地址的MR不合法，即用户试图使用一片未注册的内存中的数据。
    - Remote Access Error
        远端权限错误。本端没有权限读/写指定的对端内存地址。
    - Transport Retry Counter Exceeded Error
        重传超次错误。对端一直未回复正确的ACK，导致本端多次重传，超过了预设的次数。
    - RC服务类型的RQ完成错误
    - Local Access Error
        本地访问错误。说明对端试图写入其没有权限写入的内存区域。
    - Local Length Error
        本地长度错误。本地RQ没有足够的空间来接收对端发送的数据。

9. IB给上层用户两种处理CQ的方式，**中断**和**轮询**， 中断则是CPU保护现场，停下来处理CQE，处理完后，跳回CPU现场。轮询是隔一段时间CPU检查网卡是否有CQE，有CQE，就把缓冲区的CQE带出来处理。通常还是轮询用的多一些。两种上层接口 poll 和 notification, 对应着轮询和中断模式。

## A Address Handle

1. AH全称为Address Handle， RC的对端信息是创建QP的时候存储在QPC中的。UD的QP间没有连接关系，QP想发给谁就发给谁，所以WQE中有一个地址簿用于查询对端的信息，每次通过一个索引来指定地址簿中的一个地址信息，这个索引就是AH。
2. IB协议中并没有对为什么使用AH做出解释。不过猜测是向用户隐藏底层地址细节等。
3. 每次在wr中指定ah，`wr.wr.ud.ah` 设定之后，还需要设定`wr.wr.ud.remote_qpn`和`wr.wr.ud.remote_qkey`

## A Memory Window

1. Memory Window简称MW，每个MW都会绑定（称为bind）在一个已经注册的MR上，但是它相比于MR可以提供更灵活的权限控制。一个MR上可以划分出很多MW，每个MW都可以设置自己的权限。MW/MR根据本端/对端和读/写两两组合形成了4种权限：

|       | Local       | Remote       |
| ----- | ----------- | ------------ |
| Read  | Local Read  | Remote Read  |
| Write | Local Write | Remote Write |

2. MR是内核管理的，想要修改一个已经存在MR的耗时较长。MW在创建好之后，可以通过数据路径（即通过用户态直接下发WR到硬件的方式）动态的绑定到一个已经注册的MR上，并同时设置或者更改其访问权限，这个过程的速度远远超过重新注册MR的过程。安全性方面，目前现有的RDMA权限类攻击使用MW都是可以避免的，但是注意，每个MW会存储MW对应的rkey和QPN。
3. **如果想要给MW配置远程写或者远程原子操作（Atomic）权限，那么它绑定到的MR必须有本地写权限，其他情况下两者权限互不干扰**：远端用户用MW，就要遵循MW的权限配置；远端用户用MR，就要遵循MR的权限配置。
4. 在具体Bind之前要介绍两种MW,简单来说MW Type1是rkey的key由硬件控制，所以不能自行调用invalidate 销毁rkey，只能重新Bind，原来的rkey自动销毁。MW Type2是用户控制rkey的key段，Type2 支持invalidate 让一个rkey失效，要重新分配一个rkey到一个MW，必须先Invalidate。IB规范支持多个Type1 或 多个Type2 MW绑定到同一个MR，并且范围可以相互覆盖。
5. 要使用MW，首先要注册MW（控制面），其次是绑定MW到MR(数据面)。控制面支持增删查，Allocate MW, Deallocate MW, Query MW。数据面有两类接口Bind和Invalidate，Bind是将MW绑定到一个已经注册的MR指定范围上，并配置想要的权限。绑定的结果会产生一个rkey。如果一个MR还有被绑定的MW，那么这个MR是不能被取消注册的。Bind有两种方式，Post Send Bind MW WR只适用于Type2 MW。 Bind MW 实际上在Post Send Bind MW WR外面封了一层，这种方式仅适用于Type1 MW。下表是两种方式的区别。

|                      | Bind MW（for Type1 MW) | Post Send Bind MW WR (for Type2 MW) |
| -------------------- | ---------------------- | ----------------------------------- |
| 准备WR参数           | ✅                      | -                                   |
| 下发WR               | ✅                      | ✅                                   |
| 返回key（index部分） | ✅                      | -                                   |

6. Invalidate是上个问题中数据面的一类接口，同时也是回收rkey的接口， 只适用于 Type2 MW。**Invalidate操作的对象是R_Key而不是MW本身**，即Invalidate之后的效果是：远端用户无法再使用这个R_Key访问对应的MW，而**MW资源仍然存在**，以后仍然可以生成新的R_Key给远端使用。根据 invalidate发起方不同，Post Send Bind MW WR 可以让本地或远端的MW rkey 被 invalidate 掉。

## A Memory Basis

1. MMIO是CPU访问PCIe外设的机制。CPU发起对MMIO地址的读写操作时，会被PCIe控制器接管，然后转化为对PCIe总线上连接的设备的访问请求。最终是读写外设寄存器还是外设内部存储空间，是由设备注册时的配置决定的。

2. 没有启用虚拟IO时（IOVA)，外设访问流程如下：

    1. 通过 PCIe Bus Address 访问PCIe RC，转化为 Physical Address(PA)
    2. 通过PA访问内存

    启用虚拟IO时（IOVA），外设访问流程如下：

    1. 通过IOVA访问 IOMMU(x86平台)/SMMU(ARM平台)转化为 PCIe Bus Address
    2. 通过 PCIe Bus Address 访问 PCIe RC，转化为 Physical Address(PA)
    3. 通过PA访问内存

    IOVA的访问流程可能有第二种实现流程，步骤1和步骤2对掉，即先通过 PCIe Bus Address 访问 PCIe RC 转化为 IOVA 后，再访问 IOMMU/SMMU 转化为 PA 去访存。

    为了简单读写过程，其实可以理解PCIe外设通常直接通过PA或通过IOVA转化为PA后访存。一般情况下外设发出的总线地址的值等于物理地址，我们可以认为外设发出的就是物理地址。

## A QP Buffer

在回答 QP Buffer 问题前先说明两个比较重要的概念，QP Buffer 创建后全过程由 RNIC 使用，用户不需要关心和处理 QP Buffer。

QP Buffer 和 MR Buffer 等由 RNIC 使用的 Buffer 必须 Pin 住（锁页），旨在防止换页后 RNIC 访问未知应用的地址空间。

QP创建好后的所有Buffer如下图所示：

![QP_Buffer1](https://github.com/Lion-tang/Remu-and-protection-in-RDMA/blob/master/images/QP_Buffer1.png)

部分厂商在组织DMA Buffer Table时，固定了Buffer长度，因此将每个Buffer的长度放入QPC中，这样就不用在Buffer Table中多次记录不等长的Buffer长度了。

![QP_Buffer1](https://github.com/Lion-tang/Remu-and-protection-in-RDMA/blob/master/images/QP_Buffer2.png)

当然，Buffer Table也支持类似多级页表的多层次划分。一级Buffer Table下可再细分到二级Buffer Table。

![QP_Buffer1](https://github.com/Lion-tang/Remu-and-protection-in-RDMA/blob/master/images/QP_Buffer3.png)

1. QP Buffer 是存在内存中，但是组织方式是给RNIC看的DMA地址，即IOVA或PA。RNIC不能直接通过VA去访问内存，VA是给用户看的，和DMA地址不在一个地址空间
2. 创建QPC必将陷入内核态，因为创建Buffer，Pin页的过程是由内核完成的，总的QP Buffer创建流程如下（控制路径）：
    1. 用户APP调用`ibv_create_qp()`，用户态驱动申请虚拟内存，陷入内核态
    2. 内核态获取Buffer信息，映射并Pin住物理页，获取DMA地址，组织DMA地址为Buffer Table
    3. 填写QPC，内核态通知硬件关联QPN和已创建的QPC信息
3. 使用QP时，只需要用户态驱动参与，这也是RDMA绕过内核态直接下发数据包的优势所在，总的QP Buffer使用流程如下（数据路径）：
    1. 用户APP下发`ibv_post_send()`， 用户态驱动将WR转化为WQE，填写WQE到Queue Buffer，批量敲 DoorBell（让PCIe外设一次性DMA处理），DoorBell中包含了QPN和WQE偏移个数，偏移量用于计算WQE地址：**Buffer起始地址+每个WQE大小*偏移个数**
    2. 硬件解析DoorBell中的QPN和WQE偏移个数，从QPC中获取到物理Buffer，获取并解析Buffer中的WQE（解析WQE在于需要把WQE按照和软件协商的格式提取数据，最后配合一些其他信息（比如QPC控制信息），就可以组装出一个完整数据包发出去了）

请读者牢记，QP Buffer的创建和使用都是为了方便硬件直接工作，驱动会配合好硬件完成这部分工作。因此用户无需关心如何处理QP Buffer 和 WQE，把它当成黑盒直接使用即可

