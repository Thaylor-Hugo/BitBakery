import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

const COLORS = ["#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF", "#FFA500", "#800080"];
        
export function useDeliveryGame() {
    const router = useRouter();
    const [playerPosition, setPlayerPosition] = useState([false, false, false, true]);
    const [mapObstacles, setMapObstacles] = useState(
        Array.from({length: 128}, () => Array(4).fill({active: false, id: null, color: null}))
    );
    const [mapObjectives, setMapObjectives] = useState(
        Array.from({length: 128}, () => Array(4).fill({active: false, id: null}))
    );
    const [gameOver, setGameOver] = useState(false);
    const [deliveredCake, setDeliveredCake] = useState(false);
    const [playing, setPlaying] = useState(false);
    const [intervalo, setIntervalo] = useState(0);
    const [distance, setDistance] = useState(0);
  
    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                
                // Helper to reset map
                const resetMap = () => Array.from({length: 128}, () => Array(4).fill({active: false, id: null, color: null}));
                const resetObjectives = () => Array.from({length: 128}, () => Array(4).fill({active: false, id: null}));

                // Return to home if game is reset
                if (sensors.state === "inicio") {
                    setPlayerPosition((prev) => [false, false, false, true]);
                    setMapObstacles((prev) => resetMap());
                    setMapObjectives((prev) => resetObjectives());
                    setGameOver((prev) => false);
                    setDeliveredCake((prev) => false);
                    setPlaying((prev) => false);
                    setDistance((prev) => 0);
                    setIntervalo((prev) => 0);
                    router.push('/');
                }

                // Handle game_over state - show game over screen after delay
                if (sensors.state === "game_over" && !gameOver) {
                    // Update player position to show crash position
                    setPlayerPosition((prev) => sensors.player_position);
                    
                    // Check if player collided with an objective (cake) in first 24 rows
                    // Use sensors.map_objectives directly since React state may be stale
                    const playerLane = sensors.player_position.findIndex(val => val === true);
                    if (playerLane >= 0) {
                        for (let row = 0; row < 24; row++) {
                            if (sensors.map_objectives && sensors.map_objectives[row] && sensors.map_objectives[row][playerLane]) {
                                setDeliveredCake(true);
                                break;
                            }
                        }
                    }
                    
                    setIntervalo((prevIntervalo) => prevIntervalo + 1);
                    if (intervalo > 10) {
                        setIntervalo((prev) => 0);
                        setGameOver((prev) => true);
                        setPlaying((prev) => false);
                    }
                } else if (sensors.state !== "game_over" && gameOver) {
                    // Reset all state when transitioning OUT of game_over to any other state
                    setGameOver((prev) => false);
                    setDeliveredCake((prev) => false);
                    setPlaying((prev) => false);
                    setPlayerPosition((prev) => [false, false, false, true]);
                    setMapObstacles((prev) => resetMap());
                    setMapObjectives((prev) => resetObjectives());
                    setDistance((prev) => 0);
                    setIntervalo((prev) => 0);
                }

                // Handle playing state
                if (sensors.state === "playing") {
                    setPlaying((prev) => true);
                    setPlayerPosition((prev) => sensors.player_position);
                    
                    setMapObstacles(prevMap => {
                        const newBools = sensors.map_obstacles;
                        const newMap = [];
                        const claimedIds = new Set();
                        
                        // How many rows to look above for tracking (handles fast movement)
                        const LOOK_AHEAD = 36;
                        
                        for(let r=0; r<128; r++) {
                            newMap[r] = [];
                            for(let c=0; c<4; c++) {
                                const active = newBools[r][c];
                                let id = null;
                                let color = null;
                                
                                if (active) {
                                    let found = false;
                                    
                                    // Look up to LOOK_AHEAD rows above to find the obstacle that moved here
                                    for (let offset = 1; offset <= LOOK_AHEAD && !found; offset++) {
                                        const checkRow = r + offset;
                                        if (checkRow < 128) {
                                            const prevFromAbove = prevMap[checkRow][c];
                                            if (prevFromAbove && prevFromAbove.active && prevFromAbove.id && !claimedIds.has(prevFromAbove.id)) {
                                                id = prevFromAbove.id;
                                                color = prevFromAbove.color;
                                                claimedIds.add(id);
                                                found = true;
                                            }
                                        }
                                    }
                                    
                                    // Also check if it stayed in place
                                    if (!found) {
                                        const prevSame = prevMap[r][c];
                                        if (prevSame && prevSame.active && prevSame.id && !claimedIds.has(prevSame.id)) {
                                            id = prevSame.id;
                                            color = prevSame.color;
                                            claimedIds.add(id);
                                            found = true;
                                        }
                                    }
                                    
                                    // New obstacle - assign random color
                                    if (!found) {
                                        id = Math.random();
                                        color = COLORS[Math.floor(Math.random() * COLORS.length)];
                                    }
                                }
                                newMap[r][c] = { active, id, color };
                            }
                        }
                        return newMap;
                    });
                    
                    // Track objectives (cakes to deliver)
                    setMapObjectives(prevMap => {
                        const newBools = sensors.map_objectives;
                        const newMap = [];
                        const claimedIds = new Set();
                        
                        const LOOK_AHEAD = 8;
                        
                        for(let r=0; r<128; r++) {
                            newMap[r] = [];
                            for(let c=0; c<4; c++) {
                                const active = newBools[r][c];
                                let id = null;
                                
                                if (active) {
                                    let found = false;
                                    
                                    for (let offset = 1; offset <= LOOK_AHEAD && !found; offset++) {
                                        const checkRow = r + offset;
                                        if (checkRow < 128) {
                                            const prevFromAbove = prevMap[checkRow][c];
                                            if (prevFromAbove && prevFromAbove.active && prevFromAbove.id && !claimedIds.has(prevFromAbove.id)) {
                                                id = prevFromAbove.id;
                                                claimedIds.add(id);
                                                found = true;
                                            }
                                        }
                                    }
                                    
                                    if (!found) {
                                        const prevSame = prevMap[r][c];
                                        if (prevSame && prevSame.active && prevSame.id && !claimedIds.has(prevSame.id)) {
                                            id = prevSame.id;
                                            claimedIds.add(id);
                                            found = true;
                                        }
                                    }
                                    
                                    if (!found) {
                                        id = Math.random();
                                    }
                                }
                                newMap[r][c] = { active, id };
                            }
                        }
                        return newMap;
                    });
                    
                    // Calculate distance traveled (count map movements)
                    const hasObstacle = sensors.map_obstacles.some(row => row.some(val => val));
                    if (hasObstacle) {
                        setDistance(prev => prev + 1);
                    }
                }

            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        
        const interval = setInterval(fetchSensors, 50);
        return () => clearInterval(interval);
    }, [router, playerPosition, mapObstacles, mapObjectives, gameOver, deliveredCake, playing, distance, intervalo]);
    
    return { playerPosition, mapObstacles, mapObjectives, gameOver, deliveredCake, playing, distance };
}
