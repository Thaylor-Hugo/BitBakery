import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export function useMemoryGame() {
    const router = useRouter();
    const [jogada, setJogada] = useState();
    const [pontuacao, setPontuacao] = useState(0);
    const [gameOver, setGameOver] = useState(false);
    const [estadoMudou, setEstadoMudou] = useState(false);
    const estados_finais = ["final_timeout", "final_acertou", "final_errou"];
    const estados_mostra = ["proxima_mostra", "mostra_jogada", "intervalo_mostra"];

    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                setJogada(sensors.jogada);

                if (sensors.state == "inicial") {
                    router.push('/');
                } else if (!estados_finais.includes(sensors.state) && gameOver) {
                    setPontuacao(0);
                    setGameOver(false);
                } else if (sensors.state == "espera_jogada") {
                    setEstadoMudou(true);
                } else if (estados_mostra.includes(sensors.state) && estadoMudou) {
                    setEstadoMudou(false);
                    setPontuacao(prevpontuacao => prevpontuacao + 1);
                } else if (estados_finais.includes(sensors.state) && !gameOver) {
                    setPontuacao(prevpontuacao => prevpontuacao + (sensors.state == "final_acertou" ? 1 : 0));
                    setGameOver(true);
                }
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 25);
        return () => clearInterval(interval);
    }, [router, estadoMudou, gameOver]);
    return { jogada, pontuacao, gameOver };
}