
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
        <div className=" h-full w-full flex flex-row bg-gray-500 relative">
            <Lane obstacles={laneObs[0]} />
            <LaneMarkings numMarks={8} width="w-[5%]" />
            <Lane obstacles={laneObs[1]} />
            <LaneMarkings numMarks={8} width="w-[5%]" />
            <Lane obstacles={laneObs[2]} />
            <LaneMarkings numMarks={8} width="w-[5%]" />
            <Lane obstacles={laneObs[3]} />
            
            {/* Player rendered outside lanes for smooth transition animation */}
            <Player laneIndex={playerLane} />
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

function Car({ color }) {
    return (
        <svg viewBox="0 0 100 200" className="w-full h-full drop-shadow-lg">
            {/* Wheels */}
            <rect x="5" y="30" width="15" height="40" fill="#333" rx="5" />
            <rect x="80" y="30" width="15" height="40" fill="#333" rx="5" />
            <rect x="5" y="130" width="15" height="40" fill="#333" rx="5" />
            <rect x="80" y="130" width="15" height="40" fill="#333" rx="5" />
            
            {/* Body Shadow */}
            <path d="M 15 20 Q 50 0 85 20 L 85 180 Q 50 200 15 180 Z" fill="rgba(0,0,0,0.3)" transform="translate(2, 2)" />

            {/* Main Body */}
            <path d="M 15 20 Q 50 0 85 20 L 85 180 Q 50 200 15 180 Z" fill={color} stroke="#333" strokeWidth="1" />
            
            {/* Windshield */}
            <path d="M 20 50 L 80 50 L 75 75 L 25 75 Z" fill="#87CEEB" stroke="#555" strokeWidth="1" />
            
            {/* Roof */}
            <rect x="22" y="75" width="56" height="60" fill={color} filter="brightness(1.1)" rx="5" />
            
            {/* Rear Window */}
            <path d="M 25 135 L 75 135 L 80 150 L 20 150 Z" fill="#87CEEB" stroke="#555" strokeWidth="1" />
            
            {/* Headlights */}
            <circle cx="25" cy="15" r="5" fill="#FFFFE0" />
            <circle cx="75" cy="15" r="5" fill="#FFFFE0" />
            
            {/* Taillights */}
            <rect x="20" y="180" width="15" height="5" fill="#FF0000" />
            <rect x="65" y="180" width="15" height="5" fill="#FF0000" />
        </svg>
    );
}

