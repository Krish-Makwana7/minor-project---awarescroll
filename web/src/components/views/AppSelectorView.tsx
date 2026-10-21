import React, { useState } from 'react';
import { StorageService } from '../../services/storage';
import { RestrictedApp } from '../../types';

interface AppSelectorViewProps {
  onSelectAppToLaunch: (app: RestrictedApp) => void;
  onBackToDashboard: () => void;
}

export const AppSelectorView: React.FC<AppSelectorViewProps> = ({
  onSelectAppToLaunch,
  onBackToDashboard
}) => {
  const [apps, setApps] = useState<RestrictedApp[]>(StorageService.getRestrictedApps());

  const handleToggle = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    StorageService.toggleRestrictedApp(id);
    setApps(StorageService.getRestrictedApps());
  };

  return (
    <div className="flex-1 p-5 overflow-y-auto flex flex-col space-y-4 bg-[#F8F9FE] text-slate-800 pb-20 select-none">
      
      {/* Top Header */}
      <div className="flex items-center justify-between">
        <button
          onClick={onBackToDashboard}
          className="flex items-center space-x-1 text-xs font-bold text-[#3A5BFF] hover:underline cursor-pointer"
        >
          <span className="material-symbols-outlined text-[16px]">arrow_back</span>
          <span>Dashboard</span>
        </button>

        <span className="text-[10px] font-mono font-bold px-2.5 py-0.5 rounded-full bg-blue-50 text-[#3A5BFF] border border-blue-200">
          AWARESCROLL APP GUARD
        </span>
      </div>

      {/* Title */}
      <div>
        <div className="flex items-center space-x-1.5 text-[#3A5BFF] text-xs font-mono font-bold uppercase tracking-wider">
          <span className="material-symbols-outlined text-[16px]">tune</span>
          <span>Target Application Restriction</span>
        </div>
        <h1 className="text-2xl font-black text-slate-900 tracking-tight mt-0.5">
          Select Restricted Apps
        </h1>
        <p className="text-xs text-slate-500 mt-1 leading-relaxed">
          Choose which social media and video apps AwareScroll monitors on your device. The moment you open a guarded app, you will be prompted to set an intention and time limit.
        </p>
      </div>

      {/* App List */}
      <div className="space-y-2.5 pt-1">
        {apps.map((app) => (
          <div
            key={app.id}
            onClick={() => onSelectAppToLaunch(app)}
            className={`p-4 rounded-2xl border transition-all cursor-pointer flex items-center justify-between shadow-xs ${
              app.isGuarded
                ? 'bg-white border-blue-200/80 hover:border-[#3A5BFF]'
                : 'bg-slate-50/80 border-slate-200 opacity-60 hover:opacity-100'
            }`}
          >
            <div className="flex items-center space-x-3">
              <div className={`w-11 h-11 rounded-2xl flex items-center justify-center shrink-0 ${
                app.id === 'instagram'
                  ? 'bg-gradient-to-tr from-[#FF9F43] to-[#3A5BFF] text-white shadow-xs'
                  : app.isGuarded
                  ? 'bg-blue-50 text-[#3A5BFF]'
                  : 'bg-slate-200 text-slate-500'
              }`}>
                <span className="material-symbols-outlined text-[22px]">{app.icon}</span>
              </div>

              <div>
                <div className="flex items-center space-x-1.5">
                  <span className="font-bold text-sm text-slate-900">{app.name}</span>
                  {app.id === 'instagram' && (
                    <span className="text-[9px] font-mono font-bold px-1.5 py-0.2 rounded bg-orange-100 text-[#FF9F43]">
                      PRIMARY DEMO
                    </span>
                  )}
                </div>
                <span className="text-[11px] text-slate-500 font-mono block mt-0.5">
                  {app.isGuarded ? `Guard Active • 5m default limit` : 'Restriction Paused'}
                </span>
              </div>
            </div>

            {/* Toggle Switch */}
            <div className="flex items-center space-x-2">
              <button
                onClick={(e) => handleToggle(app.id, e)}
                className={`w-12 h-6 rounded-full p-0.5 transition-colors cursor-pointer flex items-center ${
                  app.isGuarded ? 'bg-[#3A5BFF]' : 'bg-slate-300'
                }`}
              >
                <div className={`w-5 h-5 rounded-full bg-white shadow-md transform transition-transform ${
                  app.isGuarded ? 'translate-x-6' : 'translate-x-0'
                }`} />
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Launch Card */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200 shadow-xs space-y-2 mt-2">
        <span className="text-xs font-bold text-slate-800 block">
          How App Restrictions Work:
        </span>
        <ul className="text-[11px] text-slate-600 space-y-1 list-disc pl-4 leading-relaxed">
          <li>Clicking on any restricted app displays the <strong>"Set Your Limit"</strong> pop-up modal.</li>
          <li>You select your intentional purpose (e.g. <em>"Reply to a message"</em>).</li>
          <li>At 5 minutes, feed pauses with <strong>Close</strong> or <strong>Continue</strong> choices.</li>
        </ul>
      </div>

    </div>
  );
};
