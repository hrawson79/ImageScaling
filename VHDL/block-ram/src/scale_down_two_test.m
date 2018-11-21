% ECE 6276 DSP HW chip design final project
% Tests for scale down by 2
% Author: Navdeep Dahiya
% 11/16/2018
clc
clear
in = imread('peppers.png');
I = rgb2gray(in);
I = I(1:16,1:16); % Crop image for now

D = dlmread('output_img.txt');
D = uint8(reshape(D,[8,8])');
I(1:2:end,1:2:end) - D