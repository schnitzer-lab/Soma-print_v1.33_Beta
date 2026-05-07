function option=GetDefautOption(varagin)

    option.nitermax=10; % Maximum number of iterations
    option.nitermin=3;  % Minimum number of iterations
    option.n_vec1=15; % 1st iteration
    option.n_vec2=10; % 2nd iteration
    option.n_vec3=10; % 3rd iteration
    option.p_sum1=0.66;
    option.p_sum2=1;
    option.lr1st=0.05; % LR cutoff for 1st round 
    option.lr2nd=0.05; % LR cutoff from 2nd round 
    option.foldexvivo=1;  % Ratio of ex vivo cell / in vivo cells
    option.lambda=0.001; % GMM model parameter
    option.gmmfilter=0; % GMM model parameter: critical for nosiy data with many unmatched cells 
    option.method=1; % GMM model parameter: Method 

    option.pixellength=0.66; % Critical parameters 
    option.sigma=100;% in um
    option.sigma2=100;% in um
    option.anchorsigma=250; % in um
    
    if exist('varagin')==1 & varagin== 3;

        option.nitermax=10; % Maximum number of iterations
        option.nitermin=3;  % Minimum number of iterations
        option.n_vec1=15; % 1st iteration
        option.n_vec2=10; % 2nd iteration
        option.n_vec3=10; % 3rd iteration
        option.p_sum1=0.66;
        option.p_sum2=1;
        option.lr1st=0.05; % LR cutoff for 1st round 
        option.lr2nd=0.05; % LR cutoff from 2nd round 
        option.foldexvivo=1;  % Ratio of ex vivo cell / in vivo cells
        option.lambda=1; % GMM model parameter
        option.gmmfilter=0; % GMM model parameter: critical for nosiy data with many unmatched cells 
        option.method=1; % GMM model parameter: Method 
    
        option.pixellength=0.66; % Critical parameters 
        option.sigma=100;% in um
        option.sigma2=150;% in um
        option.anchorsigma=75; % in um
        %option.penalty_ratio=5;
        %option.anchorpenalty_ratio=10;
        
    end

    if exist('varagin')==1 & varagin==4;

        option.nitermax=10; % Maximum number of iterations
        option.nitermin=5;  % Minimum number of iterations
        option.n_vec1=15; % 1st iteration
        option.n_vec2=6; % 2nd iteration
        option.n_vec3=10; % 3rd iteration
        option.p_sum1=0.66;
        option.p_sum2=1;
        option.lr1st=0.5; % LR cutoff for 1st round 
        option.lr2nd=0.05; % LR cutoff from 2nd round 
        option.foldexvivo=1;  % Ratio of ex vivo cell / in vivo cells
        option.lambda=0.1; % GMM model parameter
        option.gmmfilter=0; % GMM model parameter: critical for nosiy data with many unmatched cells 
        option.method=1; % GMM model parameter: Method 
    
        option.pixellength=0.68; % Critical parameters 
        option.sigma=40;% in um
        option.sigma2=40;% in um
        option.anchorsigma=40; % in um

    end
end