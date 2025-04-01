'use client'
import { useGameChooser } from '../hooks/useGameChooser';
import Header from '../components/basic';

function House({ game }) {
    let src = "";
    const gameName = game === "cakegame" ? "Cake Game" : "Memory Game";
    
    if (game === "cakegame") {
        src = "https://gallery.yopriceville.com/var/resizes/Free-Clipart-Pictures/Cakes-PNG/Cake_PNG_Transparent_Clip_Art_Image.png?m=1629830081";
    } else if (game === "memorygame") {
        src = "https://pngimg.com/uploads/brain/brain_PNG15.png";
    }

    return (
        <div className="group relative flex flex-col items-center justify-center p-6 m-4 bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-2 cursor-pointer">
            <div className="relative w-64 h-64 overflow-hidden rounded-xl">
                <img 
                    className="w-full h-full object-contain transition-transform duration-300 group-hover:scale-110" 
                    src={src} 
                    alt={gameName}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-gray-900/20 via-transparent to-transparent" />
            </div>
            <p className="mt-4 text-2xl font-bold text-gray-800 uppercase tracking-wide transition-colors duration-300 group-hover:text-blue-600">
                {gameName}
            </p>
        </div>
    );
}

export default function HomePage() {
    useGameChooser();
    return (
        <div className="min-h-screen bg-gradient-to-b from-blue-50 to-purple-50">
            <Header title="BitBakery" className="py-6 bg-white shadow-md" />
            
            <div className="container mx-auto px-4 py-12">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
                    <House game="cakegame" />
                    <House game="memorygame" />
                </div>
                
                <p className="text-center mt-12 text-gray-600 text-lg italic animate-pulse">
                    Select a game to start your baking adventure!
                </p>
            </div>
        </div>
    );
}