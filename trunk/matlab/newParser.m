function [feat]  = newParser()

%   dummy function: restituisce una struct di coordinate di prova in forma

%   feat.c[]    - lista livello contrasto
% non serve altro alla fine!

lam = 5;

for ii = 1:40;
    %     num = 2+ceil(rand()*3) % numero random di frame tra 3 e 5
    num = 5;
    feat(ii).c = 1-exp(-(1:num)/lam)+random('Normal',0,.05,1,num); % genero contrasto + noise
    %     plot(feat(ii).c);
end

syms x;
figure;
hold on;
ezplot('1-exp(-x/5)',[0,6]);
for ff=feat(1:end)
    plot(ff.c,'ro');
end