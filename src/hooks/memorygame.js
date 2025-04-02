import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export function useMemoryGame() { 
    const estados_iniciais = ["inicial"];
    const estados_finais = ["final_timeout", "final_acertou", "final_errou"];
    const router = useRouter();
    const [jogada, setJogada] = useState();
    const [pontuacao, setPontuacao] = useState(0);
    const [gameOver, setGameOver] = useState(false);

    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                setJogada(sensors.jogada);

                if (estados_iniciais.includes(sensors.state)) {
                    setPontuacao(0);
                    router.push('/');
                } else if (sensors.state == "mostra_jogada") {
                    estado_mudou = true;
                } else if (sensors.state == "intervalo_rodada" && estado_mudou) {
                    estado_mudou = false;
                    setPontuacao(prevpontuacao => prevpontuacao + 1);
                } else if (estados_finais.includes(sensors.state)) {
                    setGameOver(true);
                }   
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 50);
        return () => clearInterval(interval);
    }, [router, sensors.state]);
    return { jogada, pontuacao, gameOver };
}