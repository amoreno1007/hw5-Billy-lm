% Name: Mu Lin
% Student ID: S01339805

%% Problem 1
% 1. Write a function to generate an 8-bit image of size 1024x1024 with a random value 
% of the intensity in each pixel. Call your image rand8bit.tif.
img = img_gen(1024);
imshow(img);

% 2. Write a function that takes an integer value as input and outputs a
% 1024x1024 binary image mask containing 20 circles of that size in random
% locations
prompt = 'Please input the size of circles:\n';
size = input(prompt);
mask = img_circle(1024, 20, size);
imshow(mask);

% 3. Write a function that takes the image from (1) and the binary mask
% from (2) and returns a vector of mean intensities of each circle (hint: use regionprops).
mi = img_meanintensity(img, mask);

% 4. Plot the mean and standard deviation of the values in your output
% vector as a function of circle size. Explain your results.
hold on;
for size = 5:5:100
    mask = img_circle(1024, 20, size);
    mi = img_meanintensity(img, mask);
    m = mean(mi);
    s = std(mi);
    errorbar(size, m, s, '-xr');
end
xlabel('Circle Size');
ylabel('Mean Intensity');
title('Mean Intensity v.s. Circle Size');
hold off;
% From the graph we can see, as the size increases, the mean intensity
% fluctuates around the half max value (255 / 2 = 127.5), the standard
% deviation decreases. The reason is that as the size increases, number of
% points contained in a circle increases. Since the intensities of points are
% random, their mean will tend to a fixed value.

%% Problem 2
% Here is some data showing an NFKB reporter in ovarian cancer cells. 
% https://www.dropbox.com/sh/2dnyzq8800npke8/AABoG3TI6v7yTcL_bOnKTzyja?dl=0
% There are two files, each of which have multiple timepoints, z
% slices and channels. One channel marks the cell nuclei and the other
% contains the reporter which moves into the nucleus when the pathway is
% active. The first file has the first 19 times, and the 2nd one has the
% next 18 timepoints.

% 1. Use Fiji to import both data files, take maximum intensity
% projections in the z direction, concatentate the files, display both
% channels together with appropriate look up tables, and save the result as
% a movie in .avi format. Put comments in this file explaining the commands
% you used and save your .avi file in your repository (low quality ok for
% space).

% See the "nfkb_movie.avi" and the "readme.txt" in "Problem 2 - 1" file.

% 2. Perform the same operations as in part 1 but use MATLAB code. You don't
% need to save the result in your repository, just the code that produces.
% it. To make a movie, either use the function VideoWriter to write to avi, 
% or you may save as a single multicolor tif with all the timepoints in the same file.
v = VideoWriter('Problem 2 - 2.avi');
v.FrameRate = 7;
open(v);
reader = bfGetReader('nfkb_movie1.tif');
for t = 1:19
    img_c1 = bfGetPlane(reader, reader.getIndex(5, 0, t - 1) + 1);
    img_c2 = bfGetPlane(reader, reader.getIndex(5, 1, t - 1) + 1);
    img = cat(3, imadjust(img_c1), imadjust(img_c2), zeros(size(img_c1)));
    writeVideo(v, im2uint8(img));
end
reader = bfGetReader('nfkb_movie2.tif');
for t = 1:18
    img_c1 = bfGetPlane(reader, reader.getIndex(5, 0, t - 1) + 1);
    img_c2 = bfGetPlane(reader, reader.getIndex(5, 1, t - 1) + 1);
    img = cat(3, imadjust(img_c1), imadjust(img_c2), zeros(size(img_c1)));
    writeVideo(v, im2uint8(img));
end
close(v);

%% Problem 3 
% Continue with the data from part 2

% 1. Use your MATLAB code from Problem 2, Part 2  to generate a maximum
% intensity projection image of the first channel of the first time point
% of movie 1.
reader = bfGetReader('nfkb_movie1.tif');
nz = reader.getSizeZ;
img_max = uint16(zeros(1024));
for ii = 1:nz
    img_now = bfGetPlane(reader, reader.getIndex(ii - 1, 0, 0) + 1);
    img_max = max(img_max, img_now);
end
imshow(img_max, [500 5000]);

% 2. Write a function which performs smoothing and background subtraction
% on an image and apply it to the image from (1). Any necessary parameters
% (e.g. smoothing radius) should be inputs to the function. Choose them
% appropriately when calling the function.
rad = 4; % smoothing radius
sigma = 2; % sigma: standard deviation of the Gaussian filter
dr = 100; % dr: disk radius
img = img_sm_bgsub(img_max, rad, sigma, dr);
imshow(img, [0 4500]);

% 3. Write  a function which automatically determines a threshold  and
% thresholds an image to make a binary mask. Apply this to your output
% image from 2. 
mask = im_thd(img, 0.05);
imshow(mask);

% 4. Write a function that "cleans up" this binary mask - i.e. no small
% dots, or holes in nuclei. It should line up as closely as possible with
% what you perceive to be the nuclei in your image. 
mask = im_clean(mask, 5);
imshow(mask);

% 5. Write a function that uses your image from (2) and your mask from 
% (4) to get a. the number of cells in the image. b. the mean area of the
% cells, and c. the mean intensity of the cells in channel 1. 
[number_c1, meanarea_c1, meanintensity_c1] = img_stats(img, mask);

