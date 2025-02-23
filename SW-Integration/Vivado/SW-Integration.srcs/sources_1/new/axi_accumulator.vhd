library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;

entity axi_accumulator is
	port (
		clk   : in std_logic;
		reset : in std_logic;

		s_axis_tdata  : in std_logic_vector(7 downto 0);
		s_axis_tkeep  : in std_logic_vector(0 downto 0);
		s_axis_tlast  : in std_logic;
		s_axis_tready : out std_logic;
		s_axis_tvalid : in std_logic;

		m_axis_tdata  : out std_logic_vector(7 downto 0);
		m_axis_tkeep  : out std_logic_vector(0 downto 0);
		m_axis_tlast  : out std_logic;
		m_axis_tready : in std_logic;
		m_axis_tvalid : out std_logic;
		calculating   : out std_logic
	);
end entity axi_accumulator;

architecture Behavioral of axi_accumulator is

	-- type matrix_1d is array (natural range <>) of std_logic_vector;

	signal s_accumulator   : unsigned(7 downto 0);
	signal s_calculating   : std_logic;
	signal s_m_axis_tvalid : std_logic;

begin

	m_axis_tvalid <= s_m_axis_tvalid;
	calculating   <= s_calculating;

	process (clk, reset) is
	begin

		if rising_edge(clk) then
			if reset = '1' then
				m_axis_tdata    <= (others => '0');
				m_axis_tkeep    <= "1";
				m_axis_tlast    <= '0';
				s_m_axis_tvalid <= '0';
				s_axis_tready   <= '0';

				s_calculating <= '0';
				s_accumulator <= (others => '0');
			else
				-- we are ready to receive data
				s_axis_tready <= '1';

				if s_axis_tvalid = '1' then
					s_calculating <= '1';

					if s_axis_tkeep(0) = '1' then
						s_accumulator <= s_accumulator + unsigned(s_axis_tdata(7 downto 0));
					end if;

				else
					if s_calculating = '1' and s_m_axis_tvalid = '0' and m_axis_tready = '1' then
						m_axis_tdata    <= std_logic_vector(s_accumulator);
						m_axis_tlast    <= '1';
						s_m_axis_tvalid <= '1';
					end if;
					if s_calculating = '1' and s_m_axis_tvalid = '1' then
						-- finished transmitting, resetting
						s_calculating   <= '0';
						s_accumulator   <= (others => '0');
						m_axis_tlast    <= '0';
						s_m_axis_tvalid <= '0';
					end if;
				end if;
			end if;
		end if;

	end process;

end architecture Behavioral;
