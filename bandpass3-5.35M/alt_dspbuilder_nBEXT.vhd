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


entity alt_dspbuilder_nBEXT is
		generic ( 
				delay       : integer  := 0;
				widthin	    : positive := 10;
				widthout    : positive := 10
				);
		port 	( 
				din	   : in std_logic_vector(widthin-1 downto 0);
				clock  : in std_logic;
                aclr   : in std_logic;
				sclr   : in std_logic;
				ena    : in std_logic;
				dout   : out std_logic_vector(widthout-1 downto 0)
				);
end alt_dspbuilder_nBEXT;


architecture ax of alt_dspbuilder_nBEXT is

signal dout_int : std_logic_vector(widthout-1 downto 0);
signal din_int  : std_logic_vector(widthin-1 downto 0);

type winStdUArray is array (delay downto 1) of std_logic_vector (widthin-1 downto 0);
signal wiDelayLine : winStdUArray;

type woutStdUArray is array (delay downto 1) of std_logic_vector (widthout-1 downto 0);
signal woDelayLine : woutStdUArray;

begin 

gn:if delay>1 generate	
	ge:if  widthin>= widthout generate
		process(clock,aclr)
		begin
            if aclr='1' then
                woDelayLine <= (others => (others => '0'));
			elsif clock'event and clock='1' then
				if (sclr='1') then
					woDelayLine <= (others => (others => '0'));
				elsif (ena='1') then
					woDelayLine(1)	<= dout_int;
					for i in 2 to delay loop
						woDelayLine(i) <= woDelayLine(i-1); 
					end loop;
				end if ;
			end if ;
		end process ;
		dout_int(widthout-1 downto 0)	<= din(widthout-1 downto 0);	
		dout	<= woDelayLine(delay);
	end generate ge;

	gm:if  widthin< widthout generate
		process(clock,aclr)
		begin
            if aclr='1' then
                wiDelayLine <= (others => (others => '0'));
			elsif clock'event and clock='1' then
				if (sclr='1') then
					wiDelayLine <= (others => (others => '0'));
				elsif (ena='1') then
					wiDelayLine(1)	<= din;
					for i in 2 to delay loop
						wiDelayLine(i) <= wiDelayLine(i-1); 
					end loop;
				end if ;
			end if ;
		end process ;
		din_int <= 	wiDelayLine(delay);
		dout(widthin-1 downto 0)	<= din_int(widthin-1 downto 0);
		l:for i in widthin to widthout-1 generate
			dout(i) <= din_int(widthin-1);
		end generate l;
	end generate gm;

end generate gn;


end ax;


