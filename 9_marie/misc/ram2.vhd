library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity ram2 is
    generic (
        ADDRESS_WIDTH : integer := 5;
        WORD_WIDTH : integer := 9;
        ID : std_logic_vector(8 downto 0)
    );
    port (
        clk:       in std_logic;
        address:   in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        data_in:   in std_logic_vector(WORD_WIDTH-1 downto 0);
        data_out:   out std_logic_vector(WORD_WIDTH-1 downto 0) := (others=>'Z');
        dbg_state: out std_logic_vector(1 downto 0);
        dbg_cmd:   out std_logic := 'Z'
    );
end ram2;

architecture arch of ram2 is
    ---------------------------------------------
    -- Generic RAM module                      --
    ---------------------------------------------
    -- Usage:                                  --
    -- 1. Send MODE_READ (0) or MODE_WRITE (1) --
    -- 2. In the next tick:                    --
    --    * Set address                        --
    --    * Set data if writing                --
    --    * Read data if reading               --
    -- 3. ???                                  --
    -- 4. Profit                               --
    ---------------------------------------------


    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';

    constant BUS_FREE   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

    type ram_t is array(0 to 2 ** ADDRESS_WIDTH - 1)
        of std_logic_vector(WORD_WIDTH-1 downto 0);

    type state_t is (IDLE, CMD, ARGS, EXEC);

    signal memory : ram_t := (others => "000000000");

    signal state_cur  : state_t := IDLE;
    signal state_next : state_t := IDLE;

    signal address_buffer : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    signal data_buffer    : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal cmd_cur        : std_logic := 'Z';

    signal data_arg     : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal address_arg  : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    signal output       : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal sending      : std_logic := '0';
begin

    updateState : process(clk)
    begin
        if rising_edge(clk) then
            state_cur <= state_next;
            data_buffer <= data_in;
            address_buffer <= address;
        end if;
    end process;


    doState : process(state_cur, data_buffer)
    begin
        case state_cur is
            when IDLE =>
                dbg_state <= "00";
                if data_buffer = ID and sending /= '1' then
                    state_next <= CMD;
                else
                    state_next <= IDLE;
                end if;
                sending <= '0';
            when CMD =>
                dbg_state <= "01";
                cmd_cur <= data_buffer(0);
                dbg_cmd <= cmd_cur;
                state_next <= ARGS;
            when ARGS =>
                dbg_state <= "10";
                data_arg <= data_buffer;
                address_arg <= address_buffer;
                state_next <= EXEC;
            when EXEC =>
                dbg_state <= "11";
                case cmd_cur is
                    when CMD_READ =>
                        output <= memory(to_integer(unsigned(address_arg)));
                        sending <= '1';
                    when CMD_WRITE =>
                        report "writing " & str(data_arg) & " @ " & str(address_arg);
                        memory(to_integer(unsigned(address_arg))) <= data_arg;
                    when others =>
                        -- do nothing
                end case;
                state_next <= IDLE;
            when others =>
                dbg_state <= "XX";
                -- do nothing
        end case;
    end process;

    data_out <= output when sending = '1' else BUS_FREE;
end arch;