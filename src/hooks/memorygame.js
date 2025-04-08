import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export function useMemoryGame() {
    const router = useRouter();
    const [jogada, setJogada] = useState();
    const [pontuacao, setPontuacao] = useState(0);
    const [aguardar, setAguardar] = useState(true);
    const [gameOver, setGameOver] = useState(false);
    const [estadoMudou, setEstadoMudou] = useState(false);
    const [difficulty, setDifficulty] = useState("");
    const estados_finais = ["final_timeout", "final_acertou", "final_errou"];
    const estados_mostra = ["proxima_mostra", "mostra_jogada", "intervalo_mostra"];

    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                setJogada(sensors.jogada);
                setDifficulty(sensors.difficulty);

                if (sensors.state == "inicial" || sensors.state == "inicio") {
                    router.push('/');
                } else if (!estados_finais.includes(sensors.state) && gameOver) {
                    setPontuacao(-1);
                    setGameOver(false);
                } else if (sensors.state == "espera_jogada" || sensors.state == "wait_play") {
                    setAguardar(false);
                    setEstadoMudou(true);
                } else if (estados_mostra.includes(sensors.state) && estadoMudou) {
                    setEstadoMudou(false);
                    setAguardar(true);
                    setPontuacao(prevpontuacao => prevpontuacao + 1);
                    console.log("Pontuação: ", pontuacao);
                } else if (estados_finais.includes(sensors.state) && !gameOver) {
                    setPontuacao(prevpontuacao => prevpontuacao + (sensors.state == "final_acertou" ? 1 : 0));
                    console.log("Pontuação: ", pontuacao);
                    setGameOver(true);
                }
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 50);
        return () => clearInterval(interval);
    }, [router, estadoMudou, gameOver, aguardar, difficulty]);
    return { jogada, pontuacao, gameOver, aguardar, difficulty };
}