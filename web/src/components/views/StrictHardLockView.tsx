import React from 'react';

interface StrictHardLockViewProps {
  totalMinutes: number;
  initialPurpose: string;
  appName?: string;
  onReturnToDashboard: () => void;
  onStartNewSession: () => void;
}

export const StrictHardLockView: React.FC<StrictHardLockViewProps> = ({
  totalMinutes,
  initialPurpose,
  appName = 'Instagram',
  onReturnToDashboard,
  onStartNewSession
}) => {
  return (
    <div className="absolute inset-0 z-50 bg-[#0E1021] text-white flex flex-col justify-between p-6 select-none animate-in fade-in duration-300">
      
      {/* Top Tag */}
      <div className="flex items-center justify-between pt-2">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-red-500/20 border border-red-500/30 text-[#E5484D] text-[10px] font-mono font-bold uppercase tracking-wider">
          <span className="material-symbols-outlined text-[14px]">lock</span>
          <span>STRICT HARD LOCK • AUTOMATIC CLOSURE</span>
        </div>

        <span className="text-[10px] font-mono font-bold text-slate-400">
          COOLDOWN ACTIVE
        </span>
      </div>

      {/* Main Lock Card */}
      <div className="my-auto flex flex-col items-center text-center space-y-4 px-2">
        <div className="w-20 h-20 rounded-3xl bg-red-500/10 border border-red-500/30 flex items-center justify-center text-[#E5484D] shadow-xl shadow-red-500/10">
          <span className="material-symbols-outlined text-[42px]">do_not_disturb_on</span>
        </div>

        <div>
          <h2 className="text-2xl font-black text-white tracking-tight">
            Feed Automatically Closed
          </h2>
          <p className="text-xs text-slate-300 max-w-[280px] mx-auto mt-1 leading-relaxed">
            Your 5 minutes of post-quote free usage have expired. AwareScroll has locked {appName} to protect your focus.
          </p>
        </div>

        {/* Session Recap Pill */}
        <div className="w-full max-w-xs bg-white/5 border border-white/10 rounded-2xl p-4 text-left space-y-2">
          <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-slate-400 block">
            Completed Session Summary
          </span>

          <div className="flex items-center justify-between text-xs pt-1 border-t border-white/5">
            <span className="text-slate-400">Target App:</span>
            <span className="font-bold text-white">{appName}</span>
          </div>

          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-400">Total Duration:</span>
            <span className="font-mono font-bold text-[#FF9F43]">{totalMinutes}m logged</span>
          </div>

          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-400">Initial Intention:</span>
            <span className="font-medium text-slate-200 truncate max-w-[150px]">"{initialPurpose}"</span>
          </div>
        </div>

        <p className="text-[11px] text-slate-400 max-w-xs">
          To access social media again, the cycle resets: you must set a new limit and purpose from the beginning.
        </p>
      </div>

      {/* Actions */}
      <div className="flex flex-col space-y-2.5 pb-2">
        <button
          onClick={onReturnToDashboard}
          className="w-full h-13 bg-[#3A5BFF] hover:bg-blue-600 active:scale-[0.98] text-white font-extrabold text-xs uppercase tracking-wider rounded-2xl shadow-xl shadow-blue-500/30 transition-all flex items-center justify-center space-x-2 cursor-pointer"
        >
          <span className="material-symbols-outlined text-[18px]">dashboard</span>
          <span>RETURN TO DASHBOARD</span>
        </button>

        <button
          onClick={onStartNewSession}
          className="w-full py-2.5 text-slate-400 hover:text-white font-semibold text-xs tracking-wider transition-colors cursor-pointer"
        >
          Set New Limit for Another App →
        </button>
      </div>

    </div>
  );
};
