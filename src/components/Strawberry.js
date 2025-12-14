export default function Strawberry({ isActive = true, style, width = 100, height = 100, ...props }) {
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
      <path 
        d="M50 95 C 30 85, 10 60, 10 35 C 10 20, 25 10, 50 10 C 75 10, 90 20, 90 35 C 90 60, 70 85, 50 95 Z" 
        fill="#E62E2D" 
      />
      
      <g fill="#FFFFFF" opacity="0.9">
        <ellipse cx="30" cy="35" rx="1.5" ry="2.5" transform="rotate(-10 30 35)"/>
        <ellipse cx="45" cy="30" rx="1.5" ry="2.5" />
        <ellipse cx="60" cy="32" rx="1.5" ry="2.5" transform="rotate(10 60 32)"/>
        <ellipse cx="75" cy="38" rx="1.5" ry="2.5" transform="rotate(20 75 38)"/>
        
        <ellipse cx="25" cy="50" rx="1.5" ry="2.5" transform="rotate(-15 25 50)"/>
        <ellipse cx="40" cy="48" rx="1.5" ry="2.5" transform="rotate(-5 40 48)"/>
        <ellipse cx="55" cy="50" rx="1.5" ry="2.5" transform="rotate(5 55 50)"/>
        <ellipse cx="70" cy="52" rx="1.5" ry="2.5" transform="rotate(15 70 52)"/>
        <ellipse cx="82" cy="48" rx="1.5" ry="2.5" transform="rotate(25 82 48)"/>

        <ellipse cx="35" cy="65" rx="1.5" ry="2.5" transform="rotate(-10 35 65)"/>
        <ellipse cx="50" cy="68" rx="1.5" ry="2.5" />
        <ellipse cx="65" cy="66" rx="1.5" ry="2.5" transform="rotate(10 65 66)"/>
        
        <ellipse cx="45" cy="80" rx="1.5" ry="2.5" transform="rotate(-5 45 80)"/>
        <ellipse cx="55" cy="80" rx="1.5" ry="2.5" transform="rotate(5 55 80)"/>
      </g>

      <path 
        d="M50 15 L40 5 Q35 0, 30 5 L20 25 L35 20 L45 35 L50 20 L55 35 L65 20 L80 25 L70 5 Q65 0, 60 5 L50 15 Z" 
        fill="#4CA944" 
        stroke="#FFFFFF" 
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M50 15 L55 0 L45 0 Z" fill="#4CA944" />
    </svg>
  );
}
