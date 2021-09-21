clear all; clc;

I_org=imread(['C:\Users\scott\OneDrive\Documents\University\2021 S1\Research Thesis\MATLABImageProcessing\f1_240_210_S0004\f1_240_210_S0004000037.jpg']);
I=rgb2gray(I_org);
adjusted = imadjust(I, [0,0.2]);
my_image = im2double(adjusted);

image_thresholded = my_image;
image_thresholded(my_image>=0.4) = 1;
image_thresholded(my_image<0.4 & my_image>=0.1) = 0.5;
image_thresholded(my_image<0.1) = 0;

% display result
figure();
subplot(1,3,1);
imshow(I,[]);
title('original image');
subplot(1,3,2);
imshow(adjusted, []);
title('adjusted image');
subplot(1,3,3)
imshow(image_thresholded,[]);
title('thresholded image');