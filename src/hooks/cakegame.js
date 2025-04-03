import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
        
export function useCakeGame() {
    let changed = false;
    const router = useRouter();
    const [final_cake, setFinalCake] = useState([]);
    const [user_cake, setUserCake] = useState([]);
    const [jogada, setJogada] = useState(0);
    const [gameover, setGameOver] = useState(false);
    const [pontuacao, setPontuacao] = useState(0);
    const [intervalo, setIntervalo] = useState(0);
  
    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                if (sensors.state == "inicio") {
                    setFinalCake( (prevfinalCake) => []);
                    setUserCake( (prevfinalCake) => []);
                    router.push('/');
                }

                if (sensors.state == "end_state" && !gameover) {
                    setIntervalo( prevIntervalo => prevIntervalo + 1);
                    if (intervalo > 10) {
                        setIntervalo( (prevIntervalo) => 0);
                        setGameOver( (prevGameOver) => true);
                        final_cake.forEach((camada, index) => {
                            if (camada.indexOf(true) == user_cake[index].indexOf(true)) {
                                setPontuacao( (prevPontuacao) => prevPontuacao + 1);
                            }
                        });
                    }

                } else if (sensors.state != "end_state" && gameover) {
                    setGameOver( (prevGameOver) => false);
                    setFinalCake( (prevfinalCake) => []);
                    setUserCake( (prevfinalCake) => []);
                    setPontuacao( (prevPontuacao) => 0);
                    setJogada( (prevJogada) => 0);
                    setIntervalo( (prevIntervalo) => 0);
                }


                if (sensors.state == "preparation" || sensors.state == "show_play" || sensors.state == "show_interval" || sensors.state == "next_show" || sensors.state == "start_show" || sensors.state == "register_show") {
                    // Gabarito
                    if (sensors.jogada.every(val => val === false)) {
                        changed = true;
                    } else if(!sensors.jogada.every(val => val === false) && changed) {
                        changed = false;
                        console.log("Gabarito: ", sensors.jogada);
                        setFinalCake( (prevfinalCake) => [...prevfinalCake, sensors.jogada] );
                    }
                } else if (sensors.state == "wait_play" || sensors.state == "register_play" || sensors.state == "next_play" || sensors.state == "end_state") {
                    // Jogada do usuário
                    if (sensors.jogada.every(val => val === false)) {
                        changed = true;
                    } else if(!sensors.jogada.every(val => val === false) && changed) {
                        changed = false;
                        setJogada( (prevJogada) => prevJogada + 1);
                        setUserCake( (prevUserCake) => [...prevUserCake, sensors.jogada]);
                    }
                }

            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 50);
        return () => clearInterval(interval);
    }, [router, final_cake, user_cake, jogada, gameover, pontuacao, intervalo]);
    return {final_cake, user_cake, jogada, gameover, pontuacao};
}
