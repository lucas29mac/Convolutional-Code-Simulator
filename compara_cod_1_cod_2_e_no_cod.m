clear; 
clc; 
close all;

%% Introduzindo dados

nmsgs=100000; %nr de mensagens a serem transmitidas
nbits_msg=100; %nr de bits por mensagem
nbits_max=nmsgs*nbits_msg; %nr total de bits a serem transmitidos na simulacao

EBN0db_v=(0:2:10); %vetor de EB/N0 em dB a ser simulado
BER_v=zeros(length(EBN0db_v),1); %vetor de valores de BER sem usar codificação
BER_v1=zeros(length(EBN0db_v),1); %vetor de valores de BER usando COD 1
BER_v2=zeros(length(EBN0db_v),1); %vetor de valores de BER usando COD 2

K=5; %Constraint Length
tbdepth=(K-1)*5; %Traceback Depth
trellis1 = poly2trellis(K,[37 31]); %define a treliça relativa a COD 1
trellis2 = poly2trellis(K,[35 31],37); %define a treliça relativa a COD 2

%% Algoritmo de Viterbi
for ii=1:length(EBN0db_v)
    
    EBN0db=EBN0db_v(ii);
    disp(['iniciando EB/N0 = ' int2str(EBN0db) 'dB'] );
    
    EBN0=10^(EBN0db/10);
    %obs - considerando Eb=1, N0=1/EBN0
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerr=0; nerr1=0; nerr2=0; nbits=0;
    
    while nbits<=nbits_max
        
        msg_v=randi(2,nbits_msg,1)-1; %vetor de bits (0/1) da mensagem
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
        
        nbits=nbits+nbits_msg; %atualiza o nr de bits de informação transmitidos
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
legend('Sem codificação','COD 1','COD 2');
grid();