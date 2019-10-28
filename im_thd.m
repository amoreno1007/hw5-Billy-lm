function mask = im_thd(img, threshold)
img = im2double(img);
maxintensity = max(img, [], 'all');
minintensity = min(img, [], 'all');
thd = minintensity + (maxintensity - minintensity) * threshold;
mask = img > thd;
end