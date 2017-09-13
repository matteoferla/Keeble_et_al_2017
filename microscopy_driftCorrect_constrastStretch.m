%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file='whatever';
file='1-phase.tif';
file='1.tif';
file='2.tif';
%load('stack_shift.mat');
xmarg=[max(shiftframes.x),-min(shiftframes.x)];
ymarg=[max(shiftframes.y),-min(shiftframes.y)];
%https://uk.mathworks.com/matlabcentral/answers/105739-how-to-show-tiff-stacks
tiff_info = imfinfo(file); % return tiff structure, one element per image
temp_tiff = imread(file, 1) ; % read in first image
raw_tiff_stack = temp_tiff(xmarg(1)+1:end-xmarg(2),ymarg(1)+1:end-ymarg(2));
%concatenate each successive tiff to tiff_stack
for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread(file, ii);
    temp2_tiff=temp_tiff(xmarg(1)-shiftframes.x(ii)+1:end-xmarg(2)-shiftframes.x(ii),ymarg(1)+1-shiftframes.y(ii):end-ymarg(2)-shiftframes.y(ii));
    raw_tiff_stack = cat(3 , raw_tiff_stack, temp2_tiff);
end

for ii = 1 : size(raw_tiff_stack, 3)
    imwrite(raw_tiff_stack(:,:,ii) , ['170913_shifted_',file] , 'WriteMode' , 'append') ;
end

%% Contrast stretch
minii=nan(size(raw_tiff_stack, 3),1);
maxii=nan(size(raw_tiff_stack, 3),1);
minii(1)=min(min(raw_tiff_stack(:,:,1)));
tiff_stack=[];
tiff_stack(:,:,1) = raw_tiff_stack(:,:,1) - minii(1);
maxii(1)=double(max(max(tiff_stack(:,:,1))));
%concatenate each successive tiff to tiff_stack
for ii = 2 : size(raw_tiff_stack, 3)
    temp2_tiff=double(raw_tiff_stack(:,:,ii));
    minii(ii)=min(temp2_tiff(:));
    temp2_tiff=temp2_tiff-minii(ii);
    display(min(temp2_tiff(:)))
    maxii(ii)=max(temp2_tiff(:));
    temp3_tiff=uint16(temp2_tiff*(maxii(1)/maxii(ii)));
    %display(max(temp3_tiff(:)));
    tiff_stack = cat(3 , tiff_stack, temp3_tiff);
end

for ii = 1 : size(tiff_stack, 3)
    imwrite(tiff_stack(:,:,ii) , ['170913_contrastStretch_shifted_',file] , 'WriteMode' , 'append') ;
end

x=double(reshape(raw_tiff_stack,numel(temp2_tiff),size(tiff_stack,3)));
figure;
subplot(1,2,1);
violin(x);
subplot(1,2,2);
violin(x);
ylim([0E4 2.5E3])
print(['violin_raw_',file], '-dpng', '-r1200');

x=double(reshape(tiff_stack,numel(temp3_tiff),size(tiff_stack,3)));
%figure; boxplot(x)
%figure; violin(log10(x+1))
figure;
subplot(1,2,1);
violin(x);
subplot(1,2,2);
violin(x);
ylim([0E4 2.5E3])
print(['violin_corrected_',file], '-dpng', '-r1200');

close all;