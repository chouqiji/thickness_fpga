library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
entity highpass_example is  
	port(
		Input1 : in STD_LOGIC_VECTOR(9 downto 0);
		Clock : in STD_LOGIC;
		Output : out STD_LOGIC_VECTOR(9 downto 0);
		aclr : in STD_LOGIC); 
end entity;
architecture rtl of highpass_example is
component highpass
	  
	port(
		Input1 : in STD_LOGIC_VECTOR(9 downto 0);
		Clock : in STD_LOGIC;
		Output : out STD_LOGIC_VECTOR(9 downto 0);
		aclr : in STD_LOGIC); 
end component;
begin
	highpass_instance : 
		component highpass
			port map(
				Input1 => Input1,
				Clock => Clock,
				Output => Output,
				aclr => aclr);
end architecture rtl;
