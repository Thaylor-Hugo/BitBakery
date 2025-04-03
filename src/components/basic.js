
export default function Header({ title }) {
    return <h1 className="font-sans text-[#feedff] text-7xl font-bold text-center">{title ? title : "Default title"}</h1>
}