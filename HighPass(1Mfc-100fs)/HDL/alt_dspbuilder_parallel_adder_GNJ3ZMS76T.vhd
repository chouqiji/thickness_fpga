library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library altera;
use altera.alt_dspbuilder_package.all;

library lpm;
use lpm.lpm_components.all;
entity alt_dspbuilder_parallel_adder_GNJ3ZMS76T is
	generic		( 			direction : string := "+";
			dataWidth : positive := 43;
			MaskValue : string := "1";
			number_inputs : positive := 3;
			pipeline : natural := 1);

	port(
		clock : in std_logic;
		aclr : in std_logic;
		result : out std_logic_vector(44 downto 0);
		user_aclr : in std_logic;
		ena : in std_logic;
		data0 : in std_logic_vector(42 downto 0);
		data1 : in std_logic_vector(42 downto 0);
		data2 : in std_logic_vector(42 downto 0));		
end entity;

architecture rtl of alt_dspbuilder_parallel_adder_GNJ3ZMS76T is 

	-- Connectors at depth 1
	signal connector_1_1 : std_logic_vector(44 - 1 downto 0);
	signal connector_1_2 : std_logic_vector(44 - 1 downto 0);
	-- Connectors at depth 2
	signal connector_2_1 : std_logic_vector(45 - 1 downto 0);

Begin

	adder_1_1 : alt_dspbuilder_SAdderSub generic map (
					LPM_WIDTH		=>	44 - 1,
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
	adder_1_2 : alt_dspbuilder_SAdderSub generic map (
					LPM_WIDTH		=>	44 - 1,
					PIPELINE		=>	1,
					SequenceLength	=>	1,
					SequenceValue 	=>  "1",
-- 1 >= 3
-- 1 >= 4
					AddSubVal		=>	AddAdd
					)
			port map (
					dataa		=>	data2,
					datab		=>	(others=>'0'),
					clock		=>	clock,
					ena    		=>	ena,
					aclr   		=>	aclr,
					user_aclr	=>	user_aclr,
					result		=>	connector_1_2);

	adder_2_1 : alt_dspbuilder_SAdderSub generic map (
					LPM_WIDTH		=>	45 - 1,
					PIPELINE		=>	1,
					SequenceLength	=>	1,
					SequenceValue 	=>  "1",
					AddSubVal		=>	AddAdd)
			port map (
					dataa		=>	connector_1_1,
					datab		=>	connector_1_2,
					clock		=>	clock,
					ena    		=>	ena,
					aclr   		=>	aclr,
					user_aclr	=>	user_aclr,
					result		=>	connector_2_1);

result <= connector_2_1;

end architecture;