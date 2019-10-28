function img = img_sm_bgsub(img1, rad, sigma, dr)
img = imfilter(img1, fspecial('gaussian', rad, sigma));
bg = imopen(img, strel('disk', dr));
img = imsubtract(img, bg);
end