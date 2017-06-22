library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
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


    -- commands
    type cmd_t is (NOP, LOAD, STORE, ADD, SUBT, CIN, COUT, HALT, SKIPCOND, JUMP, UNDEF);
    attribute enum_encoding : string;
    attribute enum_encoding of cmd_t : type is
        "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 ZZZZ";

    -- last decoded instruction
    signal instr : cmd_t := UNDEF;


    -- buffer for bus data
    signal bus_buffer : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

    -- control signals


    -- named values for control lines
    -- generic commands for 1-bit controls
    constant CMD_READ  : std_logic := '0'; -- read from component to the bus
    constant CMD_WRITE : std_logic := '1'; -- write bus' content to the component
    constant CMD_NOP   : std_logic := 'Z';
    -- for program counter
    constant PC_SET    : std_logic_vector(2 downto 0) := "100"; -- set PC to bus' content
    constant PC_INC    : std_logic_vector(2 downto 0) := "010"; -- increment PC
    constant PC_OUTPUT : std_logic_vector(2 downto 0) := "001"; -- output PC to the bus
    constant PC_NOP    : std_logic_vector(2 downto 0) := "000";

    -- all the control signals
    signal control : control_t := (pc=> "ZZZ", others => 'Z');


    -- indices for debug signals in the combined output
    constant dbg_state : integer := 0;
    constant dbg_ctr   : integer := 1;
    constant dbg_cmd   : integer := 2;

