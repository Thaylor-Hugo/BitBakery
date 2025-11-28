export default function Strawberry({ isActive = true, style, ...props }) {
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
      {/* Shadow */}
      <ellipse cx="50" cy="92" rx="20" ry="5" fill="rgba(0,0,0,0.15)"/>
      
      {/* Berry body */}
      <path 
        d="M50 15 C25 25, 15 50, 20 70 C25 85, 40 95, 50 95 C60 95, 75 85, 80 70 C85 50, 75 25, 50 15" 
        fill="url(#strawberryGradient)" 
        stroke="#C62828" 
        strokeWidth="1"
      />
      
      {/* Gradient definition */}
      <defs>
        <linearGradient id="strawberryGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#FF6B6B"/>
          <stop offset="50%" stopColor="#EF5350"/>
          <stop offset="100%" stopColor="#C62828"/>
        </linearGradient>
      </defs>
      
      {/* Seeds */}
      <ellipse cx="35" cy="45" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="50" cy="40" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="65" cy="45" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="30" cy="60" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="45" cy="55" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="55" cy="58" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="70" cy="60" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="38" cy="72" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="50" cy="75" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      <ellipse cx="62" cy="72" rx="2" ry="3" fill="#FFECB3" stroke="#FFD54F" strokeWidth="0.5"/>
      
      {/* Leaves */}
      <path d="M50 18 L42 8 Q38 5, 35 10 L45 20 Z" fill="#4CAF50" stroke="#2E7D32" strokeWidth="1"/>
      <path d="M50 18 L58 8 Q62 5, 65 10 L55 20 Z" fill="#4CAF50" stroke="#2E7D32" strokeWidth="1"/>
      <path d="M45 20 L35 12 Q30 10, 28 15 L40 22 Z" fill="#66BB6A" stroke="#2E7D32" strokeWidth="1"/>
      <path d="M55 20 L65 12 Q70 10, 72 15 L60 22 Z" fill="#66BB6A" stroke="#2E7D32" strokeWidth="1"/>
      <path d="M50 22 L50 8 Q52 2, 50 0 Q48 2, 50 8 Z" fill="#388E3C" stroke="#2E7D32" strokeWidth="1"/>
      
      {/* Highlight */}
      <ellipse cx="38" cy="35" rx="6" ry="8" fill="rgba(255,255,255,0.3)"/>
    </svg>
  );
}
