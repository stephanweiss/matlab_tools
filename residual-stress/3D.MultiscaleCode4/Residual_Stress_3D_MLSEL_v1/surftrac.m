function fes =surftrac(ieles,nnps,nqpts,swt,bigNsurf,rjs,surtrac)% computes surface forces for traction loadingiend=3*nnps;fes= zeros(iend,1);fesqp= zeros(iend,1);bigNsqp = zeros(3,iend);  for j=1:1:nqpts  	  xkfac=swt(j)*rjs(j);  bigNsqp(:,:) = bigNsurf(:,:,j);  surtracsqp(:,1) = surtrac(:,j);  fesqp = xkfac*(bigNsqp'*surtracsqp);  fes = fes + fesqp;end