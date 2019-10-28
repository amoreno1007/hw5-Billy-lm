function img = im_clean(mask, r)
img = imopen(mask, strel('disk', r));
img = imclose(img, strel('disk', r));
end