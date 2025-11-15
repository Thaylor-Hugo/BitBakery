
'use client'
import { useDeliveryGame } from '../../../hooks/deliverygame';
import Header from '../../../components/basic';
import GameOver from '../../../components/GameOver';


function Street({map, playerPosition}) {
    return (
        <div>
            {/* Render street based on map obstacles and player position */}
        </div>
    )
}

function Player() {
    return (
        <div>
            {/* Render player */}

        </div>
    )
}

function Obstacle() {
    return (
        <div>
            {/* Render obstacle */}
        </div>
    )
}

export default function DeliveryGame() {
    const { playerPosition, mapObstacles, gameOver, playing, distance } = useDeliveryGame();

    return (
        <div className="h-screen flex flex-col bg-cover bg-[url('../../src/cakegame-bg.jpg')] relative">
            {/* Game Content */}
            <div>
                <Header title="Delivery Game" />
            </div>
            {/* Game map Street */}
            <div>
                <Street map={mapObstacles} playerPosition={playerPosition}/>
            </div>


            {/* Game Over Screen */}
            {gameOver && (
                <GameOver pontuacao={distance} max_pontuacao={500}/>
            )}
        </div>
    );
}
