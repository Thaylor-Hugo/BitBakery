import React from 'react';
import { useMemoryGame } from "../hooks/memorygame";

class Circle extends React.Component {
    render() {
        const circleStyle = {
            padding: 10,
            margin: 20,
            display: "inline-block",
            backgroundColor: this.props.bgColor,
            borderRadius: "50%",
            width: 100,
            height: 100,
        };
        return <div style={circleStyle}></div>;
    }
}

const colors = [
    "#E94F37", "#1C89BF",
    "springGreen", "#A40E4C"
];

const CirclesContainer = () => {
    const { jogada, pontuacao } = useMemoryGame(); // Mover a chamada do hook para dentro do componente funcional
    let temp_jogada = jogada ? jogada.slice(0, 4) : [];

    const renderData = colors.map((color, index) => (
        <Circle key={index + color} bgColor={temp_jogada[index] ? colors[index] : 'black'} />
    ));

    return (
        <div className='circulos'>
            {renderData}
        </div>
    );
};

export default CirclesContainer;