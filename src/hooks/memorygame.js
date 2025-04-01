import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export function useMemoryGame() { 
    const estados_iniciais = ["inicio"];
    const estados_mostra = ["show_play", "show_interval", "next_show", "register_show", "start_show"];
    const estados_jogada = ["initiate_play", "wait_play", "register_play", "compare_play", "next_play"]
    const router = useRouter();
    const [jogada, setJogada] = useState();
    const [mudou, setMudou] = useState(false);
    const [contador, setContador] = useState(0);
    const [gabarito, setGabarito] = useState([]);
    const [pontuacao, setPontuacao] = useState(0);
    const [gameOver, setGameOver] = useState(false);

    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                setJogada(sensors.jogada);

                if (estados_iniciais.includes(sensors.state)) {
                    setGabarito([]);
                    setPontuacao(0);
                    router.push('/');
                }

                if (estados_mostra.includes(sensors.state)) {
                    if (sensors.jogada.every(val => val === false)) {
                        setMudou(nextMudou => true);
                    } else if(!sensors.jogada.every(val => val === false) && mudou) {
                        setMudou(nextMudou => false);
                        setGabarito((previgabarito) => [...previgabarito, sensors.jogada] );
                        console.log(gabarito);
                    }
                } else if (estados_jogada.includes(sensors.state)) {
                    if (sensors.jogada.every(val => val == false)) {
                        setMudou(nextMudou => true);
                    } else if (sensors.jogada.some(val => val == true) && mudou) {
                        setMudou(nextMudou => false);
                        setContador((prevcontador) => prevcontador + 1);
                        let temp_gabarito = gabarito[contador];
                        console.log("Temp Gabarito:", temp_gabarito);
                        console.log("Contador Atual:", contador);                    
                        console.log("Jogada Atual:", sensors.jogada);
                        if (JSON.stringify(temp_gabarito) === JSON.stringify(sensors.jogada)) {
                            setPontuacao(prevpontuacao => prevpontuacao + 1);
                        }
                    }
                } else if(sensors.state == "preparation") {
                    setGabarito([]);
                } else {
                    setGameOver(true);
                }
                
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };

        const interval = setInterval(fetchSensors, 50);
        return () => clearInterval(interval);
    }, [router, jogada]);
    return { jogada, pontuacao, gameOver };
}