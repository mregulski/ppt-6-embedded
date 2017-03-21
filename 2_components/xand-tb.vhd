LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

ENTITY xand_tb IS
END xand_tb;

ARCHITECTURE behavior OF xand_tb IS

    constant xand_width : integer := 8;
    constant period : time := 1 fs;
    constant max_num : integer := 2**xand_width;
    COMPONENT xand
        GENERIC(width : integer);
        PORT (
            clk : IN std_logic;
            A, B : IN std_logic_vector (width-1 downto 0);
            C : OUT std_logic_vector (width-1 downto 0)  
        );
    END COMPONENT;

    signal clk : std_logic := '1';
    signal A, B : std_logic_vector(xand_width-1 downto 0) := (others => '0');

    signal C : std_logic_vector(xand_width-1 downto 0);
BEGIN
    uut: xand 
        generic map (width => xand_width)
        port map (
            clk => clk,
            A => A,
            B => B,
            C => C);
    
    stim_proc: process
    BEGIN
        for i in 0 to max_num loop
            A <= std_logic_vector(unsigned(A) + 1);
            for j in  0 to max_num loop
                B <= std_logic_vector(unsigned(B) + 1);
                wait for period;
            end loop;
        end loop;
        wait;
        -- A <= "0011";
        -- B <= "0101";
        -- wait for period;
        -- A <= std_logic_vector(to_unsigned(5,xand_width));
        -- wait;
    END process;
END behavior;