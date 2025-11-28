export default function CocoaPowder({ isActive = true, style, ...props }) {
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
      {/* Bowl */}
      <path d="M20 45 Q50 90 80 45" fill="#EFEBE9" stroke="#8D6E63" strokeWidth="2"/>
      <ellipse cx="50" cy="45" rx="30" ry="10" fill="#5D4037" stroke="#3E2723" strokeWidth="1"/>
      {/* Powder mound */}
      <path d="M30 45 Q50 20 70 45" fill="#5D4037" />
      {/* Texture dots */}
      <circle cx="45" cy="35" r="1" fill="#3E2723"/>
      <circle cx="55" cy="38" r="1" fill="#3E2723"/>
      <circle cx="50" cy="30" r="1" fill="#3E2723"/>
    </svg>
  );
}
