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
import MemoryGameHeader from '../../../components/MemoryGameHeader';

export default function memorygame() {
  console.log("Memory Game Loaded - Version with Strawberry");
  const items = [Strawberry, Butter, MilkBottle, Eggs, CocoaPowder,  FlourBag ];
  
  const colors = [
    "#ff194f", "#ffb400", "#00a6ed",
    "#00ff7f", "#632501", "#8f00ff"
  ];

  const { jogada, pontuacao, gameOver, aguardar, difficulty } = useMemoryGame();
  let temp_jogada = jogada ? jogada.slice(0, items.length) : [];
  let max_pontuacao = difficulty ? 8 : 16;

  const renderData = items.map((ItemComponent, index) => (
    <div 
      key={index}
      style={{
        margin: '1.5vw',
        filter: `drop-shadow(0 0 10px ${colors[index]}) drop-shadow(0 0 30px ${colors[index]})`,
        flexShrink: 0,
        transition: 'transform 0.3s ease',
        cursor: 'pointer',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center'
      }}
    >
      <ItemComponent 
        isActive={!!temp_jogada[index]} 
        width="12vw"
        height="12vw"
        style={{ 
          width: "12vw", 
          height: "12vw", 
          maxWidth: "200px", 
          maxHeight: "200px", 
          minWidth: "80px", 
          minHeight: "80px" 
        }} 
      />
    </div>
  ));

  return (
    <div className="bg-[url('/mem_bg.jpg')]"  id="container">
      <Head>
        <title>Jogo da memória - BitBakery</title>
        <link rel="stylesheet" href="styles/globals.css" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <link href="https://fonts.googleapis.com/css2?family=Joti+One&family=Mouse+Memoirs&family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet" />      
      </Head>
      <div className='titulo-principal'>
        <MemoryGameHeader title={"Jogo da memória"} className="space-grotesk-principal text-5xl text-center text-black"/>
      </div>
      <div>
        <p id="titulo-memoria" className="font-sans text-4xl font-bold text-center" style={{ color: !aguardar ? "#89E0E3" : "#F49DAE", WebkitTextStroke: "1px gray" }}>{aguardar ? "Aguarde para jogar" : "Faça sua jogada"}</p>
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