library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_div_tb is
end freq_div_tb;

architecture test of freq_div_tb is
    component divider
        generic(ctr_size: integer);
        port(
            clk_in: in std_logic;
            divisor: in unsigned(ctr_size downto 1);
            clk_out: out std_logic
        );
    end component;
    constant ctr_size: integer := 32;
    signal clk_main: std_logic := '0';
    signal clk_100: std_logic := '0';
    signal clk_1_1k: std_logic := '0';
    signal clk_50m: std_logic := '0';
    constant clk_period : time := 8 ns;
begin

    uut100: divider
        generic map (ctr_size => ctr_size)
        port map (
            clk_in => clk_main,
            divisor => to_unsigned(1250000*2, ctr_size),
            clk_out => clk_100
        );
    
    uut11k: divider
    generic map (ctr_size => ctr_size)
    port map (
        clk_in => clk_main,
        divisor => to_unsigned(113636*2, ctr_size),
        clk_out => clk_1_1k
    );

    uut50m: divider
    generic map (ctr_size => ctr_size)
    port map (
        clk_in => clk_main,
        divisor => to_unsigned(5, ctr_size),
        clk_out => clk_50m
    );

    main_clk: process
    begin
        clk_main <= '0';
		wait for clk_period/2;
		clk_main <= '1';
		wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        wait;
        
    end process;
end test;