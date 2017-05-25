library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.txt_util.all;

-----------------------------------------------------------------------
-- a (working) skeleton template for slave device on 8-bit bus
-- capable of executing commands sent on the bus in the sequence:
-- 	1) device_address (8 bits)
--	2) cmd_opcode (4 bits) & delay (4 bits)
--	3) (optional) cmd_args (8 bits)
--
-- currently supported commands:
-- 	* ID 		[0010] - get device address
-- 	* DATA_REQ 	[0100] - send current result in the next clockpulse
-- 	* NOP 		[0000] - don't do anything
-----------------------------------------------------------------------
-- debugging information on current state of statemachine and command
-- executed and input buffer register is given in outputs, vstate,
-- vcurrent_cmd and vq, respectively
-----------------------------------------------------------------------
-- extra commands:
-- 	* CRC 		[0011] - calculate crc
--  * ADD 		[0001] - add argument to accumulator. Accumulator is reset upon receiving DATA_REQ
--  * RAND		[0101] - return 8 pseudorandom bits (constant seed tho)
-----------------------------------------------------------------------

entity slave is
    generic ( identifier : std_logic_vector (7 downto 0) := "10101010" );
    Port ( conn_bus : inout  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
			  state : out STD_LOGIC_VECTOR (5 downto 0);
			  vq : out std_logic_vector (7 downto 0);
			  vcurrent_cmd : out std_logic_vector(3 downto 0)
			  );
end slave;

architecture Behavioral of slave is

-- statemachine definitions
type state_type is (IDLE, CMD, RUN);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;
-- for debugging entity's state
signal vstate : std_logic_vector(5 downto 0) := (others => '0');

-- command definitions
type cmd_type is (NOP, ADD, ID, CRC, DATA_REQ, RAND);
attribute enum_encoding: string;
attribute enum_encoding of cmd_type: type is
				"0000 0001 0010 0011 0100 0101";
signal current_cmd : cmd_type := NOP;

-- input buffer
signal q : std_logic_vector (7 downto 0) := (others => '0');

-- for storing results and indicating it is to be sent to bus
signal result_reg : std_logic_vector (7 downto 0) := (others => '0');
signal sending : std_logic := '0';

--------------------
-- CRC
--------------------
function crc(last, data: in std_logic_vector) return std_logic_vector is
	variable newCrc: std_logic_vector(7 downto 0);
begin
 	newCRC(0) := data(7) xor data(6) xor data(0) xor last(0) xor last(6) xor last(7);
	newCRC(1) := data(6) xor data(1) xor data(0) xor last(0) xor last(1) xor last(6);
	newCRC(2) := data(6) xor data(2) xor data(1) xor data(0) xor last(0) xor last(1)
							 xor last(2) xor last(6);
	newCRC(3) := data(7) xor data(3) xor data(2) xor data(1) xor last(1) xor last(2)
							 xor last(3) xor last(7);
	newCRC(4) := data(4) xor data(3) xor data(2) xor last(2) xor last(3) xor last(4);
	newCRC(5) := data(5) xor data(4) xor data(3) xor last(3) xor last(4) xor last(5);
	newCRC(6) := data(6) xor data(5) xor data(4) xor last(4) xor last(5) xor last(6);
	newCRC(7) := data(7) xor data(6) xor data(5) xor last(5) xor last(6) xor last(7);

	return newCRC;
end crc;



--------------------
-- ADD
--------------------
function add(a, b : in std_logic_vector) return std_logic_vector is
	variable sum, carry : std_logic_vector(7 downto 0) := (others => '0');
begin
	for i in 0 to 7 loop
		sum(i) := carry(i) xor a(i) xor b(i);
		if i < 7 then
			carry(i+1) := (a(i) and b(i)) or (a(i) and carry(i)) or (b(i) and carry(i));
		end if;
	end loop;
	return sum;
end add;

