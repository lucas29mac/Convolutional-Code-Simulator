clear; 
clc; 
close all;

%% Introduzindo dados
% numero de mensagens
nmsgs=100000;
%numero de bits por mensagem
nbits_msg=100;
%numero total de bits na simulaçao
nbits_max=nmsgs*nbits_msg; 

% vetor de EB/N0 em dB
EBN0db_v=(0:2:10); 
% vetor de de BER sem codificaçao
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
%% algoritmo de viterbi 

for ii=1:length(EBN0db_v)
    
    EBN0db=EBN0db_v(ii);
    disp(['iniciando EB/N0 = ' int2str(EBN0db) 'dB'] );
    
    EBN0=10^(EBN0db/10);
    %obs - considerando Eb=1, N0=1/EBN0
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerr1=0; nerr2=0; nerr3=0; nbits=0;
    
    while nbits<=nbits_max
        
        msg_v=randi(2,nbits_msg,1)-1; %vetor de bits (0/1) da mensagem
        
        %COD 2
        bits_v=convenc(msg_v,trellis); %vetor de bits (0/1) a serem transmitidos 
        signal_v=2*bits_v-1; %sinal com coordenadas polares (-1/1) a ser transmitido (COD 2)
        n_v=sqrt(sigma2)*randn(length(signal_v),1); %vetor de amostras de ruido AWGN
        rsig_v=signal_v+n_v; %sinal recebido após a transimssão pelo canal
        rbits_v=(sign(rsig_v)+1)/2; %decisor de limiar l=0, gera os bits recebidos
        decode_v1=vitdec(rbits_v,trellis,tbdepth1,'trunc','hard'); %bits decodificados pelo Algoritmo de Viterbi com Traceback Depth menor que K*5
        decode_v2=vitdec(rbits_v,trellis,tbdepth2,'trunc','hard'); %bits decodificados pelo Algoritmo de Viterbi com Traceback Depth K*5
        decode_v3=vitdec(rbits_v,trellis,tbdepth3,'trunc','hard'); %bits decodificados pelo Algoritmo de Viterbi com Traceback Depth maior que K*5
        
        nbits=nbits+nbits_msg; %atualiza o nr de bits de informação transmitidos
        nerr1=nerr1+sum(abs(decode_v1-msg_v)); %atualiza o nr de erros com Traceback Depth menor que K*5
        nerr2=nerr2+sum(abs(decode_v2-msg_v)); %atualiza o nr de erros com Traceback Depth K*5
        nerr3=nerr3+sum(abs(decode_v3-msg_v)); %atualiza o nr de erros com Traceback Depth maior que K*5
        
    end
    
    BER_v1(ii,1)=nerr1/nbits;
    BER_v2(ii,1)=nerr2/nbits;
    BER_v3(ii,1)=nerr3/nbits;
    
end

%% Gerando figuras
figure();
semilogy(EBN0db_v,BER_v1,'r');
hold on

semilogy(EBN0db_v,BER_v2,'bo-');
hold on

semilogy(EBN0db_v,BER_v3,'k.-');
xlabel('EB/N0 (dB)');
ylabel('BER');

legend('Traceback Depth menor que (K-1)*5','Traceback Depth (K-1)*5','Traceback Depth maior que (K-1)*5');
grid();