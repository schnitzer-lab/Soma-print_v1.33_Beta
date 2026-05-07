function Somaprint_PlotExampleCell(map1,image1,id_map1,map2,image2,id_map2,score,input_id_cell1,input_id_cell2,n_vec,p_sum)

% input_id_cell1, input_id_cell2: anchor cells from previous round

[h1,w1,n1]=size(map1);[temp,temp,n2]=size(map2);
l_buffer=round(size(image2,1)/100)*7.5;


if exist('input_id_cell1')==0;
    input_id_cell1=1:n1; 
end

if exist('input_id_cell2')==0;
    input_id_cell2=1:n2; 
end

if exist('n_vec')==0;
    n_vec=10;
end
if exist('p_sum')==0;
   p_sum=1;
end

n_vec2=n_vec;
align_method=2;

plot_map=1;
n_plot=10;

n_col=5;
n_font=10;
lw=2;
scale=3;

if length(id_map1)>n_plot;
    temp=ceil(length(id_map1)/n_plot);
    id_map1_plot=id_map1(1:temp:length(id_map1));
    id_map2_plot=id_map2(1:temp:length(id_map1));
else
    id_map1_plot=id_map1;
    id_map2_plot=id_map2;
end

n_row=length(id_map1_plot);

map1=imageaddpad(map1,l_buffer);
map2=imageaddpad(map2,l_buffer);
image1=imageaddpad(image1,l_buffer);
image2=imageaddpad(image2,l_buffer);

center1=Somaprint_ComputePeak(map1);
center2=Somaprint_ComputePeak(map2);

for iii=1:length(id_map1_plot)

id_cell1=id_map1_plot(iii);id_cell2=id_map2_plot(iii);
% subplot(n_row,n_col,n_col*(ii-1)+1);
% imagesc(image1); hold on; PlotCellOverlay(replotcellamp(map1(:,:,id_cell1),scale),[0 0.7 0]);colormap('bone');
% %title(['Cell #' num2str(id_cell1)]);
% set(gca,'XTick',[],'YTick',[]);
% 
% subplot(n_row,n_col,n_col*(ii-1)+3);
% imagesc(image2); hold on;  PlotCellOverlay(replotcellamp(map2(:,:,id_cell2),scale),[0 0.7 0]);colormap('bone');
% %title(['Cell #' num2str(id_cell2)]);
% set(gca,'XTick',[],'YTick',[]);


%[temp,idx]=sort(score_somaprintwd(id_map1,:),'descend');

% Compute soma-print for Map 1
d1=[];
for i=1:n1;
        temp=find(max(map1(:,:,i),[],2)>0);p1=round(mean(temp));
        temp=find(max(map1(:,:,i),[],1)>0);q1=round(mean(temp));     
        peak1(i,:)=[p1,q1];                     
end
%fprintf(['- Compute soma-print for Map 1, processing cell: ']);
for i=id_cell1;
    if mod(i,100)==0; fprintf([num2str(i),', ']);end
    d1(i,:)=(peak1(input_id_cell1,1)-peak1(i,1)).^2+(peak1(input_id_cell1,2)-peak1(i,2)).^2;
end
%fprintf('\n');

% Compute soma-print for Map 2
d2=[];
for i=1:n2;  
        temp=find(max(map2(:,:,i),[],2)>0);p1=round(mean(temp));
        temp=find(max(map2(:,:,i),[],1)>0);q1=round(mean(temp));
        peak2(i,:)=[p1,q1];        
end

%fprintf(['- Compute soma-print for Map 2, processing cell: ']);
for i=id_cell2;
    if mod(i,100)==0; fprintf([num2str(i),', ']);end
    d2(i,:)=(peak2(input_id_cell2,1)-peak2(i,1)).^2+(peak2(input_id_cell2,2)-peak2(i,2)).^2;
end
%fprintf('\n');


%fprintf(['- Computing cell-cell similarity scores \n']);

if n_vec>length(input_id_cell1);n_vec=length(input_id_cell1);end
n_sum=round(n_vec*p_sum);
vec_score=[];d_vec0=[];%fprintf(['-Processing cell:',])


%---------Plot 1: in vivo ----------
subplot(n_row,n_col,n_col*(iii-1)+1);
imagesc(normimage(image1((center1(id_cell1,1)-l_buffer):(center1(id_cell1,1)+l_buffer),(center1(id_cell1,2)-l_buffer):(center1(id_cell1,2)+l_buffer))));colormap('bone');   
%imagesc(image1((center1(id_cell1,1)-l_buffer):(center1(id_cell1,1)+l_buffer),(center1(id_cell1,2)-l_buffer):(center1(id_cell1,2)+l_buffer),:));%colormap('bone');   
ylabel(['Cell ',num2str(id_cell1)])

