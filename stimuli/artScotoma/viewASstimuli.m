pth = '/Volumes/GoogleDrive/My Drive/Papers/review Achromatopsia/Revision/AS Stimuli';
a = load(fullfile(pth, '8bars.mat'));
b = load(fullfile(pth, '8bars_AS_hardEdge.mat'));
c = load(fullfile(pth, '8bars_AS_softEdge.mat'));
%%
figure(1)



for ii =193 :1:length(a.stimulus.seq)

    jj = a.stimulus.seq(ii); 
    
    im = [a.stimulus.images(:,:,jj) b.stimulus.images(:,:,jj) c.stimulus.images(:,:,jj)];
         
    imagesc(im); axis image; colormap gray; axis off;
       
    pause(0.001);
end