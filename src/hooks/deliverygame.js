import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
        
export function useDeliveryGame() {
    const router = useRouter();
    const [playerPosition, setPlayerPosition] = useState([false, false, false, true]);
    const [mapObstacles, setMapObstacles] = useState(Array(16).fill([false, false, false, false]));
    const [gameOver, setGameOver] = useState(false);
    const [playing, setPlaying] = useState(false);
    const [intervalo, setIntervalo] = useState(0);
    const [distance, setDistance] = useState(0);
  
    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                
                // Return to home if game is reset
                if (sensors.state === "inicio") {
                    setPlayerPosition( (prevPlayerPosition) => [false, false, false, true]);
                    setMapObstacles( (prevMap) => Array(16).fill([false, false, false, false]));
                    setGameOver( (prevGameOver) => false);
                    setPlaying( (prevPlaying) => false);
                    setDistance( (prevDistance) => 0);
                    router.push('/');
                }

                // Update game state
                if (sensors.state === "preparation") {
                    setPlayerPosition([false, false, false, true]);
                    setMapObstacles(Array(16).fill([false, false, false, false]));
                    setGameOver(false);
                    setDistance(0);
                    setPlaying(false);
                } else if (sensors.state === "playing") {
                    setPlaying(true);
                    setPlayerPosition( (prevPlayerPosition) => sensors.player_position);
                    setMapObstacles( (prevMap) => sensors.map_obstacles);
                    
                    // Calculate distance traveled (count map movements)
                    const hasObstacle = sensors.map_obstacles.some(row => row.some(val => val));
                    if (hasObstacle) {
                        setDistance(prev => prev + 1);
                    }
                } else if (sensors.state == "game_over" && !gameOver) {
                    setIntervalo( prevIntervalo => prevIntervalo + 1);
                    if (intervalo > 10) {
                        setGameOver( (prevGameOver) => true);
                        setPlaying( (prevPlaying) => false);
                        setIntervalo( (prevIntervalo) => 0);
                    }
                } else if (sensors.state != "game_over" && gameOver) {
                    setGameOver( (prevGameOver) => true);
                    setPlayerPosition( (prevPlayerPosition) => [false, false, false, true]);
                    setMapObstacles( (prevMap) => Array(16).fill([false, false, false, false]));
                    setGameOver( (prevGameOver) => false);
                    setPlaying( (prevPlaying) => false);
                    setDistance( (prevDistance) => 0);
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
