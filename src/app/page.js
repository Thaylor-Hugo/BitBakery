'use client'
import { useGameChooser } from '../hooks/useGameChooser';
import Header from '../components/basic';

export default function HomePage() {
    useGameChooser();
    return (
        <div>
            <Header title="Develop. Preview. Ship." />
            <p>Hello World</p>
        </div>
    )
}
