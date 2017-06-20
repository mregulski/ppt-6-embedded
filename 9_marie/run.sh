entity=$1
runArgs=${@:2}

case $entity in
    "ram" | "RAM" )
        echo "Running ram testbench"
        unit="ram_tb"
        ;;
    "pc" | "PC" )
        echo "Running pc testbench"
        unit="pc_tb"
        ;;
    "controller" )
        echo "Running controller testbench"
        unit="controller_tb"
        ;;
    "testbench" | "system")
        echo "Running system testbench"
        unit="testbench"
        ;;
    *)
        echo "Unknown entity:" $entity
        exit
        ;;
esac
echo "================================================================================"
ghdl -m $unit
echo "================================================================================"
ghdl -r $unit $runArgs

# ghdl -a src/txt_util.vhd src/ram.vhd src/ram_tb.vhd
# ghdl -m ram_tb
# ghdl -r ram_tb $@:1