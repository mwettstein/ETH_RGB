library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

entity phy_to_ram_tb is
end entity phy_to_ram_tb;

architecture structural of phy_to_ram_tb is

	CONSTANT C_CLK_PERIOD:	time := 40 ns;
	CONSTANT C_FRAME_DATA_A:  STD_LOGIC_VECTOR(6591 downto 0) := x"555555555555555dffffffffffffecf4bb2f613a88e80000089b089b299b49a34aa349a349a36aa36aa36aa36aa36aa38ba36ba38bab8bab8bab8babababacabccabccabecabccabcdabcdabcdabcdabedabeeabeeabeeab0eac0fac0fac2fac2fac30ac50b471b471b491b491b491b4b2b4b2b4d2b4d2b4d3b4f3b4f3b4f3b4f4bcf4bcf4bc14bd34bd34bd34bd54bd55bd34bd34bd34bd35bd35bd35bd35c555c535c534bd55c555bd54bd55bd55c555c555c555bd55c555c535bd34bd35bd55c555c555c535c535c535c555c555c555c555c555c555c535c535c535bd35c534c514bd14c5f4bcf4bcf4bcf3bcd3bcd3bcd3bcd3bcf3bcf3bc14bd14c514c534c534c514c514c514c514c514c514c5f4bcf3c4d3c4d3c4b2bcb2bc92bc92bc51bc51bc71bc71bc92c471c451bc51bc51bc51bc30bc30bcefbbcfbbcfbbcfbbefbb10bc10bc30bc10bc10bc10bc10bc0fbc0fbc0fbccebbcebbcebbcebbaebb8ebb8dbb6dbb4dbb2cbb0cbbebbaebbaebbacbbaabb2cbbacbbaebbaebbaebbaebbacab2cab2cab2aab2aab2aab2aab2aab2a9b289b289b269aa89b289b2aab2aab2aab2aab2aab289b269aa49aa49aa49aa49aa28aa28aa29aa49aa49aa49aa49aa49aa49aa48aa28aa28aa08a208a2e7a107a207a207a2e799c799e79908a208a228a228a228a2089a089ae799e799c791e791e791e791089a089a089ae791c791c791a791a689a789e791e791c789c689c689c791c791c791c691a689a689a691c691c791c691a6898689a689a689a689868986898689a689a689a689a689a689a689a689a689a689a689a689a689a689a689a689c691a689a689a689a689a689a689c691c791e791c791c691c689c689c691c791c791e791e791e791079207922792279a489a489a689a699a89a2a9a2caa2eaaacaa2eaa2eaaa0aab0aab2aab2aab4bab4bab4bab6bab6bb38bb38bb3acabccb3ccb3ecb3ecb3ecb3ecb3ecb30cb4ecb3ecb30cb40cb40bb4ebb3ebabebabebabebabebabebabcbabcaabebabebabebb3ebb3ebb30bb40bb40bb40bb40bb40cb40cb42cb40cb40cb40cb40cb40cb40cb4ecb3ebb3ebb3ebb3ebb3cbb3cbb3cbb3aaabaaabaaab8aab8aab6aab69ab49a349a329a308a3089be89ae89ae89ac79ac79a";
	CONSTANT C_FRAME_DATA_B:  STD_LOGIC_VECTOR(6591 downto 0) := x"555555555555555dffffffffffffecf4bb2f613a88e87c008eb46eb46eb44eb42db42db42db42dac2db42db42db42db42db42db42db42db42db42db42db42db42db42db42db42db42db44db42db42db42db42db42db42db40db40db40cb4ecb30cb4ecb3ccb3cbb3ecb3cbb3ecb3ecb3ccb3cbb3cbb3cbababb3ababababababababacabccb3ccb3acabccabccabecabccabecabedab0db40db40eb42eb40eb42eb42eb42eb40eb42eb42eb44eb42fb44fb450b450b450b450b470b470b471b471b451b451b471b472b472b472bc72b452b472b452bc32b4f1b3f1b3d1b3b1b3b1b3b1b3d1b3d1b3b1b3b0b3b1b3f1b312b4f2b3f2b312bcf2bbd2b3d2b313b4f3b3d2b391b370b370b3b1bbb2b3b2b3b2b391b391b371b350b30fabefaaefb2eeb2eeb2eeaaeeaacdaaadaa8caa8caa6caa6caa6caa6baa6baa4baa4baa4ba24ba24ba22aa229a2099ae999e899c899c899a899a899a891a891a891a891a889a889a889c989e989098a098a2a8a2a8a2a8a4a8a4a924a924a922a8a2a8a2a8a2a8a098ae981e881e881e989e889c889c889c889c889a881a781a781a781a681a68186798679868186798679877986798679867986798679667966796679657965794579457945714471447144714471247124712471247123710371037103712479247944814481448145894489659165916591649964996599659985a1a6a1c6a9c6a9c6a9c6a1c6a9c6a9c6a9e7a9e7b1c6a9c6a9e7b1e7b107b207b207b228b269ba69b26ab28abaabbacbbacbbaecbaecba0dbb2dbb2ebb6fbb8fc38fbb6fbb6ebb6fbb8fc38fc38fbb8fbbafbbb0c3afc36ebb6ebb6ebb6ebb4ebb4ebb6ebb6fbb8fbb8fbb6ebb6fbb6ebb2ebbedb2edb20dbb0dbbccb2abb28bb28bb28bba6bb24bb24ab26bb26ab26ab26ab26ab28bb2abbacbbacbbaebbaebba0bbb2bbb4bbb6cbb6cb3acb3acbbccbbccb3cdbbedb3edbbedb3edb3edb30db42dbc2dbc4ebc4ebc6ebc4ebc4eb44eb44eb42eb42eb44eb44eb44eb44eb44eb44eb44db42db42db40db42db42db42db42db42dbc2dbc4db44dbc4dbc4dbc4dbc4dbc4dbc6ebc6ebc8ebc6ebc6ebc6ebc6ebc6ebc8ebc8ebc8ebc8fc48ebc8fc48fbc8fbcafc48fbcafc4afc4afc4afc4afc4afc48ec48ebc8ebc";
	
	signal sysclk 	    : STD_LOGIC;
	signal rx_dv_stim   : STD_LOGIC;
	signal rx_data_stim : STD_LOGIC_VECTOR(3 downto 0);

	component phy_to_ram
		port(clk25	   : IN   STD_ULOGIC;
		     rx_dv     : IN   STD_LOGIC;
		     rx_data   : IN   STD_LOGIC_VECTOR(3 DOWNTO 0);
		     data      : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		     wraddress : OUT  STD_LOGIC_VECTOR(16 DOWNTO 0);
		     wren      : OUT  STD_LOGIC);
	end component phy_to_ram;

