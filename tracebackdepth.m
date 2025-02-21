clear; 
clc; 
close all;

%% Introduzindo dados


nmsgs=100000;

bitspormsg=100;

bitstotal=nmsgs*bitspormsg; 

% vetor de EB/N0 em dB
EBN0db_v=(0:2:10); 

% vetor de BER sem codificaçao
BER_v1=zeros(length(EBN0db_v),1); 

%vetor de BER sem codificaçao
BER_v2=zeros(length(EBN0db_v),1); 

%vetor de BER sem codificaçao
BER_v3=zeros(length(EBN0db_v),1); 

%Constraint Length
K=5; 

%Traceback Depth menor que K*5
tbdepth1=(K-1)*5-15;

%Traceback Depth igual a K*5
tbdepth2=(K-1)*5;

%Traceback Depth maior que K*5
tbdepth3=(K-1)*5+15;



%treliça da CODIFICAÇAO 2
trellis = poly2trellis(K,[37 31],37);

%% Algoritmo de Viterbi 

for k= 1 : length(EBN0db_v)
    
    EBN0db=EBN0db_v(k);

    disp(['Para EB/N0 = ' int2str(EBN0db) 'dB'] );
    
    EBN0=10^(EBN0db/10);

    %considerando Eb=1, N0=1/EBN0
    
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerr1=0; nerr2=0; nerr3=0; nbits=0;
    
    while nbits<=bitstotal

        %trem de bits
        msg_v=randi(2,bitspormsg,1)-1; 
        
        %Codigo 2

        %trem de bits 
        bits_v=convenc(msg_v,trellis); 
        
        %coordenadas polares
        signal_v=2*bits_v-1; 
        
        %ruido 
        n_v=sqrt(sigma2)*randn(length(signal_v),1); 
        
        %sinal recebido 
        rsig_v=signal_v+n_v; 
        
        %decisor de limiar
        rbits_v=(sign(rsig_v)+1)/2; 
        
        %Algoritmo de Viterbi com Traceback Depth menor que K*5
        decode_v1=vitdec(rbits_v,trellis,tbdepth1,'trunc','hard'); 
        
        %Algoritmo de Viterbi com Traceback Depth K*5
        decode_v2=vitdec(rbits_v,trellis,tbdepth2,'trunc','hard'); 
        
        %Algoritmo de Viterbi com Traceback Depth maior que K*5
        decode_v3=vitdec(rbits_v,trellis,tbdepth3,'trunc','hard'); 
        
        %atualiza o nr de bits de informação
        nbits=nbits+bitspormsg; 
        
        %atualiza o nr de erros com Traceback Depth menor que K*5
        nerr1=nerr1+sum(abs(decode_v1-msg_v)); 

        %atualiza o nr de erros com Traceback Depth K*5
        nerr2=nerr2+sum(abs(decode_v2-msg_v)); 
        
        %atualiza o nr de erros com Traceback Depth maior que K*5
        nerr3=nerr3+sum(abs(decode_v3-msg_v)); 
        
    end
    
    BER_v1(k,1)=nerr1/nbits;
    BER_v2(k,1)=nerr2/nbits;
    BER_v3(k,1)=nerr3/nbits;
    
end

%% Gerando figuras

figure();

semilogy(EBN0db_v,BER_v1,'k');
hold on

semilogy(EBN0db_v,BER_v2,'bo-');
hold on

semilogy(EBN0db_v,BER_v3,'g.-');

xlabel('EB/N0 (dB)');
ylabel('Bits Error Rate');

legend('Traceback Depth < (K-1)*5','Traceback Depth = (K-1)*5','Traceback Depth > (K-1)*5');
grid();