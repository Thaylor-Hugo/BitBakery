
export default function Header({ title }) {
    return <h1 className="font-sans text-[#feedff] text-7xl font-bold text-center" style={{WebkitTextStroke: "1px gray"}}>{title ? title : "Default title"}</h1>
}