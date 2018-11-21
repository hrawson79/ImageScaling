% Bilinear Interpolation Algorithm
% The function can adjust scalefactor for both color and grayscale images.
% Aosen Ba
function imagescaling(scalefactor)

imag = imread('300by300.jpg');
[in_rows, in_cols, imtype] = size(imag);
out_rows = in_rows * scalefactor;
out_cols = in_cols * scalefactor;

if (scalefactor >= 1)  % scale up
    
      %// Define grid of co-ordinates in our image
      %// Generate (x,y) pairs for each point in our image
      [cf, rf] = meshgrid(1 : out_cols, 1 : out_rows);
      %// Let r_f = r'*S_R for r = 1,...,R'
      %// Let c_f = c'*S_C for c = 1,...,C'
      cf = cf / scalefactor;
      rf = rf / scalefactor;
      %// Let r = floor(rf) and c = floor(cf)
      c = floor(cf);
      r = floor(rf);
      %// Any values out of range, cap
      r(r < 1) = 1;
      c(c < 1) = 1;
      r(r > in_rows - 1) = in_rows - 1;
      c(c > in_cols - 1) = in_cols - 1;
      %// Let delta_R = rf - r and delta_C = cf - c
      delta_R =  rf - r;
      delta_C =  cf - c;
      %// Final line of algorithm
      %// Get column major indices for each point we wish
      %// to access
      in1_ind = sub2ind([in_rows, in_cols], r, c);
      in2_ind = sub2ind([in_rows, in_cols], r+1,c);
      in3_ind = sub2ind([in_rows, in_cols], r, c+1);
      in4_ind = sub2ind([in_rows, in_cols], r+1, c+1);       
      %// Now interpolate
      %// Go through each channel for the case of colour
      %// Create output image that is the same class as input
      out = zeros(out_rows, out_cols, size(imag, 3));
  %     out = cast(out, class(im));
      out = cast(out, 'like', imag);
      for idx = 1 : size(imag, 3)
          chan = double(imag(:,:,idx)); %// Get i'th channel
          %// Interpolate the channel
          tmp = chan(in1_ind).*(1 - delta_R).*(1 - delta_C) + ...
                         chan(in2_ind).*(delta_R).*(1 - delta_C) + ...
                         chan(in3_ind).*(1 - delta_R).*(delta_C) + ...
                         chan(in4_ind).*(delta_R).*(delta_C);
          out(:,:,idx) = cast(tmp,'like',imag);
      end
      
else  %scale down
    
    out = zeros(out_rows, out_cols, size(imag, 3));
    out = cast(out, 'like', imag);
    for idx = 1 : size(imag, 3)
        out(:,:,idx) = imag(1:1/scalefactor:end, 1:1/scalefactor:end, idx);
    end
end

figure(1)
imshow(imag);
figure(2)
imshow(out);

imwrite(out,'output image.jpg');

if (imtype == 1)
     dlmwrite('output pixel matrix.txt', out, 'delimiter','\t');
else
     dlmwrite('output red pixel matrix.txt', out(:,:,1), 'delimiter','\t');
     dlmwrite('output green pixel matrix.txt', out(:,:,2), 'delimiter','\t');
     dlmwrite('output blue pixel matrix.txt', out(:,:,3), 'delimiter','\t');
end

end