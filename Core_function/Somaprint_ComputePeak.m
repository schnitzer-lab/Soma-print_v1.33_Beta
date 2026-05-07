function [peak1,lx,ly]=Somaprint_ComputePeak(map1)

% Compute peak in image row/col coordiate (*not Cartesian x-y cooridate)

[~,~,n1]=size(map1);

for i=1:n1;
        p_thres=0.3;
        temp=find(max(map1(:,:,i),[],2)> p_thres);%p1=round(mean(temp));
         if isempty(temp)==0;
            p1=round((max(temp)+min(temp))/2);
            lx(i)=length(temp);
         else
            p1=0;
         end
        temp=find(max(map1(:,:,i),[],1)> p_thres);%q1=round(mean(temp));
        if isempty(temp)==0;
            q1=round((max(temp)+min(temp))/2);
            ly(i)=length(temp);
        else
            q1=0;
        end
        peak1(i,:)=[p1,q1];                     
end