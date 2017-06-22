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
        B"0001_10100", --  0. load 0x14
        B"0010_10101", --  1. store 0x15
        B"0001_10101", --  2. load 0x15
        B"1000_01000", --  3. skipcond 01 (ac = 0)
        B"1001_01000", --  4. jump 8
        B"0111_00000", --  5. halt
        B"0000_00000", --  6.
        B"0111_00000", --  7. halt
        B"0101_00000", --  8. input
        B"0110_00000", --  9. output
        B"0001_10110", --  A. load 16
        B"0011_10111", --  B. add 17
        B"0110_00000", --  C. output
        B"0000_00000", --  D.
        B"0000_00000", --  E.
        B"0000_00000", --  F.
        B"0000_00000", -- 10.
        B"0000_00000", -- 11.
        B"0000_00000", -- 12.
        B"0000_00000", -- 13.
        "011111111",   -- 14. <data>
        "000000000",   -- 15. <data>
        "000001110",   -- 16. <data>
        "011100000",   -- 17. <data>
        "000000000",   -- 18. <data>
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
