import React, { useState, useEffect } from 'react';
import { Wifi, Battery, Signal, ChevronLeft, Home } from 'lucide-react';

interface DeviceFrameProps {
  children: React.ReactNode;
  activeScreenTitle?: string;
  onHomePress?: () => void;
  onBackPress?: () => void;
  canGoBack?: boolean;
}

export const DeviceFrame: React.FC<DeviceFrameProps> = ({
  children,
  activeScreenTitle,
  onHomePress,
  onBackPress,
  canGoBack = false
}) => {
  const [time, setTime] = useState('12:45');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false }));
    };
    updateTime();
    const timer = setInterval(updateTime, 30000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="relative mx-auto my-3 flex flex-col items-center">
      {/* Outer Phone Shell */}
      <div className="relative w-[385px] h-[790px] bg-[#1a1b26] rounded-[52px] p-3 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.8),0_0_0_12px_#2a2c3d,0_0_0_14px_#1e202f] border border-white/10 flex flex-col overflow-hidden select-none">
        
        {/* Dynamic Island / Notch */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 w-28 h-6 bg-black rounded-full z-50 flex items-center justify-between px-2.5 shadow-md border border-white/5">
          <div className="w-2.5 h-2.5 rounded-full bg-[#111] border border-white/10 flex items-center justify-center">
            <div className="w-1 h-1 rounded-full bg-blue-900/60" />
          </div>
          <div className="w-1.5 h-1.5 rounded-full bg-emerald-500/80 animate-pulse" title="AwareScroll Guard Active" />
        </div>

        {/* Status Bar */}
        <div className="h-7 w-full flex items-center justify-between px-5 text-xs text-white/90 font-medium z-40 bg-transparent pt-1">
          <span className="tracking-tight text-[13px]">{time}</span>
          <div className="flex items-center space-x-1.5 text-white/80">
            <Signal className="w-3.5 h-3.5" />
            <Wifi className="w-3.5 h-3.5" />
            <Battery className="w-4 h-4 fill-white/80" />
          </div>
        </div>

        {/* App Bar / Navigation Header (Optional within native frame) */}
        {activeScreenTitle && (
          <div className="h-11 flex items-center justify-between px-3 border-b border-white/5 bg-[#171A2E]/80 backdrop-blur z-30">
            <div className="flex items-center space-x-2">
              {canGoBack && onBackPress && (
                <button
                  onClick={onBackPress}
                  className="p-1 rounded-full hover:bg-white/10 text-white/80 transition-colors"
                  title="Back"
                >
                  <ChevronLeft className="w-5 h-5" />
                </button>
              )}
              <h2 className="font-semibold text-sm text-white tracking-wide">{activeScreenTitle}</h2>
            </div>
            <div className="flex items-center space-x-1">
              <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-400 border border-blue-500/30">
                AwareScroll
              </span>
            </div>
          </div>
        )}

        {/* Viewport Content Area */}
        <div className="flex-1 overflow-y-auto overflow-x-hidden relative bg-[#0E1021] text-slate-100 flex flex-col">
          {children}
        </div>

        {/* Bottom Gesture Bar */}
        <div className="h-6 w-full flex items-center justify-center bg-[#0E1021] pt-1 z-40">
          <button
            onClick={onHomePress}
            className="w-32 h-1 bg-white/40 hover:bg-white/70 active:scale-95 rounded-full transition-all cursor-pointer"
            title="Home Gesture"
          />
        </div>
      </div>

      {/* Device Model Label */}
      <div className="mt-2 text-xs text-slate-400 flex items-center space-x-2">
        <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
        <span>Simulated Android 14 Client • Target SDK 34</span>
      </div>
    </div>
  );
};
