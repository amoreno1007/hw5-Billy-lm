function img = img_gen(sizesq)
A = rand(sizesq, sizesq, 3);
imwrite(A, 'rand8bit.tif');
reader = bfGetReader('rand8bit.tif');
iplane = reader.getIndex(0, 0, 0) + 1;
img = bfGetPlane(reader, iplane);
end