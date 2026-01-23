import 'package:finch/src/views/htmler.dart';
import 'package:finch/src/widgets/finch_string_widget.dart';

class ConsoleWidget implements FinchStringWidget {
  @override
  get layout => """
class DebuggerStatusBar {
  constructor() {
    this.isCollapsed = false;
    this.isRunning = true;
    this.startTime = Date.now();
    this.breakpoints = 0;
    this.memory = 0;
    // Create an isolated Shadow DOM to prevent external styles from affecting the debugger UI
    this.attachShadowRoot();
    // Load persisted UI state (default: open)
    this.loadCollapsedState();
    this.createStyles();
    this.createElements();
    this.bindEvents();
    this.logs = [];
    this.loadStoredLogs();
    this.updateBreakpointsDisplay();
  }

  loadCollapsedState() {
    try {
      const stored = window.localStorage.getItem('waDebuggerCollapsed');
      this.isCollapsed = stored === 'true' ? true : false; // default open if not set
    } catch (e) {
      this.isCollapsed = false;
    }
  }

  saveCollapsedState() {
    try {
      window.localStorage.setItem('waDebuggerCollapsed', this.isCollapsed ? 'true' : 'false');
    } catch (e) {
      // ignore storage errors
    }
  }

  loadStoredLogs() {
    try {
      const stored = window.localStorage.getItem('waDebuggerLogs');
      if (stored) {
        this.logs = JSON.parse(stored);
        // Ensure we only keep the last 30 logs
        if (this.logs.length > 30) {
          this.logs = this.logs.slice(-30);
          this.saveLogsToStorage();
        }
      }
    } catch (e) {
      this.logs = [];
    }
  }

  saveLogsToStorage() {
    try {
      // Only keep the last 30 logs
      const logsToSave = this.logs.slice(-30);
      window.localStorage.setItem('waDebuggerLogs', JSON.stringify(logsToSave));
    } catch (e) {
      // ignore storage errors
    }
  }

  addLogMessage(message, type) {
    const logEntry = {
      message: message,
      type: type,
      timestamp: new Date().toISOString(),
      id: Date.now() + Math.random()
    };
    
    this.logs.push(logEntry);
    
    // Keep only the last 30 logs
    if (this.logs.length > 30) {
      this.logs = this.logs.slice(-30);
    }
    
    // Save to localStorage
    this.saveLogsToStorage();
    
    return logEntry;
  }

  updateBreakpointsDisplay() {
    if (this.logs.length > 0) {
      // Get the most recent log
      const lastLog = this.logs[this.logs.length - 1];
      this.breakpointsElement.textContent = lastLog.message;
      this.breakpointsElement.className = 'log log-' + lastLog.type;
    } else {
      // No logs available
      this.breakpointsElement.textContent = 'No debug messages';
      this.breakpointsElement.className = 'log';
    }
  }

  clearAllLogs() {
    // Clear logs array
    this.logs = [];
    
    // Clear localStorage
    try {
      window.localStorage.removeItem('waDebuggerLogs');
    } catch (e) {
      // ignore storage errors
    }
    
    // Update display
    this.updateBreakpointsDisplay();
    
    // Close console and show notification
    this.closeConsole();
    this.showNotification('All logs cleared', 'info');
  }
  
  attachShadowRoot() {
    // Host element attached to body
    this.host = document.createElement('div');
    this.host.id = 'wa-debugger-host';
    // Create shadow root
    this.shadow = this.host.attachShadow({ mode: 'open' });
    document.body.appendChild(this.host);
  }
  
  createStyles() {
    const styleSheet = document.createElement('style');
    styleSheet.textContent = `
      .wa-console, .wa-console * {
        all: revert;
      }
      .wa-console #debugger-container {
        direction: ltr;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        z-index: 10000;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
        transition: transform 0.3s ease;
        background: #1e1e1e;
        border-top: 1px solid #333333;
        box-shadow: 0 -1px 3px rgba(0,0,0,0.12), 0 -1px 2px rgba(0,0,0,0.24);
        height: 40px;
        backdrop-filter: blur(8px);
      }
      
      .wa-console #debugger-container.collapsed {
        transform: translateY(100%);
      }
      
      .wa-console #debugger-container.disconnected {
        background: #2d1b1e !important;
        border-top: 1px solid #d32f2f !important;
      }
      
      .wa-console #debugger-container.disconnected #debugger-bar {
        border-top: 1px solid #d32f2f;
      }
      
      .wa-console #debugger-toggle {
        padding: 0;
        margin: 0;
        direction: ltr;
        position: fixed;
        bottom: 4px;
        left: 3px;
        z-index: 10001;
        height: 35px;
        width: 35px;
        background: rgba(255,255,255,0.8);
        border: 1px solid #696cff;
        border-radius: 8px;
        color: white;
        cursor: pointer;
        font-size: 11px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: flex;
        align-items: center;
        gap: 8px;
        text-align: center;
      }
      
      .wa-console #debugger-toggle:hover {
        background: #FFFFFF;
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
        border: 2px solid #696cff;
      }
      
      .wa-console #debugger-bar {
        padding: 4px 4px 4px 45px;
        height: 32px;
        display: flex;
        align-items: center;
        background: linear-gradient(90deg, rgba(255,255,255,0.02) 0%, rgba(255,255,255,0.01) 100%);
      }
      
      .wa-console .debugger-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
        height: 100%;
        gap: 8px;
      }
      
      .wa-console .debugger-section {
        display: flex;
        align-items: center;
        gap: 8px;
        height: 100%;
      }
      
      .wa-console .debugger-status {
        background: transparent;
        padding: 2px 8px;
        border-radius: 3px;
        color: #cccccc;
        font-size: 11px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 6px;
        letter-spacing: 0.3px;
        border: 1px solid transparent;
        height: 20px;
      }
      
      .wa-console .status-running {
        color: #4CAF50 !important;
        border: 1px solid rgba(76, 175, 80, 0.3) !important;
        background: rgba(76, 175, 80, 0.08) !important;
      }
      
      .wa-console .status-paused {
        color: #FFC107 !important;
        border: 1px solid rgba(255, 193, 7, 0.3) !important;
        background: rgba(255, 193, 7, 0.08) !important;
      }
      
      .wa-console .status-stopped {
        color: #F44336 !important;
        border: 1px solid rgba(244, 67, 54, 0.3) !important;
        background: rgba(244, 67, 54, 0.08) !important;
      }
      
      .wa-console .debugger-btn {
        background: rgba(255,255,255,0.1);
        border: 1px solid rgba(255,255,255,0.2);
        border-radius: 8px;
        color: white;
        padding: 8px 14px;
        cursor: pointer;
        font-size: 11px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
      
      .wa-console .debugger-btn:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      }
      
      .wa-console .debugger-btn:active {
        transform: translateY(0px);
      }
      
      .wa-console .debugger-btn.active {
        background: rgba(102, 126, 234, 0.5);
        border-color: #667eea;
        box-shadow: 0 0 10px rgba(102, 126, 234, 0.3);
      }
      
      .wa-console .debugger-info {
        color: #cccccc;
        font-size: 10px;
        display: flex;
        align-items: center;
        gap: 12px;
        font-weight: 400;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
        flex: 1;
        min-width: 0;
        overflow: hidden;
      }
      
      .wa-console .debugger-info span {
        display: flex;
        align-items: center;
        gap: 4px;
        white-space: nowrap;
        color: #969696;
      }
      
      .wa-console .debugger-info span:before {
        content: '';
        width: 1px;
        height: 12px;
        background: #404040;
        margin-right: 8px;
      }
      
      .wa-console .debugger-info span:first-child:before {
        display: none;
      }
      
      .wa-console .status-indicator {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        display: inline-block;
        box-shadow: none;
        border: 1px solid rgba(255,255,255,0.2);
      }
      
      .wa-console .indicator-green { 
        background: #4CAF50; 
        border-color: #4CAF50;
        box-shadow: 0 0 4px rgba(76, 175, 80, 0.4);
      }
      .wa-console .indicator-yellow { 
        background: #FFC107; 
        border-color: #FFC107;
        box-shadow: 0 0 4px rgba(255, 193, 7, 0.4);
      }
      .wa-console .indicator-red { 
        background: #F44336; 
        border-color: #F44336;
        box-shadow: 0 0 4px rgba(244, 67, 54, 0.4);
      }
      
      .wa-console .debugger-notification {
        direction: ltr;
        position: fixed;
        bottom: 70px;
        right: 20px;
        z-index: 10002;
        padding: 12px 18px;
        border-radius: 8px;
        color: white;
        font-size: 12px;
        font-weight: 500;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        backdrop-filter: blur(10px);
      }
      
      .wa-console .notification-success { 
        background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
      }
      .wa-console .notification-warning { 
        background: linear-gradient(135deg, #FF9800 0%, #f57c00 100%);
      }
      .wa-console .notification-error { 
        background: linear-gradient(135deg, #F44336 0%, #d32f2f 100%);
      }
      .wa-console .notification-info { 
        background: linear-gradient(135deg, #2196F3 0%, #1976d2 100%);
      }
      
      /* Console Modal Styles */
      .wa-console .console-modal {
        direction: ltr;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        z-index: 10003;
        display: flex;
        justify-content: center;
        align-items: center;
        opacity: 0;
        visibility: hidden;
        transition: all 0.2s ease;
        backdrop-filter: blur(4px);
      }
      
      .wa-console .console-modal.active {
        opacity: 1;
        visibility: visible;
      }

      .wa-console .console-modal-content {
        background: #1e1e1e;
        border: 1px solid #333333;
        border-radius: 6px;
        width: 90%;
        max-width: 1000px;
        max-height: 85%;
        overflow: hidden;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
        transform: scale(0.95);
        transition: transform 0.2s ease;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
      }

      .wa-console .console-modal.active .console-modal-content {
        transform: scale(1);
      }

      .wa-console .console-modal-header {
        background: #2d2d2d;
        border-bottom: 1px solid #404040;
        padding: 12px 16px;
        color: #cccccc;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .wa-console .console-modal-title {
        font-size: 13px;
        font-weight: 500;
        margin: 0;
        color: #cccccc;
        letter-spacing: 0.3px;
      }
      
      .wa-console .console-modal-close {
        background: none;
        border: none;
        color: #969696;
        font-size: 16px;
        cursor: pointer;
        padding: 0;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 3px;
        transition: all 0.2s ease;
      }
      
      .wa-console .console-modal-close:hover {
        background: rgba(255, 255, 255, 0.1);
        color: #cccccc;
      }
      
      .wa-console .console-button-container {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 12px;
        padding: 0 3px;
      }
      
      .wa-console .console-clear-btn {
        background: #d32f2f;
        border: 1px solid #f44336;
        color: white;
        font-size: 10px;
        font-weight: 500;
        cursor: pointer;
        padding: 4px 8px;
        border-radius: 3px;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        gap: 4px;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
      }
      
      .wa-console .console-clear-btn:hover {
        background: #b71c1c;
        border-color: #d32f2f;
        transform: translateY(-1px);
      }
      
      .wa-console .console-clear-btn:active {
        transform: translateY(0);
      }
      
      .wa-console .console-clear-btn svg {
        opacity: 0.9;
      }
      
      .wa-console .console-modal-body {
        padding: 16px;
        max-height: 600px;
        overflow-y: auto;
        color: #cccccc;
        background: #1e1e1e;
      }
      
      .wa-console .error-summary {
        background: rgba(244, 67, 54, 0.08);
        border-left: 3px solid #f44336;
        padding: 12px 16px;
        margin-bottom: 16px;
        border-radius: 3px;
      }
      
      .wa-console .error-title {
        font-size: 14px;
        font-weight: 500;
        color: #ff6b6b;
        margin-bottom: 6px;
      }
      
      .wa-console .error-message {
        font-size: 12px;
        color: #cccccc;
        line-height: 1.4;
      }
      
      .wa-console .error-details {
        margin-top: 16px;
      }
      
      .wa-console .error-section {
        margin-bottom: 16px;
      }
      
      .wa-console .error-section-title {
        font-size: 11px;
        font-weight: 500;
        color: #569cd6;
        margin-bottom: 8px;
        text-transform: uppercase;
        letter-spacing: 0.8px;
      }

      .wa-console .error-json {
        background: #0f0f0f;
        border: 1px solid #333;
        border-radius: 3px;
        padding: 12px;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
        font-size: 11px;
        color: #d4d4d4;
        overflow-x: auto;
        white-space: pre-wrap;
        word-wrap: break-word;
        line-height: 1.4;
      }

      .wa-console .stack-trace {
        background: #0f0f0f;
        border: 1px solid #333;
        border-radius: 3px;
        padding: 12px;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
        font-size: 10px;
        color: #ff8a80;
        max-height: 200px;
        overflow-y: auto;
        line-height: 1.3;
      }

      .wa-console .error-tabs {
        display: flex;
        border-bottom: 1px solid #333;
        margin-bottom: 12px;
        background: #252526;
        border-radius: 3px 3px 0 0;
      }

      .wa-console .error-tab {
        padding: 8px 12px;
        background: none;
        border: none;
        color: #969696;
        cursor: pointer;
        font-size: 11px;
        font-weight: 400;
        transition: all 0.2s ease;
        border-bottom: 2px solid transparent;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
      }

      .wa-console .error-tab.active {
        color: #cccccc;
        background: #1e1e1e;
        border-bottom: 2px solid #569cd6;
      }
      
      .wa-console .error-tab:hover {
        color: #cccccc;
        background: rgba(255, 255, 255, 0.05);
      }
      
      .wa-console .tab-content {
        display: none;
      }
      
      .wa-console .tab-content.active {
        display: block;
      }
      
      /* Routes Table Styles */
      .wa-console .routes-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 12px;
        background: #1e1e1e;
        border: 1px solid #333;
        border-radius: 3px;
        overflow: hidden;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
      }
      
      .wa-console .routes-table th {
        background: #2d2d2d;
        color: #cccccc;
        padding: 8px 6px;
        text-align: left;
        font-size: 10px;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #404040;
        border-right: 1px solid #333;
      }
      
      .wa-console .routes-table th:last-child {
        border-right: none;
      }
      
      .wa-console .routes-table td {
        padding: 6px 6px;
        border-bottom: 1px solid #2a2a2a;
        border-right: 1px solid #2a2a2a;
        font-size: 10px;
        color: #cccccc;
        vertical-align: top;
      }
      
      .wa-console .routes-table td:last-child {
        border-right: none;
      }
      
      .wa-console .routes-table tr:nth-child(even) {
        background: rgba(255,255,255,0.02);
      }
      
      .wa-console .routes-table tr:hover {
        background: rgba(255, 255, 255, 0.05);
      }
      
      .wa-console .method-badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 9px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
      
      .wa-console .method-get { background: #4CAF50; color: white; }
      .wa-console .method-post { background: #2196F3; color: white; }
      .wa-console .method-put { background: #FF9800; color: white; }
      .wa-console .method-delete { background: #f44336; color: white; }
      .wa-console .method-patch { background: #9C27B0; color: white; }
      .wa-console .method-error { background: #f44336; color: white; }
      .wa-console .method-warning { background: #FF9800; color: white; }
      .wa-console .method-info { background: #2196F3; color: white; }
      .wa-console .method-debug { background: #4CAF50; color: white; }
      .wa-console .method-fatal { background: #9C27B0; color: white; }

      .wa-console .type-badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 9px;
        font-weight: 500;
        background: rgba(52, 152, 219, 0.2);
        color: #3498db;
        border: 1px solid #3498db;
      }
      
      .wa-console .auth-indicator {
        display: inline-block;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        margin-right: 6px;
      }
      
      .wa-console .auth-true { background: #4CAF50; }
      .wa-console .auth-false { background: #f44336; }
      
      .wa-console .routes-summary {
        background: rgba(86, 156, 214, 0.08);
        border-left: 3px solid #569cd6;
        padding: 10px 12px;
        margin-bottom: 12px;
        border-radius: 3px;
        color: #cccccc;
        font-size: 11px;
      }
      
      .wa-console .routes-summary-title {
        font-weight: 500;
        color: #569cd6;
        margin-bottom: 4px;
        font-size: 11px;
      }
      
      /* Dropdown Menu Styles */
      .wa-console .debugger-dropdown {
        position: relative;
        display: inline-block;
      }
      
      .wa-console .dropdown-toggle {
        background: transparent;
        border: 1px solid #404040;
        border-radius: 3px;
        color: #cccccc;
        padding: 4px 8px;
        cursor: pointer;
        font-size: 10px;
        font-weight: 400;
        transition: all 0.2s ease;
        outline: none;
        display: flex;
        align-items: center;
        gap: 4px;
        height: 20px;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
      }
      
      .wa-console .dropdown-toggle:hover {
        background: rgba(255,255,255,0.05);
        border-color: #565656;
      }
      
      .wa-console .dropdown-toggle::after {
        content: '▼';
        font-size: 8px;
        transition: transform 0.2s ease;
        color: #969696;
      }
      
      .wa-console .dropdown-toggle.active::after {
        transform: rotate(180deg);
      }
      
      .wa-console .dropdown-menu {
        position: absolute;
        bottom: 100%;
        right: 0;
        background: #252526;
        border: 1px solid #404040;
        border-radius: 3px;
        min-width: 180px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.4);
        z-index: 1000;
        opacity: 0;
        visibility: hidden;
        transform: translateY(5px);
        transition: all 0.2s ease;
        margin-bottom: 6px;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
      }
      
      .wa-console .dropdown-menu.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
      }
      
      .wa-console .dropdown-section {
        padding: 8px 0;
        border-bottom: 1px solid rgba(255,255,255,0.1);
      }
      
      .wa-console .dropdown-section:last-child {
        border-bottom: none;
      }
      
      .wa-console .dropdown-section-title {
        padding: 6px 16px;
        font-size: 10px;
        font-weight: 600;
        color: rgba(255,255,255,0.6);
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 4px;
      }
      
      .wa-console .dropdown-item {
        display: block;
        width: 100%;
        padding: 10px 16px;
        background: none;
        border: none;
        color: white;
        text-align: left;
        cursor: pointer;
        font-size: 12px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        display: flex;
        align-items: center;
        gap: 10px;
      }
      
      .wa-console .dropdown-item:hover {
        background: rgba(255,255,255,0.1);
        padding-left: 20px;
      }
      
      .wa-console .dropdown-item:active {
        background: rgba(255,255,255,0.2);
      }
      
      .wa-console .dropdown-item.active {
        background: rgba(102, 126, 234, 0.3);
        border-left: 3px solid #667eea;
      }
      
      .wa-console .dropdown-icon {
        width: 16px;
        height: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        opacity: 0.8;
      }
      
      @media (max-width: 768px) {
        .wa-console #debugger-container {
          height: 32px !important;
        }
        
        .wa-console #debugger-bar {
          padding: 2px 2px 2px 38px;
          height: 32px;
          overflow: hidden;
        }
        
        .wa-console .debugger-content {
          gap: 4px;
          height: 100%;
          flex-wrap: nowrap;
        }
        
        .wa-console .debugger-section {
          gap: 6px;
          min-width: 0;
          flex-shrink: 1;
        }
        
        .wa-console .debugger-section:first-child {
          flex: 1;
          min-width: 0;
          overflow: hidden;
        }
        
        .wa-console .debugger-section:last-child {
          flex-shrink: 0;
        }
        
        .wa-console .debugger-status {
          padding: 2px 6px;
          font-size: 9px;
          gap: 3px;
          flex-shrink: 0;
          height: 18px;
        }
        
        .wa-console .debugger-info {
          font-size: 9px;
          gap: 8px;
          overflow: hidden;
          flex: 1;
          min-width: 0;
        }
        
        .wa-console .debugger-info span {
          gap: 2px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          min-width: 0;
        }
        
        .wa-console #debugger-toggle {
          width: 30px;
          height: 30px;
          font-size: 8px;
          bottom: 1px;
          left: 2px;
        }
        
        .wa-console .dropdown-toggle {
          padding: 2px 6px;
          font-size: 9px;
          gap: 2px;
          height: 18px;
        }
        
        .wa-console .console-modal-content {
          width: 95%;
          max-height: 90%;
        }
        
        .wa-console .dropdown-menu {
          min-width: 150px;
          right: -5px;
        }
        
        .wa-console .status-indicator {
          width: 6px;
          height: 6px;
        }
      }

      @media (max-width: 480px) {
        .wa-console #debugger-container {
          height: 40px !important;
        }
        
        .wa-console #debugger-bar {
          padding: 1px 1px 1px 32px;
        }
        
        .wa-console .debugger-content {
          gap: 3px;
        }
        
        .wa-console .debugger-section {
          gap: 2px;
        }
        
        .wa-console .debugger-status {
          padding: 2px 6px;
          font-size: 8px;
          gap: 2px;
        }
        
        .wa-console .debugger-info {
          font-size: 8px;
          gap: 4px;
        }
        
        .wa-console .debugger-info span {
          gap: 2px;
        }
        
        .wa-console #debugger-toggle {
          width: 28px;
          height: 28px;
          font-size: 7px;
        }
        
        .wa-console .dropdown-toggle {
          padding: 3px 6px;
          font-size: 8px;
          gap: 2px;
        }
        
        .wa-console .dropdown-menu {
          min-width: 140px;
        }
        
        .wa-console .dropdown-item {
          padding: 5px 8px;
          font-size: 9px;
        }
        
        .wa-console .status-indicator {
          width: 8px;
          height: 8px;
        }
      }

      .wa-console .log {
        color: #cccccc;
        border: 1px solid #404040;
        background: rgba(255,255,255,0.03);
        font-style: normal;
        border-radius: 2px;
        padding: 1px 6px;
        word-break: normal;
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Consolas', monospace;
        font-size: 10px;
        cursor: pointer;
        transition: all 0.2s ease;
      }

      .wa-console .log:hover {
        background: rgba(255,255,255,0.08);
        border-color: #565656;
      }

      .wa-console .log-error {
        border: 1px solid #d32f2f;
        background: rgba(244, 67, 54, 0.08);
        color: #ff6b6b;
      }

      .wa-console .log-warning {
        border: 1px solid #f57c00;
        background: rgba(255, 152, 0, 0.08);
        color: #ffb74d;
      }

      .wa-console .log-info {
        border: 1px solid #1976d2;
        background: rgba(33, 150, 243, 0.08);
        color: #64b5f6;
      }

      .wa-console .log-debug {
        border: 1px solid #388e3c;
        background: rgba(76, 175, 80, 0.08);
        color: #81c784;
      }

      .wa-console .log-fatal {
        border: 1px solid #7b1fa2;
        background: rgba(156, 39, 176, 0.08);
        color: #ba68c8;
      }

      .wa-console .logo{
        width: 100%;
        height: 100%;
      }

      .wa-console #debug-breakpoints {
        max-width: 400px;
        white-space: nowrap;
        overflow: hidden;   /* optional: hides overflow */
        text-overflow: ellipsis;
      }
    `;
  // Inject styles inside the shadow root for complete isolation
  this.shadow.appendChild(styleSheet);
  }
  
  createElements() {
    // Create main container
    this.mainContainer = document.createElement('div');
    this.mainContainer.className = 'wa-console';
  // Append the debugger UI only inside the shadow root
  this.shadow.appendChild(this.mainContainer);

    this.container = document.createElement('div');
    this.container.id = 'debugger-container';
    this.container.className = 'wa-console';
    // Apply initial collapsed state from storage
    if (this.isCollapsed) {
      this.container.classList.add('collapsed');
    }

    // Create debugger bar
    const debuggerBar = document.createElement('div');
    debuggerBar.id = 'debugger-bar';
    
    // Create content wrapper
    const content = document.createElement('div');
    content.className = 'debugger-content';
    
    // Create left section (status and info)
    const leftSection = document.createElement('div');
    leftSection.className = 'debugger-section';
    
    // Create status element
    this.statusElement = document.createElement('span');
    this.statusElement.className = 'debugger-status status-running';
    this.statusElement.id = 'debug-status';
    
    const statusIndicator = document.createElement('span');
    statusIndicator.className = 'status-indicator indicator-green';
    
    const statusText = document.createElement('span');
    statusText.textContent = 'RUNNING';
    
    this.statusElement.appendChild(statusIndicator);
    this.statusElement.appendChild(statusText);
    
    // Create info section
    const infoDiv = document.createElement('div');
    infoDiv.className = 'debugger-info';
    
    // Time info
    const timeSpan = document.createElement('span');
    timeSpan.innerHTML = '';
    this.timeElement = document.createElement('span');
    this.timeElement.id = 'debug-time';
    this.timeElement.textContent = '00:00:00';
    timeSpan.appendChild(this.timeElement);
    
    // Memory info
    const memorySpan = document.createElement('span');
    memorySpan.innerHTML = 'MEM: ';
    this.memoryElement = document.createElement('span');
    this.memoryElement.id = 'debug-memory';
    this.memoryElement.textContent = '0 MB';
    memorySpan.appendChild(this.memoryElement);
    
    // Breakpoints info
    const breakpointsSpan = document.createElement('span');
    breakpointsSpan.innerHTML = '#';
    this.breakpointsElement = document.createElement('span');
    this.breakpointsElement.id = 'debug-breakpoints';
    this.breakpointsElement.textContent = ``;
    breakpointsSpan.appendChild(this.breakpointsElement);
    
    infoDiv.appendChild(timeSpan);
    infoDiv.appendChild(memorySpan);
    infoDiv.appendChild(breakpointsSpan);
    
    // Make breakpoints element clickable to open console
    this.breakpointsElement.style.cursor = 'pointer';
    this.breakpointsElement.addEventListener('click', () => {
      this.openConsole(this.logs);
    });
    
    leftSection.appendChild(this.statusElement);
    leftSection.appendChild(infoDiv);
    
    // Create right section (dropdown menu)
    const rightSection = document.createElement('div');
    rightSection.className = 'debugger-section';
    
    // Create dropdown container
    const dropdown = document.createElement('div');
    dropdown.className = 'debugger-dropdown';
    
    // Create dropdown toggle button
    this.dropdownToggle = document.createElement('button');
    this.dropdownToggle.className = 'dropdown-toggle';
    this.dropdownToggle.textContent = '';
    
    // Create dropdown menu
    this.dropdownMenu = document.createElement('div');
    this.dropdownMenu.className = 'dropdown-menu';
    
    // Control Actions Section
    const controlSection = document.createElement('div');
    controlSection.className = 'dropdown-section';
    
    const controlTitle = document.createElement('div');
    controlTitle.className = 'dropdown-section-title';
    controlTitle.textContent = 'Control';
    controlSection.appendChild(controlTitle);
    
    // this.playBtn = this.createDropdownItem('AA', 'Continue');
    this.updateLangBtn = this.createDropdownItem('||', 'Update Languages');
    this.updateTemplateBtn = this.createDropdownItem('><', 'Update Template');
    // this.stepBtn = this.createDropdownItem('DD', 'Step');
    // this.stopBtn = this.createDropdownItem('BB', 'Stop');
    this.restartBtn = this.createDropdownItem('CC', 'Restart');
    
    // controlSection.appendChild(this.playBtn);
    controlSection.appendChild(this.updateLangBtn);
    controlSection.appendChild(this.updateTemplateBtn);
    // controlSection.appendChild(this.stepBtn);
    // controlSection.appendChild(this.stopBtn);
    controlSection.appendChild(this.restartBtn);
    
    // Panel Actions Section
    const panelSection = document.createElement('div');
    panelSection.className = 'dropdown-section';
    
    const panelTitle = document.createElement('div');
    panelTitle.className = 'dropdown-section-title';
    panelTitle.textContent = 'Panels';
    panelSection.appendChild(panelTitle);
    
    this.consoleBtn = this.createDropdownItem('[]', 'Console');
    this.routesBtn = this.createDropdownItem('./', 'Routes');
    this.variablesBtn = this.createDropdownItem('{}', 'Variables');
    this.reinitBtn = this.createDropdownItem('@', 'Reinit');
    // this.settingsBtn = this.createDropdownItem('A', 'Settings');
    
    panelSection.appendChild(this.consoleBtn);
    panelSection.appendChild(this.routesBtn);
    panelSection.appendChild(this.variablesBtn);
    panelSection.appendChild(this.reinitBtn);
    // panelSection.appendChild(this.settingsBtn);
    
    // Assemble dropdown
    this.dropdownMenu.appendChild(controlSection);
    this.dropdownMenu.appendChild(panelSection);
    dropdown.appendChild(this.dropdownToggle);
    dropdown.appendChild(this.dropdownMenu);
    rightSection.appendChild(dropdown);
    
    // Assemble everything
    content.appendChild(leftSection);
    content.appendChild(rightSection);
    debuggerBar.appendChild(content);
    this.container.appendChild(debuggerBar);
    
    // Create toggle button
    this.toggleBtn = document.createElement('button');
    this.toggleBtn.id = 'debugger-toggle';
    this.toggleBtn.innerHTML = `<img class="wa-console logo" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAMAAAAp4XiDAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAC91BMVEVHcExDw+tNYoVDw+tQgaEBJVxtvOSap8ABJFuGxtdjyeotRW0CJVtkyOlDwutexulEwupEwutHwupZx+lozewCJFqOzuoAJFs3UXtKksE9wu0Egc5Ew+tDw+tIwulEw+tayOpiyuxFw+tZx+szSnJTxuoNLF5JwukBJV0qQ2Y+v+oBJVtCwOkjPWkgOmdnz+oEIlYvSHFbx+sWM2JJw+kRLl0EKFxQxOkgj9AvldBGwepJw+kShs8XM2Jmy+oGg88gOmgFg9FBwuw/wu0zSG8iPWpOxepSxek/wu0kPmozmNUIKFoJhtATiM4idqYEeMQFJ1siaJ4OLWALK1xHo8wsk9EJgs0qQ24rRG9OxOlJwuhcyO1cyOtXx+lEwuxOwukKhc8HbrQUiM8hgMAtk9ImkNAdOmYais8tPGkhb6ooj88Qg8sKOXICK2NJvOMwaY9eyOlhy+2b2PApgbk/v+o6s+UNP3UOeb0zn9kIitQHe8QZYJMVh8wMKl8GN3A3mM8DMmsRMGAgcKADOnQTfsEAw+xEw+sAJVxDw+tEw+xBw+wAJFtDwutFw+wAJVsAJlw9w+9Dw+xCwusAJFwChNFFw+sCgtACgtECg9FExOtAw+wAJl1Cw+tFxOxAwes8wOsBJ19DxOwDhtIAJV09xO9BwusDdsA6veo9wu4BKWEDgs8FiNMCf8w9w+4JjNQCK2MDgM5AwuwFOXI5tuI3sN0BM20TM2YEZqwCfck1t+gCTIwcnt07u+YCU5UDYqYDcroFMGcYYJLFzdcDWJsusOQrreMCRYQ+xO8BLmgVl9omqOAYm9sCPnsDbrYDLmRu0O4LLWJ2hqG3wM0lpt8got4FgcsXWY0BMWs0qNUWXZAEN28ca50Dc74xlcQzpdMYZZkwmccKQXaQnbTe7fKq4vLR1d0iP24Pf8IBMWkTldcPRXksj745s+Aae7QOR3o1rtoqlMI0rdoTUoZIw+sTOm1twuIMQneqvMy+3+rb3uRrfZvN1Nzc4OXa2vpnAAAAzXRSTlMA+gn3A/oHAfYEECzwG/4h7OPccR7rDP4fEfb89P3L8Vwn55M1nNW6/Rr++89OXxfvPk651ajjc1kYx53Amj3wcfby3TGDi6PufDTb1a/7+8lSzb4MQupmZbvERaek/LHj9ZqRLXEjlhEnIMPO+bhkalQhhPO9o+Ao+d3hn4TfSvha9PjK///////////////////////////////////////////////////////////////////////////////////////////////+uM/LvgAABPFJREFUSMfFlmdUE1kUx6kpFOmKIkUBFUTXtrjWVVdd17WsuLq99957cduZApmETCYJISGVnlACSO8IK4tUe6/r9t7X/bD3vQGZgCLf/J/MnDk575d7//fe9zJubtdT4slxc+bedfec+eHSca33Cp+7cJ6E17yUdXEe1wSeXBEmmZ02JLnEb+H8MSHx06vCJCqVKk2O16O73DtsRcIYRPh2ySQVQoalSpskSfEVXy2pZ55/Qa/ihVabKyvNaejJe8ZVGPGzz21tquo4XGAjEaPqO3fpy3OVmPZOCb8iMvmp1RpNaXVud9u+vWYbSf77X3//P/19JPyA+dPPdt05mpDedLMmA8RxhQe/+uH0n82tA5V9AwOVgOjLmiJ2bt4xClqyvFCj1QJh7dqTZ6qvOPP3pYsXW//63WzTH+suLS2N2Pn+RpGrdwii1UAc+4E8Z6bTmZPTe7619fwfJ7f8erbxRC7S1rdem+jiZHOhFiHWTlNmZioS03vhQu9vxsTyUy1lu0EfffjmNpcwGx9GhCbDXjNIpKYadBSbAzJWtPTM9rvjA1/XMRA/sVqbgfIqNmHCghCDgYUPm2Ms/2T7xwleI8yLHoW8tBptRrFzKAhFKSkkGTBJk0c3/vFNWiyI4nTCeqVSSSkRIgOxkTNH74IlyyMcjlJIjLPX8ARaDRdBEPDgfuuogfF47JG22tq27mqHxlpncvJpISlpxFwBEfsmmxUKkjR/3XGi1N6OGZ5QEjqCkMkmjErM40ZvEqQAldQ67HV54IdFACYIGcsm+YxA1iaTQ1KY91VzxV17jBhBaRHIf1DAiHLxQZDkkF2HBiaz3WigCEyAFRkbHeOKJCTjrDAiJxUFVRzHfQEIpdPRNK4Y6x7viqySDBJyQOQKfVkhx+2HzACgdTrEUJH3uvj3mDHrcgwkRUEuQgyUhaYtQ3EWucywb5jtshUQuKnK4MCLkuaF3CiDbxAit0lsNgEiJ82NGZqaHIqC5RaMQM2C/AVt9Lh9lt7mYgb8W00GNCw4LQjCstOFVV7rZ9PbFJiAG0aauG/4gqEa6wglZTC4IOsktkPfluiReFC/9yCuMTHYF4JSprLCxKBeBSfLzxw61tzTXNZynFSQ5gbOnscCoVarMUZRLBssmJg4P7Ls+yI4UY6cOlLx048oSK71ACsDglHrspB9aH9klEhYr5LvTEXpn2dnZxeZfu4hFSWNXHEelIthdDodA0VD3feMHZ5+aYp3Sz1PZOf/clahKGhwWNtTocBMFsQgLBY8MIErBX30O1qej5D07PTyowXmkoZqa50RJlKtzmLU4ISmgYiMElh5aQsQRelI5cdLzLsbHVxnHm+dYVC5aGgku2bx8PEifTExHxBg8itONx+uzS20dtbzxBAC9YqMEoxL6IYiRBTlT0l6b19Dk4Ozd0EMhicY3EpAAmMEZ9grUzAx5Zb1AdvejbBai/cnWixQrCwkHc3vMM9lwm0cb8xHwLJpIjfRjk3vdNXkwO5lEIIvPMXuMwWdd5sYvGZD0NLFobhPXm+/8foEFkaeQUkxANHIu+fSacIT6dXYl1f6i4a+EfuETPeUKaGuQNA4BPVg9EMB4rH+xKUB8YFTIyk8v8iGe3RwjM+1XhWkoSGLoqd6uoM8owPvWeAjHs8biWjagpD1D9wfG3Kfv9RNPP4Xn+v62uX2P6iABWxyJplQAAAAAElFTkSuQmCC" alt="Toggle Debugger">`;
    
    // Append to body
    this.mainContainer.appendChild(this.container);
    this.mainContainer.appendChild(this.toggleBtn);
  }

  showLog(message, type) {
    const logEntry = this.addLogMessage(message, type);
    // Update the debug-breakpoints display with the latest log
    this.updateBreakpointsDisplay();
  }

  createButton(id, text) {
    const button = document.createElement('button');
    button.id = id;
    button.className = 'debugger-btn';
    button.textContent = text;
    return button;
  }
  
  createDropdownItem(icon, text) {
    const item = document.createElement('button');
    item.className = 'dropdown-item';
    
    const iconSpan = document.createElement('span');
    iconSpan.className = 'dropdown-icon';
    iconSpan.textContent = icon;
    
    const textSpan = document.createElement('span');
    textSpan.textContent = text;
    
    item.appendChild(iconSpan);
    item.appendChild(textSpan);
    
    return item;
  }
  
  bindEvents() {
    // Toggle button
    this.toggleBtn.addEventListener('click', () => this.toggle());
    
    // Dropdown toggle
    this.dropdownToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      this.toggleDropdown();
    });
    
    // Close dropdown when clicking outside (within shadow root)
    this.shadow.addEventListener('click', (e) => {
      const target = e.target;
      if (!this.dropdownMenu.contains(target) && !this.dropdownToggle.contains(target)) {
        this.closeDropdown();
      }
    });
    
    // Control buttons
    // this.playBtn.addEventListener('click', () => {
    //   this.continue();
    //   this.closeDropdown();
    // });
    this.updateLangBtn.addEventListener('click', () => {
      this.updateLang();
      this.closeDropdown();
    });
    this.updateTemplateBtn.addEventListener('click', () => {
      this.updateTemplate();
      this.closeDropdown();
    });
    // this.stepBtn.addEventListener('click', () => {
    //   this.step();
    //   this.closeDropdown();
    // });
    // this.stopBtn.addEventListener('click', () => {
    //   this.stop();
    //   this.closeDropdown();
    // });
    this.restartBtn.addEventListener('click', () => {
      this.restart();
      this.closeDropdown();
    });
    
    // Panel buttons
    this.consoleBtn.addEventListener('click', () => {
      this.openConsole(this.logs);
      this.togglePanel('console');
      this.closeDropdown();
    });

    this.routesBtn.addEventListener('click', () => {
      window.socketDebugger.send(JSON.stringify({ path: 'get_routes' }));
      this.togglePanel('routes');
      this.closeDropdown();
    });

    this.variablesBtn.addEventListener('click', () => {
      window.socketDebugger.send(JSON.stringify({ path: 'get_data' }));
      this.togglePanel('variables');
      this.closeDropdown();
    });
    this.reinitBtn.addEventListener('click', () => {
      window.socketDebugger.send(JSON.stringify({ path: 'reinit' }));
      this.closeDropdown();
    });
    // this.settingsBtn.addEventListener('click', () => {
    //   this.togglePanel('settings');
    //   this.closeDropdown();
    // });
  }
  
  toggle() {
    this.isCollapsed = !this.isCollapsed;
    this.container.classList.toggle('collapsed', this.isCollapsed);
  this.saveCollapsedState();
  }
  
  toggleDropdown() {
    const isOpen = this.dropdownMenu.classList.contains('show');
    if (isOpen) {
      this.closeDropdown();
    } else {
      this.openDropdown();
    }
  }
  
  openDropdown() {
    this.dropdownMenu.classList.add('show');
    this.dropdownToggle.classList.add('active');
  }
  
  closeDropdown() {
    this.dropdownMenu.classList.remove('show');
    this.dropdownToggle.classList.remove('active');
  }
  
  continue() {
    this.isRunning = true;
    this.updateStatus('running', 'RUNNING');
    this.setActiveButton(this.playBtn);
  }
  
  updateLang() {
    window.socketDebugger.send(JSON.stringify({ path: 'update_languages' }));
    this.setActiveButton(this.updateLangBtn);
  }
  
  updateTemplate() {
    window.socketDebugger.send(JSON.stringify({ path: 'update_template' }));
    this.setActiveButton(this.updateTemplateBtn);
  }
  
  step() {
    this.simulateBreakpoint();
  }
  
  stop() {
    this.isRunning = false;
    this.updateStatus('stopped', 'STOPPED');
    this.setActiveButton(this.stopBtn);
    this.showNotification('Debugger stopped', 'error');
  }
  
  restart() {
    this.isRunning = true;
    this.startTime = Date.now();
    this.updateStatus('running', 'RESTARTING...');
    socketDebugger.send(JSON.stringify({ path: 'restart' }));
    this.setActiveButton(this.playBtn);
  }
  
  togglePanel(panel) {
    // Remove active class from all panel buttons
    [this.consoleBtn, this.variablesBtn, this.reinitBtn, this.settingsBtn]
      .forEach(btn => btn.classList.remove('active'));
    
    // Add active class to clicked button
    const targetBtn = panel === 'console' ? this.consoleBtn :
                     panel === 'variables' ? this.variablesBtn :
                     panel === 'callstack' ? this.reinitBtn : this.settingsBtn;
    targetBtn.classList.add('active');
  }
  
  setActiveButton(activeBtn) {
    activeBtn.classList.add('active');
  }
  
  updateStatus(status, text) {
    this.statusElement.className = 'debugger-status status-' + status;
    
    const indicator = this.statusElement.querySelector('.status-indicator');
    const textSpan = this.statusElement.querySelector('span:last-child');
    
    indicator.className = 'status-indicator indicator-' + 
      (status === 'running' ? 'green' : status === 'paused' ? 'yellow' : 'red');
    textSpan.textContent = text;
  }

  setTimer(timestamp) {
      const date = new Date(timestamp).toLocaleString();
      this.timeElement.textContent = date;
  }
  
  padZero(num) {
    return num.toString().padStart(2, '0');
  }
  
  simulateBreakpoint() {
    this.breakpoints++;
    this.breakpointsElement.textContent = this.breakpoints.toString();
  }
  
  showNotification(message, type, time = 3000) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'debugger-notification notification-' + type;
    notification.textContent = message;
    
    this.mainContainer.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
      notification.style.transform = 'translateX(0)';
    }, 10);
    
    // Remove after 3 seconds
    setTimeout(() => {
      notification.style.transform = 'translateX(100%)';
      setTimeout(() => {
        if (notification.parentNode) {
          this.mainContainer.removeChild(notification);
        }
      }, 300);
    }, time);
  }
  
  openConsole(errorData) {
    // Remove existing modal if any
  const existingModal = this.shadow.querySelector('.console-modal');
    if (existingModal) {
      existingModal.remove();
    }
    
    // Create modal overlay
    const modal = document.createElement('div');
    modal.className = 'console-modal';
    
    // Create modal content
    const modalContent = document.createElement('div');
    modalContent.className = 'console-modal-content';
    
    // Create header
    const header = document.createElement('div');
    header.className = 'console-modal-header';
    
    const title = document.createElement('h3');
    title.className = 'console-modal-title';
    
    // Check if data is routes array
    const isRoutesData = Array.isArray(errorData) && errorData.length > 0 && errorData[0].hasOwnProperty('path');
    // Check if data is logs array
    const isLogsData = Array.isArray(errorData) && errorData.length > 0 && errorData[0].hasOwnProperty('timestamp');
    
    if (isLogsData) {
      title.textContent = 'DEBUG CONSOLE - LOGS HISTORY';
    } else if (isRoutesData) {
      title.textContent = 'DEBUG CONSOLE - ROUTES TABLE';
    } else {
      title.textContent = 'DEBUG CONSOLE - ERROR DETAILS';
    }
    
    const closeBtn = document.createElement('button');
    closeBtn.className = 'console-modal-close';
    closeBtn.innerHTML = 'X';
    closeBtn.addEventListener('click', () => this.closeConsole());
    
    header.appendChild(title);
    header.appendChild(closeBtn);
    
    // Create body
    const body = document.createElement('div');
    body.className = 'console-modal-body';
    
    if (isLogsData) {
      // Create logs summary
      const summary = document.createElement('div');
      summary.className = 'routes-summary';
      
      const summaryTitle = document.createElement('div');
      summaryTitle.className = 'routes-summary-title';
      summaryTitle.textContent = 'Console Logs History';
      
      const summaryInfo = document.createElement('div');
      const logCounts = errorData.reduce((acc, log) => {
        acc[log.type] = (acc[log.type] || 0) + 1;
        return acc;
      }, {});
      summaryInfo.textContent = 'Total Logs: ' + errorData.length + ' | ' + Object.entries(logCounts).map(([type, count]) => type.toUpperCase() + ': ' + count).join(' | ');
      
      summary.appendChild(summaryTitle);
      summary.appendChild(summaryInfo);
      
      // Create clear button with SVG icon
      const clearBtn = document.createElement('button');
      clearBtn.className = 'console-clear-btn';
      clearBtn.innerHTML = `
        Clear All
      `;
      clearBtn.title = 'Clear all logs';
      clearBtn.addEventListener('click', () => this.clearAllLogs());
      
      // Create button container
      const buttonContainer = document.createElement('div');
      buttonContainer.className = 'console-button-container';
      buttonContainer.appendChild(clearBtn);
      
      // Create logs table
      const table = document.createElement('table');
      table.className = 'routes-table';
      
      // Create table header
      const thead = document.createElement('thead');
      const headerRow = document.createElement('tr');

      const headers = ['#', 'Time', 'Type', 'Message'];
      headers.forEach(headerText => {
        const th = document.createElement('th');
        th.textContent = headerText;
        headerRow.appendChild(th);
      });
      
      thead.appendChild(headerRow);
      table.appendChild(thead);
      
      // Create table body
      const tbody = document.createElement('tbody');
      
      // Sort logs by timestamp (newest first)
      const sortedLogs = [...errorData].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
      
      sortedLogs.forEach((log, index) => {
        const row = document.createElement('tr');
        
        // #
        const indexCell = document.createElement('td');
        indexCell.textContent = (index + 1).toString();
        row.appendChild(indexCell);
        
        // Time
        const timeCell = document.createElement('td');
        const date = new Date(log.timestamp);
        timeCell.textContent = date.toLocaleTimeString();
        timeCell.title = date.toLocaleString();
        row.appendChild(timeCell);
        
        // Type
        const typeCell = document.createElement('td');
        const typeBadge = document.createElement('span');
        typeBadge.className = 'method-badge method-' + log.type.toLowerCase();
        typeBadge.textContent = log.type.toUpperCase();
        typeCell.appendChild(typeBadge);
        row.appendChild(typeCell);
        
        // Message
        const messageCell = document.createElement('td');
        messageCell.textContent = log.message;
        messageCell.style.wordBreak = 'break-word';
        messageCell.style.maxWidth = '400px';
        row.appendChild(messageCell);
        
        tbody.appendChild(row);
      });
      
      table.appendChild(tbody);
      
      // Assemble logs view
      body.appendChild(summary);
      body.appendChild(buttonContainer);
      body.appendChild(table);
    } else if (isRoutesData) {
      // Create routes summary
      const summary = document.createElement('div');
      summary.className = 'routes-summary';
      
      const summaryTitle = document.createElement('div');
      summaryTitle.className = 'routes-summary-title';
      summaryTitle.textContent = 'Routes Summary';
      
      const summaryInfo = document.createElement('div');
      summaryInfo.textContent = 'Total Routes: ' + errorData.length + ' | API: ' + errorData.filter(function(r) { return r.type === 'API'; }).length + ' | WEB: ' + errorData.filter(function(r) { return r.type === 'WEB'; }).length;
      
      summary.appendChild(summaryTitle);
      summary.appendChild(summaryInfo);
      
      // Create routes table
      const table = document.createElement('table');
      table.className = 'routes-table';
      
      // Create table header
      const thead = document.createElement('thead');
      const headerRow = document.createElement('tr');

      const headers = ['#', 'Method', 'Path', 'Type', 'Auth', 'Controller', 'Hosts'];
      headers.forEach(headerText => {
        const th = document.createElement('th');
        th.textContent = headerText;
        headerRow.appendChild(th);
      });
      
      thead.appendChild(headerRow);
      table.appendChild(thead);
      
      // Create table body
      const tbody = document.createElement('tbody');
      
      errorData.forEach(route => {
        const row = document.createElement('tr');
        // #
        const indexCell = document.createElement('td');
        indexCell.textContent = route['#'] || '-';
        row.appendChild(indexCell);
        // Method
        const methodCell = document.createElement('td');
        const methodBadge = document.createElement('span');
        methodBadge.className = 'method-badge method-' + route.method.toLowerCase();
        methodBadge.textContent = route.method;
        methodCell.appendChild(methodBadge);
        row.appendChild(methodCell);
        
        // Path
        const pathCell = document.createElement('td');
        pathCell.textContent = "Path: " + (route.path || route.fullPath || '-');
        if(route.key){
          pathCell.appendChild(document.createElement('br'));
          pathCell.appendChild(document.createTextNode('Key: '+route.key));
        }
        row.appendChild(pathCell);
        
        // Type
        const typeCell = document.createElement('td');
        const typeBadge = document.createElement('span');
        typeBadge.className = 'type-badge';
        typeBadge.textContent = route.type || 'UNKNOWN';
        typeCell.appendChild(typeBadge);
        row.appendChild(typeCell);
        
        // Auth
        const authCell = document.createElement('td');
        const authIndicator = document.createElement('span');
        authIndicator.className = 'auth-indicator auth-' + route.hasAuth;
        authCell.appendChild(authIndicator);
        authCell.appendChild(document.createTextNode(route.hasAuth ? 'Yes' : 'No'));
        row.appendChild(authCell);
        
        // Controller
        const controllerCell = document.createElement('td');
        controllerCell.textContent = route.controller || route.index || '-';
        row.appendChild(controllerCell);
        
        // Hosts
        const hostsCell = document.createElement('td');
        hostsCell.textContent = Array.isArray(route.hosts) ? route.hosts.join(', ') : (route.hosts || '*');
        row.appendChild(hostsCell);
        
        tbody.appendChild(row);
      });
      
      table.appendChild(tbody);
      
      // Assemble routes view
      body.appendChild(summary);
      body.appendChild(table);
    } else {
      // Handle error data (existing logic)
      // Parse error data
      let parsedError;
      try {
        parsedError = typeof errorData === 'string' ? JSON.parse(errorData) : errorData;
      } catch (e) {
        parsedError = { message: errorData || 'Unknown error', raw: errorData };
      }
      
      // Create error summary
      const summary = document.createElement('div');
      summary.className = 'error-summary';
      
      const errorTitle = document.createElement('div');
      errorTitle.className = 'error-title';
      errorTitle.textContent = parsedError.error || parsedError.message || parsedError.type || 'Runtime Error';
      
      const errorMessage = document.createElement('div');
      errorMessage.className = 'error-message';
      errorMessage.textContent = parsedError.message || parsedError.description || 'An error occurred during execution';
      
      summary.appendChild(errorTitle);
      summary.appendChild(errorMessage);
      
      // Create tabs
      const tabs = document.createElement('div');
      tabs.className = 'error-tabs';
      
      const jsonTab = document.createElement('button');
      jsonTab.className = 'error-tab active';
      jsonTab.textContent = 'JSON Data';
      jsonTab.addEventListener('click', () => this.switchTab('json'));
      
      const stackTab = document.createElement('button');
      stackTab.className = 'error-tab';
      stackTab.textContent = 'Stack Trace';
      stackTab.addEventListener('click', () => this.switchTab('stack'));
      
      const detailsTab = document.createElement('button');
      detailsTab.className = 'error-tab';
      detailsTab.textContent = 'Details';
      detailsTab.addEventListener('click', () => this.switchTab('details'));
      
      tabs.appendChild(jsonTab);
      tabs.appendChild(stackTab);
      tabs.appendChild(detailsTab);
      
      // Create tab contents
      const jsonContent = document.createElement('div');
      jsonContent.className = 'tab-content active';
      jsonContent.id = 'json-tab';
      
      const jsonCode = document.createElement('pre');
      jsonCode.className = 'error-json';
      jsonCode.textContent = JSON.stringify(parsedError, null, 2);
      jsonContent.appendChild(jsonCode);
      
      const stackContent = document.createElement('div');
      stackContent.className = 'tab-content';
      stackContent.id = 'stack-tab';
      
      const stackTrace = document.createElement('pre');
      stackTrace.className = 'stack-trace';
      stackTrace.textContent = parsedError.stack || parsedError.trace || parsedError.stackTrace || 'No stack trace available';
      stackContent.appendChild(stackTrace);
      
      const detailsContent = document.createElement('div');
      detailsContent.className = 'tab-content';
      detailsContent.id = 'details-tab';
      
      const detailsInfo = document.createElement('div');
      detailsInfo.innerHTML = 
        '<div class="error-section">' +
          '<div class="error-section-title">Error Type</div>' +
          '<div>' + (parsedError.type || parsedError.error || 'Unknown') + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">File</div>' +
          '<div>' + (parsedError.file || parsedError.filename || 'Unknown') + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">Line</div>' +
          '<div>' + (parsedError.line || parsedError.lineNumber || 'Unknown') + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">Timestamp</div>' +
          '<div>' + new Date().toLocaleString() + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">Session</div>' +
          '<div>' + (parsedError.session || 'Current Debug Session') + '</div>' +
        '</div>';
      detailsContent.appendChild(detailsInfo);
      
      // Assemble error view
      body.appendChild(summary);
      body.appendChild(tabs);
      body.appendChild(jsonContent);
      body.appendChild(stackContent);
      body.appendChild(detailsContent);
    }
    
    modalContent.appendChild(header);
    modalContent.appendChild(body);
    modal.appendChild(modalContent);
    
    // Add to DOM
  this.mainContainer.appendChild(modal);
    
    // Show modal with animation
    setTimeout(() => {
      modal.classList.add('active');
    }, 10);
    
    // Close on background click
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        this.closeConsole();
      }
    });
    
    // Close on Escape key
  const escapeHandler = (e) => {
      if (e.key === 'Escape') {
        this.closeConsole();
        document.removeEventListener('keydown', escapeHandler);
      }
    };
    document.addEventListener('keydown', escapeHandler);
  }
  
  closeConsole() {
  const modal = this.shadow.querySelector('.console-modal');
    if (modal) {
      modal.classList.remove('active');
      setTimeout(() => {
        if (modal.parentNode) {
          modal.remove();
        }
      }, 300);
    }
  }
  
  switchTab(tabName) {
    // Remove active class from all tabs and contents
  this.shadow.querySelectorAll('.error-tab').forEach(tab => tab.classList.remove('active'));
  this.shadow.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // Add active class to selected tab and content
    event.target.classList.add('active');
  const content = this.shadow.querySelector('#' + tabName + '-tab');
  if (content) content.classList.add('active');
  }
}


// Initialize debugger when DOM is ready
function initDebuggerFinch() {
  window.debugger = new DebuggerStatusBar();
}

// Initialize based on document state
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initDebuggerFinch);
} else {
  initDebuggerFinch();
}

// Global function to open console with error data
window.openConsole = function(errorData) {
  if (window.debugger) {
    window.debugger.openConsole(errorData);
  } else {
    console.error('Debugger not initialized yet');
  }
};

var socketDebuggerEvents = {
    connected: function (data) {
      this.output({ data: 'Web Socket connected' });
      console.log('Web Socket connected');
      // Update debugger status to running when connected
      if (window.debugger) {
        window.debugger.updateStatus('running', 'RUNNING');
        window.debugger.container.classList.remove('disconnected');
      }
    },

    close: function (e) {
        this.output({ data: 'Web Socket closed' });
        console.log('Web Socket closed');
        // Update debugger status to stopped when disconnected
        if (window.debugger) {
          window.debugger.updateStatus('stopped', 'STOPPED');
          window.debugger.container.classList.add('disconnected');
          window.debugger.showNotification('WebSocket disconnected - Reconnecting in 3s...', 'error', 3000);

          // Try to reconnect after 3 seconds
          setTimeout(() => {
            window.debugger.showNotification('Attempting to reconnect...', 'warning');
            initWebSocketConnection();
          }, 3000);
        }
    },

    output: function (data) {
        if (typeof socketDebuggerOutput === 'undefined') {
          window.socketDebuggerOutput = 0;
        }
        window.socketDebuggerOutput++;
        console.log(data);
    },

    clients: function (data) {
        console.log('Web Socket clients:', data);
    },

    streamServer: function (data) {
        console.log('Web Socket clients:', data);
    },

    restartStarted: function (data) {
        window.debugger.showNotification('Debugger restarting...', 'error', 10000);
        setTimeout(() => {
          window.location.reload();
        }, 11000);
    },

    updateMemory: function (data) {
        window.debugger.memoryElement.textContent = `\${data.data.memory}  |  MAX: \${data.data.max_memory}`;
        window.debugger.setTimer(data.timestamp);
    },

    console: function (data) {
        window.debugger.openConsole(data.data.error);
    },

    update_languages: function (data) {
        window.debugger.showNotification('Language updated', 'info');
    },

    update_template: function (data) {
        window.debugger.showNotification(data.data.message, 'info');
    },

    get_routes: function (data) {
      var routes = data.data.routes;
      window.debugger.openConsole(routes);
    },

    log: function (data) {
        if (window.debugger) {
            window.debugger.showLog(data.data.message, data.data.type);
        }
    }
}

var socketDebugger = null;
var socketDebuggerOutput = 0;

function initWebSocketConnection() {
  try {
    if (socketDebugger && socketDebugger.readyState === WebSocket.OPEN) {
      socketDebugger.close();
    }
    
    socketDebugger = new WebSocket("/debugger");
    
    socketDebugger.onopen = function(e) {
      socketDebuggerEvents.connected({ data: 'Connected' });
    };
    
    socketDebugger.onmessage = function (e) {
        var data = JSON.parse(e.data);
        
        if (socketDebuggerEvents[data.path]) {
            socketDebuggerEvents[data.path](data);
        }
    };

    socketDebugger.onclose = function (e) {
        socketDebuggerEvents.close(e);
    };
    
    socketDebugger.onerror = function (e) {
        console.error('WebSocket error:', e);
        if (window.debugger) {
          window.debugger.showNotification('WebSocket connection error', 'error');
        }
    };
  } catch (error) {
    console.error('Failed to create WebSocket connection:', error);
    if (window.debugger) {
      window.debugger.showNotification('Failed to connect to WebSocket', 'error');
    }
  }
}

// Initialize WebSocket connection
initWebSocketConnection();
""";

  @override
  Tag Function(Map args)? generateHtml;
}
