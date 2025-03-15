'use client'
import { useGameChooser } from '../hooks/useGameChooser';
import Header from '../components/basic';

// Component for showing a minigame icon
function House({ game }) {
    let src = ""
    if (game === "cakegame") {
        src = "https://gallery.yopriceville.com/var/resizes/Free-Clipart-Pictures/Cakes-PNG/Cake_PNG_Transparent_Clip_Art_Image.png?m=1629830081"
    } else if (game === "chothesgame") {
        src = "https://www.pngplay.com/wp-content/uploads/6/Clothes-Vector-Background-PNG-Image.png"
    } else if (game === "memorygame") {
        src = "https://pngimg.com/uploads/brain/brain_PNG15.png"
    }
    return<div class="flex flex-col items-center justify-center">
            <img class="w-1/2" src={src} />
            <p class="text-3xl text-center">{game}</p>
        </div>
    
}

export default function HomePage() {
    useGameChooser();
    return (
        <div>
            <Header title="BitBakery" />
            <div class="columns-3">
                <House game="cakegame" />
                <House game="chothesgame" />
                <House game="memorygame" />
            </div>
        </div>
    )
}
