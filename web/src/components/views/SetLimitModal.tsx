import React, { useState } from 'react';
import { StorageService } from '../../services/storage';
import { ClientSessionPurpose } from '../../types';

interface SetLimitModalProps {
  isOpen: boolean;
  appName?: string;
  onClose: () => void;
  onLaunchInstagram: (limitMinutes: number, purpose: string) => void;
  canCancel?: boolean;
}

export const SetLimitModal: React.FC<SetLimitModalProps> = ({
  isOpen,
  appName = 'Instagram',
  onClose,
  onLaunchInstagram,
  canCancel = true
}) => {
  const goal = StorageService.getGoal();
  const [limitMinutes, setLimitMinutes] = useState<number>(goal.defaultSessionLimit || 5);
  const [selectedPurpose, setSelectedPurpose] = useState<ClientSessionPurpose>('Reply to a message');
  const [customPurpose, setCustomPurpose] = useState<string>('');
  const [error, setError] = useState<string | null>(null);

  if (!isOpen) return null;

  const presets = [3, 5, 10, 15];
  
  // Client's exact 7 requested purposes
  const clientPurposes: { label: ClientSessionPurpose; icon: string }[] = [
    { label: 'Reply to a message', icon: 'chat' },
    { label: 'Checking someone\'s reply', icon: 'mark_chat_unread' },
    { label: 'Check updates', icon: 'notifications' },
    { label: 'Nothing to do, so watch reels', icon: 'movie' },
    { label: 'Finished all tasks, want to watch reels', icon: 'task_alt' },
    { label: 'Study or research', icon: 'menu_book' },
    { label: 'Opened automatically / out of habit', icon: 'repeat' }
  ];

  const effectivePurpose = customPurpose.trim() ? customPurpose : selectedPurpose;

  const handlePresetSelect = (preset: number) => {
    setLimitMinutes(preset);
    setError(null);
  };

  const handleConfirm = () => {
    if (error || limitMinutes < 1) return;
    StorageService.saveConfiguredLimit(limitMinutes);
    onLaunchInstagram(limitMinutes, effectivePurpose);
  };

  const formattedTimer = `${limitMinutes.toString().padStart(2, '0')}:00`;

  return (
    <div className="fixed inset-0 z-50 bg-[#0E1021]/65 backdrop-blur-[6px] flex items-center justify-center p-4 animate-in fade-in duration-200 select-none">
      <div 
        className="w-full max-w-[420px] bg-white rounded-[28px] shadow-[0_20px_50px_rgba(0,0,0,0.35)] p-5 flex flex-col gap-3.5 border border-white/60 relative overflow-hidden max-h-[94%] overflow-y-auto"
        role="dialog"
        aria-modal="true"
      >
        {/* Top Grab Handle */}
        <div className="w-full flex items-center justify-center -mt-1">
          <div className="w-10 h-1 bg-slate-200 rounded-full" />
        </div>

        {canCancel && (
          <button
            onClick={onClose}
            className="absolute top-4 right-4 w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-500 hover:text-slate-800 transition-all cursor-pointer"
            aria-label="Close"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        )}

        {/* Mascot Header */}
        <div className="flex items-center justify-center">
          <div className="relative w-40 h-24 flex items-center justify-center">
            <svg className="w-full h-full overflow-visible" fill="none" viewBox="0 0 190 120" xmlns="http://www.w3.org/2000/svg">
              <path d="M22 68C16 42 38 16 75 12C122 8 168 22 172 60C176 92 144 116 104 116C52 116 26 95 22 68Z" fill="#F0F4FF" opacity="0.9" />
              <circle cx="160" cy="28" fill="#FED7AA" r="3" />
              <rect fill="#64748B" height="24" rx="2" width="34" x="84" y="66" />
              <rect fill="#F8FAFC" height="20" rx="1" width="30" x="86" y="68" />
              <path d="M44 94C44 74 55 63 67 63C79 63 85 74 85 94H44Z" fill="#FF9F43" />
              <circle cx="65" cy="76" fill="#5C2900" r="1.5" />
              <path d="M116 94C116 76 127 65 139 65C151 65 159 76 159 94H116Z" fill="#F8FAFC" stroke="#E2E8F0" strokeWidth="1.2" />
              <path d="M125 67C128 61 135 62 138 67" fill="#3A5BFF" />
              <circle cx="98" cy="93" fill="#00B894" r="9.5" />
              <path d="M93 91C96 88 101 89 104 92" fill="none" stroke="#A7F3D0" strokeWidth="1.6" />
            </svg>
          </div>
        </div>

        {/* Title */}
        <div className="text-center flex flex-col items-center gap-0.5">
          <span className="text-[10px] font-bold tracking-wider text-[#3A5BFF] uppercase font-mono">
            SET LIMIT • {appName.toUpperCase()}
          </span>
          <h2 className="text-[22px] font-bold text-[#0E1021] tracking-tight">
            Set Your Limit
          </h2>
          <p className="text-xs text-slate-500 max-w-[290px] leading-relaxed">
            The moment you open {appName}, set your target limit to stay mindful.
          </p>
        </div>

        {/* Time Limit Input Card in IBM Plex Mono */}
        <div className="flex flex-col items-center justify-center bg-[#F8FAFC] rounded-2xl py-2.5 px-4 border border-slate-100">
          <span className="text-4xl font-semibold font-mono tracking-tight text-[#0E1021] leading-none">
            {formattedTimer}
          </span>
          <span className="text-[9px] font-bold tracking-widest uppercase text-slate-400 mt-1">
            TARGET TIME LIMIT
          </span>

          {/* Quick Presets */}
          <div className="flex items-center gap-2 mt-2.5 w-full justify-center">
            {presets.map((preset) => {
              const isSelected = limitMinutes === preset;
              return (
                <button
                  key={preset}
                  type="button"
                  onClick={() => handlePresetSelect(preset)}
                  className={`px-3 py-1 rounded-full font-mono text-xs font-semibold flex items-center gap-1 active:scale-95 transition-all cursor-pointer ${
                    isSelected
                      ? 'bg-[#3A5BFF] text-white shadow-sm'
                      : 'bg-white border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  <span>{preset}m</span>
                  {preset === 5 && (
                    <span className="material-symbols-outlined text-[13px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                      star
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Purpose: Client's 7 exact options */}
        <div className="flex flex-col gap-1.5">
          <label className="text-[11px] font-bold uppercase tracking-wider text-slate-600">
            Why do you want to use it?
          </label>

          <div className="grid grid-cols-1 gap-1.5 max-h-48 overflow-y-auto pr-1">
            {clientPurposes.map((p) => {
              const isSelected = selectedPurpose === p.label && !customPurpose;
              return (
                <button
                  key={p.label}
                  type="button"
                  onClick={() => {
                    setSelectedPurpose(p.label);
                    setCustomPurpose('');
                  }}
                  className={`flex items-center space-x-2 px-3 py-2 rounded-xl text-xs font-medium text-left transition-all cursor-pointer border ${
                    isSelected
                      ? 'bg-orange-50 border-[#FF9F43] text-orange-950 font-bold shadow-xs'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  <span className={`material-symbols-outlined text-[16px] ${isSelected ? 'text-[#FF9F43]' : 'text-slate-400'}`}>
                    {p.icon}
                  </span>
                  <span className="truncate flex-1">{p.label}</span>
                  {isSelected && (
                    <span className="material-symbols-outlined text-[16px] text-[#FF9F43]">check</span>
                  )}
                </button>
              );
            })}
          </div>

          <input
            type="text"
            value={customPurpose}
            onChange={(e) => setCustomPurpose(e.target.value)}
            placeholder="Or type custom reason..."
            className="w-full mt-1 px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:border-[#3A5BFF]"
          />
        </div>

        {/* Launch Button */}
        <div className="pt-1 flex flex-col gap-2">
          <button
            type="button"
            onClick={handleConfirm}
            className="w-full h-12 rounded-full bg-[#3A5BFF] hover:bg-blue-600 active:scale-[0.98] text-white text-xs font-bold tracking-wider flex items-center justify-center gap-2 shadow-lg shadow-blue-500/30 transition uppercase cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]" style={{ fontVariationSettings: "'FILL' 1" }}>
              play_arrow
            </span>
            <span>OPEN {appName.toUpperCase()} ({limitMinutes} MIN LIMIT)</span>
          </button>

          {canCancel && (
            <button
              type="button"
              onClick={onClose}
              className="w-full h-7 rounded-full bg-transparent hover:bg-slate-100 text-slate-500 text-xs font-medium flex items-center justify-center transition active:scale-[0.99] cursor-pointer"
            >
              Cancel
            </button>
          )}
        </div>

      </div>
    </div>
  );
};
