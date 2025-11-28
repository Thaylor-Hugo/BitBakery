
export default function Header({ title, className = "" }) {
    return (
        <div className={`py-3 px-6 ${className}`}>
            <h1 className="font-sans text-white text-4xl md:text-5xl font-bold text-center drop-shadow-md tracking-wide">
                {title ? title : "Default title"}
            </h1>
        </div>
    );
}