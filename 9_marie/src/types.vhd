library ieee;
USE ieee.std_logic_1164.ALL;

package types is
    type debug_t is array(integer range<>) of std_logic_vector(3 downto 0);

     type control_t is record
        PC     : std_logic_vector(2 downto 0);
        -- memory
        MEM    : std_logic;
        -- ALU
        ALU    : std_logic;
        -- registers
        AC     : std_logic;
        MAR    : std_logic;
        MBR    : std_logic;
        IR     : std_logic;
        INreg  : std_logic;
        OUTreg : std_logic;
    end record;

end types;