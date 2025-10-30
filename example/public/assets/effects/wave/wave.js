/**
 * Material Design Ripple Effect
 */

// Initialize Material Design ripple effect
function initMaterialRipple() {
    // Add Material Design CSS styles
    const style = document.createElement('style');
    style.textContent = `
        .material-ripple {
            position: relative;
            overflow: hidden;
            transform: translate3d(0, 0, 0);
        }
        
        .material-ripple::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.1);
            border-radius: inherit;
            opacity: 0;
            transition: opacity 0.2s ease;
            pointer-events: none;
            z-index: 1;
        }
        
        /* Dark theme adjustments */
        .dark-style .material-ripple::before {
            background: rgba(255, 255, 255, 0.08);
        }
        
        /* Button specific styles */
        .btn.material-ripple::before {
            background: rgba(0, 0, 0, 0.12);
        }
        
        .dark-style .btn.material-ripple::before {
            background: rgba(255, 255, 255, 0.12);
        }
        
        /* Enhanced button focus states */
        .material-ripple:focus {
            outline: none;
        }
        
        .material-ripple:focus::before {
            opacity: 0.12;
        }
        
        /* Accessibility improvements */
        .material-ripple:focus-visible {
            box-shadow: 0 0 0 2px rgba(66, 165, 245, 0.5);
        }
        
        .material-ripple-wave {
            will-change: transform, opacity;
        }
        
        @media (prefers-reduced-motion: reduce) {
            .material-ripple-wave {
                animation-duration: 0.01ms !important;
            }
        }
    `;
    document.head.appendChild(style);
    
    // Apply Material Design ripple class to elements
    const elements = document.querySelectorAll('.btn:not(.disable-wave), .page-link:not(.disable-wave), .menu-link:not(.disable-wave), .dropdown-menu a:not(.disable-wave), .nav-link:not(.disable-wave), .wave:not(.disable-wave)');
    elements.forEach(el => {
        el.classList.add('material-ripple');
        // Ensure proper positioning
        if (getComputedStyle(el).position === 'static') {
            el.style.position = 'relative';
        }
    });
}

// Enhanced Material Design Ripple Effect
function initEnhancedMaterialRipple() {
    // Use event delegation for better performance
    document.addEventListener('pointerdown', function(e) {
        const target = e.target.closest('.btn:not(.disable-wave), .page-link:not(.disable-wave), .menu-link:not(.disable-wave), .dropdown-menu a:not(.disable-wave), .nav-link:not(.disable-wave), .wave:not(.disable-wave)');
        
        if (!target) return;
        
        // Ensure proper positioning
        if (getComputedStyle(target).position === 'static') {
            target.style.position = 'relative';
        }
        target.style.overflow = 'hidden';
        
        // Create Material Design ripple
        requestAnimationFrame(() => createMaterialRipple(e, target));
    }, { passive: true });
}

function createMaterialRipple(e, element) {
    // Get element bounds and calculate ripple properties
    const rect = element.getBoundingClientRect();
    
    // Calculate click position relative to element
    const clickX = e.clientX - rect.left;
    const clickY = e.clientY - rect.top;
    
    // Calculate distance to farthest corner for ripple size
    const corners = [
        Math.sqrt(Math.pow(clickX, 2) + Math.pow(clickY, 2)),
        Math.sqrt(Math.pow(clickX - rect.width, 2) + Math.pow(clickY, 2)),
        Math.sqrt(Math.pow(clickX, 2) + Math.pow(clickY - rect.height, 2)),
        Math.sqrt(Math.pow(clickX - rect.width, 2) + Math.pow(clickY - rect.height, 2))
    ];
    const rippleSize = Math.max(...corners) * 2;
    
    // Remove existing ripples
    const existingRipples = element.querySelectorAll('.material-ripple-wave');
    existingRipples.forEach(ripple => ripple.remove());
    
    // Create ripple element
    const ripple = document.createElement('div');
    ripple.className = 'material-ripple-wave';
    
    // Determine ripple color based on element and theme
    let rippleColor;
    const isDark = document.documentElement.classList.contains('dark-style');
    
    if (element.classList.contains('btn-primary')) {
        rippleColor = 'rgba(255, 255, 255, 0.45)';
    } else if (element.classList.contains('btn-secondary')) {
        rippleColor = isDark ? 'rgba(255, 255, 255, 0.35)' : 'rgba(0, 0, 0, 0.35)';
    } else if (element.classList.contains('btn-dark')) {
        rippleColor = 'rgba(255, 255, 255, 0.35)';
    } else if (element.classList.contains('btn-light')) {
        rippleColor = 'rgba(0, 0, 0, 0.35)';
    } else {
        // Default colors
        rippleColor = isDark ? 'rgba(255, 255, 255, 0.32)' : 'rgba(0, 0, 0, 0.32)';
    }
    
    // Apply styles
    Object.assign(ripple.style, {
        position: 'absolute',
        width: rippleSize + 'px',
        height: rippleSize + 'px',
        left: (clickX - rippleSize / 2) + 'px',
        top: (clickY - rippleSize / 2) + 'px',
        background: rippleColor,
        borderRadius: '50%',
        pointerEvents: 'none',
        zIndex: '10',
        transform: 'scale(0)',
        opacity: '1',
        willChange: 'transform, opacity'
    });
    
    element.appendChild(ripple);
    
    // Animate using Web Animations API for smooth performance
    const animation = ripple.animate([
        { 
            transform: 'scale(0)', 
            opacity: 1 
        },
        { 
            transform: 'scale(0.8)', 
            opacity: 0.6,
            offset: 0.3 
        },
        { 
            transform: 'scale(1)', 
            opacity: 0 
        }
    ], {
        duration: 500,
        easing: 'cubic-bezier(0.4, 0, 0.2, 1)', // Material Design easing
        fill: 'forwards'
    });
    
    // Clean up after animation
    animation.onfinish = () => {
        if (ripple.parentNode) {
            ripple.remove();
        }
    };
    
    // Backup cleanup
    setTimeout(() => {
        if (ripple.parentNode) {
            ripple.remove();
        }
    }, 600);
}

// Initialize the Material Design ripple effect
document.addEventListener('DOMContentLoaded', function() {
    // Apply base Material Design styling
    initMaterialRipple();
    
    // Add enhanced JavaScript ripple functionality
    initEnhancedMaterialRipple();
    
    // Optional: Add touch feedback for mobile devices
    document.addEventListener('touchstart', function() {}, { passive: true });
});