set(gca,'XTick',[],'YTick',[])
if plot_map==1;
     hold on;  PlotCellOverlay(map1((center1(id_cell1,1)-l_buffer):(center1(id_cell1,1)+l_buffer),(center1(id_cell1,2)-l_buffer):(center1(id_cell1,2)+l_buffer),:),[.7 .7 .7],[],0.2);
             PlotCellOverlay(map1((center1(id_cell1,1)-l_buffer):(center1(id_cell1,1)+l_buffer),(center1(id_cell1,2)-l_buffer):(center1(id_cell1,2)+l_buffer),id_cell1),[0 .7 0],[],0.2);
end


%---------Plot 2: ex vivo ----------

subplot(n_row,n_col,n_col*(iii-1)+3);
imagesc(normimage(image2((center2(id_cell2,1)-l_buffer):(center2(id_cell2,1)+l_buffer),(center2(id_cell2,2)-l_buffer):(center2(id_cell2,2)+l_buffer))));colormap('bone');
%imagesc(image2((center2(id_cell2,1)-l_buffer):(center2(id_cell2,1)+l_buffer),(center2(id_cell2,2)-l_buffer):(center2(id_cell2,2)+l_buffer),:));%colormap('bone');

set(gca,'XTick',[],'YTick',[])
if plot_map==1;
     hold on; PlotCellMap(map2((center2(id_cell2,1)-l_buffer):(center2(id_cell2,1)+l_buffer),(center2(id_cell2,2)-l_buffer):(center2(id_cell2,2)+l_buffer),:),[.7 .7 .7]);
     PlotCellMap(map2((center2(id_cell2,1)-l_buffer):(center2(id_cell2,1)+l_buffer),(center2(id_cell2,2)-l_buffer):(center2(id_cell2,2)+l_buffer),id_cell2));
end


%title(['Somaprint']);set(gca,'FontSize',n_font)
%title(['Cell #' num2str(id_cell2)]);
% if id_cell2==id_map2;
%        title(['Cell #' num2str(id_cell2)],'Color','r');
% end

vec_score=[];
if align_method==1;
    if isnan(d1(id_map1,1))==0;
           [~,temp]=sort(d1(id_map1,:));idx=temp(2:1+n_vec);vec1=peak1(input_id_cell1(idx),:)- peak1(id_map1,:);  
           [~,temp]=sort(d2(id_map2,:));idx=temp(2:1+n_vec2);vec2=peak2(input_id_cell2(idx),:)- peak2(id_map2,:);
           % Compute vector-pair distances
           for ii=1:n_vec;               
               d_vec0(ii,:)=sqrt((vec2(:,1)-vec1(ii,1)).^2 + (vec2(:,2)-vec1(ii,2)).^2);                  
           end
           d_vec=d_vec0;max_vec=max(max(d_vec));

          % Match vector into pairs
          if sum(sum(isnan(vec2)))==0;
               for ii=1:n_vec;          
                       minidx=find(d_vec==min(min(d_vec)));     
                       [pair(ii,1),pair(ii,2)]=ind2sub([n_vec,n_vec2],minidx(1));   
                       vec_score(i,ii)= d_vec0(pair(ii,1),pair(ii,2));
                       d_vec(pair(ii,1),:)=max_vec;d_vec(:,pair(ii,2))=max_vec;    end     
                score2(id_cell1,id_cell2)=100./(sum(vec_score(i,1:n_sum),2))*n_sum;
          else; score2(id_cell1,id_cell2)=0;
          end               
    end

    for ii=1:n_sum;
        subplot(n_row,n_col,2);hold on;plot([l_buffer l_buffer+vec1(pair(ii,1),2)],[l_buffer l_buffer+vec1(pair(ii,1),1)],'w');
        subplot(n_row,n_col,4);hold on;plot([l_buffer l_buffer+vec2(pair(ii,2),2)],[l_buffer l_buffer+vec2(pair(ii,2),1)],'w');
    end;

end

