[m,n]=size(score_raw);

score_1st=[];score_2nd=[];ratio=[];id_cell=[];
for i=1:m;
    [~,idx]=sort(score_raw(i,:),'descend');
    score_1st(i)=score_raw(i,idx(1));
    score_2nd(i)=score_raw(i,idx(2));
    ratio(i)=score_1st(i)/score_2nd(i);
    id_cell(i)=idx(1);
end
hist(score_1st,30)

%%
id_output1=find(score_1st>30 & ratio>1.75)
id_output2=id_cell(id_output1);

%%
score2_1st=[];score2_2nd=[];ratio2=[];id_cell2=[];
for i=1:n;
    [~,idx]=sort(score_raw(:,i),'descend');
    score2_1st(i)=score_raw(idx(1),i);
    score2_2nd(i)=score_raw(idx(2),i);
    ratio2(i)=score2_1st(i)/score2_2nd(i);
    id_cell2(i)=idx(1);
end

id_output2=find(score2_1st>5 & ratio2>1.25);
id_output1=id_cell2(id_output2);

hist(score2_1st)


%% 

imshowpair(max(map1(:,:,id_output1),[],3),max(map2(:,:,id_output2),[],3))
%% Mock experiment 
row_crop=301:600;
col_crop=601:900;
image1_crop=image1(row_crop,col_crop);
map1_crop=map1(row_crop,col_crop,:);
id_crop=find(squeeze(max(max(map1_crop)))>0);
map1_crop=map1_crop(:,:,id_crop);

score_raw=data_score_somaprint{1}(id_crop,:);

[m,n]=size(score_raw);

score_1st=[];score_2nd=[];ratio=[];id_cell=[];
for i=1:m;
    [~,idx]=sort(score_raw(i,:),'descend');
    score_1st(i)=score_raw(i,idx(1));
    score_2nd(i)=score_raw(i,idx(2));
    ratio(i)=score_1st(i)/score_2nd(i);
    id_cell(i)=idx(1);
end
hist(score_1st,30)

id_output1=find(score_1st>20 & ratio>1.5)
id_output2=id_cell(id_output1);

imshowpair(max(map1_crop(:,:,id_output1),[],3),max(map2(:,:,id_output2),[],3))

%%
figure(1);clf;
imagesc(image1_crop);
hold on;PlotCellMap(map1_crop,[0 0.7 0],id_output1);set(gca,'Visible','off');

figure(2);clf;
imagesc(image2);
hold on;PlotCellMap(map2,[0.7 0 0.7],id_output2);colormap('bone');set(gca,'Visible','off')
xlim([40,990]);ylim([40,990]);