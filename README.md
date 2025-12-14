# BitBakery 🍰

## Introdução 📜

Projeto elaborado para a disciplina de PCS3635. O objetivo do projeto é criar jogos sérios para pessoas com TEA (transtorno do espectro autísta) executáveis em uma fpga, usando como base o jogo genius.

O projeto é constituído por três minigames, um deles sendo o próprio jogo da memória, outro semelhante ao minigame da fábrica de bolos do jogo purble place, do windows 7, além de um terceiro jogo de entregas. 

Nesse repositório encontram-se tanto códigos da interface (src/), e descrição de hardware utilizadas (verilog/), quanto da comunicação entre ambas (api/).

Na feira de projetos final da disciplina de LabDig1, recebemos a menção honrosa do terceiro lugar.

<div align="center">
    <img src="src/final_project.jpeg" alt="drawing" width="50%"/>
</div>

## Dependências 🎮

- [node.js](https://nodejs.org/pt) 
- flask 
- flask_cors 
- pygame (opcional)

### Instalação das dependências
```
pip install -r requirements.txt
npm install
```

## Pygame vs. sensores reais ⚔️

Para alternar entre leituras feitas em instrumentos reais e leituras feitas , comente as linhas indicadas nas instruções contidas no arquivo api/analog_server.py

## Execução da interface 🎨

Para executar o projeto em modo de desenvolvimento, utilize o comando abaixo. Isso iniciará tanto a interface Next.js quanto o servidor API Python simultaneamente.

```bash
npm run dev
```

Para buildar e iniciar em modo de produção:

```bash
npm run start
```

Após executar um dos comandos acima, o site pode ser acessado em http://localhost:3000/