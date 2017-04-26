library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_divider is
    generic(outs: integer);
    port(
        clk_in: in std_logic;
        clk_out: out std_logic_vector(outs downto 1)
        := std_logic_vector(to_unsigned(0, outs))
    );
end bin_divider;

architecture behaviour of bin_divider is
signal ctr: unsigned(outs downto 1) := to_unsigned(1, outs);
-- signal state: std_logic_vector(32 downto 1) := (others => '0');
begin
    counter: process(clk_in)
    begin
        if clk_in'event then
            if (ctr = 2**outs-1) then
                ctr <= to_unsigned(0, outs);
            else    
                ctr <= unsigned(ctr + "1");
            end if;
            clk_out <= std_logic_vector(ctr);
        end if;
    end process;
end behaviour;