-- This file is not intended for synthesis, is is present so that simulators
-- see a complete view of the system.

-- You may use the entity declaration from this file as the basis for a
-- component declaration in a VHDL file instantiating this entity.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity bandpass4M is
	port (
		Clock : in std_logic;
		Input1 : in std_logic_vector(10-1 downto 0);
		Output : out std_logic_vector(10-1 downto 0);
		aclr : in std_logic
	);
end entity bandpass4M;

architecture rtl of bandpass4M is

component bandpass4M_GN is
	port (
		Clock : in std_logic;
		Input1 : in std_logic_vector(10-1 downto 0);
		Output : out std_logic_vector(10-1 downto 0);
		aclr : in std_logic
	);
end component bandpass4M_GN;

begin

bandpass4M_GN_0: if true generate
	inst_bandpass4M_GN_0: bandpass4M_GN
		port map(Clock => Clock, Input1 => Input1, Output => Output, aclr => aclr);
end generate;

end architecture rtl;

