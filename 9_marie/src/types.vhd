library ieee;
USE ieee.std_logic_1164.ALL;

package types is
    type debug_t is array(integer range<>) of std_logic_vector(3 downto 0);
end types;