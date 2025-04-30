LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec16 IS
	PORT (
		dig : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
		data : IN sTD_LOGIC_VECTOR (15 DOWNTO 0); -- 16-bit (4-digit) data
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS
	SIGNAL data4 : STD_LOGIC; -- binary value of current digit
BEGIN

	data4 <= data(0) when dig = "000" else
	       data(1) when dig = "001" else
	       data(2) when dig = "010" else
	       data(3) when dig = "011" else
	       data(4) when dig = "100" else
	       data(5) when dig = "101" else
	       data(6) when dig = "110" else
	       data(7) when dig = "111" else
	       '0';
	
	
	seg <= "0000001" WHEN data4 = '0' ELSE -- 0
	       "1001111" ; 
	-- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
             "11111101" WHEN dig = "001" ELSE -- 1
	         "11111011" WHEN dig = "010" ELSE -- 2
	         "11110111" WHEN dig = "011" ELSE -- 3
	         "11101111" WHEN dig = "100" ELSE -- 4
	         "11011111" WHEN dig = "101" ELSE -- 5 
	         "10111111" WHEN dig = "110" ELSE -- 6
	         "01111111" WHEN dig = "111" ELSE -- 7
	         "11111111";
END Behavioral;

