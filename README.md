This is a hardware prototype for Shale, a datacenter-scale reconfigurable network.
A detailed explanation of the algorithms can be found in the SIGCOMM paper.
This FPGA-based prototype implements NIC logic at nodes, and a circuit switch connecting nodes through a predetermined schedule.

We use Bluespec Systems Verilog, a high-level hardware description language.
The NIC implementation is in `shale-NIC/`, this is where all of the routing and buffering logic lives. The `circuit-switch/` directory implements an electrical circuit switch for the given schedule. The code in `shale-hw-simulator` combines these to simulate a Shale network, with parameters such as number of nodes and levels in `lib/bsv/ShaleUtil.bsv`. 

For hardware compilation and simulation, this repository requires require (Quartus 17.0)[https://www.intel.com/content/www/us/en/software-kit/669513/intel-quartus-prime-standard-edition-design-software-version-17-0-for-linux.html] and (Questa)[https://www.intel.com/content/www/us/en/software-kit/776289/questa-intel-fpgas-pro-edition-software-version-23-1.html] with a working license. This should be free with a university accounts. 

We also use the open source versions of bsc and bsc-contrib, connectal, and fpgamake, 
These can be set up to execute simulations using docker as described below.

```
git clone --recursive https://github.com/reconfigurable-networks/shale-hardware-prototype
cd shale-hardware-prototype
sudo docker build --tag shale .
# Run a conatiner with the built image, and link quartus and questa installations, as well as shale code.
docker run -v /path/to/host_quartus_directory:/quartus_dir -v /path/to/host_questa_directory:/questa_dir -v /path/to/shale-hardware-prototype/:/root/shale-hardware-prototype  -it shale /bin/sh
```

Here the host paths to quartus and questa directories would be where specific versions were installed. For example, an installation path in the home directory may be `/home/<user>/intelFPGA/<version-num>` for quartus or `/home/<user>/intelFPGA_pro/<version-num>` for questa.
Inside the docker container, set paths to enable binaries for both of these, using the mounted path quartus_dir and questa_dir:

```
export PATH=/quarus_dir/quartus/bin:$PATH
export QUARTUS_64BIT=1                                                              
export QUARTUS_ROOTDIR=/quartus_dir/quartus"                          
export QSYS_ROOTDIR=/quartus_dir/quartus/sopc_builder/bin"
export PATH=$QUARTUS_ROOTDIR/bin:$PATH                                              
export PATH=$QSYS_ROOTDIR:$PATH
export PATH=/questa_dir/questa_fse/linux_x86_64:$PATH
```

And then build and run the simulator code:

```
cd /root/shale-hardware-prototype/shale-hw-simulator/
make build.vsim
cd vsim
export BOARD=vsim
make run <timeslot_len_cycles> <stats_interval_ms> <load_Gbps> <num_cycles_to_run>
```

We use 10Gbps FPGAs here, and the clock rate assumed is 6.4ns. By default, the cell size per time slot is set to 512 bits, so an example run command with arguments could be `make run 8 3000 10 6000`