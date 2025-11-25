'use client'
import { useGameChooser } from '../hooks/useGameChooser';
import Header from '../components/basic';

function House({ game, selected }) {
    let img_src = "";
    const gameName = game === "cakegame" ? "Cake Game" : (game === "memorygame"? "Memory Game" : "Delivery Game");
    
    if (game === "cakegame") {
        img_src = "https://i.pinimg.com/236x/b6/3b/48/b63b48117aa60a3cc28cb8d18231ddc9.jpg";
    } else if (game === "memorygame") {
        img_src = "https://i.pinimg.com/736x/0d/82/89/0d82895ccae32667f7508a597f594d30.jpg";
    } else if (game === "deliverygame") {
        img_src = "https://i.pinimg.com/1200x/7d/65/63/7d6563a79d2763631859842d91b4f8c1.jpg";
    }

    return (
        <div className={`group relative flex flex-col items-center justify-center p-6 mx-4 bg-[#1f193c88] rounded-2xl transition-all duration-300 cursor-pointer w-80
            ${selected ? 'shadow-xl -translate-y-2' : 'shadow-lg'}`}>
            
            <div className="relative w-64 h-64 overflow-hidden rounded-xl">
                <img 
                    className={`w-full h-full object-cover transition-transform duration-300 ${selected ? 'scale-110' : ''}`}
                    src={img_src} 
                    alt={gameName}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-gray-900/20 via-transparent to-transparent" />
            </div>
            
            <p className={`mt-4 text-2xl font-bold uppercase tracking-wide transition-colors duration-300
                ${selected ? 'text-[#e04368]' : 'text-[#feedff]'}`}>
                {gameName}
            </p>
        </div>
    );
}

function Dificuldade({ difficulty, text }) {
    return (
        <div className={`group relative flex flex-col items-center justify-center p-4
             m-4 bg-[#1f193c88] rounded-2xl transition-all duration-300 cursor-pointer
            ${difficulty ? 'shadow-xl -translate-y-2' : 'shadow-lg'}`}>
            <p className={`mt-4 text-2xl font-bold uppercase tracking-wide transition-colors duration-300
                ${difficulty ? 'text-[#e04368]' : 'text-[#feedff]'}`}>
                {text}
            </p>
        </div>
    );
}

export default function HomePage() {
    const {minigame, difficulty} = useGameChooser();
    return (
        <div className="min-h-screen from-blue-50 to-purple-50 bg-[url('https://images2.alphacoders.com/136/thumb-1920-1364876.png')]">
            <Header title="BitBakery" className="py-6 bg-white shadow-md" />
            
            <div className="container mx-auto px-4 py-12">
                <div className="flex flex-row justify-center items-start gap-6 max-w-6xl mx-auto">
                    <House game="cakegame" selected={minigame === "cakegame"} />
                    <House game="memorygame" selected={minigame === "memorygame"}/>
                    <House game="deliverygame" selected={minigame === "deliverygame"} />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto mt-8">
                    <Dificuldade difficulty={difficulty} text="Fácil"/>
                    <Dificuldade difficulty={!difficulty} text="Difícil"/>
                </div>
                <p className="text-center mt-12 text-[#feedff] text-lg italic animate-pulse">
                    Select a game to start your baking adventure!
                </p>
            </div>
        </div>
    );
}