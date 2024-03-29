-- This file is not intended for synthesis, is is present so that simulators
-- see a complete view of the system.

-- You may use the entity declaration from this file as the basis for a
-- component declaration in a VHDL file instantiating this entity.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity alt_dspbuilder_delay is
	generic (
		CLOCKPHASE : string := "1";
		DELAY : positive := 1;
		USE_INIT : natural := 0;
		BITPATTERN : string := "00000001";
		WIDTH : positive := 8
	);
	port (
		input : in std_logic_vector(width-1 downto 0) := (others=>'0');
		clock : in std_logic := '0';
		sclr : in std_logic := '0';
		aclr : in std_logic := '0';
		output : out std_logic_vector(width-1 downto 0);
		ena : in std_logic := '0'
	);
end entity alt_dspbuilder_delay;

architecture rtl of alt_dspbuilder_delay is

component alt_dspbuilder_delay_GN6XVZIBTQ is
	generic (
		CLOCKPHASE : string := "1";
		DELAY : positive := 1;
		USE_INIT : natural := 0;
		BITPATTERN : string := "0000000000000000000100000";
		WIDTH : positive := 25
	);
	port (
		aclr : in std_logic := '0';
		clock : in std_logic := '0';
		ena : in std_logic := '0';
		input : in std_logic_vector(25-1 downto 0) := (others=>'0');
		output : out std_logic_vector(25-1 downto 0);
		sclr : in std_logic := '0'
	);
end component alt_dspbuilder_delay_GN6XVZIBTQ;

component alt_dspbuilder_delay_GNQC3GUCBB is
	generic (
		CLOCKPHASE : string := "1";
		DELAY : positive := 1;
		USE_INIT : natural := 0;
		BITPATTERN : string := "00000000000000000000000100000";
		WIDTH : positive := 29
	);
	port (
		aclr : in std_logic := '0';
		clock : in std_logic := '0';
		ena : in std_logic := '0';
		input : in std_logic_vector(29-1 downto 0) := (others=>'0');
		output : out std_logic_vector(29-1 downto 0);
		sclr : in std_logic := '0'
	);
end component alt_dspbuilder_delay_GNQC3GUCBB;

begin

alt_dspbuilder_delay_GN6XVZIBTQ_0: if ((CLOCKPHASE = "1") and (DELAY = 1) and (USE_INIT = 0) and (BITPATTERN = "0000000000000000000100000") and (WIDTH = 25)) generate
	inst_alt_dspbuilder_delay_GN6XVZIBTQ_0: alt_dspbuilder_delay_GN6XVZIBTQ
		generic map(CLOCKPHASE => "1", DELAY => 1, USE_INIT => 0, BITPATTERN => "0000000000000000000100000", WIDTH => 25)
		port map(aclr => aclr, clock => clock, ena => ena, input => input, output => output, sclr => sclr);
end generate;

alt_dspbuilder_delay_GNQC3GUCBB_1: if ((CLOCKPHASE = "1") and (DELAY = 1) and (USE_INIT = 0) and (BITPATTERN = "00000000000000000000000100000") and (WIDTH = 29)) generate
	inst_alt_dspbuilder_delay_GNQC3GUCBB_1: alt_dspbuilder_delay_GNQC3GUCBB
		generic map(CLOCKPHASE => "1", DELAY => 1, USE_INIT => 0, BITPATTERN => "00000000000000000000000100000", WIDTH => 29)
		port map(aclr => aclr, clock => clock, ena => ena, input => input, output => output, sclr => sclr);
end generate;

assert not (((CLOCKPHASE = "1") and (DELAY = 1) and (USE_INIT = 0) and (BITPATTERN = "0000000000000000000100000") and (WIDTH = 25)) or ((CLOCKPHASE = "1") and (DELAY = 1) and (USE_INIT = 0) and (BITPATTERN = "00000000000000000000000100000") and (WIDTH = 29)))
	report "Please run generate again" severity error;

end architecture rtl;

