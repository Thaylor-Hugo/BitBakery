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

  const { jogada, pontuacao, gameOver } = useMemoryGame();
  let temp_jogada = jogada ? jogada.slice(0, colors.length) : [];

  const renderData = colors.map((color, index) => (
      <Circle key={index + color} bgColor={temp_jogada[index] ? colors[index] : 'black'} />
  ));

  return (
    <div id="container">
      <Head>
        <title>Jogo da memória - BitBakery</title>
        <link rel="stylesheet" href="styles/globals.css" />
      </Head>
      <div className='circulos'>
          {renderData}
      </div>
      {gameOver && (
            <GameOver pontuacao={pontuacao} />
        )}
    </div>
  );
}