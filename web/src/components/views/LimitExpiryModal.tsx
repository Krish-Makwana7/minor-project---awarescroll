import React from 'react';

interface LimitExpiryModalProps {
  limitMinutes: number;
  actualMinutes: number;
  appName?: string;
  onCloseApp: () => void;
  onContinue: () => void;
}

export const LimitExpiryModal: React.FC<LimitExpiryModalProps> = ({
  limitMinutes,
  appName = 'Instagram',
  onCloseApp,
  onContinue
}) => {
  const formattedTimer = `${limitMinutes.toString().padStart(2, '0')}:00`;

  return (
    <div className="absolute inset-0 z-50 bg-[#0E1021]/75 backdrop-blur-[8px] flex flex-col justify-end animate-in fade-in duration-200 select-none text-slate-800">
      
      {/* 24px Top-Radius Reflective Bottom Sheet */}
      <div 
        className="w-full bg-white shadow-2xl rounded-t-[28px] pt-4 px-5 pb-8 flex flex-col items-center z-10 max-h-[92%] overflow-y-auto relative"
      >
        {/* Warm Accent Grab Handle in #FF9F43 */}
        <div className="w-12 h-1.5 rounded-full mb-3.5 mx-auto bg-[#FF9F43]" />

        {/* Dynamic Split Header with Edge-Cropped Circular Orange Dial */}
        <div className="w-full flex items-center justify-between gap-3 mb-3 bg-slate-50 p-3 rounded-2xl border border-slate-200/60">
          {/* Circular Orange Dial with ticks */}
          <div className="relative flex items-center justify-center shrink-0 w-24 h-24">
            <svg className="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
              <circle cx="50" cy="50" r="40" stroke="#FFDCC2" strokeWidth="7" fill="none" opacity="0.5" />
              <circle cx="50" cy="50" r="40" stroke="#FF9F43" strokeWidth="7" fill="none" strokeDasharray="251.2" strokeDashoffset="0" strokeLinecap="round" />
              <line x1="50" y1="14" x2="50" y2="19" stroke="#824700" strokeWidth="2" strokeLinecap="round" />
              <line x1="86" y1="50" x2="81" y2="50" stroke="#824700" strokeWidth="2" strokeLinecap="round" />
              <line x1="50" y1="86" x2="50" y2="81" stroke="#824700" strokeWidth="2" strokeLinecap="round" />
              <line x1="14" y1="50" x2="19" y2="50" stroke="#824700" strokeWidth="2" strokeLinecap="round" />
              <circle cx="50" cy="10" r="5.5" fill="#FF9F43" stroke="#FFFFFF" strokeWidth="2" />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
              <span className="font-mono font-semibold text-[16px] text-[#824700] tracking-tight leading-none">
                {formattedTimer}
              </span>
              <span className="text-[9px] font-bold text-[#FF9F43] uppercase tracking-wider mt-0.5">
                LIMIT
              </span>
            </div>
          </div>

          {/* Bold Right-Aligned Reflection Typography */}
          <div className="flex-1 flex flex-col text-right pl-1">
            <div className="inline-flex items-center justify-end gap-1 mb-1">
              <span className="inline-block w-2 h-2 rounded-full bg-[#FF9F43] animate-pulse" />
              <span className="text-[10px] font-mono font-semibold text-[#824700] uppercase tracking-wider">
                LIMIT REACHED
              </span>
            </div>
            <h2 className="text-[16px] font-bold text-slate-900 tracking-tight leading-tight uppercase">
              YOUR {limitMinutes} MINUTES ARE COMPLETE.<br />
              <span className="text-slate-800">CLOSE OR CONTINUE?</span>
            </h2>
            <p className="text-[12px] font-medium mt-1 leading-snug text-[#3A5BFF]">
              Choose whether to end your session or answer a quick check-in.
            </p>
          </div>
        </div>

        {/* Flat Vector Chubby Grey Cat Tangled in Cable */}
        <div className="w-full bg-slate-50 rounded-2xl p-2.5 flex flex-col items-center justify-center relative overflow-hidden mb-3 border border-slate-200/60">
          <div className="relative w-full h-32 flex items-center justify-center select-none">
            <svg className="w-full h-full max-w-[260px] drop-shadow-xs" viewBox="0 0 280 145" fill="none" xmlns="http://www.w3.org/2000/svg">
              <line x1="20" y1="35" x2="90" y2="35" stroke="#C4C5D9" strokeWidth="2" strokeLinecap="round" />
              <rect x="30" y="18" width="8" height="17" rx="1.5" fill="#E1E0FF" stroke="#747688" strokeWidth="1.2" />
              <rect x="41" y="14" width="10" height="21" rx="1.5" fill="#BAC3FF" stroke="#747688" strokeWidth="1.2" />
              <rect x="54" y="20" width="7" height="15" rx="1.5" fill="#FFDCC2" stroke="#747688" strokeWidth="1.2" />
              <path d="M 72 35 C 70 28, 77 24, 76 18 C 79 24, 82 28, 80 35" fill="#00B894" opacity="0.8" />
              <path d="M 195 25 Q 200 20 205 25 Q 210 30 215 25" stroke="#FFB77A" strokeWidth="1.5" strokeLinecap="round" fill="none" />
              <circle cx="230" cy="28" r="2" fill="#3A5BFF" opacity="0.5" />
              <circle cx="240" cy="20" r="3.5" fill="#FF9F43" opacity="0.5" />
              
              <path d="M 25 125 C 25 105, 255 105, 255 125 Z" fill="#E7E6FF" opacity="0.5" />
              <ellipse cx="140" cy="118" rx="78" ry="20" fill="#00B894" />
              <ellipse cx="140" cy="116" rx="74" ry="16" fill="#00D2A4" />
              <circle cx="140" cy="82" r="32" fill="#94A3B8" />
              <ellipse cx="140" cy="98" rx="35" ry="22" fill="#94A3B8" />
              <polygon points="118,65 110,46 130,58" fill="#94A3B8" />
              <polygon points="119,62 113,50 126,58" fill="#FCA5A5" />
              <polygon points="162,65 170,46 150,58" fill="#94A3B8" />
              <polygon points="161,62 167,50 154,58" fill="#FCA5A5" />
              <ellipse cx="140" cy="96" rx="20" ry="13" fill="#CBD5E1" />
              <circle cx="130" cy="78" r="3.5" fill="#0F172A" />
              <circle cx="150" cy="78" r="3.5" fill="#0F172A" />
              <polygon points="138,84 142,84 140,86.5" fill="#F43F5E" />
              <path d="M 140 86.5 Q 137 89 134 88 M 140 86.5 Q 143 89 146 88" stroke="#0F172A" strokeWidth="1.4" strokeLinecap="round" fill="none" />
              <path d="M 75 118 C 70 85, 115 62, 140 64 C 175 66, 185 105, 160 120 C 130 135, 105 110, 115 88 C 125 65, 168 85, 180 112" fill="none" stroke="#3A5BFF" strokeWidth="2.8" strokeLinecap="round" />
            </svg>
          </div>
          <p className="text-[11px] text-slate-500 text-center mt-1">
            Caught in the scroll loop? Gentle reminder: life is unfolding offline.
          </p>
        </div>

        {/* Positive reinforcement notice */}
        <div className="w-full bg-emerald-50/70 p-3 rounded-2xl mb-3 flex items-center gap-2.5 border border-emerald-200/60">
          <div className="w-8 h-8 rounded-xl bg-emerald-100 flex items-center justify-center shrink-0">
            <span className="material-symbols-outlined text-[#00B894] text-[20px]">thumb_up</span>
          </div>
          <p className="text-xs text-emerald-900 leading-snug font-medium">
            Clicking <strong>Close</strong> stores a positive success in your personal dashboard database!
          </p>
        </div>

        {/* Dual Actions: CLOSE or CONTINUE */}
        <div className="w-full flex flex-col gap-2.5">
          {/* CLOSE Button (Positive Response Saved in Database) */}
          <button
            onClick={onCloseApp}
            className="w-full h-12 rounded-full flex items-center justify-center gap-2 text-xs font-bold uppercase tracking-wider shadow-md hover:opacity-95 transition-all active:scale-[0.98] text-white bg-[#00B894] cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">check_circle</span>
            <span>CLOSE (Save Positive Adherence)</span>
          </button>

          {/* CONTINUE Button (Opens Rapid 3-5s Feedback Form) */}
          <button
            onClick={onContinue}
            className="w-full h-12 rounded-full flex items-center justify-center gap-1.5 text-xs font-bold uppercase tracking-wider transition-all active:scale-[0.98] bg-transparent hover:bg-orange-50 text-[#FF9F43] border-2 border-[#FF9F43] cursor-pointer"
          >
            <span>CONTINUE (Quick 3s Feedback Form)</span>
            <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
          </button>
        </div>

        <div className="flex items-center gap-1.5 mt-2.5 text-slate-400 opacity-80">
          <span className="material-symbols-outlined text-[14px]">lock_clock</span>
          <span className="text-[11px] font-mono">AwareScroll Behavioral Self-Regulation</span>
        </div>

      </div>
    </div>
  );
};
