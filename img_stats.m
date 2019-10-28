function [number, meanarea, meanintensity] = img_stats(img, mask)
stats = regionprops(mask, 'Area');
area = [stats.Area];
ids = find(area > 1000);
area = area(ids);
number = length(area);
meanarea = mean(area);
stats = regionprops(mask, img, 'MeanIntensity');
meanintensity = mean([stats(ids).MeanIntensity]);
end