export default function MilkBottle({ isActive = true, style, ...props }) {
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
      <rect x="35" y="40" width="30" height="50" rx="5" fill="#FFFFFF" stroke="#333" strokeWidth="2"/>
      <path d="M35 40 L40 20 L60 20 L65 40 Z" fill="#FFFFFF" stroke="#333" strokeWidth="2"/>
      <rect x="40" y="15" width="20" height="5" fill="#87CEEB" stroke="#333" strokeWidth="1"/>
      <text x="50" y="70" textAnchor="middle" fill="#87CEEB" fontSize="10" fontFamily="sans-serif" fontWeight="bold">MILK</text>
    </svg>
  );
}