begin
    -- setup control outputs
    ctrl_out <= control;


    progress: process(clk)
    begin
        -- if clk'event then
        if rising_edge(clk) then
            bus_buffer <= data_bus;
            state_cur <= state_nxt;
        end if;
    end process;

    main: process(state_cur, data_bus)
        variable state_ctr : integer := -1; -- for 'substates'
        variable opcode    : std_logic_vector(3 downto 0);
        variable cmp       : std_logic_vector(1 downto 0);
        variable cmp_res   : boolean;

    begin
        case state_cur is
            ------------
            -- FETCH
            ------------
            when FETCH =>
                dbg(dbg_state) <= "0000";
                if state_ctr >= 0 then
                    dbg(dbg_ctr) <= std_logic_vector(to_unsigned(state_ctr, 4));
                else
                    dbg(dbg_ctr) <= "ZZZZ";
                end if;
                case state_ctr is
                    when 0 => -- fetch instruction address from PC
                        control.PC <= PC_OUTPUT;
                        -- state_nxt <= FETCH;
                    when 1 => -- save address in MAR; read from memory
                        control.PC <= PC_NOP;
                        control.MAR <= CMD_WRITE;
                        -- state_nxt <= FETCH;
                    when 2 =>
                        control.MAR <= CMD_NOP;
                        control.MEM <= CMD_READ;
                        -- state_nxt <= FETCH;
                    when 3 => -- write instruction to IR
                        control.MEM <= CMD_NOP;
                        control.IR <= CMD_WRITE;
                        state_nxt <= DECODE;
                    when others =>
                        -- ignore
                        state_nxt <= FETCH;
                end case;
                state_ctr := state_ctr + 1;
            ------------
            -- DECODE
            ------------
            when DECODE =>
                control.IR <= CMD_NOP;
                dbg(dbg_state) <= "0001";
                state_ctr := 0;
                dbg(dbg_ctr) <= "ZZZZ";
                report "decoding: " & str(bus_buffer);
                opcode := bus_buffer(WORD_WIDTH-1 downto WORD_WIDTH-4);
                case opcode is
                    when "0000" => instr <= NOP; -- the legal one
                    when "0001" => instr <= LOAD;
                    when "0010" => instr <= STORE;
                    when "0011" => instr <= ADD;
                    when "0100" => instr <= SUBT;
                    when "0101" => instr <= CIN;
                    when "0110" => instr <= COUT;
                    when "0111" => instr <= HALT;
                    when "1000" => instr <= SKIPCOND;
                    when "1001" => instr <= JUMP;
                    when others => instr <= UNDEF; -- the nasty one
                end case;
                control.PC <= PC_INC;
                state_nxt <= EXECUTE;
            ------------
            -- EXECUTE
            ------------
            when EXECUTE =>
                dbg(dbg_state) <= "0010";
                control.PC <= PC_NOP;
                dbg(dbg_ctr) <= std_logic_vector(to_unsigned(state_ctr, 4));
                case instr is
                    when NOP =>
                        report "EXECUTE:NOP";
                        state_nxt <= FETCH;
                    when LOAD => -- mem[addr] -> ac
                        report "EXECUTE:LOAD:" & str(state_ctr);
                        case state_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;
                                -- state_nxt <= EXECUTE;
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.MAR <= CMD_WRITE; -- from IR
                                -- state_nxt <= EXECUTE;
                            when 2 =>
                                control.MAR <= CMD_NOP;
                                control.MEM <= CMD_READ;
                                -- state_nxt <= EXECUTE;
                            when 3 =>
                                control.MEM <= CMD_NOP;
                                control.MBR <= CMD_WRITE;
                                -- state_nxt <= EXECUTE;
                            when 4 =>
                                control.MBR <= CMD_READ;
                                -- state_nxt <= EXECUTE;
                            when 5 =>
                                control.MBR <= CMD_NOP;
                                control.AC <= CMD_WRITE;
                                -- state_nxt <= EXECUTE;
                            when 6 =>
                                control.AC <= CMD_NOP;
                                state_ctr := -1;
                                state_nxt <= FETCH;
                            when others =>
                                assert false report "EXECUTE:LOAD:wut";
                        end case;
                        -- state_ctr := state_ctr + 1;
                    when STORE => -- ac -> mem[addr]
                        report "EXECUTE:STORE:" & str(state_ctr);
                        case state_ctr is
                            when 0 =>

                                control.AC <= CMD_READ;
                                -- state_nxt <= EXECUTE;
                            when 1 =>
                                control.AC <= CMD_NOP;
                                control.IR <= CMD_READ;
                                control.MBR <= CMD_WRITE;
                                -- state_nxt <= EXECUTE;
                            when 2 =>
                                control.MBR <= CMD_NOP;
                                control.IR <= CMD_NOP;
                                control.MAR <= CMD_WRITE;
                                -- state_nxt <= EXECUTE;
                            when 3 =>
                                control.MAR <= CMD_NOP;
                                state_ctr := -1;
                                state_nxt <= STORE;
                            when others =>
                                report "EXECUTE:STORE:wut";
                                state_nxt <= FETCH;
                        end case;

                    when ADD =>
                        report "EXECUTE:ADD";
                    when SUBT =>
                        report "EXECUTE:SUBT";
                    when CIN =>
                        report "EXECUTE:CIN";
                        case state_ctr is
                            when 0 =>
                                control.INREG <= CMD_READ;
                            when 1 =>
                                control.INREG <= CMD_NOP;
                                control.AC <= CMD_WRITE;
                            when 2 =>
                                control.AC <= CMD_NOP;
                                state_ctr := -1;
                                state_nxt <= FETCH;
                            when others =>
                                state_ctr := -1;
                                state_nxt <= FETCH;
                        end case;
                    when COUT =>
                        report "EXECUTE:COUT";
                        case state_ctr is
                            when 0 =>
                                control.AC <= CMD_READ;
                            when 1 =>
                                control.AC <= CMD_NOP;
                                control.OUTREG <= CMD_WRITE;
                            when 2 =>
                                control.OUTREG <= CMD_NOP;
                                state_ctr := -1;
                                state_nxt <= FETCH;
                            when others =>
                                state_ctr := -1;
                                state_nxt <= FETCH;
                        end case;
                    when HALT =>
                        assert false report "received HALT - stopping";
                    when SKIPCOND =>
                        report "EXECUTE:SKIPCOND:" & str(state_ctr);
                        case state_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.AC <= CMD_READ;
                            when 2 =>
                                control.AC <= CMD_NOP;
                                cmp := bus_buffer(ADDRESS_WIDTH-1 downto ADDRESS_WIDTH-2); -- must wait this long because reasons
                                -- do the comparing
                                if cmp = "00" then -- LT 0
                                    report "SKIPCOND:comparing AC < 0";
                                    cmp_res := signed(bus_buffer) < to_signed(0, WORD_WIDTH);
                                elsif cmp = "01" then -- EQ 0
                                    report "SKIPCOND:comparing AC = 0";
                                    cmp_res := signed(bus_buffer) = to_signed(0, WORD_WIDTH);
                                elsif cmp = "10" then -- GT 0
                                    report "SKIPCOND:comparing AC > 0";
                                    cmp_res := signed(bus_buffer) > to_signed(0, WORD_WIDTH);
                                else
                                    report "SKIPCOND:comparing AC ? 0";
                                    cmp_res := false;
                                end if;
                                if cmp_res then
                                    -- increment pc
                                    control.PC <= PC_INC;
                                else
                                    state_ctr := -1;
                                    state_nxt <= FETCH;
                                end if;
                            when 3 =>
                                control.PC <= PC_NOP;
                                state_ctr := -1;
                                state_nxt <= FETCH;
                            when others =>
                                control.PC <= PC_NOP;
                                state_ctr := -1;
                                state_nxt <= FETCH;
                        end case;
                    when JUMP =>
                        report "EXECUTE:JUMP:" & str(state_ctr);
                        case state_ctr is
                            when 0 =>
                                control.IR <= CMD_READ; -- get the adress on the bus
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.PC <= PC_SET;
                            when 2 =>
                                control.PC <= PC_NOP;
                                state_ctr := -1;
                                state_nxt <= FETCH;
                            when others =>
                        end case;
                    when UNDEF =>
                        state_nxt <= FETCH;

                end case;
                state_ctr := state_ctr + 1;
                -- state_nxt <= EXECUTE;

            when STORE =>
                -- push MBR to mem[MAR]
                dbg(dbg_state) <= "0011";
                dbg(dbg_ctr) <= std_logic_vector(to_unsigned(state_ctr, 4));
                report "STORE:" & str(state_ctr);
                case state_ctr is
                    when 0 =>
                        control.MBR <= CMD_READ;
                        state_nxt <= STORE;
                    when 1 =>
                        control.MBR <= CMD_NOP;
                        control.MEM <= CMD_WRITE;
                        state_nxt <= STORE;
                    when 2 =>
                        control.MEM <= CMD_NOP;
                        state_ctr := -1;
                        state_nxt <= FETCH;
                    when others =>
                        assert false report "STORE:wut";
                end case;
                state_ctr := state_ctr + 1;

        end case;
    end process;


end arch;