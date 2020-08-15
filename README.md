# DMA
* A simple 8237A Multimode Direct Memory Access (DMA) Controller is a peripheral interface circuit for microprocessor
systems. It is designed to improve system performance by allowing external devices to directly transfer
information from the system memory. Memory-to-memory transfer capability is also provided. The 8237A
offers a wide variety of programmable control features to enhance data throughput and system optimization
and to allow dynamic reconfiguration under program control.
* The DMA supports four Independent DMA Channels.

## Transfer Data Types
* Memory-to-Memory transfers: that perform block moves of data from one memory address space to another
with a minimum of program effort and time, the 8237A includes a memory-to-memory transfer feature.
* Write transfers: that move data from an I/O device to the memory.
* Read transfers: that move data from memory to an I/O device.

## Priority
Fixed Priority which fixes the channels in priority order based upon the descending value of their number.

## Programming Stage
When no channel is requesting service, the 8237A will enter the Idle cycle looking for an attempt by the microprocessor to
write or read the internal registers of the 8237A.

## Internal Registers and enables
* Current Address Register: each channel has current address register to hold address used during DMA transfer.
* mem to mem enable: mem_to_mem_enable give the cpu the ability to disable memory to memory data transfer type. 
* mode register: used to determine the transfer type of each channel is either write or read
 as every bit represents a channel , also 1 for read and 0 for write.
* mask register: used to disable channels even if devices has requested a DMA transfer.
* temp register: used during memory to memory transfer data type to exchange data.
