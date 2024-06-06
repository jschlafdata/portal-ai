---
sidebar_position: 3
---

# Understanding Virtual Machines

![how vms work](/img/how-virtual-machines-work/azure_data_center.png)


### Virtual Machines (VMs):

Virtual machines are essentially software emulations of physical computers. They allow you to run multiple operating systems on a single physical machine, which is called the host machine. Each virtual machine acts as an independent computer with its own virtualized hardware components, such as CPU, RAM, storage, and network interfaces.
Here's how they work:

1. Hypervisor: A hypervisor, also known as a virtual machine monitor (VMM), is a software or firmware that creates and runs virtual machines. It sits between the physical hardware and the virtual machines. There are two types of hypervisors:
    - Type 1 (Bare-metal): This type of hypervisor runs directly on the host's hardware to control the hardware and to manage guest operating systems. Examples include VMware ESXi, Microsoft Hyper-V, and Xen.
    - Type 2 (Hosted): This type of hypervisor runs on top of a conventional operating system, such as Windows or Linux. Examples include VMware Workstation, Oracle VirtualBox, and Parallels Desktop.
2. Guest OS: Each virtual machine runs its own guest operating system, which can be different from the host operating system. Common guest operating systems include various versions of Windows, Linux distributions, and others.
3. Virtual Hardware: The hypervisor emulates virtual hardware components for each virtual machine, including virtual CPUs, memory (RAM), storage (usually in the form of virtual disks), and network interfaces.
4. Resource Allocation: The hypervisor manages the allocation of physical resources (CPU, memory, disk space, etc.) among the virtual machines. It ensures that each VM gets its fair share of resources and prevents one VM from impacting the performance of others.
5. Isolation: Virtual machines are isolated from each other, meaning that activities or issues within one VM typically do not affect other VMs running on the same host. This isolation is achieved through various mechanisms implemented by the hypervisor.


### Data Centers:
A data center is a facility used to house computer systems and associated components, such as storage systems and networking equipment. It typically includes redundant or backup power supplies, redundant data communications connections, environmental controls (e.g., air conditioning, fire suppression), and security devices.


1. Hardware Infrastructure: Data centers contain racks of servers, storage devices, networking equipment, and other hardware necessary to support the computing needs of businesses or organizations.
2. Networking: Data centers are equipped with high-speed networking infrastructure to facilitate communication between servers, storage systems, and other devices within the data center, as well as connections to external networks and the internet.



----------
## Understanding Horizontal and Vertical Scaling
## Vertical Scaling Diagram
![](/img/how-virtual-machines-work/vertical-scaling-vm.png)


### Vertical Scaling

Vertical scaling, also known as scaling up, involves upgrading individual machines with more resources, such as CPU, memory, or storage, to handle increased workload or demand. Instead of adding more machines, you enhance the capabilities of existing machines.
In the context of data engineering and data science workflows, vertical scaling can be applied in the following ways:


1. `Resource-intensive Algorithms`: Some data science algorithms or models may require a significant amount of computational resources, such as memory or CPU cores, to process large datasets or perform complex computations. Vertical scaling allows you to run these algorithms on more powerful machines with higher specifications.
2. `In-memory Processing`: Vertical scaling can be particularly beneficial for in-memory processing tasks, where the entire dataset needs to be loaded into memory for analysis or computation. Increasing the memory capacity of a machine allows you to handle larger datasets without resorting to disk-based processing, which can be slower.
3. `Single-node Data Processing`: In some cases, vertical scaling may be preferred over horizontal scaling, especially when the workload can't be easily parallelized or when maintaining data locality is crucial. For example, certain database systems may perform better on a single powerful server with ample resources than on a distributed cluster.


## Horizontal Scaling Diagram

![](/img/how-virtual-machines-work/horizontal-scaling-vm.png)


### Horizontal Scaling

Horizontal scaling, also known as scaling out, involves adding more machines or nodes to a system to handle increasing load or demand. Instead of upgrading individual machines with more resources, you add more machines to the existing pool, distributing the workload across them.

### Horizontal Scaling with Databricks

Databricks enables horizontal scaling by allowing users to dynamically allocate resources and scale out clusters to handle larger workloads. Users can adjust the number of worker nodes in a Databricks cluster based on the processing requirements of their data engineering or data science tasks.

When a Spark job is submitted to Databricks, the Databricks Runtime dynamically allocates resources across the cluster and distributes the tasks to different worker nodes. Each worker node processes a portion of the data in parallel, leveraging the computing power of multiple machines to achieve faster processing speeds and increased capacity.

1. Data Processing Pipelines: In data engineering workflows, horizontal scaling enables the parallel execution of data processing tasks across multiple nodes. This can include tasks such as data ingestion, transformation, aggregation, and analysis.


----------
## How Databricks facilitates easy cluster scaling and management.
![](/img/how-virtual-machines-work/databricks-managed-scaling.png)


- `Increased Performance`: By distributing data processing tasks across multiple nodes, Databricks can achieve significant performance improvements compared to processing data on a single machine.
- `Scalability`: Databricks can easily scale out to handle growing datasets and workloads by adding more worker nodes to the cluster. This scalability ensures that Databricks can accommodate the evolving needs of data engineering and data science projects.
- `Fault Tolerance`: Databricks provides built-in fault tolerance mechanisms, such as data replication and task rescheduling, to ensure that processing continues uninterrupted in the event of node failures or other issues.
- `Cost Efficiency`: With Databricks, users only pay for the resources they consume, allowing them to scale the cluster up or down based on demand. This pay-as-you-go model helps optimize costs by avoiding over-provisioning of resources.

