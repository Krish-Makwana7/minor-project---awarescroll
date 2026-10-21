import React, { useState, useEffect } from 'react';
import { MotivationalQuote } from '../../types';

interface MotivationalQuoteViewProps {
  quote: MotivationalQuote;
  onStartFreeUsage: () => void;
  onCloseNow: () => void;
}

export const MotivationalQuoteView: React.FC<MotivationalQuoteViewProps> = ({
  quote,
  onStartFreeUsage,
  onCloseNow
}) => {
  return (
    <div className="absolute inset-0 z-50 bg-[#0E1021] text-white flex flex-col justify-between p-6 select-none animate-in fade-in duration-300">
      
      {/* Top Header Badge */}
      <div className="flex items-center justify-between pt-2">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 border border-white/20 text-[#FF9F43] text-[10px] font-mono font-bold uppercase tracking-wider">
          <span className="material-symbols-outlined text-[14px]">psychology</span>
          <span>AWARESCROLL MINDSET CALIBRATION</span>
        </div>

        <span className="text-[10px] font-mono font-bold text-slate-400">
          5M EXTENSION PENDING
        </span>
      </div>

      {/* Main Quote Card */}
      <div className="my-auto flex flex-col items-center text-center space-y-5 px-2">
        <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#3A5BFF] to-[#FF9F43] flex items-center justify-center shadow-lg shadow-blue-500/30">
          <span className="material-symbols-outlined text-white text-[28px]">format_quote</span>
        </div>

        <div className="space-y-3">
          <blockquote className="text-xl sm:text-2xl font-black text-white tracking-tight leading-snug">
            "{quote.text}"
          </blockquote>

          <div className="flex items-center justify-center space-x-2">
            <div className="h-0.5 w-6 bg-[#FF9F43]" />
            <span className="font-mono text-xs font-bold text-[#FF9F43] uppercase tracking-wider">
              {quote.author}
            </span>
            <div className="h-0.5 w-6 bg-[#FF9F43]" />
          </div>
        </div>

        {/* Personalized Rationale Pill */}
        <div className="bg-white/5 border border-white/10 rounded-2xl p-3 max-w-xs text-center space-y-1">
          <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-slate-400 block">
            Generated For Your Current State
          </span>
          <p className="text-xs text-slate-300 leading-relaxed">
            {quote.rationale}
          </p>
        </div>

        {/* 5-Min Free Time Policy Notice */}
        <div className="bg-amber-500/10 border border-amber-500/30 rounded-xl p-3 max-w-xs flex items-center space-x-2 text-left">
          <span className="material-symbols-outlined text-amber-400 text-[20px] shrink-0">timer</span>
          <p className="text-[11px] text-amber-200 leading-snug">
            You will receive <strong>5 minutes of free usage</strong>. When the 5 minutes end, the app will <strong>automatically close</strong>.
          </p>
        </div>
      </div>

      {/* Dual Actions */}
      <div className="flex flex-col space-y-2.5 pb-2">
        {/* Primary Action: Start 5-Minute Free Extension */}
        <button
          onClick={onStartFreeUsage}
          className="w-full h-13 bg-[#3A5BFF] hover:bg-blue-600 active:scale-[0.98] text-white font-extrabold text-xs uppercase tracking-wider rounded-2xl shadow-xl shadow-blue-500/30 transition-all flex items-center justify-center space-x-2 cursor-pointer"
        >
          <span className="material-symbols-outlined text-[18px]">play_arrow</span>
          <span>START FINAL 5-MINUTE USAGE (AUTO-CLOSE ACTIVE)</span>
        </button>

        {/* Alternate Action: Change mind & close right away */}
        <button
          onClick={onCloseNow}
          className="w-full py-2.5 text-slate-400 hover:text-white font-semibold text-xs tracking-wider transition-colors cursor-pointer"
        >
          I've changed my mind, Close Now (Save Self-Control Points)
        </button>
      </div>

    </div>
  );
};
