library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.txt_util.all;
entity hamming_sender is
    port (
        clk : in std_logic;
        data_in : in std_logic_vector(4 downto 1);
        encoded : out std_logic_vector(7 downto 1)
    );
end hamming_sender;

architecture encode of hamming_sender is
    begin
    encoder : process(clk)
        -- data_in : in std_logic_vector(4 downto 1);
        variable output : std_logic_vector(7 downto 1);
    begin
        if rising_edge(clk) then
            -- data
            encoded(3) <= data_in(4);
            encoded(5) <= data_in(3);
            encoded(6) <= data_in(2);
            encoded(7) <= data_in(1);
            -- parity
            encoded(1) <= data_in(4) xor data_in(3) xor data_in(1); -- 3 5 7
            encoded(2) <= data_in(4) xor data_in(2) xor data_in(1); -- 3 6 7
            encoded(4) <= data_in(3) xor data_in(2) xor data_in(1); -- 5 6 7
        end if;
    end process;
end encode;
