'use client'

import { useCakeGame } from "../../../hooks/cakegame";

function Camada({camada}) {
    const colors = ["bg-red-900", "bg-green-900", "bg-blue-900", "bg-yellow-900", "bg-purple-900"];
    for (let i = 0; i < camada.length; i++) {
        if (camada[i] === true) {
            return (
                <div class={colors[i]}>
                    <span class="text-1xl">True</span>
                </div>
            );
        }
    }
}

function CakePreview( {title, cake} ) {
    return (
        <div>
            <h2 class="text-2xl">Cake {title}</h2>
            <p>Here is your cake:</p>

            <ul>
                {cake ? cake.map((row, rowIndex) => (
                    <li key={rowIndex}>
                        <Camada camada={row} />
                    </li>
                )) : "No cake available"}
            </ul>
        </div>
    );
}

export default function CakeGame() {
    const {final_cake, user_cake} = useCakeGame();
    return (
        <div>
            <h1 class="text-9xl text-center">Cake MiniGame</h1>
            <p>You choose the cake game!</p>
            <CakePreview title="Gabarito" cake={final_cake} />
            <CakePreview title="Entrada Usuario" cake={user_cake} />
        </div>
    );
}
