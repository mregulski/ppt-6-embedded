library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_div_tb is
end bin_div_tb;

architecture test of bin_div_tb is
    component bin_divider
        generic(outs: integer);
        port(
            clk_in: in std_logic;
            clk_out: out std_logic_vector(outs downto 1)
        );
    end component;
    constant outs: integer := 4;
    signal clk_main: std_logic := '0';
    signal clk_out: std_logic_vector(outs downto 1) := (others => '0');
    constant clk_period : time := 8 ns;
begin

    uut: bin_divider
        generic map (outs => outs)
        port map (
            clk_in => clk_main,
            clk_out => clk_out
        );
    
    main_clk: process
    begin
        clk_main <= '0';
		wait for clk_period/2;
		clk_main <= '1';
		wait for clk_period/2;
    end process;
    
end test;