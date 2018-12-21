--------------------------------------------------------------------------------------------
-- DSP Builder (Version 9.1)
-- Quartus II development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: © 2001 Altera Corporation. All rights reserved.  Your use of Altera 
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

library altera;
use altera.alt_dspbuilder_package.all;

entity alt_dspbuilder_BEXT is
		generic ( 
				delay       : integer  := 0;
				widthin	    : positive := 10;
				widthout    : positive := 10
				);
		port 	( 
				din			: in std_logic_vector(widthin-1 downto 0);
				clock       : in std_logic;
                aclr        : in std_logic;
				sclr        : in std_logic;
				ena         : in std_logic;
				dout		: out std_logic_vector(widthout-1 downto 0)
				);
end alt_dspbuilder_BEXT;


architecture ax of alt_dspbuilder_BEXT is

signal dout_int : std_logic_vector(widthout-1 downto 0);
signal din_int  : std_logic_vector(widthin-1 downto 0);

begin 
u0: alt_dspbuilder_sAltrPropagate generic map(QTB=>DSPBuilderQTB, QTB_PRODUCT => DSPBuilderProduct, QTB_VERSION => DSPBuilderVersion , width=> widthin)
                   port map   (d => din, r => din_int);

g0:if delay=0 generate
	ge:if  widthin>=widthout generate
		dout(widthout-1 downto 0)<=din_int(widthout-1 downto 0);
	end generate ge;		
	gm:if  widthin< widthout generate
		dout(widthin-1 downto 0)<=din_int(widthin-1 downto 0);
		l:for i in widthin to widthout-1 generate
			dout(i) <= din_int(widthin-1);
		end generate l;
	end generate gm;
end generate g0;

g1:if delay=1 generate	
	ge:if  widthin>= widthout generate
		process(clock,aclr)
		begin
            if aclr='1' then
                dout <=(others=>'0');
			elsif clock'event and clock='1' then
				if (sclr ='1') then
					dout <=(others=>'0');
				elsif ena ='1' then
					dout(widthout-1 downto 0)<=din_int(widthout-1 downto 0);
				end if ;
			end if ;
		end process ;
	end generate ge;		

	gm:if  widthin< widthout generate
		process(clock,aclr)
		begin
            if aclr='1' then
                dout_int(widthin-1 downto 0) <=(others=>'0');
			elsif clock'event and clock='1' then
				if (sclr ='1') then
					dout_int(widthin-1 downto 0) <=(others=>'0');
				elsif ena ='1' then
					dout_int(widthin-1 downto 0)<=din_int(widthin-1 downto 0);
				end if ;
			end if ;
		end process ;
		l:for i in widthin to widthout-1 generate
			dout_int(i) <= dout_int(widthin-1);
		end generate l;
		dout <= dout_int;
	end generate gm;
end generate g1;

gn:if delay>1 generate	
	U0:alt_dspbuilder_nBEXT generic map (delay => delay, widthin =>widthin , widthout =>widthout)
			 port map	 (din => din_int, clock => clock, aclr => aclr, sclr =>  sclr , ena => ena, dout => dout);
end generate gn;

end ax;


