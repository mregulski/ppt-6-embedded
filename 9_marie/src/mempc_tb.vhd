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
            output : in std_logic;
            set    : in std_logic;
            inc    : in std_logic;
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

    component controller
        generic (
            ADDRESS_WIDTH : integer := 5;
            WORD_WIDTH    : integer := 9
        );
        port (
            clk      : in std_logic;
            data_bus : inout std_logic_vector(WORD_WIDTH-1 downto 0);
            control  : out std_logic_vector(5 downto 0);
            pc_ctrl  : out std_logic_vector(2 downto 0); -- set, inc, out
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



    -- ram controls
    signal mem_cmd  : std_logic := 'Z';
    signal mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z');

    -- pc controls
    signal pc_out : std_logic := '0';
    signal pc_set : std_logic := '0';
    signal pc_inc : std_logic := '0';

begin

    memory : ram
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => mem_cmd,
        address => mem_addr,
        data => data_bus
    );

    progc : pc
    generic map (
        COUNTER_WIDTH => ADDRESS_WIDTH
    )
    port map (
        clk => clk,
        output => pc_out,
        set => pc_set,
        inc => pc_inc,
        data => data_bus(ADDRESS_WIDTH-1 downto 0)
    );

    test_process : process
    begin
        ---------------------------------------------------
        -- Test 1.
        --
        -- Read a value from memory address provided by PC
        ---------------------------------------------------

        wait for 100 ns;
        -- prepare data in memory
        mem_cmd <= '1';
        mem_addr <= "01010";
        data_bus <= "100110011";
        wait for clk_period;

        -- clear memory controls
        mem_cmd <= 'Z';
        mem_addr <= "ZZZZZ";
        -- set pc to the same address
        data_bus <= "000001010";
        pc_set <= '1';
        wait for clk_period;

        -- output pc value
        pc_set <= '0';
        pc_out <= '1';
        data_bus <= "0000ZZZZZ";
        wait for clk_period;

        -- read from memory
        pc_out <= '0';
        mem_addr <= data_bus(ADDRESS_WIDTH-1 downto 0);
        mem_cmd <= '0';
        data_bus <= DATA_CLR;
        wait for clk_period;

        mem_cmd <= 'Z';
        assert data_bus = "100110011"
            report "expected '100110011' but got '" & str(data_bus) & "'";

        wait for clk_period;
        -- reset all
        mem_addr <= ADDR_CLR;
        data_bus <= DATA_CLR;

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