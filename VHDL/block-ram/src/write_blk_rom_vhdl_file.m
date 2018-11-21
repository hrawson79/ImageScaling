% ECE 6276 DSP HW chip design final project
% Write hdl file for input image to be stored in ROM
% Author: Navdeep Dahiya
% 11/16/2018
clc
clear
in = imread('peppers.png');
I = rgb2gray(in);
I = I(1:16,1:16); % Crop image for now
imshow(I);

num_elements = length(I(:));
addr_bits = int32(ceil(log2(num_elements)));

I = I';
I = I(:); % concatenated row by row
BIN = dec2bin(I,8);

% Writing vhd file

% Header comments
header = ['--Engineer     : Navdeep Dahiya\n--'...
    'Date         : 11/15/2018\n'...
    '--Name of file : block_rom.vhd\n'...
    '--Description  : module ROM as block rom\n\n'];

includes = ['library ieee;\n'...
            'use ieee.std_logic_1164.all;\n'...
            'use ieee.numeric_std.all;\n\n'];

entity = sprintf(['entity blk_rom is\n'...
          '  port (\n'...
          '\t-- input side\n'...
          '\tclk\t: in std_logic;\n'...
          '\trst\t: in std_logic;\n'...
          '\taddr\t: in std_logic_vector(%d downto 0); -- address bits\n'...
          '\t--output side\n'...
          '\tdata_o\t: out std_logic_vector(7 downto 0)\n'...
          '\t);\n'...
          'end blk_rom;\n\n'],addr_bits-1);


architecture = sprintf(['architecture arch of blk_rom is\n\n'...
     'type rom_t is array(0 to %d) of std_logic_vector(7 downto 0);\n\n']...
     ,num_elements-1);

rom_start = ['signal rom : rom_t := (\n'];
rom_end = ['\t\t\t);\n\n'];

rom_contents = {};
num = size(BIN,1);

for i = 1:num-1
    curr_str = sprintf(['\t\t"%c%c%c%c%c%c%c%c",\n'],BIN(i,:));
    %fprintf(curr_str);
    rom_contents{i} = curr_str;%strcat(rom_contents,curr_str);
end
rom_contents{num} = sprintf(['\t\t"%c%c%c%c%c%c%c%c"\n'],BIN(end,:));

process = ['begin\n\n'...
           'process(clk)\n'...
           'begin\n'...
           '  if(rising_edge(clk)) then\n'...
           '    if (rst = ''1\'') then\n'...
           '      data_o <= "00000000";\n'...
           '    else\n'...
           '      data_o <= rom(to_integer(unsigned(addr)));\n'...
           '    end if;\n'...
           '  end if;\n'...
           'end process;\n'...
           'end arch;\n'];

% Write to actual vhd file
fileID = fopen('blk_rom.vhd','w');
fprintf(fileID,header);
fprintf(fileID,includes);
fprintf(fileID,entity);
fprintf(fileID,architecture);
fprintf(fileID,rom_start);
for i = 1:size(BIN,1)
    fprintf(fileID,rom_contents{i});
end
fprintf(fileID,rom_end);
fprintf(fileID,process);
fclose(fileID);

















