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
        ctrl_out : out control_t;
        dbg      : out debug_t  
    );
end controller;

architecture arch of controller is


    -- state
    type state_t is (FETCH, DECODE, EXECUTE, STORE);

    signal state_cur : state_t := FETCH;
    signal state_nxt : state_t := FETCH;


    -- command
    type cmd_t is (NOP, LOAD, STORE, ADD, SUBT, CIN, COUT, HALT, SKIPCOND, JUMP);
    attribute enum_encoding : string;
    attribute enum_encoding of cmd_t : type is
        "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001";

    signal instr : cmd_t := HALT;


    -- buffer for bus data
    signal bus_buffer : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

    -- control signals
   

    -- named values for control lines' states
    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';
    constant CMD_NOP   : std_logic := 'Z';
    constant PC_SET    : std_logic_vector(2 downto 0) := "100";
    constant PC_INC    : std_logic_vector(2 downto 0) := "010";
    constant PC_OUTPUT : std_logic_vector(2 downto 0) := "001";
    constant PC_NOP    : std_logic_vector(2 downto 0) := "000";

    signal control : control_t := (pc=> "ZZZ", others => 'Z');


    -- debug
    constant dbg_state : integer := 0;
    constant dbg_cmd   : integer := 1;
    -- signal debug       : debug_t(1 downto 0) := ("ZZZZ", "ZZZZ");

begin
    -- setup control outputs
    ctrl_out <= control;
    -- pc_ctrl <= control.pc;
    -- ctrl_out(0) <= control.mem;
    -- ctrl_out(1) <= control.ac;
    -- ctrl_out(2) <= control.mar;
    -- ctrl_out(3) <= control.mbr;
    -- ctrl_out(4) <= control.ir;
    -- ctrl_out(5) <= control.inreg;
    -- ctrl_out(6) <= control.outreg;


    progress: process(clk)
    begin
        if rising_edge(clk) then
            bus_buffer <= data_bus;
            state_cur <= state_nxt;
        end if;
    end process;

    main: process(state_cur, bus_buffer)
        variable state_ctr : integer := 0;
    begin
        case state_cur is
            when FETCH =>
                dbg(dbg_state) <= "0000";
                case state_ctr is
                    when 0 =>
                        dbg(1) <= "0000";
                        -- write PC to MAR
                        control.pc <= PC_OUTPUT;
                        control.mar <= CMD_WRITE;
                        state_ctr := state_ctr + 1;
                        state_nxt <= FETCH;
                    when 1 =>
                        dbg(1) <= "0001";
                        -- read from mem[MAR] to IR
                        control.pc <= PC_NOP;
                        control.mem <= CMD_READ;
                        control.ir <= CMD_WRITE;
                        state_ctr := state_ctr + 1;
                        state_nxt <= FETCH;
                    when 2 => 
                        dbg(1) <= "0010";
                        state_nxt <= DECODE;
                    when others =>    
                        -- ignore
                        state_nxt <= FETCH;
                end case;
            when DECODE =>
                state_ctr := 0;
                dbg(dbg_state) <= "0001";
                dbg(1) <= "0000";
                control.mem <= CMD_NOP;
                control.ir <= CMD_NOP;
                state_nxt <= FETCH;
            when EXECUTE =>
                dbg(dbg_state) <= "0010";
            when STORE =>
                dbg(dbg_state) <= "0011";
        end case;
    end process;


end arch;