LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY lfsr_rng_tb IS
END lfsr_rng_tb;
 
ARCHITECTURE behavior OF lfsr_rng_tb IS 
 
    -- UUT (Unit Under Test)
    COMPONENT lfsr_16
        PORT(
            clk : IN  std_logic;
            q : INOUT  std_logic_vector(15 downto 0)
            );
    END COMPONENT;
    
    COMPONENT lfsr_19
        Port ( clk : in  STD_LOGIC;
           q : inout  STD_LOGIC_VECTOR(18 downto 0) 
            := std_logic_vector(to_unsigned(1, 19))
			);
    end COMPONENT;
   -- input signals
   signal clk : std_logic := '0';

   -- output signal
   signal qs : std_logic_vector(15 downto 0);
   signal ql : std_logic_vector(18 downto 0);
   signal rn : std_logic_vector(15 downto 0);
   signal start : std_logic := '0';
   -- set clock period 
   constant clk_period : time := 1 ns;
 
BEGIN
	-- instantiate UUT
  rng_1: lfsr_16 
      PORT MAP (
          clk => clk,
          q   => qs
      );
  rng_2: lfsr_19
    port map (
      clk => clk,
        q => ql
    );
   -- clock management process
   -- no sensitivity list, but uses 'wait'
  clk_process: PROCESS
    BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
  END PROCESS;
  
    -- stimulating process
    stim_proc: PROCESS
    BEGIN
      wait until clk'event and clk = '1';
      rn <= ql(15 downto 0) xor qs(15 downto 0);

    END PROCESS;	
END;
