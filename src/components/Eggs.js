export default function Eggs({ isActive = true, style, ...props }) {
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
      {/* Back row eggs */}
      <ellipse cx="30" cy="40" rx="12" ry="15" fill="#F5DEB3" stroke="#D2691E" strokeWidth="1"/>
      <ellipse cx="50" cy="38" rx="12" ry="15" fill="#F5DEB3" stroke="#D2691E" strokeWidth="1"/>
      <ellipse cx="70" cy="40" rx="12" ry="15" fill="#F5DEB3" stroke="#D2691E" strokeWidth="1"/>
      
      {/* Carton back */}
      <path d="M15 50 L85 50 L80 70 L20 70 Z" fill="#E0E0E0" stroke="#9E9E9E" strokeWidth="1"/>
      
      {/* Front row eggs */}
      <ellipse cx="30" cy="55" rx="13" ry="16" fill="#F5DEB3" stroke="#D2691E" strokeWidth="1"/>
      <ellipse cx="50" cy="55" rx="13" ry="16" fill="#F5DEB3" stroke="#D2691E" strokeWidth="1"/>
      <ellipse cx="70" cy="55" rx="13" ry="16" fill="#F5DEB3" stroke="#D2691E" strokeWidth="1"/>

      {/* Carton front */}
      <path d="M10 60 Q10 80 20 85 L80 85 Q90 80 90 60 L90 55 L10 55 Z" fill="#F5F5F5" stroke="#9E9E9E" strokeWidth="1"/>
    </svg>
  );
}