function Truck() {
    return (
        <svg viewBox="0 0 100 220" className="w-full h-full drop-shadow-lg">
            {/* Wheels */}
            <rect x="0" y="40" width="12" height="35" fill="#333" rx="4" />
            <rect x="88" y="40" width="12" height="35" fill="#333" rx="4" />
            <rect x="0" y="150" width="12" height="35" fill="#333" rx="4" />
            <rect x="88" y="150" width="12" height="35" fill="#333" rx="4" />
            
            {/* Shadow */}
            <rect x="15" y="15" width="70" height="190" rx="8" fill="rgba(0,0,0,0.3)" transform="translate(5, 5)" />

            {/* Cab (Front) */}
            <path d="M 15 40 Q 15 10 50 10 Q 85 10 85 40 L 85 70 L 15 70 Z" fill="#FF69B4" stroke="#C71585" strokeWidth="2" />
            
            {/* Windshield */}
            <path d="M 20 45 Q 50 35 80 45 L 80 65 L 20 65 Z" fill="#87CEEB" stroke="#4682B4" strokeWidth="1" />

            {/* Cargo Body (Back) */}
            <rect x="12" y="70" width="76" height="130" rx="5" fill="#FFB6C1" stroke="#C71585" strokeWidth="2" />
            
            {/* Cake Group */}
            <g transform="translate(50, 135)">
                {/* Plate */}
                <circle cx="0" cy="0" r="32" fill="#FFFFFF" stroke="#DDD" strokeWidth="1" opacity="0.9" />
                
                {/* Cake Base (Chocolate) */}
                <circle cx="0" cy="0" r="28" fill="#8B4513" stroke="#5D4037" strokeWidth="1" />
                
                {/* Icing Layer */}
                <circle cx="0" cy="0" r="24" fill="#FF69B4" />
                
                {/* Decorative Cream Dollops */}
                <circle cx="0" cy="-20" r="4" fill="#FFF" />
                <circle cx="14" cy="-14" r="4" fill="#FFF" />
                <circle cx="20" cy="0" r="4" fill="#FFF" />
                <circle cx="14" cy="14" r="4" fill="#FFF" />
                <circle cx="0" cy="20" r="4" fill="#FFF" />
                <circle cx="-14" cy="14" r="4" fill="#FFF" />
                <circle cx="-20" cy="0" r="4" fill="#FFF" />
                <circle cx="-14" cy="-14" r="4" fill="#FFF" />
                
                {/* Center Cherry */}
                <circle cx="0" cy="0" r="6" fill="#FF0000" stroke="#8B0000" strokeWidth="1" />
                <circle cx="-2" cy="-2" r="2" fill="#FFFFFF" opacity="0.6" />
            </g>
            
            {/* Headlights */}
            <circle cx="25" cy="15" r="5" fill="#FFFFE0" stroke="#DAA520" strokeWidth="1" />
            <circle cx="75" cy="15" r="5" fill="#FFFFE0" stroke="#DAA520" strokeWidth="1" />
        </svg>
    );
}

function Lane({obstacles}) {
    return (
        <div className={`grow relative items-center`}>
            {/* Render obstacles */}
            {obstacles.map((obstacle, index) => {
                // Handle both boolean (legacy/init) and object structure
                const isActive = obstacle.active !== undefined ? obstacle.active : obstacle;
                
                if (!isActive) return null;
                
                // Calculate position from bottom
                // Index 0 is lowest. We want only top 1/3 visible (approx -8% bottom)
                // Index 127 is highest (approx 92% bottom)
                const bottomPercent = (index / 127) * 100 - 8;
                const color = obstacle.color || "#FF0000"; // Default red if no color
                
                // Use ID for key if available to enable smooth transitions
                const key = obstacle.id || index;

                return (
                    <Obstacle 
                        key={key} 
                        bottomPercent={bottomPercent}
                        color={color}
                        zIndex={200 - index} // Higher index (further away) should be behind lower index (closer)
                    />
                );
            })}
        </div>
    );
}

function Player({ laneIndex }) {
    // Calculate horizontal position based on lane
    // Each lane is ~21.25% wide (85% total / 4 lanes)
    // Lane markings are 5% each (3 markings = 15%)
    // Lane 0 starts at 0%, Lane 1 at 26.25%, Lane 2 at 52.5%, Lane 3 at 78.75%
    const lanePositions = [0, 26.25, 52.5, 78.75];
    const leftPercent = laneIndex >= 0 ? lanePositions[laneIndex] : 0;
    
    return (
        <div 
            className='absolute bottom-5 h-24 flex items-center justify-center z-[250]'
            style={{
                left: `${leftPercent}%`,
                width: '21.25%',
                paddingLeft: '5.3%',
                paddingRight: '5.3%',
                transition: 'left 0.5s ease-out'
            }}
        >
            <Truck />
        </div>
    )
}

function Obstacle({bottomPercent, color, zIndex}) {
    return (
        <div 
            className={`absolute left-1/4 w-1/2 h-24 flex items-center justify-center`}
            style={{
                bottom: `${bottomPercent}%`,
                transition: 'bottom 0.5s ease-out',
                zIndex: zIndex
            }}
        >
            <Car color={color} />
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
            {/* {gameOver && (
                <GameOver pontuacao={distance} max_pontuacao={500}/>
            )} */}
        </div>
    );
}
