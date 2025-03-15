'use client'

import { useCakeGame } from "../../../hooks/cakegame";
import Canvas from "../../../components/canvas";
import Header from "../../../components/basic";

function Cobertura({color, dark_color}) {
    const draw = (ctx, frameCount) => {
        const startX = 0;        // Left starting position
        const startY = 0;        // Top position
        const baseHeight = ctx.canvas.height / 5;     // Base height before drips
        const dripIntensity = 100;  // How far drips hang down
        // Start at top-left
        ctx.moveTo(startX, startY);
        // Draw left side
        ctx.lineTo(startX, startY + baseHeight);
        // Create dripping bottom edge
        let x = startX;
        const segments = 5; // Number of drip points
        
        for(let i = 0; i <= segments; i++) {
            const segmentWidth = ctx.canvas.width/segments;
            const nextX = x + segmentWidth;
            
            // Randomize drip parameters
            const dripHeight = baseHeight + Math.random() * dripIntensity;
            const controlY = startY + dripHeight + 15;
            const controlX = x + segmentWidth/2;
            
            // Create quadratic curve for drip
            ctx.quadraticCurveTo(
                controlX,  // Control point X
                controlY,  // Control point Y (creates the drip)
                nextX,     // End point X
                startY + baseHeight + (Math.random() * 5) // End point Y
            );
            
            x = nextX;
        }
        
        // Close the path back to top-right
        ctx.lineTo(startX + ctx.canvas.width, startY);
        ctx.closePath();
        
        // Create gradient fill
        const gradient = ctx.createLinearGradient(startX, startY, startX, startY + baseHeight + dripIntensity);
        gradient.addColorStop(0, color); // Light color
        gradient.addColorStop(1, dark_color); // Darker color
        
        // Draw shape
        ctx.fillStyle = gradient;
        ctx.fill();
        
    }
    return (
        <Canvas class="w-30 h-10" draw={draw} /> 
    );
}

function Massa({color}) {
    const draw = (ctx, frameCount) => {
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)
        ctx.fillStyle = color
        ctx.beginPath()
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)
        ctx.fill()
    }
    return (
        <Canvas class="w-30 h-10" draw={draw} />
    );
}

function Camada({camada, cobertura}) {
    const colors = ["Crimson", "HotPink", "OrangeRed", "Khaki", "SkyBlue", "LightSlateGray", "SpringGreen"];
    const dark_colors = ["FireBrick", "MediumVioletRed", "DarkOrange", "DarkKhaki", "DeepSkyBlue", "DarkSlateGray", "SeaGreen"];
    for (let i = 0; i < camada.length; i++) {
        if (camada[i] === true) {
            if (cobertura) {
                return (
                    <div class="absolute">
                        <Cobertura color={colors[i]} dark_color={dark_colors[i]} />
                    </div>
                );
            } else {
                return (
                    <Massa color={colors[i]} />
                );
            }
        }
    }
}

function CakePreview( {title, cake} ) {
    return (
        <div id="cake_div" class="relative h-full flex flex-col-reverse">
            {cake.slice().map((row, rowIndex) => {
                let camada_class = (rowIndex) % 2 !== 0 ? "relative z-2" : "relative z-1";
                let fall_start = "";
                var clientHeight = document.getElementById('cake_div').clientHeight;
                if (rowIndex === cake.length - 1) {
                    camada_class += " fall-animation";
                    fall_start = "-" + (clientHeight - (rowIndex*20)) + "px";
                    console.log(fall_start);
                }
                return <div key={rowIndex} class={camada_class} style={{"--fall-start": fall_start}}>
                    <Camada camada={row} cobertura={(rowIndex) % 2 !== 0} />
                </div>
            })}
        </div>
    );
}

export default function CakeGame() {
    const {final_cake, user_cake, jogada} = useCakeGame();

    const possible_positions = ["left-5", "left-40", "left-75", "left-110", "left-145", "left-180", "left-215", "left-250", "left-285", "left-320", "left-355", "left-390", "left-425", "left-460", "left-495", "left-530"];
    const user_cake_class = "h-full absolute bottom-0 left-0 transition-all duration-500 ease-in-out".concat(" ", possible_positions[jogada]);
    return (
        <div class="h-screen flex flex-col">
            <div>
                <Header title="Cake MiniGame" />
            </div>
            <div class="bg-amber-600 h-1/4">
            
            </div>
            <div class="flex flex-grow">
                <div class="bg-stone-400 w-1/8 flex items-end justify-center">
                    <CakePreview title="Gabarito" cake={final_cake} />
                </div>
                <div class="bg-stone-500 relative w-full">
                    <div class={user_cake_class}>
                        <CakePreview title="Entrada Usuario" cake={user_cake} />
                    </div>
                </div>
            </div>
            <div class="bg-amber-200 h-1/8">

            </div>
        </div>
    );
}
