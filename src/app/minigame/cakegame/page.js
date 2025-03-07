'use client'

import { useCakeGame } from "../../../hooks/cakegame";


function CakePreview( {title, cake} ) {
    return (
        <div>
            <h2>Cake {title}</h2>
            <p>Here is your cake:</p>
            <ul>
                {cake ? cake.map((row, rowIndex) => (
                    <li key={rowIndex}>
                        {row.map((cell, cellIndex) => (
                            <span key={cellIndex}>{cell ? "True" : "False"} </span>
                        ))}
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
            <h1>Cake MiniGame</h1>
            <p>You choose the cake game!</p>
            <CakePreview title="Gabarito" cake={final_cake} />
            <CakePreview title="Entrada Usuario" cake={user_cake} />
        </div>
    );
}
