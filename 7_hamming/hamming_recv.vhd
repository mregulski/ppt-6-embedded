library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.txt_util.all;
entity hamming_recv is
    port (
        clk : in std_logic;
        data_in : in std_logic_vector(7 downto 1);
        decoded : out std_logic_vector(4 downto 1)
    );
end hamming_recv;

architecture decode of hamming_recv is

    signal idx_err : integer := 0;
begin


    decoder : process(data_in)
        variable idx_err : integer := 0;
        variable tmp : std_logic_vector(7 downto 1) := (others => '0');
    begin
            tmp := data_in;
            idx_err := 0;
            if ((data_in(3) xor data_in(5) xor data_in(6)) /= data_in(1)) then
                idx_err := idx_err + 1;
            end if;
            if ((data_in(3) xor data_in(6) xor data_in(7))) /= data_in(2) then
                idx_err := idx_err + 2;
            end if;
            if (data_in(5) xor data_in(6) xor data_in(7)) /= data_in(4) then
                idx_err := idx_err + 4;
            end if;

            if (idx_err > 0) then
                tmp(idx_err+1) := not tmp(idx_err+1);
            end if;
                decoded(4) <= tmp(3);
                decoded(3) <= tmp(5);
                decoded(2) <= tmp(6);
                decoded(1) <= tmp(7);
    end process;

end decode;