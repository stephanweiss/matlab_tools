function  asscr(ses,fes,iele)%  add elemental matrices to global matrices - called once for each elementglobal numel numnp iband meltypglobal nnpe nqptvglobal npglobal scrglobal fcrfor ifor = 1:1:nnpe	irow = np(iele,ifor);	fcr(irow) = fcr(irow) + fes(ifor);	for jfor = 1:1:nnpe		jrow = np(iele,jfor)-irow+1;		if(jrow>0)		scr(irow,jrow) = scr(irow,jrow) + ses(ifor,jfor);		end	endend