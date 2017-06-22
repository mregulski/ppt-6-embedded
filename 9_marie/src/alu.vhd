library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.types.all;

entity alu is
    generic (
        WORD_WIDTH : integer := 9
    );
    port (
        clk  : in std_logic;
        cmd  : in std_logic;
        data : in std_logic_vector(WORD_WIDTH-1 downto 0);
        ac   : inout std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end alu;

architecture arch of alu is

begin

    process(clk)
    begin
        if rising_edge(clk) then
        end if;
    end process;
end arch;