library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity pc is
    generic (
        COUNTER_WIDTH : integer := 9
    );
    port (
        clk      : in std_logic;
        dout   : in std_logic; -- if 1, output the state to data
        set      : in std_logic; -- if 1, override the state with value from data
        inc      : in std_logic;
        data     : inout std_logic_vector(COUNTER_WIDTH-1 downto 0)
    );
end pc;

architecture arch of pc is
    -------------------------------------------------------------------------------
    -- Program Counter module                                                    --
    -------------------------------------------------------------------------------
    -- Basic program counter. Can be auto incremented or set to a value.         --
    --                                                                           --
    -- Generic parameters:                                                       --
    -- * COUNTER_WIDTH - length (in bits) of counter's state                     --
    --                                                                           --
    -- Usage                                                                     --
    -- 1. Increment                                                              --
    --    * set `inc` to '1'                                                     --
    --    * counter is incremented on next tick                                  --
    --    * reset `inc` to '0'                                                   --
    -- 2. Set value                                                              --
    --    * set `set` to '1'                                                     --
    --    * set `data` to target value                                           --
    --    * counter's state is updated on the next tick                          --
    -- 3. Output                                                                 --
    --    * set `dout` to `1`                                                  --
    --    * clear `data` (set to "ZZ...Z")                                       --
    --    * counter's state will be written to `data` on next tick               --
    --                                                                           --
    -------------------------------------------------------------------------------


    constant BUS_CLR : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => 'Z');

    signal state : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if set = '1' then
                state <= data;
                data <= BUS_CLR;
            elsif inc = '1' then
                if unsigned(state) >= 2 ** COUNTER_WIDTH - 1 then
                    state <= (others => '0');
                else
                    state <= std_logic_vector(unsigned(state) + 1);
                end if;
                data <= BUS_CLR;
            elsif dout = '1' then
                data <= state;
            else
                data <= BUS_CLR;
            end if;
        end if;
    end process;

end arch;