export default function Butter({ isActive = true, style, ...props }) {
  return (
    <svg
      width="100"
      height="100"
      viewBox="0 0 100 100"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      style={{ ...style, filter: isActive ? 'none' : 'grayscale(100%) brightness(0.2)' }}
      {...props}
    >
      {/* Butter Block */}
      <rect x="20" y="50" width="60" height="30" fill="#FFF176" stroke="#FBC02D" strokeWidth="1"/>
      <path d="M20 50 L30 40 L90 40 L80 50 Z" fill="#FFF59D" stroke="#FBC02D" strokeWidth="1"/>
      <path d="M80 50 L90 40 L90 70 L80 80 Z" fill="#FDD835" stroke="#FBC02D" strokeWidth="1"/>
      
      {/* Knife */}
      <path d="M10 30 L40 60 L50 55 L20 25 Z" fill="#E0E0E0" stroke="#9E9E9E" strokeWidth="1"/> {/* Blade */}
      <path d="M50 55 L60 65" stroke="#9E9E9E" strokeWidth="2"/>
      <rect x="60" y="60" width="30" height="10" transform="rotate(45 60 60)" fill="#8D6E63" stroke="#5D4037" strokeWidth="1"/> {/* Handle */}
    </svg>
  );
}
