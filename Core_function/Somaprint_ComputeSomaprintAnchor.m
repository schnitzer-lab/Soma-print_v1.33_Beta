function [data_score_somaprintwd,data_score_somaprint]=Somaprint_ComputeSomaprintAnchor(map1,map2,n_vec,p_sum,sigma,id_cell1,id_cell2,anchor_sigma)

% Core function to compute Somaprint scores (>=2st iteration, w/ anchor cells)

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


Somaprint_LogMessage(['- Number of vectors used for Soma-print:',num2str(round(n_vec*p_sum)), ' out of ', num2str(n_vec)]);


% Compute soma-print for Map 1
d1=[];

if input==1;
    peak1=Somaprint_ComputePeak(map1);
else
    peak1=map1;
end

%fprintf(['- Compute soma-print for Map 1, processing cell: ']);
for i=1:n1;
    %if mod(i,100)==0; fprintf([num2str(i),', ']);end
    d1(i,:)=sqrt((peak1(id_cell1,1)-peak1(i,1)).^2+(peak1(id_cell1,2)-peak1(i,2)).^2);
end
%fprintf('\n');

% Compute peak for map 2

d2=[];
if input==1;
    peak2=Somaprint_ComputePeak(map2);
else
    peak2=map2;
end

Somaprint_LogMessage('- Computing cell-cell Soma-print similarity scores, processing cell:', false);

if n_vec>length(id_cell1);n_vec=length(id_cell1);end
n_sum=round(n_vec*p_sum);
n_sum=n_vec;
vec_score=[];d_vec0=[];


for i=1:n1;          
    if mod(i,100)==0;Somaprint_LogMessage([',',num2str(i)],false);end
    if isnan(d1(i,1))==0;
        [~,temp]=sort(d1(i,:));idx=temp(2:1+n_vec);
        vec1=peak1(id_cell1(idx),:)- peak1(i,:);  
        
        for j=1:n2;
           vec2=peak2(id_cell2(idx),:)- peak2(j,:);            
           if sum(sum(isnan(vec2)))==0;
               % -------Metric 1: Compute vector-pair distances------
               for ii=1:n_vec;          
                   vec_score(i,j,ii)=sqrt((vec2(ii,1)-vec1(ii,1)).^2 + (vec2(ii,2)-vec1(ii,2)).^2);              
               end
               data_score_somaprint(i,j)=100./((mean(vec_score(i,j,1:n_sum),3))+1);

              %%
               run_anchorrotate=0; % If rotate anchor points; Default: Keep it 0!
               if run_anchorrotate==1; 
                    fp = vec1;
                    mp = vec2;
                    tform = fitgeotform2d(mp,fp,"affine");
                    [p,q]=transformPointsForward(tform,0,0);
                    vec2_tform=transformPointsForward(tform,vec2)-[p,q];
                    for ii=1:n_vec;          
                        vec_score_tform(ii)=sqrt((vec2_tform(ii,1)-vec1(ii,1)).^2 + (vec2_tform(ii,2)-vec1(ii,2)).^2);              
                    end
                    data_score_somaprint(i,j)=100./((mean(vec_score_tform(1:n_sum)))+1);
               end
               %%

               if exist('anchor_sigma')==1;
                   if isempty(anchor_sigma)==0;
                     data_score_somaprint(i,j)=data_score_somaprint(i,j)*normpdf(mean(d1(i,idx)),0,anchor_sigma)/normpdf(0,0,anchor_sigma);
                   end
               end

           else; 
               data_score_somaprint(i,j)=0;
               data_dis(i,j)=1024;
           end
          
        end
        d_weight(i,:)=sqrt((peak1(i,1)-peak2(:,1)).^2+(peak1(i,2)-peak2(:,2)).^2);
    else
        data_score_somaprint(i,:)=100000000;
        d_weight(i,:)=100000;
    end
end
Somaprint_LogMessage('');


d_weight(find(isnan(d_weight)==1))=1000000000;
% Distance-weighted score

for i=1:n1;for j=1:n2;
        data_score_somaprintwd(i,j)= data_score_somaprint(i,j)*normpdf(d_weight(i,j),0,sigma)/normpdf(0,0,sigma);
end;end
        





end
