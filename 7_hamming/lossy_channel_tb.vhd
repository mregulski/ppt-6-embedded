
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lossy_channel_tb IS
END lossy_channel_tb;

ARCHITECTURE behavior OF lossy_channel_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT lossy_channel
      GENERIC (N : positive);
      PORT(
         data_in : IN  std_logic_vector(N-1 downto 0);
         clk : IN  std_logic;
         data_out : OUT  std_logic_vector(N-1 downto 0)
        );
    END COMPONENT;

    component hamming_sender
      port (
        clk : in std_logic;
        data_in : in std_logic_vector(4 downto 1);
        encoded : out std_logic_vector(7 downto 1)
      );
    end component;

    component hamming_recv
      port (
        clk : in std_logic;
        data_in : in std_logic_vector(7 downto 1);
        decoded : out std_logic_vector(4 downto 1)
      );
    end component;

    signal clk : std_logic := '0';

    -- channel bitwidth
    constant WIDTH : positive := 7;
    signal chan_in : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal chan_out : std_logic_vector(WIDTH-1 downto 0);

    signal data_in : std_logic_vector(4 downto 1) := (others => '0');
    signal data_out : std_logic_vector(4 downto 1) := (others => '0');


   -- clock period definitions
  constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: lossy_channel
   GENERIC MAP ( N => WIDTH )
   PORT MAP (
          data_in => chan_in,
          clk => clk,
          data_out => chan_out
        );

  sender: hamming_sender
  port map (
     data_in => data_in,
     clk => clk,
     encoded => chan_in
  );

  recv: hamming_recv
  port map (
    data_in => chan_out,
    clk => clk,
    decoded => data_out
  );

   -- Clock process definitions
   clk_process: process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
    variable last_in : std_logic_vector(4 downto 1);
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

    for j in 0 to 50
    loop
      for i in 0 to 15
      loop

        data_in <= std_logic_vector(to_unsigned(i, data_in'length));
        last_in := data_in;
        wait for clk_period;
          assert last_in = data_out report "flip!";
      end loop;
    end loop;
    wait;
   end process;

END;
