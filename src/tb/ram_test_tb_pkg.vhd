library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

package ram_test_tb_pkg is

	-- Types
	TYPE t_wr_port IS RECORD
		clock  : std_logic;
		enable : std_logic;
		addr   : std_logic_vector(9 downto 0);
		data   : std_logic_vector(15 downto 0);
	END RECORD t_wr_port;

	TYPE t_rd_port IS RECORD
		clock : std_logic;
		addr  : std_logic_vector(9 downto 0);
		data  : std_logic_vector(15 downto 0);
	END RECORD t_rd_port;

	-- Constants
	constant C_END_OF_SIM : time := 1 us;
	constant C_CLK_PERIOD : time := 20 ns;

	-- Procedures
	procedure wr_mem(
		signal addr    : in    std_logic_vector(9 downto 0);
		signal data    : in    std_logic_vector(15 downto 0);
		signal wr_port : inout t_wr_port);

	procedure rd_mem(
		signal addr        : in    std_logic_vector(9 downto 0);
		signal exp_data    : in    std_logic_vector(15 downto 0);
		signal rd_port     : inout t_rd_port;
		variable result_line : inout   line);

end package ram_test_tb_pkg;

package body ram_test_tb_pkg is
	procedure wr_mem(
		signal addr    : in    std_logic_vector(9 downto 0);
		signal data    : in    std_logic_vector(15 downto 0);
		signal wr_port : inout t_wr_port) is
	begin
		wait until rising_edge(wr_port.clock);
		wr_port.enable <= '1';
		wr_port.addr   <= transport addr after 1 ns;
		wr_port.data   <= transport data;
	end procedure wr_mem;

	procedure rd_mem(
		signal addr        : std_logic_vector(9 downto 0);
		signal exp_data    : in    std_logic_vector(15 downto 0);
		signal rd_port     : inout t_rd_port;
		variable result_line : inout   line) IS
	begin
		wait until rising_edge(rd_port.clock);
		rd_port.addr <= transport addr;
		wait until rising_edge(rd_port.clock);
		--write results
			write(result_line, NOW, left, 8);
			write(result_line, to_integer(unsigned(addr)),left,6 );
			write(result_line, to_integer(unsigned(addr)),left, 4);
			hwrite(result_line, exp_data, left, 6 );
			hwrite(result_line, rd_port.data, left, 6 );
			write(result_line, exp_data, left, 18 );
			write(result_line, rd_port.data, left, 18 );
			
			assert rd_port.data = exp_data report "Wrong data read: " & result_line.all severity error;
		--assert rd_port.data = exp_data report "Wrong data: " & integer'image(to_integer(unsigned(rd_port.data))) & " instead of " & integer'image(to_integer(unsigned(exp_data))) & " !"
			--severity error;
		
	end procedure rd_mem;

end package body ram_test_tb_pkg;
