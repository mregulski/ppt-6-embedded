entity thing is
    port (i0, i1, i2 : in bit; o1, o2 : out bit);
end thing;

architecture bhv of thing is
    signal t, b : bit;
begin
    o1 <= (i0 and i1) nor (i1 or i2);
    o2 <= (i0 and i1) xor (i1 or i2);
end bhv;