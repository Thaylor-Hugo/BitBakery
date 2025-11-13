import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export function useGameChooser() {
    const router = useRouter();
    
    const [minigame, setMinigame] = useState("");
    const [difficulty, setDifficulty] = useState("");

    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                setMinigame(sensors.minigame);
                setDifficulty(sensors.difficulty);
                if (sensors.state == "inicio" || sensors.state == "inicial") {
                    router.push('/');
                } else if (sensors.minigame == "cakegame" || sensors.minigame == "memorygame" || sensors.minigame == "deliverygame") {
                    router.push('/minigame/' + minigame);
                }
                
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 100);
        return () => clearInterval(interval);
    }, [router, minigame, difficulty]);
    return {minigame, difficulty};
}