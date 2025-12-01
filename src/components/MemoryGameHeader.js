
export default function MemoryGameHeader({ title, className = "" }) {
    return (
        <div className={`py-2 px-4 ${className}`}>
            <h1 className="font-sans text-black text-4xl md:text-5xl font-bold text-center drop-shadow-md tracking-wide">
                {title ? title : "Memory Game"}
            </h1>
        </div>
    );
}