function [data_score_somaprintwd,data_score_somaprint]=ComputeSomaprint(map1,map2,n_vec,p_sum,sigma,id_cell1,id_cell2,n_vec2)

% Core function to compute Somaprint scores (1st iteration, from all cells)

% ----------------- Input ------------
% map1: in vivo cell map
% map2: ex vivo cell map
% n_vec: number of vectors connecting nearest neighbours used to compute Somaprint
% p_sum: the percentage of vectors used in the final scoee (final number of vectors = n_vec * p_sum)
% sigma: distance penalization
% id_cell1 & id_cell2: if anchors cells are used 
% n_vec2(optional): if a different number of vectors are used for ex vivo

% ---------------- Output --------------
% data_score_somaprintwd: Somaprint score w/ distance penalization
% data_score_somaprint: raw Somaprint score
if length(size(map2))==3;
    input=1;
else if length(size(map2))==2;
    input=2;
    end
end


if input==1;
    [h1,w1,n1]=size(map1);[temp,temp,n2]=size(map2);
else;
    [n1,temp]=size(map1);[n2,temp]=size(map2);
end

if nargin<6;
   id_cell1=1:n1; 
   id_cell2=1:n2; 
end

if nargin<8;
   n_vec2=n_vec;
end


% =================================================================
% -------------- Step 1: Compute Somaprint for each cell -------------

if input==1;

    % Compute soma-print for Map 1
    d1=[];
    for i=1:n1;
            temp=find(max(map1(:,:,i),[],2)>0);p1=round(mean(temp));
            temp=find(max(map1(:,:,i),[],1)>0);q1=round(mean(temp));     
            peak1(i,:)=[p1,q1];                     
    end
else
    peak1=map1;

end

fprintf(['- Compute soma-print for Map 1, processing cell: ']);
for i=1:n1;
    if mod(i,100)==0; fprintf([num2str(i),', ']);end
    d1(i,:)=(peak1(id_cell1,1)-peak1(i,1)).^2+(peak1(id_cell1,2)-peak1(i,2)).^2;
end
fprintf('\n');

% Compute soma-print for Map 2
d2=[];
if input==1;
    for i=1:n2;  
            temp=find(max(map2(:,:,i),[],2)>0);p1=round(mean(temp));
            temp=find(max(map2(:,:,i),[],1)>0);q1=round(mean(temp));
            
            peak2(i,:)=[p1,q1];        
    end
else
    peak2=map2;
end

fprintf(['- Compute soma-print for Map 2, processing cell: ']);
for i=1:n2;
    if mod(i,100)==0; fprintf([num2str(i),', ']);end
    d2(i,:)=(peak2(id_cell2,1)-peak2(i,1)).^2+(peak2(id_cell2,2)-peak2(i,2)).^2;
end
fprintf('\n');

% =================================================================
% -------------- Step 2: Compute pair-wise Somaprint socres-------------

fprintf(['- Computing cell-cell similarity scores, ']);

if n_vec>length(id_cell1);n_vec=length(id_cell1);end
n_sum=round(n_vec*p_sum);
vec_score=[];d_vec0=[];fprintf(['processing cell:',])


for i=1:n1;          
    if mod(i,100)==0;fprintf([',',num2str(i)]);end
    if isnan(d1(i,2))==0;
        [~,temp]=sort(d1(i,:));idx=temp(2:1+n_vec);vec1=peak1(id_cell1(idx),:)- peak1(i,:);  
        for j=1:n2;
           [~,temp]=sort(d2(j,:));idx=temp(2:1+n_vec2);vec2=peak2(id_cell2(idx),:)- peak2(j,:);
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
                       vec_score(i,j,ii)= d_vec0(pair(ii,1),pair(ii,2));
                       d_vec(pair(ii,1),:)=max_vec;d_vec(:,pair(ii,2))=max_vec;    
                end     
                data_score_somaprint(i,j)=100./((mean(vec_score(i,j,1:n_sum),3))+1);

                % ----- Metric 2: distortion index ------
                % fp = vec1(pair(1:n_sum,1),:);
                % mp = vec2(pair(1:n_sum,2),:);
                % tform = fitgeotform2d(mp,fp,"affine");
                % [p,q]=transformPointsForward(tform,0,0);
                % % image0_tf=imwarp(image0,tform,'OutputView',imref2d(size(image0)));
                % % temp=find(image0_tf==max(max(image0_tf))); temp=temp(1);
                % % [p,q]=ind2sub(size(image0),temp);
                % data_dis(i,j)=sqrt(p^2+q^2);

          else; 
              data_score_somaprint(i,j)=0;
          end               
        end
        d_weight(i,:)=sqrt((peak1(i,1)-peak2(:,1)).^2+(peak1(i,2)-peak2(:,2)).^2);
    else
        data_score_somaprint(i,:)=0;
        d_weight(i,:)=100000;
    end
end
fprintf('\n');



% =============================================================================
% -------------- Step 3: Compute the score with distance penalization-------------

d_weight(find(isnan(d_weight)==1))=100000;
% Distance-weighted score

for i=1:n1;for j=1:n2;
        data_score_somaprintwd(i,j)= data_score_somaprint(i,j)*normpdf(d_weight(i,j),0,sigma)/normpdf(0,0,sigma);
end;end
        
end