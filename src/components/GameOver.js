
import Header from './basic';

export default function GameOver({ pontuacao }) {
    const title = "Game Over!";
    const message_pontuacao = "Sua pontuação foi: " + pontuacao + " pontos de 16.";
    
    if (pontuacao <= 8) {
        var message = "Voce quase conseguiu! Tente novamente!";
    } else if (pontuacao < 16) {
        var message = "Parabens! Voce foi muituo bem!";
    } else {
        var message = "Incrivel! Voce arrasou, acertou tudo!";
    }

    return (
        <div class="h-screen flex flex-col">
            <div>
                <Header title={title} />
            </div>
            <div>
                <p>{message}</p>
            </div>
            <div>
                <p>{message_pontuacao}</p>
            </div>
        </div>
    );

}
