library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity ram is
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
end ram;

architecture arch of ram is
    --------------------------------------------------------------
    -- Generic RAM module                                       --
    --------------------------------------------------------------
    -- Simple, adjustable, word-addressed RAM                   --
    --                                                          --
    -- Generic parameters:                                      --
    -- * ADDRESS_WIDTH - length (in bits) of memory addresses   --
    -- * WORD_WIDTH - length (in bits) of the addressable unit  --
    --                                                          --
    -- Usage:                                                   --
    -- 1. Reading                                               --
    --    * set `cmd` to '0'                                    --
    --    * set `address` to  target address                    --
    --    * clear `data` (set to "ZZ...Z")                      --
    --    * word under address is output to `data` on next tick --
    --    * reset `cmd` to 'Z'                                  --
    -- 2. Writing                                               --
    --    * set `cmd` to '0'                                    --
    --    * set `address` to <target address>                   --
    --    * set `data` to what you want to store                --
    --    * data is saved in the next tick                      --
    --    * reset `cmd` to 'Z'                                  --
    --                                                          --
    -- Note: `cmd` should be kept in high impendance state when --
    --       ram is not being actively used                     --
    --                                                          --
    -- Note: this module is synchronized on `clk`'s rising edge --
    --                                                          --
    --------------------------------------------------------------


    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';

    constant BUS_FREE   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
    constant WORD_EMPTY : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

    type memory_t is array(0 to 2 ** ADDRESS_WIDTH - 1)
        of std_logic_vector(WORD_WIDTH-1 downto 0);


    signal memory : memory_t := (
        "000000001", "000000010", "000000011", "000000100",
        "000000101", "000000110", "000000111", "000001000",
        "000001001", "000001010", "000001011", "000001100",
        others => WORD_EMPTY);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if cmd = CMD_READ then
                data <= memory(to_integer(unsigned(address)));
            elsif cmd = CMD_WRITE then
                memory(to_integer(unsigned(address))) <= data;
                data <= BUS_FREE;
            else
                data <= BUS_FREE;
            end if;
        end if;
    end process;

end arch;
