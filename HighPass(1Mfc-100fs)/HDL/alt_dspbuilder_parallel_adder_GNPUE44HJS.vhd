library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library altera;
use altera.alt_dspbuilder_package.all;

library lpm;
use lpm.lpm_components.all;
entity alt_dspbuilder_parallel_adder_GNPUE44HJS is
	generic		( 			direction : string := "+";
			dataWidth : positive := 11;
			MaskValue : string := "1";
			number_inputs : positive := 2;
			pipeline : natural := 1);

	port(
		clock : in std_logic;
		aclr : in std_logic;
		result : out std_logic_vector(11 downto 0);
		user_aclr : in std_logic;
		ena : in std_logic;
		data0 : in std_logic_vector(10 downto 0);
		data1 : in std_logic_vector(10 downto 0));		
end entity;

architecture rtl of alt_dspbuilder_parallel_adder_GNPUE44HJS is 

	-- Connectors at depth 1
	signal connector_1_1 : std_logic_vector(12 - 1 downto 0);

Begin

	adder_1_1 : alt_dspbuilder_SAdderSub generic map (
					LPM_WIDTH		=>	12 - 1,
					PIPELINE		=>	1,
					SequenceLength	=>	1,
					SequenceValue 	=>  "1",
-- 1 >= 1
-- +
-- 1 >= 2
					AddSubVal		=>	AddAdd
					)
			port map (
					dataa		=>	data0,
					datab		=>	data1,
					clock		=>	clock,
					ena    		=>	ena,
					aclr   		=>	aclr,
					user_aclr	=>	user_aclr,
					result		=>	connector_1_1);


result <= connector_1_1;

end architecture;