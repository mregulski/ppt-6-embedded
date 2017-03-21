use std.textio.all;

entity hello_world is
end hello_world;

architecture behaviour of hello_world is
begin
    process
        variable l : line;
        variable bool : boolean;
        variable num : integer;
    begin
        write (l, String'("Hello World"));
        writeline (output, l);
        readline (input, l);
        writeline (output, l);
        write (output, String'("gimme bool and int"));
        readline (input, l);
        read (l, bool);
        read (l, num);
        write (l, bool);
        write (l, num);
        writeline (output, l);
        wait;
    end process;
end behaviour;