LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY multislave_tb IS
END multislave_tb;

ARCHITECTURE behavior OF multislave_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

	COMPONENT slave
		generic ( identifier : std_logic_vector (7 downto 0) );
    PORT(
        	conn_bus : INOUT  std_logic_vector(7 downto 0);
        	clk : IN  std_logic;
			state : out STD_LOGIC_VECTOR (5 downto 0);
			vq : out std_logic_vector (7 downto 0);
			vcurrent_cmd : out std_logic_vector(3 downto 0)
        );
    END COMPONENT;


   	--Inputs
   	signal clk : std_logic := '0';

	--BiDirs
   	signal conn_bus : std_logic_vector(7 downto 0) := (others => 'Z');


	-- outputs from UUT for debugging: A
	signal stateA : std_logic_vector(5 downto 0);
	signal vqA : std_logic_vector (7 downto 0);
	signal current_cmdA : std_logic_vector (3 downto 0);

	-- outputs from UUT for debugging: B
	signal stateB : std_logic_vector(5 downto 0);
	signal vqB : std_logic_vector (7 downto 0);
	signal current_cmdB : std_logic_vector (3 downto 0);

   	-- Clock period definitions
   	constant clk_period : time := 10 ns;

	procedure send(id, cmd : in std_logic_vector; signal conn_bus : out std_logic_vector) is
		begin
		conn_bus <= id;
		wait for clk_period;
		conn_bus <= cmd;
		wait for clk_period;
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;
	end send;

   	procedure send(id, cmd, args : in std_logic_vector; signal conn_bus : out std_logic_vector) is
	begin
		conn_bus <= id;
		wait for clk_period;
		conn_bus <= cmd;
		wait for clk_period;
		conn_bus <= args;
		wait for clk_period;
	end send;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   slave_A: slave
	GENERIC MAP (identifier => "00001010")
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => stateA,
			 vq => vqA,
			 vcurrent_cmd => current_cmdA
        );

	slave_B: slave
	GENERIC MAP (identifier => "00001011")
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => stateB,
			 vq => vqB,
			 vcurrent_cmd => current_cmdB
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

		-- A, ADD, 0x10
		send(conn_bus => conn_bus, id => "00001010", cmd => "00010000", args => "00100000");

		-- B, ADD, 0x01
		send(conn_bus => conn_bus, id => "00001011", cmd => "00010000", args => "00000010");

		-- B, ADD, <after 3>
		send(conn_bus => conn_bus, id => "00001011", cmd => "00010100", args => "00010000");

		-- A, DATA_REQ
		send(conn_bus => conn_bus, id => "00001010", cmd => "01000000");
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;

		-- B, DATA_REQ
		send(conn_bus => conn_bus, id => "00001011", cmd => "01000000");
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;

      	-- -- wait for clk_period*10;
	  	-- -- CMD: id
		-- send(conn_bus => conn_bus, id => "00001010", cmd => "00101111");
		-- -- CMD: id
		-- send(conn_bus => conn_bus, id => "00001011", cmd => "00100000");

		-- -- CMD: data_req
		-- send(conn_bus => conn_bus, id => "00001011", cmd => "01000000");

		-- conn_bus <= "ZZZZZZZZ";
		-- wait for clk_period*3;

		-- -- CMD: data_req
		-- send(conn_bus => conn_bus, id => "00001010", cmd => "01000000");
		-- wait for clk_period*3;
		-- conn_bus <= "ZZZZZZZZ";

		-- send(conn_bus => conn_bus, id => "00001010", cmd => "00010000", args=>"00000001");
		-- send(conn_bus => conn_bus, id => "00001010", cmd => "00010000", args=>"00000001");
		-- send(conn_bus => conn_bus, id => "00001010", cmd => "01000000");
		-- send(conn_bus => conn_bus, id => "00001011", cmd => "00010000", args=>"00000001");
		-- wait for clk_period*3;
		-- conn_bus <= "ZZZZZZZZ";


		-- -- CMD: id
		-- send(conn_bus => conn_bus, id => "00001011", cmd => "00100000");
		-- -- CMD: data_req
		-- send(conn_bus => conn_bus, id => "00001011", cmd => "01000000");

		-- conn_bus <= "ZZZZZZZZ";
		-- wait for clk_period*3;
		-- -- CMD: crc
		-- send(conn_bus => conn_bus, id => "10101010", cmd => "00110000", args => "10101011");
		-- -- CMD: data_req
		-- send(conn_bus => conn_bus, id => "10101010", cmd => "01000000");


		-- conn_bus <= "ZZZZZZZZ";
		-- wait for clk_period*3;


		-- -- CMD: add
		-- send(conn_bus => conn_bus, id => "10101010", cmd=> "00010000", args => "01010101");
		-- -- CMD: add
		-- send(conn_bus => conn_bus, id => "10101010", cmd=> "00010000", args => "10101010");

		-- -- CMD: data_req
		-- send(conn_bus => conn_bus, id => "10101010", cmd => "01000000");

		-- conn_bus <= "ZZZZZZZZ";
		-- wait for clk_period*3;

		-- for i in 0 to 7 loop
		-- 	-- CMD: rand
		-- 	send(conn_bus => conn_bus, id => "10101010", cmd => "01010000");

		-- 	-- CMD: data_req
		-- 	send(conn_bus => conn_bus, id => "10101010", cmd => "01000000");

		-- 	conn_bus <= "ZZZZZZZZ";
		-- 	wait for clk_period*3;
		-- end loop;


      	wait;
   	end process;

END;
