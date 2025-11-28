'use client'

import { useCakeGame } from "../../../hooks/cakegame";
import Canvas from "../../../components/canvas";
import Header from "../../../components/basic";
import GameOver from "../../../components/GameOver";

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
        <Canvas className="w-30 h-cake rounded-lg" draw={draw} /> 
    );
}

function Massa({color}) {
    return (
        // <Canvas className="w-30 h-cake" draw={draw} />
        <div className="w-30 h-cake rounded-lg" 
        style={{ backgroundColor: color }}></div>
    );
}

function Camada({camada, cobertura}) {
    const colors = [
        "#ff194f", "#ffb400", "#00a6ed",
        "#00ff7f", "#632501", "#8f00ff"
      ];
    const dark_colors = ["#d41442", "#cc9000", "#0077b3",
        "#00cc66", "#4a1c01", "#6b00bf"];

    const more_dark_colors = ["#ad1035", "#a67300", "#005c8a",
        "#00994d", "#311300", "#4d008c"];
    for (let i = 0; i < camada.length; i++) {
        if (camada[i] === true) {
            if (cobertura) {
                return (
                    <div className="absolute left-1/2 -translate-x-1/2">
                        <Cobertura color={dark_colors[i]} dark_color={more_dark_colors[i]} />
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
        <div id="cake_div" className="flex flex-col-reverse items-center">
            {cake.slice().map((row, rowIndex) => {
                let camada_class = (rowIndex) % 2 !== 0 ? "relative z-2" : "relative z-1";
                let fall_start = "";
                if (rowIndex === cake.length - 1) {
                    camada_class += " fall-animation";
                    fall_start = "-300px";
                }
                return <div key={rowIndex} className={camada_class} style={{"--fall-start": fall_start}}>
                    <Camada camada={row} cobertura={(rowIndex) % 2 !== 0} />
                </div>
            })}
        </div>
    );
}

export default function CakeGame() {
    const {final_cake, user_cake, jogada, gameover, pontuacao, playing} = useCakeGame();

    // Percentage-based positions for full screen movement
    const possible_positions = ["left-pos-0", "left-pos-1", "left-pos-2", "left-pos-3", "left-pos-4", "left-pos-5", "left-pos-6", "left-pos-7", "left-pos-8", "left-pos-9", "left-pos-10", "left-pos-11", "left-pos-12", "left-pos-13", "left-pos-14", "left-pos-15"];
    const user_cake_class = "absolute transition-all duration-2500 ease-in-out".concat(" ", possible_positions[jogada]);

    return (
        <div className="h-screen flex flex-col bg-cover bg-center bg-[url('../../src/cakegame-bg.jpg')] relative">
            {/* Game Content */}
            <div>
                <Header title="Cake MiniGame" />
            </div>
            <div>
                <p className="font-sans text-4xl font-bold text-center text-shadow-lg stroke-0" style={{ color: playing ? "#28a745ff" : "#cc0000ff", WebkitTextStroke: "1px gray" }}>{playing ? "Faça o Bolo" : "Aguarde o Pedido"}</p>
            </div>
            
            {/* Cake Preview (Gabarito) - positioned on the empty plate in the middle */}
            <div className="absolute bottom-[40%] left-[48%] transform -translate-x-1/2 z-10">
                <CakePreview title="Gabarito" cake={final_cake} />
            </div>
            
            {/* User Cake - moves across the entire screen on the conveyor belt */}
            <div className="absolute bottom-[28%] left-0 right-0 z-20">
                <div className={user_cake_class + " bottom-0"}>
                    <CakePreview title="Entrada Usuario" cake={user_cake} />
                </div>
            </div>

            {/* Game Over Overlay */}
            {gameover && (
                <GameOver pontuacao={pontuacao} max_pontuacao={16} />
            )}
        </div>
    );
}
