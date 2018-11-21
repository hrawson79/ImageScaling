% ECE 6276 DSP HW chip design final project
% Tests for scale down by 2
%
% Compare the result obtained from scale down by 2 nearest neighbor
% algorithm implemented in VHDL with the gold standard reference.
% Put the test bench output file 'output_image.txt' in the same folder
% as this script. testbench writes each output pixel (row by row) in one
% row by itself so we need to reshape it to expected size which is half of input
% image size in each dimension
% 
% Author: Navdeep Dahiya
% 11/20/2018
clc
clear
close all
I = imread('peppers.png');
%I = imread('300by300.jpg');
if (length(size(I)) > 2)
    I = rgb2gray(I);
end

I = imresize(I,[400 600]);

scaled_down_reference = I(1:2:end,1:2:end);
D = dlmread('output_img.txt'); % matlab stacks column by column
D = uint8(reshape(D,[300 200]))'; % but we need row by row

figure, imshow(I)
title('Input image')

figure, imshow(scaled_down_reference)
title('Reference scaled down by 2')

figure,imshow(D)
title('Output from VHDL testbench')

diff = nnz(scaled_down_reference - D);

fprintf(['Number of elements different between reference and test bench '...
     'output = %d\n'], diff);