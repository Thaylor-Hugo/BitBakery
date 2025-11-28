export default function FlourBag({ isActive = true, style, ...props }) {
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
      {/* Bag */}
      <path d="M25 20 L30 15 L70 15 L75 20 L80 85 Q80 95 70 95 L30 95 Q20 95 20 85 Z" fill="#FFF8E7" stroke="#5D4037" strokeWidth="2"/>
      <path d="M25 20 L75 20" stroke="#5D4037" strokeWidth="2"/>
      {/* Label */}
      <ellipse cx="50" cy="55" rx="20" ry="12" fill="none" stroke="#5D4037" strokeWidth="2"/>
      <text x="50" y="59" textAnchor="middle" fill="#5D4037" fontSize="14" fontFamily="sans-serif" fontWeight="bold">FLOUR</text>
      {/* Scoop */}
      <path d="M60 80 L90 65" stroke="#8D6E63" strokeWidth="4" strokeLinecap="round"/>
      <path d="M50 80 Q40 80 40 90 L60 90 Q60 80 50 80" fill="#D7CCC8" stroke="#5D4037" strokeWidth="2"/>
    </svg>
  );
}
