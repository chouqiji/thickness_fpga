--------------------------------------------------------------------------------------------
-- DSP Builder (Version 7.2)
-- Quartus II development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: © 2007 Altera Corporation. All rights reserved.  Your use of Altera 
-- Corporation's design tools, logic functions and other software and tools, and its 
-- AMPP partner logic functions, and any output files any of the foregoing 
-- (including device programming or simulation files), and any associated 
-- documentation or information are expressly subject to the terms and conditions 
-- of the Altera Program License Subscription Agreement, Altera MegaCore Function 
-- License Agreement, or other applicable license agreement, including, without 
-- limitation, that your use is for the sole purpose of programming logic devices 
-- manufactured by Altera and sold by Altera or its authorized distributors.  
-- Please refer to the applicable agreement for further details.
--------------------------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library altera;
use altera.alt_dspbuilder_package.all;

library LPM;
use LPM.LPM_COMPONENTS.all;

entity alt_dspbuilder_CST_MULT is 
		GENERIC (
			      widthin      : positive          := 4;    
			      widthcoef    : positive          := 4;    
			      widthr       : positive          := 10;    
			      cst          : std_logic_vector  := "0001";
			      lpm_hint	   : string            := "INPUT_B_IS_CONSTANT=YES";
			      pipeline     : natural           := 0);
		PORT (
					clock		: in std_logic                             ;
					aclr		: in std_logic                             ;
                    part_sclr	: in std_logic                             ;
					ena     	: in std_logic                             ;
					data		: in std_logic_vector  (widthin-1 DOWNTO 0);
					result		: out std_logic_vector (widthr-1 DOWNTO 0)
		      );
end alt_dspbuilder_CST_MULT;

architecture synth of alt_dspbuilder_CST_MULT is

constant CSTVec   : std_logic_vector(widthcoef-1 downto 0):= cst;
constant zeroCst  : std_logic_vector(widthcoef-1 downto 0):= (others=>'0'); 
constant oneCst   : std_logic_vector(widthcoef-1 downto 0):= int2ustd(1, widthcoef); 
constant moneCst  : std_logic_vector(widthcoef-1 downto 0):= int2sstd(-1, widthcoef); 

signal	data1_int : std_logic_vector(widthin DOWNTO 0);
signal	data2_int : std_logic_vector(widthin DOWNTO 0);

constant nwcst    : integer                               := Nstd_bitnecessary(CSTVec);
constant sCSTVec  : std_logic_vector(nwcst-1 downto 0)    := CSTVec(nwcst-1 downto 0) ;
signal   sres     : std_logic_vector(nwcst+widthin-1 downto 0)                             ;

signal sCSTVec_int : std_logic_vector(nwcst-1 downto 0);

begin
	-- Multiply by 0
	gz: if CSTVec=zeroCst generate
		result <=(others=>'0');
	end generate gz; 

	-- Multiply by 1 (coef width must be >1 as coef signed)
	go: if CSTVec=oneCst and widthcoef>1 generate
		U0: alt_dspbuilder_BEXT generic map(delay=>pipeline, widthin=>widthin,widthout=>widthr)
			     port map 	(din=>data, clock=>clock, aclr=>aclr, sclr=>part_sclr, ena=>ena, dout=>result);
	end generate go; 

	-- Multiply by positive power of two
	gp2: if StdPowerOfTwo(CSTVec)>0 and StdPowerOfTwo(CSTVec)<(widthcoef-1) and widthcoef>1  generate -- coef power of two
		glsb: for i in 0 to StdPowerOfTwo(CSTVec)-1 generate
			sres(i) <= '0';
		end generate glsb;

		gm: for i in StdPowerOfTwo(CSTVec) to StdPowerOfTwo(CSTVec)+widthin-1 generate
			sres(i) <= data(i-StdPowerOfTwo(CSTVec));
		end generate gm;
		
		gt:if StdPowerOfTwo(CSTVec)+widthin-1<nwcst+widthin-1 generate
			gt1: for i in StdPowerOfTwo(CSTVec)+widthin to nwcst+widthin-1 generate
				sres(i) <= sres(StdPowerOfTwo(CSTVec)+widthin-1);
			end generate gt1;
		end generate gt;

		BEXT0: alt_dspbuilder_BEXT generic map(delay=>pipeline, widthin=>nwcst+widthin,widthout=>widthr)
			     port map 	(din=>sres, clock=>clock, aclr=>aclr, sclr=>part_sclr, ena=>ena, dout=>result);
			     		
	end generate gp2;

	-- Multiply by -1
	gmo: if CSTVec=moneCst generate
		
		data1_int(widthin-1 DOWNTO 0) <= data(widthin-1 DOWNTO 0);
		data1_int(widthin) <= data1_int(widthin-1);

		gc:if pipeline=0 generate
			data2_int <= -data1_int;			
		end generate gc;

		gp:if pipeline>0 generate
			U1 : lpm_add_sub generic map ( lpm_width => widthin+1, lpm_representation => "SIGNED",lpm_direction => "SUB", lpm_type => "LPM_ADD_SUB", lpm_hint => "UNUSED", lpm_pipeline => pipeline)
							 port map     (dataa => (others=>'0'), datab => data1_int, clken=>ena, aclr => aclr, clock => clock, result => data2_int);
		end generate gp;
						
		BEXT0: alt_dspbuilder_BEXT generic map(delay=>0, widthin=>widthin+1,widthout=>widthr)
			     port map 	(din=>data2_int, clock=>clock, aclr=>aclr, sclr=>part_sclr, ena=>ena, dout=>result);

	end generate gmo; 

	-- Other cases
	gg:if CSTVec/=zeroCst and CSTVec/=oneCst and CSTVec/=moneCst and (StdPowerOfTwo(CSTVec)=0 or StdPowerOfTwo(CSTVec)=(widthcoef-1)) and widthcoef>1 generate
					
		gp:if pipeline>0 generate
		
			   U0 : lpm_mult GENERIC MAP ( lpm_widtha         => widthin,
				                           lpm_widthb         => nwcst,
				                           lpm_widthp         => nwcst+widthin,
				                           lpm_widths         => 1,
				                           lpm_pipeline       => pipeline,
				                           lpm_type           => "LPM_MULT",
				                           lpm_representation => "SIGNED",		                           
				                           lpm_hint           => lpm_hint)
		    				PORT MAP (     dataa              => data,
				                           datab              => sCSTVec,
				                           clock              => clock,
										   clken              => ena,
				                           aclr               => aclr,
				                           result             => sres);   
		end generate gp;
	
		gc:if pipeline=0 generate
				sres <= sCSTVec * data;
		end generate gc;

		BEXT0: alt_dspbuilder_BEXT generic map(delay=>0, widthin=>nwcst+widthin,widthout=>widthr)
			     port map 	(din=>sres, clock=>clock, aclr=>aclr, sclr=>part_sclr, ena=>ena, dout=>result);
				
	end generate gg;

end architecture synth;

