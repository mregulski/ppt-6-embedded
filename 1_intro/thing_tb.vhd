entity thing_tb is
end thing_tb;

architecture bhv of thing_tb is
    component thing
        port (i0, i1, i2 : in bit; o1, o2 : out bit);
    end component;
    for thing_0: thing use entity work.thing;
    signal i0, i1, i2, o1, o2 : bit;
begin
    thing_0: thing port map (i0 => i0, i1 => i1, i2 => i2, o1 => o1, o2 => o2);
    process
        type pattern_type is record
            i0, i1, i2 : bit;
            o1, o2 : bit;
        end record;
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        (('0','0','0','1','0'),
         ('0', '0', '1', '0', '1'),
         ('0', '1', '0', '0', '1'),
         ('0', '1', '1', '0', '1'),
         ('1', '0', '0', '1', '0'),
         ('1', '0', '1', '0', '1'),
         ('1', '1', '0', '0', '0'),
         ('1', '1', '1', '0', '0'));
    begin
        for i in patterns'range loop
            i0 <= patterns(i).i0;
            i1 <= patterns(i).i1;
            i2 <= patterns(i).i2;
            wait for 1 ns;
            assert o1 = patterns(i).o1
                report "bad out_1 value" severity error;
            assert o2 = patterns(i).o2
                report "bad out_2 value" severity error;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end bhv;