% 6. Apply your function from (2) to make a smoothed, background subtracted
% image from channel 2 that corresponds to the image we have been using
% from channel 1 (that is the max intensity projection from the same time point). Apply your
% function from 5 to get the mean intensity of the cells in this channel.
img_max = uint16(zeros(1024));
for ii = 1:nz
    img_now = bfGetPlane(reader, reader.getIndex(ii - 1, 1, 0) + 1);
    img_max = max(img_max, img_now);
end
rad = 4;
sigma = 2;
dr = 100;
img = img_sm_bgsub(img_max, rad, sigma, dr);
imshow(img, [10 1000]);
mask = im_thd(img, 0.05);
mask = im_clean(mask, 5);
[~, ~, meanintensity_c2] = img_stats(img, mask);

%% Problem 4
% 1. Write a loop that calls your functions from Problem 3 to produce binary masks
% for every time point in the two movies. Save a movie of the binary masks.
v = VideoWriter('Problem 4 - 1.avi');
v.FrameRate = 7;
open(v);
reader = bfGetReader('nfkb_movie1.tif');
for t = 1:19
    img_c1 = bfGetPlane(reader, reader.getIndex(5, 0, t - 1) + 1);
    img_c2 = bfGetPlane(reader, reader.getIndex(5, 1, t - 1) + 1);
    img_c1 = img_sm_bgsub(img_c1, 4, 2, 100);
    mask_c1 = im_thd(img_c1, 0.05);
    mask_c1 = im_clean(mask_c1, 5);
    img_c2 = img_sm_bgsub(img_c2, 4, 2, 100);
    mask_c2 = im_thd(img_c2, 0.05);
    mask_c2 = im_clean(mask_c2, 5);
    img = cat(3, mask_c1, mask_c2, zeros(size(img_c1)));
    writeVideo(v, im2uint8(img));
end
reader = bfGetReader('nfkb_movie2.tif');
for t = 1:18
    img_c1 = bfGetPlane(reader, reader.getIndex(5, 0, t - 1) + 1);
    img_c2 = bfGetPlane(reader, reader.getIndex(5, 1, t - 1) + 1);
    img_c1 = img_sm_bgsub(img_c1, 4, 2, 100);
    mask_c1 = im_thd(img_c1, 0.05);
    mask_c1 = im_clean(mask_c1, 5);
    img_c2 = img_sm_bgsub(img_c2, 4, 2, 100);
    mask_c2 = im_thd(img_c2, 0.05);
    mask_c2 = im_clean(mask_c2, 5);
    img = cat(3, mask_c1, mask_c2, zeros(size(img_c1)));
    writeVideo(v, im2uint8(img));
end
close(v);

% 2. Use a loop to call your function from problem 3, part 5 on each one of
% these masks and the corresponding images and 
% get the number of cells and the mean intensities in both
% channels as a function of time. Make plots of these with time on the
% x-axis and either number of cells or intensity on the y-axis. 
number_c1 = [];
number_c2 = [];
meanintensity_c1 = [];
meanintensity_c2 = [];
reader = bfGetReader('nfkb_movie1.tif');
for t = 1:19
    img_c1 = bfGetPlane(reader, reader.getIndex(5, 0, t - 1) + 1);
    img_c2 = bfGetPlane(reader, reader.getIndex(5, 1, t - 1) + 1);
    img_c1 = img_sm_bgsub(img_c1, 4, 2, 100);
    mask_c1 = im_thd(img_c1, 0.05);
    mask_c1 = im_clean(mask_c1, 5);
    img_c2 = img_sm_bgsub(img_c2, 4, 2, 100);
    mask_c2 = im_thd(img_c2, 0.05);
    mask_c2 = im_clean(mask_c2, 5);
    [number_c1(t), ~, meanintensity_c1(t)] = img_stats(img_c1, mask_c1);
    [number_c2(t), ~, meanintensity_c2(t)] = img_stats(img_c2, mask_c2);
end
reader = bfGetReader('nfkb_movie2.tif');
for t = 1:18
    img_c1 = bfGetPlane(reader, reader.getIndex(5, 0, t - 1) + 1);
    img_c2 = bfGetPlane(reader, reader.getIndex(5, 1, t - 1) + 1);
    img_c1 = img_sm_bgsub(img_c1, 4, 2, 100);
    mask_c1 = im_thd(img_c1, 0.05);
    mask_c1 = im_clean(mask_c1, 5);
    img_c2 = img_sm_bgsub(img_c2, 4, 2, 100);
    mask_c2 = im_thd(img_c2, 0.05);
    mask_c2 = im_clean(mask_c2, 5);
    img = cat(3, mask_c1, mask_c2, zeros(size(img_c1)));
    [number_c1(t + 19), ~, meanintensity_c1(t + 19)] = img_stats(img_c1, mask_c1);
    [number_c2(t + 19), ~, meanintensity_c2(t + 19)] = img_stats(img_c2, mask_c2);
end
subplot(2, 1, 1);
plot(1:37, number_c1, 1:37, number_c2, 'LineWidth', 1);
xlabel('Time');
ylabel('Number of Cells');
title('Number of Cells v.s. Time');
legend('Channel 1', 'Channel 2');
subplot(2, 1, 2);
plot(1:37, meanintensity_c1, 1:37, meanintensity_c2, 'LineWidth', 1);
xlabel('Time');
ylabel('Mean Intensity of Cells');
title('Mean Intensity of Cells v.s. Time');
legend('Channel 1', 'Channel 2');
