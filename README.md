# Exemplo de Aplicativo Shiny contruido com Módulos

Este é um exemplo de um aplicativo Shiny construído usando módulos para facilitar a sua manutenção. Os gráficos são reativos e utilizam o pacote `plotly` para visualização interativa.

## Aviso Importante

**Atenção: As informações fornecidas neste aplicativo são apenas um exemplo e não devem ser consideradas para nenhuma tomada de decisão financeira.**

Antes de prosseguir, é importante ressaltar que as análises espectrais realizadas neste exemplo não levaram em consideração a irregularidade do espaçamento dos dados. Essas análises foram feitas apenas com propósitos ilustrativos. O principal objetivo aqui é demonstrar as funcionalidades e facilidades oferecidas pelo Shiny.

Ao trabalhar com dados irregularmente espaçados e realizar uma análise de espectro de potência (Fourier) ou um espectrograma de wavelets, é recomendável considerar alternativas mais adequadas. Alguns métodos que poderiam ser mais viáveis incluem:

- Interpolação dos dados para torná-los regularmente espaçados;
  - interpolação linear;
  - interpolação por splines;
  - interpolação por vizinho mais próximo;
  - interpolação por média móvel;
  - etc.
- Exploração de métodos de análise espectral projetados para lidar diretamente com dados irregulares;
  - Periodograma de Lomb-Scargle (espectro de potência);
  - transformada wavelet sobre árvore adaptativa (AWT);
  - transformada wavelet com malhas não uniformes.

Certifique-se de adaptar a análise de acordo com a natureza dos dados e as necessidades específicas do seu projeto.

## Executando o Aplicativo

Para executar este aplicativo Shiny, você precisará ter o R instalado em seu sistema e o pacote Shiny. Além disso, as dependências necessárias podem ser instaladas executando o seguinte comando no R:

shiny::runGitHub("stocks_analyzer", username ="cruz-ml-pedro", subdir = "aplicativo")


Caso você não esteja familiarizado com o R, mas tenha conhecimento em operar com Docker, este repositório possui um Dockerfile para a construção de uma imagem do aplicativo. Para executar o aplicativo utilizando o Docker, siga as instruções abaixo:

Certifique-se de ter o Docker instalado em seu sistema. Você pode encontrar instruções de instalação para diferentes plataformas no site oficial do Docker: https://docs.docker.com/get-docker/.

Clone o repositório do GitHub para o seu ambiente local. Utilize o comando git clone seguido da URL do repositório. Por exemplo:

git clone https://github.com/cruz-ml-pedro/stocks_analyzer.git

Isso criará uma cópia local do repositório em seu diretório atual.

Navegue até o diretório clonado do repositório. Por exemplo:

cd stocks_analyzer

Construa a imagem do aplicativo utilizando o Docker. Execute o seguinte comando:

docker build -t stock_analyzer .

Após a conclusão da construção da imagem, você pode executar o aplicativo utilizando o Docker. Utilize o comando a seguir:

docker run -p 3838:3838 stock_analyzer

Isso iniciará um contêiner Docker com o aplicativo em execução. O aplicativo estará acessível no endereço http://localhost:3838 em seu navegador.

Dessa forma, você poderá executar o aplicativo Shiny utilizando o Docker, mesmo sem estar familiarizado com o R.

Talvez você esteja se perguntando por que não fiz o deploy deste aplicativo. Infelizmente, o tamanho de aproximadamente 2GB excede os limites de muitas plataformas para opções de deploy gratuito. Assim que eu encontrar um local que permita o deploy, irei fazê-lo. 

