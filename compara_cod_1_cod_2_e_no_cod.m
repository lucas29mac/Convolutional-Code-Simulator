clear all; 
clc; 
close all;
%% Introduzindo dados

%mensagens transmitidas
mensagens=100000;

%numero de bits por mensagens
nbits=100; 

%numero total de bits na simulaçao
nbits_max=mensagens*nbits; 

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

%Traceback Depth
tbdepth=(K-1)*5; 

%% treliça 1
%define a treliça relativa a CODIFICAÇAO 1
%trellis1 = poly2trellis(K,'x4','x4+1'); 

trellis1 = poly2trellis(K,[20 21]); %define a treliça relativa a COD 1

%% treliça 2
%define a treliça relativa a COD 2
%trellis2 = poly2trellis(K,); 

trellis2 = poly2trellis(K,[37 23],37); %define a treliça relativa a CODIFICAÇAO 2

%%

for ii=1:length(EBN0db_v)
    
    EBN0db=EBN0db_v(ii);
    disp(['iniciando EB/N0 = ' int2str(EBN0db) 'dB'] );
    
    EBN0=10^(EBN0db/10);
    %obs - considerando Eb=1, N0=1/EBN0
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerr=0; nerr1=0; nerr2=0; nbits=0;
    
    while nbits<=nbits_max
        
        msg_v=randi(2,nbits,1)-1; %vetor de bits (0/1) da mensagem
        signal_v=2*msg_v-1; %sinal com coordenadas polares (-1/1) a ser transmitido (sem codificação)
        n_v=sqrt(sigma2)*randn(length(signal_v),1); %vetor de amostras de ruido AWGN
        rsig_v=signal_v+n_v; %sinal recebido após a transimssão pelo canal
        rbits_v=(sign(rsig_v)+1)/2; %decisor de limiar l=0, gera os bits recebidos
        
        %COD 1
        bits_v1=convenc(msg_v,trellis1); %vetor de bits (0/1) a serem transmitidos 
        signal_v1=2*bits_v1-1; %sinal com coordenadas polares (-1/1) a ser transmitido (COD 1)
        n_v1=sqrt(sigma2)*randn(length(signal_v1),1); %vetor de amostras de ruido AWGN
        rsig_v1=signal_v1+n_v1; %sinal recebido após a transimssão pelo canal
        rbits_v1=(sign(rsig_v1)+1)/2; %decisor de limiar l=0, gera os bits recebidos
        decode_v1=vitdec(rbits_v1,trellis1,tbdepth,'trunc','hard'); %bits decodificados pelo Algoritmo de Viterbi
        
        %COD 2
        bits_v2=convenc(msg_v,trellis2); %vetor de bits (0/1) a serem transmitidos 
        signal_v2=2*bits_v2-1; %sinal com coordenadas polares (-1/1) a ser transmitido (COD 2)
        n_v2=sqrt(sigma2)*randn(length(signal_v2),1); %vetor de amostras de ruido AWGN
        rsig_v2=signal_v2+n_v2; %sinal recebido após a transimssão pelo canal
        rbits_v2=(sign(rsig_v2)+1)/2; %decisor de limiar l=0, gera os bits recebidos
        decode_v2=vitdec(rbits_v2,trellis2,tbdepth,'trunc','hard'); %bits decodificados pelo Algoritmo de Viterbi
        
        nbits=nbits+nbits; %atualiza o nr de bits de informação transmitidos
        nerr=nerr+sum(abs(rbits_v-msg_v)); %atualiza o nr de erros sem utilizar codificação
        nerr1=nerr1+sum(abs(decode_v1-msg_v)); %atualiza o nr de erros ao utilizar COD 1
        nerr2=nerr2+sum(abs(decode_v2-msg_v)); %atualiza o nr de erros ao utilizar COD 2
        
    end
    
    BER_v(ii,1)=nerr/nbits;
    BER_v1(ii,1)=nerr1/nbits;
    BER_v2(ii,1)=nerr2/nbits;
    
end

%% Gerando figuras
figure();
semilogy(EBN0db_v,BER_v,'r+-');
hold on
semilogy(EBN0db_v,BER_v1,'b.-');
hold on
semilogy(EBN0db_v,BER_v2,'ko-');
xlabel('EB/N0 (dB)');
ylabel('BER');
legend('Sem codificação','CODIFICAÇÃO 1','CODIFICAÇÃO 2');
grid();