if align_method==2;     
       if isnan(d1(id_cell1,1))==0;
            [~,temp]=sort(d1(id_cell1,:));idx=temp(2:1+n_vec);
            vec1=peak1(input_id_cell1(idx),:)- peak1(id_cell1,:);         
             vec2=peak2(input_id_cell2(idx),:)- peak2(id_cell2,:);            
             
               % -------Metric 1: Compute vector-pair distances------
               for ii=1:n_vec;          
                   vec_score(ii)=sqrt((vec2(ii,1)-vec1(ii,1)).^2 + (vec2(ii,2)-vec1(ii,2)).^2);              
               end
               score2(id_cell1)=100./(sum(vec_score(1:n_sum)))*n_sum ;              
        end
     for ii=1:n_sum;
        subplot(n_row,n_col,n_col*(iii-1)+1);hold on;plot([l_buffer l_buffer+vec1(ii,2)],[l_buffer l_buffer+vec1(ii,1)],'-w','LineWidth',1.5);
        subplot(n_row,n_col,n_col*(iii-1)+2);hold on;plot([l_buffer l_buffer+vec1(ii,2)],[l_buffer l_buffer+vec1(ii,1)],'-k','LineWidth',2);

        subplot(n_row,n_col,n_col*(iii-1)+3);;hold on;plot([l_buffer l_buffer+vec2(ii,2)],[l_buffer l_buffer+vec2(ii,1)],'-w','LineWidth',1.5);
        subplot(n_row,n_col,n_col*(iii-1)+4);;hold on;plot([l_buffer l_buffer+vec2(ii,2)],[l_buffer l_buffer+vec2(ii,1)],'-k','LineWidth',2);
    end;
       subplot(n_row,n_col,n_col*(iii-1)+2);;set(gca,'Visible','off','Ydir','reverse');xlim([0 2*l_buffer]);ylim([0 2*l_buffer]);
       subplot(n_row,n_col,n_col*(iii-1)+4);;set(gca,'Visible','off','Ydir','reverse');xlim([0 2*l_buffer]);ylim([0 2*l_buffer]);

end


    %d_weight(i,:)=sqrt((peak1(i,1)-peak2(:,1)).^2+(peak1(i,2)-peak2(:,2)).^2);

%score=score2;
plot_score=1;
 if plot_score==1;;
    target_score=score(id_cell1,id_cell2);
    %title(['score:',num2str(score(id_cell1((i-1)*3+j),id_cell2((i-1)*3+j)),3)]);
    temp=sort(score(id_cell1,:),'descend');
    % if temp(1)==target_score;
    %     title(['Gap:',num2str(temp(1)-temp(2),3)]);
    % else
    %     title(['Gap:',num2str(target_score-temp(1),3)]);
    % end
    set(gca,'FontSize',n_font);
 end
%---------Plot 3: histogram ----------
subplot(n_row,n_col,n_col*(iii-1)+5);
[b,a]=hist(score(id_cell1,:));
bar(a,b,'k');

hold on;
[b2]=hist(score(id_cell1,id_cell2),a);
bar(a,b2,'g');
%set(gca,'XTick',[],'YTick',[])
set(gca,'FontSize',n_font,'box','off','LineWidth',lw);
set(gca,'YScale','log'); 
set(gca,'YTick',[0,0.1,1,100,10000]);
set(gca,'YMinorTick','on','YMinorTick','on')
set(gca,'TickLength',[0.026,1])
ylim([0.5,max(b)*1.5])

% if plot_score==1;
%     if temp(1)==target_score;
%         [temp,idx]=sort(score(id_cell1,:),'descend');
%         title(['Ratio:',num2str(temp(1)/temp(2),3)]);set(gca,'FontSize',n_font)
%     else
%         title(['Ratio:',num2str(target_score/temp(1),3)]);set(gca,'FontSize',n_font)
%     end
% end

% % Local distortion
% subplot(n_row,n_col,6);
% target_distortion=distortion(id_cell1,id_cell2);
% a=0:5:60;
% [b,a]=hist(distortion(id_cell1,:),a);
% bar(a,log(b+1),'k');
% hold on;
% [b2]=hist(distortion(id_cell1,id_cell2),a);
% bar(a,log(b2+1),'g');
% set(gca,'XTick',0:30:60);
% 
% %imshowpair(max(map1(:,:,id_cell1),[],3),max(map2(:,:,id_cell2),[],3))
%  %title(['Dist.:',num2str(target_distortion)]);
% set(gca,'FontSize',n_font,'box','off','LineWidth',lw);
end

%fprintf('\n');

%d_weight(find(isnan(d_weight)==1))=0;
% Distance-weighted score

end

%  ------------- 



        