#!/bin/bash
# Simple thermal throttling script for Intel Xeon (Nehalem-based) 
# Authors Sudarsun Kannan (sudarsun@gatech,edu), Vishal Gupta
# If useful, please cite {pVM: Persistent Virtual Memory for Efficient Capacity Scaling and Object Storage}

# Usage:
# $./mem_throttle.sh socket_num throttle_value

# For the exact registers for your platform, please see, Intel software development manual
# and search for  Thermal register values.
# TODO: More generic script for multiple sockets and configurations

#Which socket number to throttle. If you have more sockets in the 
# machine, increase the case.
if [ $1 == 0 ] #first socket
then
    for i in {4..6}
    do
        setpci -s fe:0$i.3 0x84.L=$throttle
        setpci -s fe:0$i.3 0x48.L=$apply
    done
elif [ $1 == 1 ] #second socket
then
    for i in {4..6}
    do
        setpci -s ff:0$i.3 0x84.L=$throttle
        setpci -s ff:0$i.3 0x48.L=$apply
    done
elif [ $1 == 2 ] #both
then
    for i in {4..6}
    do
        setpci -s fe:0$i.3 0x84.L=$throttle
        setpci -s fe:0$i.3 0x48.L=$apply
    done
    for i in {4..6}
    do
        setpci -s ff:0$i.3 0x84.L=$throttle
        setpci -s ff:0$i.3 0x48.L=$apply
    done
fi

#Throttle Values. Modify values specific to your platforms using 
#development manual.
if [ $2 == 0 ]
then #no throttle (disables throttling)
    throttle='0xffff'
    apply='0x0'

elif [ $2 == 1 ] # reduces bandwidth by 2x
then #2x
    throttle='0x1f0f'
    apply='0x2'
elif [ $2 == 2 ]  # reduces bandwidth by 8x
then #5x
    throttle='0x0f0f'
    apply='0x2'
fi

#After throttlig, run stream benchmark and test the bandwidth.
sleep 4
echo "validation"
echo "***********************8"

echo "Memory bandwidth when binding to Mem node"
numactl --membind=0 stream/stream_c.exe 

sleep 2

echo "Memory bandwidth when binding to Mem node"
numactl --membind=1 stream/stream_c.exe
