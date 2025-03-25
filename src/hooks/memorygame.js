import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export function useMemoryGame() {
    const router = useRouter();
    const [jogada, setJogada] = useState();
    const [pontuacao, setPontuacao] = useState();

    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                setJogada(sensors.jogada);
                setPontuacao(sensors.pontuacao);

                if (sensors.state == "inicio") {
                    router.push('/');
                }
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };

        const interval = setInterval(fetchSensors, 1);
        return () => clearInterval(interval);
    }, [router, jogada]);
    return { jogada, pontuacao };
}