begin

    clk_proc: process
    begin
        sysclk <= '1';
        wait for C_CLK_PERIOD/2;
        sysclk <= '0';
        wait for C_CLK_PERIOD/2;
    end process;
    
    data_proc: process
    begin
        rx_dv_stim <= '0';
		rx_data_stim <= (others => '0');
        wait for 10 * C_CLK_PERIOD;
        
		rx_dv_stim <= '1';
		for nibble_cnt in 0 to ((C_FRAME_DATA_A'length) / 4 - 1) loop
			rx_data_stim <= C_FRAME_DATA_A((C_FRAME_DATA_A'length - nibble_cnt * 4 - 1) downto (C_FRAME_DATA_A'length - nibble_cnt * 4 - 4));
		wait for C_CLK_PERIOD;
		end loop;
		rx_dv_stim <= '0';

        wait for 12 * C_CLK_PERIOD;
        
		rx_dv_stim <= '1';
		for nibble_cnt in 0 to ((C_FRAME_DATA_B'length) / 4 - 1) loop
			rx_data_stim <= C_FRAME_DATA_B((C_FRAME_DATA_B'length - nibble_cnt * 4 - 1) downto (C_FRAME_DATA_B'length - nibble_cnt * 4 - 4));
		wait for C_CLK_PERIOD;
		end loop;
		rx_dv_stim <= '0';

        wait;
    end process;
    
	phy_to_ram_inst : phy_to_ram PORT MAP(
			clk25  => sysclk,
			rx_dv  => rx_dv_stim,
			rx_data => rx_data_stim
			);

end architecture structural;
