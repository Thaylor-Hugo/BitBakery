export default function CocoaPowder({ isActive = true, style, width = 100, height = 100, ...props }) {
  return (
    <svg
      width={width}
      height={height}
      viewBox="0 0 100 100"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      style={{ ...style, filter: isActive ? (style?.filter || 'none') : 'grayscale(100%) brightness(0.2)' }}
      {...props}
    >
      <rect x="25" y="30" width="50" height="60" rx="2" fill="#5D4037" stroke="#3E2723" strokeWidth="2"/>
      <rect x="23" y="25" width="54" height="8" rx="1" fill="#8D6E63" stroke="#3E2723" strokeWidth="2"/>      
      <rect x="25" y="40" width="50" height="35" fill="#D7CCC8"/>
      <text x="50" y="55" textAnchor="middle" fill="#3E2723" fontSize="10" fontFamily="sans-serif" fontWeight="bold">COCOA</text>
      <text x="50" y="65" textAnchor="middle" fill="#3E2723" fontSize="8" fontFamily="sans-serif">POWDER</text>
      <ellipse cx="50" cy="80" rx="6" ry="4" fill="#3E2723" transform="rotate(-15 50 80)"/>
      <path d="M48 80 Q50 78 52 80" stroke="#8D6E63" strokeWidth="1" transform="rotate(-15 50 80)"/>
    </svg>
  );
}