--------------------
-- RANDOM
-- generate 8 bits of lfsr output, starting with state
--------------------
procedure random(state : inout std_logic_vector; signal output : out std_logic_vector) is
	variable acc  : std_logic_vector(7 downto 0) := (others => '0');
begin
	for i in 0 to 7 loop
		state(7 downto 1) := state(6 downto 0);
		state(0) := state(7) xor state(5) xor state(4) xor state(3);
		acc(i) := state(0);
	end loop;
	report "rand: acc: " & str(acc);
	output <= acc;
end random;

signal vdelay : std_logic_vector(3 downto 0) := "0000";

begin

stateadvance: process(clk)
begin
  if rising_edge(clk)
  then
    q  <= conn_bus;
    current_s <= next_s;
  end if;
end process;


nextstate: process(current_s,q)
  variable fourbit : std_logic_vector(3 downto 0) := "0000";
  variable crc_acc, add_acc : std_logic_vector(7 downto 0) := (others => '0');
  variable lfsr : std_logic_vector(7 downto 0) := (others => '1');
  variable delay_ctr : std_logic_vector(3 downto 0) := "0000";
begin

 case current_s is
   when IDLE =>
		vstate <= "000001";		-- set for debugging
		if q = identifier and sending /= '1'
		then
	      next_s <= CMD;
		else
			next_s <= IDLE;
		end if;
		sending <= '0';
	when CMD =>
		report "(" & str(identifier) & ") CMD: current delay: " & str(delay_ctr);

		if delay_ctr = "0000" then
			vstate <= "000010";
			-- command decode

			if q(3 downto 0) /= "0000" and q(3 downto 0) /= "ZZZZ" then
				delay_ctr := q(3 downto 0);
				report "(" & str(identifier) & ") new delay: " & str(delay_ctr);
			end if;
			fourbit := q(7 downto 4);
			case fourbit is
					when "0000" => current_cmd <= NOP;
					when "0001" => current_cmd <= ADD;
					when "0010" => current_cmd <= ID;
					when "0011" => current_cmd <= CRC;
					when "0100" => current_cmd <= DATA_REQ;
					when "0101" => current_cmd <= RAND;
					when others => current_cmd <= NOP;
				end case;
			if delay_ctr = "0000" then
				next_s <= RUN;
			else
				next_s <= CMD;
			end if;
		else
			delay_ctr := std_logic_vector(unsigned(delay_ctr) - 1);
			report "(" & str(identifier) & ") delay left: " & str(delay_ctr);
			if delay_ctr = "0000" then
				next_s <= RUN;
			else
				next_s <= CMD;
			end if;
		end if;
	when RUN =>
		vstate <= "000100";
		-- determine action based on currend_cmd state
		case current_cmd is
			when NOP
				=> result_reg <= result_reg;
			when ID
				=> result_reg <= identifier;
			when DATA_REQ =>
					report "(" & str(identifier) & ") DATA_REQ";
					sending <= '1';
					add_acc := (others => '0');
			when CRC =>
					report "(" & str(identifier) & ") CRC";
					result_reg <= crc(crc_acc, q);
			when ADD =>
					report "(" & str(identifier) & ") ADD: acc: " & str(add_acc) & ", q: " & str(q);
					add_acc := add(add_acc, q);
					result_reg <= add_acc;
			when RAND =>
					report "(" & str(identifier) & ") RAND";
					random(lfsr, result_reg);

			-- here other commands execution
			--
			when others
				=> result_reg <= result_reg;
		end case;
		-- current_cmd <= NOP;
		next_s <= IDLE;
   when others =>
		vstate <= "111111";
		next_s <= IDLE;
   end case;
end process;


-- tri-state bus
conn_bus <= result_reg when sending = '1' else "ZZZZZZZZ";

-- output debugging signals
state <= vstate;
vq    <= q;
with current_cmd select
 vcurrent_cmd <= 	"0001" when ADD,
					"0010" when ID,
					"0011" when CRC,
					"0100" when DATA_REQ,
					"0101" when RAND,
					"0000" when others;


end Behavioral;

