import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

// let final_cake = new CakeObject();
// let user_cake = new CakeObject();

// function CakeObject() {
//     this.reset = function() {
//         this.camada = [];
//     }
//     this.reset();
// }
        
export function useCakeGame() {
    let changed = false;
    const router = useRouter();
    const [final_cake, setFinalCake] = useState([]);
    const [user_cake, setUserCake] = useState([]);
  
    useEffect(() => {
        const fetchSensors = async () => {
            try {
                const res = await fetch('http://localhost:5328/api/sensors');
                const { sensors } = await res.json();
                if (sensors.state == "initial" || sensors.state == "preparacao" || sensors.state == "escolha_minigame") {
                    setFinalCake([]);
                    setUserCake([]);
                    router.push('/');
                }
                if (sensors.state == "mostra_bolo") {
                    if (sensors.leds.every(val => val === false)) {
                        changed = true;
                    } else if(!sensors.leds.every(val => val === false) && changed) {
                        changed = false;
                        console.log([...final_cake, sensors.leds]);
                        setFinalCake([
                            ...final_cake, 
                            sensors.leds
                        ]);
                    }
                } else {
                    if (sensors.leds.every(val => val === false)) {
                        changed = true;
                    } else if(!sensors.leds.every(val => val === false) && changed) {
                        changed = false;
                        setUserCake([...user_cake, sensors.leds]);
                    }
                }
            } catch (error) {
                console.error('Error fetching sensors:', error);
            }
        };
        const interval = setInterval(fetchSensors, 100);
        return () => clearInterval(interval);
    }, [router, final_cake, user_cake]);
    return {final_cake, user_cake};
}