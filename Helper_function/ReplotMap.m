function map_output=ReplotMap(map,scale);
   if length(size(map))==2;
       [h2,w2]=size(map);  
       filter=zeros(h2,w2); % Recreate cell map
       
       map=map>0.3;
       temp=find(max(map,[],2)>0);p1=round(mean(temp));xl=length(temp)/2*scale;
       temp=find(max(map,[],1)>0);q1=round(mean(temp));yl=length(temp)/2*scale;
       center2=[p1,q1];    
    
       t=-pi:0.01:pi;x=center2(1,1)+xl*cos(t);y=center2(1,2)+yl*sin(t);x=round(x);y=round(y);
       x(x<1)=1;y(y<1)=1;x(x>h2)=h2;y(y>w2)=w2;
       for j=min(x):max(x);
       temp=find(x==j);       
       filter(j,min(y(temp)):max(y(temp)))=1; end
       map_output=filter;
   end

   if length(size(map))==3;

       [h2,w2,n]=size(map);  
       fprintf(['Processing cells: ']); 
       for i=1:n;
           if mod(i,100)==0;fprintf([num2str(i), ',']);end
           filter=zeros(h2,w2); % Recreate cell map
           
           map2=map(:,:,i)>0.3;
           temp=find(max(map2,[],2)>0);p1=round(mean(temp));xl=length(temp)/2*scale;
           temp=find(max(map2,[],1)>0);q1=round(mean(temp));yl=length(temp)/2*scale;
           center2=[p1,q1];    
        
           t=-pi:0.01:pi;x=center2(1,1)+xl*cos(t);y=center2(1,2)+yl*sin(t);x=round(x);y=round(y);
           x(x<1)=1;y(y<1)=1;x(x>h2)=h2;y(y>w2)=w2;
           for j=min(x):max(x);
           temp=find(x==j);      
           if isempty(temp)==0
            filter(j,min(y(temp)):max(y(temp)))=1; end
           end
        map_output(:,:,i)=filter;
       end
      fprintf(['\n']);
   end
end
