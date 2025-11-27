import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

const COLORS = ["#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF", "#FFA500", "#800080"];
        
export function useDeliveryGame() {
    const router = useRouter();
    const [playerPosition, setPlayerPosition] = useState([false, false, false, true]);
    const [mapObstacles, setMapObstacles] = useState(
        Array.from({length: 128}, () => Array(4).fill({active: false, id: null, color: null}))
    );
    const [gameOver, setGameOver] = useState(false);
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

                // Return to home if game is reset
                if (sensors.state === "inicio") {
                    setPlayerPosition([false, false, false, true]);
                    setMapObstacles(resetMap());
                    setGameOver(false);
                    setPlaying(false);
                    setDistance(0);
                    router.push('/');
                }

                // Update game state
                if (sensors.state === "preparation") {
                    setPlayerPosition([false, false, false, true]);
                    setMapObstacles(resetMap());
                    setGameOver(false);
                    setDistance(0);
                    setPlaying(false);
                } else if (sensors.state === "playing") {
                    setPlaying(true);
                    setPlayerPosition(sensors.player_position);
                    
                    setMapObstacles(prevMap => {
                        const newBools = sensors.map_obstacles;
                        const newMap = [];
                        const claimedIds = new Set();
                        
                        for(let r=0; r<128; r++) {
                            newMap[r] = [];
                            for(let c=0; c<4; c++) {
                                const active = newBools[r][c];
                                let id = null;
                                let color = null;
                                
                                if (active) {
                                    // Check r+1 (moved down) first, then r (stayed)
                                    const prevFromAbove = (r < 127) ? prevMap[r+1][c] : null;
                                    const prevSame = prevMap[r][c];
                                    
                                    if (prevFromAbove && prevFromAbove.active && prevFromAbove.id && !claimedIds.has(prevFromAbove.id)) {
                                        id = prevFromAbove.id;
                                        color = prevFromAbove.color;
                                        claimedIds.add(id);
                                    } else if (prevSame && prevSame.active && prevSame.id && !claimedIds.has(prevSame.id)) {
                                        id = prevSame.id;
                                        color = prevSame.color;
                                        claimedIds.add(id);
                                    } else {
                                        id = Math.random();
                                        color = COLORS[Math.floor(Math.random() * COLORS.length)];
                                    }
                                }
                                newMap[r][c] = { active, id, color };
                            }
                        }
                        return newMap;
                    });
                    
                    // Calculate distance traveled (count map movements)
                    const hasObstacle = sensors.map_obstacles.some(row => row.some(val => val));
                    if (hasObstacle) {
                        setDistance(prev => prev + 1);
                    }
                } else if (sensors.state == "game_over" && !gameOver) {
                    setIntervalo( prevIntervalo => prevIntervalo + 1);
                    if (intervalo > 10) {
                        setGameOver(true);
                        setPlaying(false);
                        setIntervalo(0);
                    }
                } else if (sensors.state != "game_over" && gameOver) {
                    setGameOver(false);
                    setPlayerPosition([false, false, false, true]);
                    setMapObstacles(resetMap());
                    setPlaying(false);
                    setDistance(0);
                }

            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        
        const interval = setInterval(fetchSensors, 50);
        return () => clearInterval(interval);
    }, [router, playerPosition, mapObstacles, gameOver, playing, distance, intervalo]);
    
    return { playerPosition, mapObstacles, gameOver, playing, distance };
}
