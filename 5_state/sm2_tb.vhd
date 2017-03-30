LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- include also the local library for 'str' call 
USE work.txt_util.ALL;

  
ENTITY sm2_tb IS
END sm2_tb;
 
ARCHITECTURE behavior OF sm2_tb IS 
    COMPONENT sm2
    PORT(
         clk : IN  std_logic;
         pusher : IN  std_logic;
         driver : OUT  std_logic;
         reset: IN std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal pusher : std_logic := '0';
   signal reset : std_logic := '0';
 	--Outputs
   signal driver : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sm2 PORT MAP (
          clk => clk,
          pusher => pusher,
          driver => driver,
          reset => reset
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
    wait for 100 ns;	

      -- wait for clk_period*10;
		pusher <=   '1';				   -- allow state transitions now
		wait for clk_period * 4;	-- let some states transit to some other... 
		pusher <= '0';
    wait for clk_period;
    reset <= '1';
    wait for clk_period;
    reset <= '0';
    pusher <= '1';
		-- assert driver = 			-- test what we've got
		--   report "expected state '01' on driver not achieved -- got '" & str(driver) & "'";

		-- wait for clk_period;			
		-- pusher <= '0';					-- disable state transitions
		-- wait for clk_period * 2;

		-- assert driver = "11"
		-- 	report "expected state '00' on driver not achieved -- got '" & str(driver) & "'";

    -- reset <= '1';
    -- wait for 1 fs;
    -- assert driver = "00" report "expected '00' on driver; got '" & str(driver) & "'";     
    wait;
   end process;

END;

		
