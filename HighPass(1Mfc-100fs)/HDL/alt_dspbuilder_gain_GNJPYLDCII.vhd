library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library altera;
use altera.alt_dspbuilder_package.all;

library lpm;
use lpm.lpm_components.all;
entity alt_dspbuilder_gain_GNJPYLDCII is
	generic		( 			lpm : natural := 0;
			InputWidth : natural := 29;
			MaskValue : string := "1";
			gain : string := "10";
			pipeline : natural := 0);

	port(
		clock : in std_logic;
		aclr : in std_logic;
		Input : in std_logic_vector(28 downto 0);
		Output : out std_logic_vector(30 downto 0);
		user_aclr : in std_logic;
		ena : in std_logic);		
end entity;


architecture rtl of alt_dspbuilder_gain_GNJPYLDCII is 
	constant mask		: STD_LOGIC_VECTOR(ToNatural(1-1) downto 0) := "1";
	signal aclr_signal : STD_LOGIC;
	signal seqenable	: std_logic ;
	signal enadff		: std_logic ;

Begin

	-- Reset is a combination of system reset and the user exposed reset
	aclr_signal <= aclr or user_aclr;

	-- Phase selection sequence
	gsq:if 0>0 generate
		gnoseq: if ((1=1) and (mask="1")) generate 
			enadff <= ena;
		end generate gnoseq;	
		gseq: if not ((1=1) and (mask="1")) generate 
			u:alt_dspbuilder_vecseq 	generic map 	(
							SequenceLength=>1,
							SequenceValue=>"1")
					port map		(clock=>clock, ena=>ena, aclr=>aclr_signal, sclr=>'0', yout=> seqenable);	
			enadff <= 	seqenable and ena;
		end generate gseq;
	end generate gsq;

	gnsq:if 0=0 generate
		enadff<='0';
	end generate gnsq;

	-- Gain
	U0:alt_dspbuilder_CST_MULT GENERIC MAP(widthin     => 29,   
			                widthcoef   => 2,   
			                widthr      => 31,   
			                cst         => "10",
			                lpm_hint	=> "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5",
			                pipeline    => 0)
		        PORT MAP   (clock	    => clock,
					        aclr	    => aclr_signal,
					        ena         => enadff,
					        data	    => Input,
					        result	    => Output);					
							
end architecture;