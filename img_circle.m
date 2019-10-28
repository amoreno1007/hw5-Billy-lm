function img = img_circle(sizesq, n, size)
img_point  = false(sizesq);
for ii = 1:n
    img_point(randi(sizesq), randi(sizesq)) = true;
end
img = imdilate(img_point, strel('sphere', size));
end