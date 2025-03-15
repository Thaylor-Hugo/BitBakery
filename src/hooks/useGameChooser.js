import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export function useGameChooser() {
    const router = useRouter();
  
    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                if (sensors.state == "inicio" || sensors.state == "inicial" || sensors.state == "preparation" || sensors.state == "preparacao") {
                    router.push('/');
                } else {
                    router.push('/minigame/' + sensors.minigame);
                }

            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 100);
        return () => clearInterval(interval);
    }, [router]);
}