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
        read : in std_logic;
        data : inout std_logic_vector(WORD_WIDTH-1 downto 0);
        ac   : inout std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end alu;

architecture arch of alu is
    signal result : std_logic_vector(WORD_WIDTH-1 downto 0);
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if cmd = '1' then -- ADD
                -- ac <= std_logic_vector(signed(data) + signed(ac));
                result <= std_logic_vector(signed(data) + signed(ac));
            elsif cmd = '0' then -- SUBT
                -- ac <= std_logic_vector(signed(data) - signed(ac));
                result <= std_logic_vector(signed(data) - signed(ac));
            elsif read = '1' then
                ac <= result;
            else
                ac <= (others => 'Z');
            end if;
        end if;
    end process;
end arch;