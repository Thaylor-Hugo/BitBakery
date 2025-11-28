
'use client'
import { useDeliveryGame } from '../../../hooks/deliverygame';
import Header from '../../../components/basic';
import GameOver from '../../../components/GameOver';


function VillageBackground() {
    // Reusable building block component rendered inline
    const BuildingBlock = ({ y }) => (
        <g transform={`translate(0, ${y})`}>
            {/* Grass base */}
            <rect x="0" y="0" width="400" height="200" fill="#7CCD7C" />
            
            {/* Sidewalk/curb near road */}
            <rect x="350" y="0" width="50" height="200" fill="#D3D3D3" />
            <rect x="345" y="0" width="5" height="200" fill="#A9A9A9" />
            
            {/* Building 1 - Bakery (top-down roof view) */}
            <g transform="translate(30, 20)">
                <rect x="0" y="0" width="120" height="80" fill="#C71585" stroke="#8B008B" strokeWidth="2" rx="3" />
                <rect x="10" y="10" width="100" height="60" fill="#FFB6C1" stroke="#C71585" strokeWidth="1" />
                {/* Roof details */}
                <rect x="50" y="25" width="20" height="30" fill="#8B4513" opacity="0.6" />
                {/* Sign on roof */}
                <rect x="30" y="30" width="15" height="20" fill="#FFF" stroke="#C71585" strokeWidth="1" />
            </g>
            
            {/* Tree 1 */}
            <circle cx="180" cy="50" r="25" fill="#228B22" />
            <circle cx="170" cy="60" r="18" fill="#32CD32" />
            <circle cx="195" cy="55" r="15" fill="#2E8B57" />
            
            {/* Building 2 - House (top-down roof view) */}
            <g transform="translate(220, 30)">
                <rect x="0" y="0" width="80" height="60" fill="#CD853F" stroke="#8B4513" strokeWidth="2" rx="2" />
                <rect x="8" y="8" width="64" height="44" fill="#FFDAB9" stroke="#DEB887" strokeWidth="1" />
                {/* Chimney */}
                <rect x="55" y="5" width="12" height="12" fill="#8B4513" stroke="#5D4037" strokeWidth="1" />
            </g>
            
            {/* Flowers patch 1 */}
            <circle cx="165" cy="100" r="4" fill="#FF69B4" />
            <circle cx="175" cy="105" r="3" fill="#FFB6C1" />
            <circle cx="185" cy="98" r="4" fill="#DDA0DD" />
            
            {/* Building 3 - Cake shop (top-down roof view) */}
            <g transform="translate(50, 110)">
                <rect x="0" y="0" width="100" height="70" fill="#9370DB" stroke="#8B008B" strokeWidth="2" rx="3" />
                <rect x="10" y="10" width="80" height="50" fill="#E6E6FA" stroke="#9370DB" strokeWidth="1" />
                {/* AC unit on roof */}
                <rect x="60" y="20" width="20" height="15" fill="#A9A9A9" stroke="#808080" strokeWidth="1" />
            </g>
            
            {/* Tree 2 */}
            <circle cx="200" cy="140" r="20" fill="#32CD32" />
            <circle cx="190" cy="150" r="15" fill="#228B22" />
            <circle cx="215" cy="145" r="12" fill="#2E8B57" />
            
            {/* Small bush */}
            <ellipse cx="280" cy="120" rx="15" ry="10" fill="#228B22" />
            <ellipse cx="295" cy="118" rx="12" ry="8" fill="#32CD32" />
            
            {/* Parking lot lines */}
            <g stroke="#FFF" strokeWidth="2" opacity="0.7">
                <line x1="320" y1="30" x2="320" y2="70" />
                <line x1="320" y1="130" x2="320" y2="170" />
            </g>
            
            {/* Flowers patch 2 */}
            <circle cx="260" cy="170" r="3" fill="#FF69B4" />
            <circle cx="270" cy="175" r="4" fill="#FFB6C1" />
            <circle cx="250" cy="178" r="3" fill="#BA55D3" />
        </g>
    );

    return (
        <div className="w-full h-full overflow-hidden relative">
        <svg viewBox="0 0 400 800" className="w-full h-[200%] animate-village-scroll" preserveAspectRatio="xMidYMid slice">
            <defs>
                {/* No sky gradient needed for top-down view */}
            </defs>
            
            {/* First block (0-200) */}
            <BuildingBlock y={0} />
            
            {/* Second block (200-400) - slightly different arrangement */}
            <g transform="translate(0, 200)">
                <rect x="0" y="0" width="400" height="200" fill="#7CCD7C" />
                <rect x="350" y="0" width="50" height="200" fill="#D3D3D3" />
                <rect x="345" y="0" width="5" height="200" fill="#A9A9A9" />
                
                {/* House with pink roof */}
                <g transform="translate(20, 25)">
                    <rect x="0" y="0" width="90" height="65" fill="#FF69B4" stroke="#C71585" strokeWidth="2" rx="2" />
                    <rect x="8" y="8" width="74" height="49" fill="#FFE4E1" stroke="#FFB6C1" strokeWidth="1" />
                </g>
                
                {/* Tree */}
                <circle cx="150" cy="40" r="22" fill="#228B22" />
                <circle cx="140" cy="50" r="16" fill="#32CD32" />
                <circle cx="165" cy="45" r="14" fill="#2E8B57" />
                
                {/* Long building */}
                <g transform="translate(180, 20)">
                    <rect x="0" y="0" width="130" height="50" fill="#A0522D" stroke="#8B4513" strokeWidth="2" rx="2" />
                    <rect x="10" y="8" width="110" height="34" fill="#DEB887" stroke="#D2691E" strokeWidth="1" />
                    {/* Skylights */}
                    <rect x="25" y="15" width="20" height="20" fill="#87CEEB" opacity="0.6" />
                    <rect x="85" y="15" width="20" height="20" fill="#87CEEB" opacity="0.6" />
                </g>
                
                {/* Bush cluster */}
                <ellipse cx="130" cy="100" rx="18" ry="12" fill="#228B22" />
                <ellipse cx="145" cy="95" rx="14" ry="10" fill="#32CD32" />
                <ellipse cx="155" cy="105" rx="12" ry="8" fill="#2E8B57" />
                
                {/* Small house */}
                <g transform="translate(200, 90)">
                    <rect x="0" y="0" width="70" height="55" fill="#4682B4" stroke="#36648B" strokeWidth="2" rx="2" />
                    <rect x="8" y="8" width="54" height="39" fill="#B0C4DE" stroke="#6495ED" strokeWidth="1" />
                </g>
                
                {/* Flowers */}
                <circle cx="40" cy="130" r="4" fill="#FF69B4" />
                <circle cx="55" cy="135" r="3" fill="#DDA0DD" />
                <circle cx="70" cy="128" r="4" fill="#FFB6C1" />
                
                {/* Tree */}
                <circle cx="300" cy="130" r="20" fill="#32CD32" />
                <circle cx="290" cy="140" r="15" fill="#228B22" />
                
                {/* Bench (top-down) */}
                <rect x="170" y="160" width="40" height="10" fill="#8B4513" stroke="#5D4037" strokeWidth="1" />
            </g>
            
            {/* Third block (400-600) */}
            <BuildingBlock y={400} />
            
            {/* Fourth block (600-800) - same as second for seamless loop */}
            <g transform="translate(0, 600)">
                <rect x="0" y="0" width="400" height="200" fill="#7CCD7C" />
                <rect x="350" y="0" width="50" height="200" fill="#D3D3D3" />
                <rect x="345" y="0" width="5" height="200" fill="#A9A9A9" />
                
                <g transform="translate(20, 25)">
                    <rect x="0" y="0" width="90" height="65" fill="#FF69B4" stroke="#C71585" strokeWidth="2" rx="2" />
                    <rect x="8" y="8" width="74" height="49" fill="#FFE4E1" stroke="#FFB6C1" strokeWidth="1" />
                </g>
                
                <circle cx="150" cy="40" r="22" fill="#228B22" />
                <circle cx="140" cy="50" r="16" fill="#32CD32" />
                <circle cx="165" cy="45" r="14" fill="#2E8B57" />
                
                <g transform="translate(180, 20)">
                    <rect x="0" y="0" width="130" height="50" fill="#A0522D" stroke="#8B4513" strokeWidth="2" rx="2" />
                    <rect x="10" y="8" width="110" height="34" fill="#DEB887" stroke="#D2691E" strokeWidth="1" />
                    <rect x="25" y="15" width="20" height="20" fill="#87CEEB" opacity="0.6" />
                    <rect x="85" y="15" width="20" height="20" fill="#87CEEB" opacity="0.6" />
                </g>
                
                <ellipse cx="130" cy="100" rx="18" ry="12" fill="#228B22" />
                <ellipse cx="145" cy="95" rx="14" ry="10" fill="#32CD32" />
                <ellipse cx="155" cy="105" rx="12" ry="8" fill="#2E8B57" />
                
                <g transform="translate(200, 90)">
                    <rect x="0" y="0" width="70" height="55" fill="#4682B4" stroke="#36648B" strokeWidth="2" rx="2" />
                    <rect x="8" y="8" width="54" height="39" fill="#B0C4DE" stroke="#6495ED" strokeWidth="1" />
                </g>
                
                <circle cx="40" cy="130" r="4" fill="#FF69B4" />
                <circle cx="55" cy="135" r="3" fill="#DDA0DD" />
                <circle cx="70" cy="128" r="4" fill="#FFB6C1" />
                
                <circle cx="300" cy="130" r="20" fill="#32CD32" />
                <circle cx="290" cy="140" r="15" fill="#228B22" />
                
                <rect x="170" y="160" width="40" height="10" fill="#8B4513" stroke="#5D4037" strokeWidth="1" />
            </g>
        </svg>
        </div>
    );
}


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
        <div className="w-screen h-screen flex flex-row items-stretch relative overflow-hidden">
            {/* Left Village Background */}
            <div className="w-1/4 h-full flex-shrink-0">
                <VillageBackground />
            </div>
            
            {/* Game Content - Center */}
            <div className="w-1/2 h-full flex flex-col flex-shrink-0">
                <div>
                    <Header title="Delivery Game" />
                </div>
                {/* Game map */}
                <div className="flex-1 relative -mx-1">
                    <Map map={mapObstacles} playerPosition={playerPosition}/>
                </div>
            </div>
            
            {/* Right Village Background (mirrored) */}
            <div className="w-1/4 h-full flex-shrink-0" style={{ transform: 'scaleX(-1)' }}>
                <VillageBackground />
            </div>

            {/* Game Over Screen */}
            {gameOver && (
                <GameOver pontuacao={distance} max_pontuacao={500}/>
            )}
        </div>
    );
}
