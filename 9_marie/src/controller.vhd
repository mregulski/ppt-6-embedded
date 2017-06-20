library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.types.all;


entity controller is

    generic (
        ADDRESS_WIDTH : integer := 5;
        WORD_WIDTH    : integer := 9
    );
    port (
        clk      : in std_logic;
        data_bus : inout std_logic_vector(WORD_WIDTH-1 downto 0);
        -- mem_addr : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        ctrl_out : out std_logic_vector(6 downto 0);
        pc_ctrl  : out std_logic_vector(2 downto 0); -- set, inc, out
        dbg      : out debug_t
    );
end controller;

architecture arch of controller is


    -- state
    type state_t is (FETCH, DECODE, EXECUTE, STORE);

    signal state_cur : state_t := FETCH;
    signal state_nxt : state_t := FETCH;


    -- command
    type cmd_t is (NOP, LOAD, STORE, ADD, SUBT, INPUT, OUTPUT, HALT, SKIPCOND, JUMP);
    attribute enum_encoding : string;
    attribute enum_encoding of cmd_t : type is
        "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001";

    signal instr : cmd_t := HALT;


    -- buffer for bus data
    signal bus_buffer : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

    -- control signals
    type control_t is record
        PC : std_logic_vector(2 downto 0);
        -- memory
        MEM : std_logic;
        -- registers
        AC : std_logic;
        MAR : std_logic;
        MBR : std_logic;
        IR : std_logic;
        INreg : std_logic;
        OUTreg : std_logic;
    end record;

    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';
    signal control : control_t := (others => 'Z');


    -- debug
    constant dbg_state : integer := 0;
    constant dbg_cmd   : integer := 1;
    signal debug       : debug_t(1 downto 0);

begin

    ctrl_out <= control;

    progress: process(clk)
    begin
        if rising_edge(clk) then
            bus_buffer <= data_bus;
            state_cur <= state_nxt;
        end if;
    end process;

    main: process(state_cur, bus_buffer)
    begin
        case state_cur is
            when FETCH =>
                debug(dbg_state) <= "0000";

            when DECODE =>
                debug(dbg_state) <= "0001";
            when EXECUTE =>
                debug(dbg_state) <= "0010";
            when STORE =>
                debug(dbg_state) <= "0011";
        end case;
    end process;


end arch;