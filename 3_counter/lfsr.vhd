library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity lfsr_16 is
  Port ( clk : in  STD_LOGIC;
           q : inout  STD_LOGIC_VECTOR(15 downto 0) 
            := std_logic_vector(to_unsigned(16#D295#, 16))
			);
end lfsr_16;



ARCHITECTURE Behavioral OF lfsr_16 IS
BEGIN
  PROCESS
  BEGIN

	q(15 downto 1) <= q(14 downto 0);
  
  q(0) <= (q(15) XOR q(14) XOR q(13) XOR q(4));
	-- q(0) <= not(q(15) XOR q(14) XOR q(13) XOR q(4));
	
	WAIT UNTIL clk'event AND clk='1';
  END PROCESS;
END Behavioral;
