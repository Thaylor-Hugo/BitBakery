'use client'

import Head from 'next/head';
import FlourBag from '../../../components/FlourBag';
import MilkBottle from '../../../components/MilkBottle';
import Eggs from '../../../components/Eggs';
import Butter from '../../../components/Butter';
import CocoaPowder from '../../../components/CocoaPowder';
import Strawberry from '../../../components/Strawberry';
import '../../globals.css';
import { useMemoryGame } from '../../../hooks/memorygame';
import GameOver from '../../../components/GameOver';
import Header from "../../../components/basic";

export default function memorygame() {
  console.log("Memory Game Loaded - Version with Strawberry");
  const items = [Strawberry, Butter, MilkBottle, Eggs, CocoaPowder,  FlourBag ];

  const { jogada, pontuacao, gameOver, aguardar, difficulty } = useMemoryGame();
  let temp_jogada = jogada ? jogada.slice(0, items.length) : [];
  let max_pontuacao = difficulty ? 8 : 16;

  const renderData = items.map((ItemComponent, index) => (
      <ItemComponent 
        key={index} 
        isActive={!!temp_jogada[index]} 
        style={{ width: 150, height: 150, margin: 20 }} 
      />
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
        <Header title={"Jogo da memória"} className="space-grotesk-principal text-5xl text-center text-black"/>
      </div>
      <div>
        <p id="titulo-memoria" className="font-sans text-4xl font-bold text-center" style={{ color: !aguardar ? "#28a745ff" : "#cc0000ff", WebkitTextStroke: "1px gray" }}>{aguardar ? "Aguarde para jogar" : "Faça sua jogada"}</p>
      </div>
      <div id="circles">
        <div className='circulos'>
            {renderData}
        </div>
      </div>
      {gameOver && (
            <GameOver pontuacao={pontuacao} max_pontuacao={max_pontuacao} />
        )}
    </div>
  );
}