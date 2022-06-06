clear; 
clc; 
close all;

%% Introduzindo dados

mensagens=100000; 


bitspormsg=100;


bitstotal=mensagens*bitspormsg; 

%vetor de EB/N0 em dB
EBN0db_v=(0:2:10); 

%vetor de valores de BER sem usar codificação
BER_v=zeros(length(EBN0db_v),1); 

%vetor de valores de BER usando o codigo 1
BER_v1=zeros(length(EBN0db_v),1);

%vetor de valores de BER usando Codigo 2
BER_v2=zeros(length(EBN0db_v),1);

%Constraint Length = 5 pois 
K=5; 
%Traceback Depth
tbdepth=(K-1)*5; 
%Treliça 1
trellis1 = poly2trellis(K,[37 31]); 
%Treliça 2
trellis2 = poly2trellis(K,[35 31],37);

%% Algoritmo de Viterbi e adiçao de ruido

for k=1:length(EBN0db_v)
    
    EBN0db=EBN0db_v(k);
    disp(['Analisando caso de EB/N0 = ' int2str(EBN0db) 'dB'] );
    
    EBN0=10^(EBN0db/10);

    %Para Eb=1, N0=1/EBN0
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerr=0; 
    nerr1=0; 
    nerr2=0; 
    nbits=0;
    
    while nbits<=bitstotal
        %trem de bits 0/1 
        msg_v=randi(2,bitspormsg,1)-1;
        %coordenadas polares 
        signal_v=2*msg_v-1; 
        %ruido 
        n_v=sqrt(sigma2)*randn(length(signal_v),1);
        %sinal recebido 
        rsig_v=signal_v+n_v; 
        %decisor de limiar 
        rbits_v=(sign(rsig_v)+1)/2; 
        
        %Codificação 1
        %trem de bits 0/1  
        bits_v1=convenc(msg_v,trellis1); 
        %coordenadas polares 
        signal_v1=2*bits_v1-1; 
        %ruido 
        n_v1=sqrt(sigma2)*randn(length(signal_v1),1); 
        %sinal recebido 
        rsig_v1=signal_v1+n_v1; 
        %decisor de limiar l=0, gera os bits recebidos
        rbits_v1=(sign(rsig_v1)+1)/2; 
        %Algoritmo de Viterbi

        decode_v1=vitdec(rbits_v1,trellis1,tbdepth,'trunc','hard');
        
        %Codificação 2
        %trem de bits 0/1  
        bits_v2=convenc(msg_v,trellis2);  
        %coordenadas polares 
        signal_v2=2*bits_v2-1; 
        %ruido 
        n_v2=sqrt(sigma2)*randn(length(signal_v2),1); 
        %sinal recebido 
        rsig_v2=signal_v2+n_v2; 
        %decisor de limiar
        rbits_v2=(sign(rsig_v2)+1)/2; 

        %Algoritmo de Viterbi
        decode_v2=vitdec(rbits_v2,trellis2,tbdepth,'trunc','hard');

        %atualiza o nr de bits de informação 
        nbits=nbits+bitspormsg; 
        %atualiza o nr de erros 
        nerr=nerr+sum(abs(rbits_v-msg_v)); 
        %atualiza o nr de erros do codigo 1
        nerr1=nerr1+sum(abs(decode_v1-msg_v)); 
        %atualiza o nr de erros do codigo 2
        nerr2=nerr2+sum(abs(decode_v2-msg_v)); 

    end
    
    BER_v(k,1)=nerr/nbits;
    BER_v1(k,1)=nerr1/nbits;
    BER_v2(k,1)=nerr2/nbits;
    
end

%% Gerando figuras

figure();
semilogy(EBN0db_v,BER_v,'g+-');
hold on
semilogy(EBN0db_v,BER_v1,'y.-');
hold on
semilogy(EBN0db_v,BER_v2,'ko-');

xlabel('EB/N0 (dB)');
ylabel('Bit Error Rate');

legend('Sem codificação','Codificação 1','Codificação 2');

grid();