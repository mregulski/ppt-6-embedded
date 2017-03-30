
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.txt_util.all;

entity sm2 is
  port(
	clk:     in std_logic;
	pusher:  in std_logic;
	reset: 	in std_logic;
	driver: out std_logic
  );
end sm2;

architecture Flow of sm2 is
  type stan is (SA, SB, SC, SD);
  signal stan_teraz : stan := SA;
  signal stan_potem : stan := SA;
begin

state_advance: process(clk, reset)
begin
	if reset = '1'
	then
		stan_teraz <= SA;
	end if;
  if rising_edge(clk) then
		-- report "tick";
		-- if pusher = '1' then
    	stan_teraz <= stan_potem;
		-- end if;
  end if;
end process;

printer: process(stan_teraz)
begin
	case stan_teraz is
		when SA => 
			report "New state: SA";
		when SB => 
			report "New state: SB";
		when SC => 
			report "New state: SC";
		when SD => 
			report "New state: SD";
	end case;
end process;

next_state: process(stan_teraz, pusher)
begin
   case stan_teraz is
     when SA => 
		 		if pusher = '1' then 
					stan_potem <= SB;
					else stan_potem <= SA;
				end if;
				driver <= '0';
	  when SB => 
			if pusher = '1' then 
				stan_potem <= SC;
			else stan_potem <= SB;
			end if;
			driver <= '1';
	  when SC => 
			if pusher = '1' then 
				stan_potem <= SD;
			else stan_potem <= SC;
			end if;
			driver <= '0';				
	  when SD => 
			if pusher = '1' then 
				stan_potem <= SB;
			else stan_potem <= SD;
			end if;
			driver <= '1';				
   end case;
end process;
end Flow;

