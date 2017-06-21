library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.types.all;

entity testbench is
end testbench;

architecture test of testbench is

    ---------------------------------------
    -- Components
    ---------------------------------------

    component ram
        generic (
            ADDRESS_WIDTH : integer := 5;
            WORD_WIDTH : integer := 9
        );
        port (
            clk:       in std_logic;
            cmd:       in std_logic;
            address:   in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
            data:      inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others=>'Z')
        );
    end component;

    component pc
        generic (
            COUNTER_WIDTH : integer
        );
        port (
            clk    : in std_logic;
            set    : in std_logic;
            inc    : in std_logic;
            output : in std_logic;
            data   : inout std_logic_vector(COUNTER_WIDTH-1 downto 0)
        );
    end component;

    component reg
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk:       in std_logic;
            cmd:       in std_logic;
            data:      inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others=>'Z')
        );
    end component;

    component addr_reg
        generic (
            WORD_WIDTH : integer := 9;
            ADDRESS_WIDTH : integer := 5
        );
        port (
            clk:       in std_logic;
            cmd:       in std_logic;
            data:      inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others=>'Z');
            address:   out std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others=>'Z')
        );
    end component;

    component controller
        generic (
            ADDRESS_WIDTH : integer := 5;
            WORD_WIDTH    : integer := 9
        );
        port (
            clk      : in std_logic;
            data_bus : inout std_logic_vector(WORD_WIDTH-1 downto 0);
            ctrl_out : out control_t;
            dbg      : out debug_t
        );
    end component;

    ---------------------------------------
    -- Constants
    ---------------------------------------

    -- configuration constants
    constant ADDRESS_WIDTH  : integer := 5;
    constant WORD_WIDTH     : integer := 9;

    -- "clear" signals for lines ("ZZ..Z")
    constant ADDR_CLR : std_logic_vector(ADDRESS_WIDTH - 1 downto 0) := (others => 'Z');
    constant DATA_CLR : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => 'Z');

    -- other constants
    constant clk_period : time := 20 ns;


    ---------------------------------------
    -- Signals
    ---------------------------------------

    -- general signals
    signal clk            : std_logic := '0';
    signal data_bus       : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

    signal control : control_t := (pc=> "ZZZ", others => 'Z');

    signal c_pc  : std_logic_vector(2 downto 0);
    signal c_mem : std_logic;
    signal c_ac  : std_logic;
    signal c_mar : std_logic;
    signal c_mbr : std_logic;
    signal c_ir  : std_logic;
    signal c_inreg : std_logic;
    signal c_outreg : std_logic;

    signal debug   : debug_t(1 downto 0);
    signal dbg_state : std_logic_vector(3 downto 0);
    signal dbg_ctr : std_logic_vector(3 downto 0);
    -- ram controls
    -- signal mem_cmd  : std_logic := 'Z';
    signal mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z');

    -- pc controls: set, inc, out
    -- signal pc_cmd : std_logic_vector(2 downto 0) := "000";

    signal mar_cmd: std_logic := 'Z';

begin
    c_pc  <= control.pc; 
    c_mem <= control.mem;
    c_ac  <= control.ac;
    c_mar <= control.mar;
    c_mbr <= control.mbr;
    c_ir  <= control.ir;
    c_inreg <= control.inreg;
    c_outreg <= control.outreg;
    dbg_state <= debug(0);
    dbg_ctr <= debug(1);

    memory : ram
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.mem,
        address => mem_addr,
        data => data_bus
    );

    progc : pc
    generic map (
        COUNTER_WIDTH => ADDRESS_WIDTH
    )
    port map (
        clk => clk,
        set => control.pc(2),
        inc => control.pc(1),
        output => control.pc(0),
        data => data_bus(ADDRESS_WIDTH-1 downto 0)
    );

    mar : addr_reg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => mar_cmd,
        data => data_bus,
        address => mem_addr
    );

    ctrl : controller
    generic map (
        ADDRESS_WIDTH => 5,
        WORD_WIDTH => 9
    )
    port map (
        clk => clk,
        data_bus => data_bus,
        ctrl_out => control,
        dbg => debug
    );
    -- mbr : reg
    -- generic map (
    --     WORD_WIDTH => WORD_WIDTH
    -- )
    -- port map (
    --     clk
    --     cmd
    --     data
    -- );

    -- acc : reg
    -- generic map (
    --     WORD_WIDTH => WORD_WIDTH
    -- )
    -- port map (
    --     clk
    --     cmd
    --     data
    -- );

    ir : reg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.ir,
        data => data_bus    
    );

    test_process : process
    begin
        wait for 100 ns;

        wait;
    end process;


    clk_process : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;

end test;