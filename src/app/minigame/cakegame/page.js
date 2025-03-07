'use client'

import { useCakeGame } from "../../../hooks/cakegame";


function CakePreview( {cake} ) {
    return (
        <div>
            <h2>Cake Preview</h2>
            <p>Here is your cake:</p>
        </div>
    );
}

export default function CakeGame() {
    const {final_cake, user_cake} = useCakeGame();
    // console.log(final_cake);
    return (
        <div>
            <h1>Cake MiniGame</h1>
            <p>You choose the cake game!</p>
            <CakePreview cake={final_cake} />
            <CakePreview cake={user_cake} />
        </div>
    );
}
