'use client'

import Head from 'next/head';
import Circle from '../../../components/Circle';
import '../../globals.css';
import { useMemoryGame } from '../../../hooks/memorygame';
import GameOver from '../../../components/GameOver';

export default function memorygame() {

  const colors = [
    "#ff194f", "#ffb400", "#00a6ed",
    "#00ff7f", "#632501", "#8f00ff"
  ];

  const { jogada, pontuacao, gameOver, aguardar } = useMemoryGame();
  let temp_jogada = jogada ? jogada.slice(0, colors.length) : [];

  const renderData = colors.map((color, index) => (
      <Circle key={index + color} bgColor={temp_jogada[index] ? colors[index] : 'black'} />
  ));

  return (
    <div className="bg-[url('../../src/memorygame-bg.png')]"  id="container">
      <Head>
        <title>Jogo da memória - BitBakery</title>
        <link rel="stylesheet" href="styles/globals.css" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <link href="https://fonts.googleapis.com/css2?family=Joti+One&family=Mouse+Memoirs&family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet" />      </Head>
      <div className='titulo-principal'>
        <h1 className="space-grotesk-principal text-5xl text-center text-black">Jogo da memória</h1>
      </div>
      <div>
        <p id="titulo-memoria" className="font-sans text-4xl font-bold text-center text-white">{aguardar ? "Aguarde para jogar" : "Faça sua jogada"}</p>
      </div>
      <div id="circles">
        <div className='circulos'>
            {renderData}
        </div>
      </div>
      {gameOver && (
            <GameOver pontuacao={pontuacao} />
        )}
    </div>
  );
}