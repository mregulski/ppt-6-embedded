library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hamming_sender is
    port (
        clk : in std_logic;
        data : in std_logic_vector(4 downto 1);
        encoded : out std_logic_vector(7 downto 1)
    );
end hamming_sender;

architecture hammingify of hamming_sender is
    begin   
    encoder : process(clk)
    begin
        if rising_edge(clk) then
            -- data
            encoded(3) <= data(1);
            encoded(5) <= data(2);
            encoded(6) <= data(3);
            encoded(7) <= data(4);
            -- parity
            encoded(1) <= data(1) xor data(2) xor data(3);
            encoded(2) <= data(1) xor data(3) xor data(4);
            encoded(4) <= data(2) xor data(3) xor data(4);
        end if;
    end process;
end hammingify;
