library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity ram2_tb is
end ram2_tb;

architecture test of ram2_tb is
    component ram2
        generic (
            ID : std_logic_vector(8 downto 0);
            ADDRESS_WIDTH: integer;
            WORD_WIDTH: integer
        );
        port (
            clk:       in std_logic;
            address:   in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
            data_in:   in std_logic_vector(WORD_WIDTH-1 downto 0);
            data_out:   out std_logic_vector(WORD_WIDTH-1 downto 0);
            dbg_state: out std_logic_vector(1 downto 0);
            dbg_cmd:   out std_logic
        );
    end component;

    constant clk_period : time := 20 ns;

    signal clk      : std_logic := '0';
    signal data_bus : std_logic_vector(8 downto 0) := (others => 'Z');
    signal address  : std_logic_vector(4 downto 0) := (others => 'Z');
    signal dbg_state: std_logic_vector(1 downto 0) := (others => 'Z');
    signal dbg_cmd  : std_logic;


begin
     uut: ram2
        generic map(
            ID => "100010001",
            ADDRESS_WIDTH => 5,
            WORD_WIDTH => 9
        )
        port map(
            clk => clk,
            data_in => data_bus,
            data_out => data_bus,
            address => address,
            dbg_state => dbg_state,
            dbg_cmd => dbg_cmd
        );

    test_process : process
    begin
        wait for clk_period * 2;

        -- write "101010101" to address 00001

        data_bus <= "100010001";
        wait for clk_period;

        data_bus <= "000000001";
        wait for clk_period;

        address <= "00001";
        data_bus <= "101010101";
        wait for clk_period * 2;


        -- write "111100001" to address 00010

        data_bus <= "100010001";
        wait for clk_period;

        data_bus <= "000000001";
        wait for clk_period;

        address <= "00010";
        data_bus <= "111100001";
        wait for clk_period * 2;


        -- read from 00001

        data_bus <= "100010001";
        wait for clk_period;

        data_bus <= "000000000";
        wait for clk_period;

        address <= "00001";
        wait for clk_period;
        data_bus <= "ZZZZZZZZZ";
        wait for clk_period;
        assert data_bus = "101010101" report "Expected '101010101', but got '" & str(data_bus) & "'";
        wait for clk_period;

        -- read from 00010

        data_bus <= "100010001";
        wait for clk_period;

        data_bus <= "000000000";
        wait for clk_period;

        address <= "00010";
        wait for clk_period;
        data_bus <= "ZZZZZZZZZ";
        wait for clk_period;
        assert data_bus = "111100001" report "Expected '111100001', but got '" & str(data_bus) & "'";
        wait for clk_period;
        wait;
    end process;


    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
end test;