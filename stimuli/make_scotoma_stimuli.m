load('/Users/jonathanwinawer/Desktop/AS/8bars.mat');

% load('/Users/jonathanwinawer/Desktop/AS/8bars_AS.mat');

% check the images
figure(1)
for ii =193 :length(stimulus.seq)
   jj = stimulus.seq(ii); 
   imshow(stimulus.images(:,:,jj))
   %title(sprintf('%d\t%d', ii, jj))
   pause(0.0001)
    
end



max_r = 12; % deg
num_p = size(stimulus.images,1);


deg2pix = num_p / 2 / max_r;

sigma = 0.5; % deg
h = fspecial('gaussian',200,sigma * deg2pix) ;
%%
mask = ones(num_p*2);

mask(1:num_p+deg2pix,1:num_p+deg2pix) = 0;


mask = conv2(mask, h, 'same');

mask = mask((1:num_p) + num_p/2, (1:num_p) + num_p/2);

figure, imagesc(mask)

blank = double(stimulus.images(1,1,385));
im = double(stimulus.images) - blank;
im = bsxfun(@times, im, mask);
im = uint8(im+blank);

figure(1)
for ii =193 :length(stimulus.seq)
   jj = stimulus.seq(ii); 
   imshow(im(:,:,jj))
   %title(sprintf('%d\t%d', ii, jj))
   pause(0.0001)
    
end

a=load('/Users/jonathanwinawer/Desktop/AS/8bars.mat');
a.stimulus.images = im;
save('/Users/jonathanwinawer/Desktop/AS/8bars_AS_softEdge.mat', '-struct', 'a');

