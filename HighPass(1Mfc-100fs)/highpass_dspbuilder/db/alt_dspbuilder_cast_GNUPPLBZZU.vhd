library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library altera;
use altera.alt_dspbuilder_package.all;

library lpm;
use lpm.lpm_components.all;
entity alt_dspbuilder_cast_GNUPPLBZZU is
	generic		( 			round : natural := 0;
			saturate : natural := 0);

	port(
		input : in std_logic_vector(24 downto 0);
		output : out std_logic_vector(42 downto 0));		
end entity;



architecture rtl of alt_dspbuilder_cast_GNUPPLBZZU is 
Begin

-- Output - I/O assignment from Simulink Block  "Output"
Outputi : alt_dspbuilder_SBF generic map(
				width_inl=> 20 ,
				width_inr=> 5,
				width_outl=> 22,
				width_outr=> 21,
				lpm_signed=>  BusIsSigned ,
				round=> round,
				satur=> saturate)
		port map (
								xin(24 downto 0)  => input,
																yout => output				
				);
				
end architecture;