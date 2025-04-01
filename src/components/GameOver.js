import Header from './basic';

export default function GameOver({ pontuacao }) {
    const title = "Game Over!";
    const messagePontuacao = `Sua pontuação foi: ${pontuacao} pontos de 16.`;
    
    let message;
    if (pontuacao <= 8) {
        message = "Você quase conseguiu! Tente novamente!";
    } else if (pontuacao < 16) {
        message = "Parabéns! Você foi muito bem!";
    } else {
        message = "Incrível! Você arrasou, acertou tudo!";
    }

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white rounded-xl p-8 max-w-md w-full mx-4 shadow-2xl">
                <div className="flex flex-col items-center justify-center bg-gradient-to-b from-blue-50 to-purple-50 p-8">
                    <div className="w-full max-w-2xl text-center space-y-8">
                        <Header title={title} className="text-4xl md:text-5xl font-bold text-red-600 mb-8 animate-bounce" />
                        
                        <div className="bg-white rounded-lg shadow-lg p-6 ">
                            <p className="text-xl md:text-2xl text-gray-800 font-medium leading-relaxed">
                                {message}
                            </p>
                            
                            <p className="text-lg md:text-xl text-gray-600 italic border-t-2 border-dashed border-gray-200 pt-4">
                                {messagePontuacao}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}