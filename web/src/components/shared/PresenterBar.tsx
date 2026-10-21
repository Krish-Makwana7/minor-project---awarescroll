import React from 'react';
import { 
  Smartphone, 
  Monitor, 
  Tablet, 
  Maximize2, 
  Users, 
  Play, 
  Sparkles, 
  RotateCcw,
  Wifi
} from 'lucide-react';
import { DeviceMode, DemoStep } from '../../types';
import { StorageService } from '../../services/storage';

interface PresenterBarProps {
  deviceMode: DeviceMode;
  onSetDeviceMode: (mode: DeviceMode) => void;
  activeStep: DemoStep;
  onSelectStep: (step: DemoStep) => void;
}

export const PresenterBar: React.FC<PresenterBarProps> = ({
  deviceMode,
  onSetDeviceMode,
  activeStep,
  onSelectStep
}) => {
  const steps: { id: DemoStep; label: string }[] = [
    { id: 'auth', label: '1. Google Auth' },
    { id: 'app_selector', label: '2. Select Apps' },
    { id: 'dashboard', label: '3. User Dashboard' },
    { id: 'set_limit', label: '4. Set Limit' },
    { id: 'instagram_scroll', label: '5. Feed' },
    { id: 'limit_expiry', label: '6. Expiry Box' },
    { id: 'feedback_form', label: '7. Feedback Form' },
    { id: 'motivational_quote', label: '8. Quote View' },
    { id: 'hard_lock', label: '9. Hard Lock' },
    { id: 'cohort_study', label: '10. Class Study' },
  ];

  return (
    <div className="w-full bg-[#0a0d1a] border-b border-white/10 px-4 py-2 flex flex-wrap items-center justify-between gap-3 text-xs select-none sticky top-0 z-50">
      
      {/* Brand & Sync indicator */}
      <div className="flex items-center space-x-3">
        <div className="flex items-center space-x-1.5 font-bold text-white tracking-wide">
          <span className="w-2 h-2 rounded-full bg-blue-500" />
          <span>AwareScroll AI</span>
          <span className="text-slate-500 font-normal">| Demo Mode</span>
        </div>

        <div className="flex items-center space-x-1.5 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-2 py-0.5 rounded-full text-[10px] font-semibold">
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
          <span>Live Cross-Device Sync</span>
        </div>
      </div>

      {/* Demo Walkthrough Stepper */}
      <div className="flex items-center bg-black/40 rounded-xl p-1 border border-white/5 space-x-1">
        {steps.map((s) => (
          <button
            key={s.id}
            onClick={() => onSelectStep(s.id)}
            className={`px-2.5 py-1 rounded-lg font-bold text-[11px] transition-all ${
              activeStep === s.id
                ? 'bg-blue-600 text-white shadow-sm'
                : 'text-slate-400 hover:text-white hover:bg-white/5'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>

      {/* Reset Demo Data */}
      <div className="flex items-center space-x-2">
        <button
          onClick={() => {
            if (typeof window !== 'undefined') {
              localStorage.clear();
              window.location.reload();
            }
          }}
          className="flex items-center space-x-1 bg-white/5 hover:bg-white/10 text-slate-300 border border-white/10 rounded-lg px-2.5 py-1 text-[11px] transition-all cursor-pointer"
          title="Reset demo data to default"
        >
          <RotateCcw className="w-3 h-3 text-orange-400" />
          <span>Reset Demo</span>
        </button>
      </div>

      {/* Device Viewport Selector */}
      <div className="flex items-center space-x-1 bg-black/40 p-1 rounded-xl border border-white/5">
        <button
          onClick={() => onSetDeviceMode('desktop')}
          className={`p-1.5 rounded-lg transition-all ${
            deviceMode === 'desktop' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'
          }`}
          title="Command Center (Dual Pane)"
        >
          <Monitor className="w-4 h-4" />
        </button>
        <button
          onClick={() => onSetDeviceMode('phone')}
          className={`p-1.5 rounded-lg transition-all ${
            deviceMode === 'phone' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'
          }`}
          title="Phone Mockup"
        >
          <Smartphone className="w-4 h-4" />
        </button>
        <button
          onClick={() => onSetDeviceMode('tablet')}
          className={`p-1.5 rounded-lg transition-all ${
            deviceMode === 'tablet' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'
          }`}
          title="Tablet View"
        >
          <Tablet className="w-4 h-4" />
        </button>
        <button
          onClick={() => onSetDeviceMode('fullscreen')}
          className={`p-1.5 rounded-lg transition-all ${
            deviceMode === 'fullscreen' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'
          }`}
          title="Fullscreen / Native Mobile"
        >
          <Maximize2 className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
};
