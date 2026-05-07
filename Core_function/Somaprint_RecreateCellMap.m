function [map,data_cellorder]=Somaprint_RecreateCellMap(data_position);

    h2=ceil(max(data_position(:,4))*1.2);% y position
    w2=ceil(max(data_position(:,3))*1.2);% x position
    v_cutoff=500; % Critical parameter!!!Bubbles will be filtered out
    r=7.5;
    
    map=[];filter=[];;count=0;
    fprintf('- Creating ROIs based on positions: ')
    for i=1:size(data_position);
       if mod(i,100)==0;fprintf([num2str(i),', ']);end    
           center2(i,:)=data_position(i,(3:4));        
           filter=zeros(h2,w2); % Recreate cell map
           xl=r;yl=r;
           if data_position(i,2)>v_cutoff; % *** Volumn fitler for MERFISH data!
               count=count+1;
               t=-pi:0.01:pi;x=center2(i,2)+xl*cos(t);y=center2(i,1)+yl*sin(t);x=round(x);y=round(y);
               x(x<1)=1;y(y<1)=1;x(x>h2)=h2;y(y>w2)=w2;
               for j=min(x):max(x);
               temp=find(x==j);       
               filter(j,min(y(temp)):max(y(temp)))=1; end
               map(:,:,count)=filter;
               id(i)=count;
               cellid(count)=data_position(i,1);
               cellorder(count)=i;
           end       
    end
    fprintf('\n')
    %data_id=id;
    data_cellorder=cellorder;
    figure;
    imagesc(max(map,[],3));

end