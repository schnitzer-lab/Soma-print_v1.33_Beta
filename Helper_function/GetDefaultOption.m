function option=GetDefaultOption(varagin)

    % Soma-print 2D parameters

    option.nitermax=10; % Maximum number of iterations
    option.nitermin=3;  % Minimum number of iterations
    option.n_vec1=15; % 1st iteration
    option.n_vec2=10; % 2nd iteration
    option.n_vec3=option.n_vec2;%10; % 3rd iteration
    option.p_sum1=0.66;
    option.p_sum2=1;
    option.lr1st=0.05; % LR cutoff for 1st round 
    option.lr2nd=0.05; % LR cutoff from 2nd round 
    option.foldexvivo=1;  % Ratio of ex vivo cell / in vivo cells
    option.lambda=0.001; % GMM model parameter
    option.gmmfilter=0; % GMM model parameter: critical for nosiy data with many unmatched cells 
    option.method=1; % GMM model parameter: Method 

    option.pixellength=1.31; % Critical parameters 
    option.sigma=100;% in um
    option.sigma2=100;% in um
    option.anchorsigma=250; % in um

     % Soma-print 3D parameters
    if exist('varagin')==1 & varagin== 3;

        option.nitermax=10; % Maximum number of iterations
        option.nitermin=3;  % Minimum number of iterations
        option.n_vec1=15; % 1st iteration
        option.n_vec2=10; % 2nd iteration
        option.n_vec3=option.n_vec2;%10; % 3rd iteration
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
        option.anchorsigma=75; % in um (%LFOV: 150 um)

        
    end

    if exist('varagin')==1 & varagin==4;

        option.nitermax=10; % Maximum number of iterations
        option.nitermin=5;  % Minimum number of iterations
        option.n_vec1=15; % 1st iteration
        option.n_vec2=5; % 2nd iteration
        option.n_vec3=10; % 3rd iteration
        option.p_sum1=0.66;
        option.p_sum2=1;
        option.lr1st=0.2; % LR cutoff for 1st round 
        option.lr2nd=0.05; % LR cutoff from 2nd round 
        option.foldexvivo=1;  % Ratio of ex vivo cell / in vivo cells
        option.lambda=1; % GMM model parameter
        option.gmmfilter=0; % GMM model parameter: critical for nosiy data with many unmatched cells 
        option.method=1; % GMM model parameter: Method 
    
        option.pixellength=0.75; % Critical parameters 
        option.sigma=50;% in um
        option.sigma2=50;% in um
        option.anchorsigma=50; % in um

    end
end
