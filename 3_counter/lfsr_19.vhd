library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity lfsr_19 is
  Port ( clk : in  std_logic;
           q : inout  STD_LOGIC_VECTOR(18 downto 0) := std_logic_vector(to_unsigned(16#593ca#, 19))
			);
end lfsr_19;


ARCHITECTURE Behavioral OF lfsr_19 IS
BEGIN
  PROCESS
  BEGIN
	q(18 downto 1) <= q(17 downto 0);
  
  -- q(0) <= (q(15) XOR q(14) XOR q(13) XOR q(4));
	q(0) <= q(18) XOR q(17) XOR q(16) XOR q(13);
	
	WAIT UNTIL clk'event AND clk='1';
  END PROCESS;
END Behavioral;
