LIBRARY ieee;
USE ieee.std_logic_1164.all;

library altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY ram_dual IS
	PORT(
		data      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		rdaddress : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		rdclock   : IN  STD_LOGIC;
		wraddress : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		wrclock   : IN  STD_LOGIC := '1';
		wren      : IN  STD_LOGIC := '0';
		q         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ram_dual;

ARCHITECTURE SYN OF ram_dual IS
	SIGNAL sub_wire0 : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
	q <= sub_wire0(15 DOWNTO 0);

	altsyncram_component : altsyncram
		GENERIC MAP(
			address_aclr_b         => "NONE",
			address_reg_b          => "CLOCK1",
			clock_enable_input_a   => "BYPASS",
			clock_enable_input_b   => "BYPASS",
			clock_enable_output_b  => "BYPASS",
			intended_device_family => "MAX 10",
			lpm_type               => "altsyncram",
			numwords_a             => 1024,
			numwords_b             => 1024,
			operation_mode         => "DUAL_PORT",
			outdata_aclr_b         => "NONE",
			outdata_reg_b          => "CLOCK1",
			power_up_uninitialized => "FALSE",
			widthad_a              => 10,
			widthad_b              => 10,
			width_a                => 16,
			width_b                => 16,
			width_byteena_a        => 1
		)
		PORT MAP(
			address_a => wraddress,
			address_b => rdaddress,
			clock0    => wrclock,
			clock1    => rdclock,
			data_a    => data,
			wren_a    => wren,
			q_b       => sub_wire0
		);

END SYN;