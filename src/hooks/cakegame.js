import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
        
export function useCakeGame() {
    let changed = false;
    const router = useRouter();
    const [final_cake, setFinalCake] = useState([]);
    const [user_cake, setUserCake] = useState([]);
    const [jogada, setJogada] = useState(0);
  
    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                if (sensors.state == "inicio" || sensors.state == "preparation") {
                    setFinalCake([]);
                    setUserCake([]);
                    router.push('/');
                }

                if (sensors.state == "show_play" || sensors.state == "show_interval" || sensors.state == "next_show" || sensors.state == "start_show" || sensors.state == "register_show") {
                    // Gabarito
                    if (sensors.jogada.every(val => val === false)) {
                        changed = true;
                    } else if(!sensors.jogada.every(val => val === false) && changed) {
                        changed = false;
                        console.log(sensors.jogada);
                        setFinalCake( (prevfinalCake) => [...prevfinalCake, sensors.jogada] );
                    }
                } else {
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
        const interval = setInterval(fetchSensors, 1);
        return () => clearInterval(interval);
    }, [router, final_cake, user_cake, jogada]);
    return {final_cake, user_cake, jogada};
}
