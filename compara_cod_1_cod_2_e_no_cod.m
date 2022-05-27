clear all; 
clc; 
close all;

%% Introduzindo dados

%mensagens transmitidas
mensagens=100000;

%numero de bits por mensagens
nbits=100; 

%numero total de bits na simulaçao
nbitsmax=mensagens*nbits; 

% vetor de EB/N0 em dB
EBN0db=(0:2:10); 

% vetor de de BER sem codificaçao
vetorBER1=zeros(length(EBN0db),1); 

%vetor de BER sem codificaçao
vetorBER3=zeros(length(EBN0db),1); 

%vetor de BER sem codificaçao
vetorBER3=zeros(length(EBN0db),1); 

%Constraint Length
K=5; 

%Traceback Depth
tbdepth=(K-1)*5; 

%% Codificaçao 1
%treliça relativa a CODIFICAÇAO 1
%trellis1 = poly2trellis(K,'x4','x4+1'); 

%treliça relativa a CODIFICAÇAO 1
trellis1 = poly2trellis(K,[20 21]); 

%% Codificaçao 2
%treliça relativa a COD 2
%trellis2 = poly2trellis(K,); 


%treliça relativa a CODIFICAÇAO 2
trellis2 = poly2trellis(K,[37 31],37); 

%% Viterbi

for ii=1:length(EBN0db)
    
    EBN0db=EBN0db(ii);
    disp(['iniciando EB/N0 = ' int2str(EBN0db) 'dB'] );
    
    EBN0=10^(EBN0db/10);
    
    %Eb = 1 e N0 = 1/EBN0
    
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerr=0; nerr1=0; nerr2=0; nbits=0;
    
    while nbits<=nbitsmax
        
        %vetor de bits (0/1) da mensagem
        vetormsg=randi(2,nbits,1)-1; 

        %sinal com coordenadas polares (-1/1) a ser transmitido (sem codificação)
        vetorpolar=2*vetormsg-1; 

        %vetor de amostras de ruido AWGN
        vetoramostras=sqrt(sigma2)*randn(length(vetorpolar),1); 
        
        %sinal recebido após a transimssão pelo canal
        sinalrecebido=vetorpolar+vetoramostras; 
        
        %decisor de limiar l=0, gera os bits recebidos
        bitsrecebidos=(sign(rsig_v)+1)/2; 
        
        %CODIFICADOR 1

        %vetor de bits (0/1) a serem transmitidos
        bits_v1=convenc(vetormsg,trellis1); 

        %sinal com coordenadas polares (-1/1) a ser transmitido (COD 1)
        signal_v1=2*bits_v1-1;

        %vetor de amostras de ruido AWGN
        n_v1=sqrt(sigma2)*randn(length(signal_v1),1); 

        %sinal recebido após a transimssão pelo canal
        rsig_v1=signal_v1+n_v1; 

        %decisor de limiar l=0, gera os bits recebidos
        rbits_v1=(sign(rsig_v1)+1)/2; 
        
        %bits decodificados pelo Algoritmo de Viterbi
        decode_v1=vitdec(rbits_v1,trellis1,tbdepth,'trunc','hard'); 
        
        %CODIFICADOR 2

        %vetor de bits (0/1) a serem transmitidos 
        bits_v2=convenc(vetormsg,trellis2); 
        %sinal com coordenadas polares (-1/1) a ser transmitido (COD 2)
        signal_v2=2*bits_v2-1; 
        %vetor de amostras de ruido AWGN
        n_v2=sqrt(sigma2)*randn(length(signal_v2),1); 
        %sinal recebido após a transimssão pelo canal
        rsig_v2=signal_v2+n_v2; 
        %decisor de limiar l=0, gera os bits recebidos
        rbits_v2=(sign(rsig_v2)+1)/2; 
        %bits decodificados pelo Algoritmo de Viterbi
        decode_v2=vitdec(rbits_v2,trellis2,tbdepth,'trunc','hard'); 
        %atualiza o nr de bits de informação transmitidos
        nbits=nbits+nbits; 
        %atualiza o nr de erros sem utilizar codificação
        nerr=nerr+sum(abs(bitsrecebidos-vetormsg)); 
        %atualiza o nr de erros ao utilizar COD 1
        nerr1=nerr1+sum(abs(decode_v1-vetormsg)); 
        %atualiza o nr de erros ao utilizar COD 2
        nerr2=nerr2+sum(abs(decode_v2-vetormsg)); 
        
    end
    
    BER_v(ii,1)=nerr/nbits;
    vetorBER1(ii,1)=nerr1/nbits;
    vetorBER3(ii,1)=nerr2/nbits;
    
end

%% Gerando figuras

figure();
semilogy(EBN0db,BER_v,'r+-');
hold on

semilogy(EBN0db,vetorBER1,'b.-');
hold on

semilogy(EBN0db,vetorBER3,'ko-');
xlabel('EB/N0 (dB)');
ylabel('BER');

legend('Sem codificação','CODIFICAÇÃO 1','CODIFICAÇÃO 2');
grid();