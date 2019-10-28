function vec = img_meanintensity(img, mask)
stats = regionprops(mask, img, 'MeanIntensity');
vec = cat(1, stats.MeanIntensity);
end