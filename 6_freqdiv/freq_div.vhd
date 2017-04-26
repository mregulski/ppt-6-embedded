library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider is
    generic(ctr_size: integer);
    port(
        clk_in: in std_logic;
        divisor: in unsigned(ctr_size downto 1);
        clk_out: out std_logic := '0'
    );
end divider;

architecture behaviour of divider is
    signal ctr: unsigned(ctr_size downto 1) := 
    to_unsigned(1, ctr_size);
    signal state: std_logic := '1';
begin 
    
    counter: process(clk_in)
    begin
        if clk_in'event then
            ctr <= unsigned(ctr + "1");
            if ctr >= divisor then
                state <= not state; 
                ctr <= to_unsigned(1, ctr_size);
                clk_out <= state;
            end if;
            
        end if;
    end process;
end behaviour;