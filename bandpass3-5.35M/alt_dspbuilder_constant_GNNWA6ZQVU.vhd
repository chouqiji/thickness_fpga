library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library altera;
use altera.alt_dspbuilder_package.all;

library lpm;
use lpm.lpm_components.all;
entity alt_dspbuilder_constant_GNNWA6ZQVU is
	generic		( 			HDLTYPE : string := "STD_LOGIC_VECTOR";
			BitPattern : string := "1000000000";
			width : natural := 10);

	port(
		output : out std_logic_vector(9 downto 0));		
end entity;

architecture rtl of alt_dspbuilder_constant_GNNWA6ZQVU is 
Begin
-- Constant
output		<=	"1000000000";				
end architecture;