function m = SymTensor2OfVector(v)
% SymTensor2OfVector - Generates a symmetric tensor from a vector as the
% following:
%
%   {A} = [A_11, A_22, A_33, sqrt(2)*A_12, sqrt(2)*A_13, sqrt(2)*A_23]
%       |
%       |
%       V
%   [A] = [A_11, A_12, A_13;
%          A_12, A_22, A_23;
%          A_13, A_23, A_33]
%           
%
%   Usage:
%   
%       m = SymTensor2OfVector(v)
%
%   Input:
%
%       v   (6 x 1) matrix of m
%
%   Output:
%
%       m   (3 x 3) symmetric 2nd order tensor (strain / stress)
% 
%   Note:
%   strain and stress are vectorized as the following:
%   [strain]    = [e11, e12, e13;
%                  e12, e22, e23;
%                  e13, e23, e33]
%
%   {strain}    = {e11
%                  e22
%                  e33
%                  sqrt(2)*e12
%                  sqrt(2)*e13
%                  sqrt(2)*e23}
% 
%   [stress]    = [s11, s12, s13;
%                  s12, s22, s23;
%                  s13, s23, s33]
%
%   {stress}    = {s11
%                  s22
%                  s33
%                  sqrt(2)*s12
%                  sqrt(2)*s13
%                  sqrt(2)*s23}
%
%   By this convention strain energy (E) is
%   E = {stress}*{strain}
%   
%   When using stiffness coefficients from Hosford
%   Hosford defines 
%   {strain}_h  = {e11
%                  e22
%                  e33
%                  gamma12
%                  gamma13
%                  gamma23}
%
%   Thus simply multiplying {strain} from above will give
%   {stress}    = {s11
%                  s22
%                  s33
%                  s12/sqrt(2)
%                  s13/sqrt(2)
%                  s23/sqrt(2)}


v12 = v(4)/sqrt(2);
v13 = v(5)/sqrt(2);
v23 = v(6)/sqrt(2);

m   = [v(1) v12 v13;
    v12 v(2) v23;
    v13 v23 v(3)];