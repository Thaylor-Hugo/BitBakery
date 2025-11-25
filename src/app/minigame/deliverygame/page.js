
'use client'
import { useDeliveryGame } from '../../../hooks/deliverygame';
import Header from '../../../components/basic';
import GameOver from '../../../components/GameOver';


function Map({map, playerPosition}) {
    // Calculate which lane each obstacle and player is in
    const getPosition = (boolArray) => boolArray.findIndex(val => val === true);
    const laneObs = [[], [], [], []];
    for (let index = 0; index < map.length; index++) {
        laneObs[0].push(map[index][0]);
        laneObs[1].push(map[index][1]);
        laneObs[2].push(map[index][2]);
        laneObs[3].push(map[index][3]);
    }
    const playerLane = getPosition(playerPosition);

    return (
        <div className=" h-full w-full flex flex-row bg-gray-500">
            <Lane obstacles={laneObs[0]} isPlayer={playerLane == 0}/>
            <LaneMarkings numMarks={8} width="w-[5%]" />
            <Lane obstacles={laneObs[1]} isPlayer={playerLane == 1}/>
            <LaneMarkings numMarks={8} width="w-[5%]" />
            <Lane obstacles={laneObs[2]} isPlayer={playerLane == 2}/>
            <LaneMarkings numMarks={8} width="w-[5%]" />
            <Lane obstacles={laneObs[3]} isPlayer={playerLane == 3}/>
        </div>
    )
}


function LaneMarkings({numMarks, width}) {
    const marks = [];
    // Double the marks so we can create infinite scroll effect
    for (let index = 0; index < numMarks * 2; index++) {
        marks.push(
            <div key={index} className='flex-1'>
                <div className="h-1/2 bg-white"></div>
                <div className="h-1/2"></div>
            </div>
        )   
    }
    return (
        <div className={`${width} h-full flex flex-col overflow-hidden relative`}>
            <div className="absolute inset-0 flex flex-col animate-scroll-down">
                {marks}
            </div>
        </div>
    );
}

function Lane({obstacles, isPlayer}) {
    // Calculate position for each obstacle
    // Index 0 is closest to bottom, index 15 is farthest
    // We need to subtract obstacle height (h-16 = 4rem = 64px) from positioning
    return (
        <div className={`grow relative items-center`}>
            {/* Render obstacles */}
            {obstacles.map((hasObstacle, index) => {
                if (!hasObstacle) return null;
                
                // Calculate position from bottom, accounting for 16 sections
                // Leave space at top so index 15 doesn't go off screen
                // Use 85% of height for obstacles (index 15 at 85%)
                const bottomPercent = (index / 15) * 85;
                console.log("index: ", index)
                console.log("Percent: ", bottomPercent)

                return (
                    <Obstacle 
                        key={index} 
                        bottomPercent={bottomPercent}
                    />
                );
            })}
            
            {/* Render player */}
            {isPlayer && <Player />}
        </div>
    );
}

function Player() {
    return (
        <div className='absolute bottom-5 left-1/4 w-1/2 h-16 bg-blue-500 rounded-full flex items-center justify-center'>
            {/* Render player */}
            <span className="text-white text-2xl">🚴</span>
        </div>
    )
}

function Obstacle({bottomPercent}) {
    return (
        <div 
            className={`absolute left-1/4 w-1/2 h-16 bg-red-500 rounded-lg flex items-center justify-center`}
            style={{
                bottom: `${bottomPercent}%`,
                transition: 'bottom 0.5s ease-out'
            }}
        >
            <span className="text-white text-2xl">🚧</span>
        </div>
    );
}

export default function DeliveryGame() {
    const { playerPosition, mapObstacles, gameOver, playing, distance } = useDeliveryGame();

    return (
        <div className="w-screen h-screen flex flex-col items-center bg-cover bg-[url('../../src/cakegame-bg.jpg')] relative">
            {/* Game Content */}
            <div>
                <Header title="Delivery Game" />
            </div>
            {/* Game map Map */}
            <div className="w-1/2 h-full relative">
                <Map map={mapObstacles} playerPosition={playerPosition}/>
            </div>


            {/* Game Over Screen */}
            {gameOver && (
                <GameOver pontuacao={distance} max_pontuacao={500}/>
            )}
        </div>
    );
}
