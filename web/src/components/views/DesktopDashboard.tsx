import React, { useState, useEffect } from 'react';
import { 
  BarChart3, 
  Activity, 
  Sparkles, 
  Clock, 
  Database, 
  ShieldCheck, 
  Sun,
  Sunset,
  Moon,
  Sunrise,
  CheckCircle2
} from 'lucide-react';
import { InstagramDashboardSummary, InstagramSessionRecord, UserGoal, DemoStep } from '../../types';
import { StorageService } from '../../services/storage';

interface DesktopDashboardProps {
  childrenPhone: React.ReactNode;
  activeStep: DemoStep;
  onSelectStep: (step: DemoStep) => void;
}

export const DesktopDashboard: React.FC<DesktopDashboardProps> = ({
  childrenPhone,
  activeStep,
  onSelectStep
}) => {
  const [summary, setSummary] = useState<InstagramDashboardSummary>(StorageService.getDashboardSummary());
  const [sessions, setSessions] = useState<InstagramSessionRecord[]>(StorageService.getSessions());
  const [goal, setGoal] = useState<UserGoal>(StorageService.getGoal());

  useEffect(() => {
    const unsub = StorageService.subscribe(() => {
      setSummary(StorageService.getDashboardSummary());
      setSessions(StorageService.getSessions());
      setGoal(StorageService.getGoal());
    });
    return unsub;
  }, []);

  const steps: { id: DemoStep; label: string; desc: string }[] = [
    { id: 'auth', label: '1. Auth', desc: 'Google Sign In' },
    { id: 'app_selector', label: '2. Apps', desc: 'Select Restricted' },
    { id: 'dashboard', label: '3. Dashboard', desc: 'Telemetry' },
    { id: 'set_limit', label: '4. Set Limit', desc: '5m & Purpose' },
    { id: 'instagram_scroll', label: '5. Feed', desc: 'Active Timer' },
    { id: 'limit_expiry', label: '6. Expiry', desc: 'Close vs Continue' },
    { id: 'feedback_form', label: '7. Feedback', desc: '3-5s Form' },
    { id: 'motivational_quote', label: '8. Quote', desc: 'AI Quote' },
    { id: 'hard_lock', label: '9. Lock', desc: 'Auto Closed' },
    { id: 'cohort_study', label: '10. Class Study', desc: 'Presentation' }
  ];

  return (
    <div className="w-full min-h-screen bg-[#090b14] text-slate-100 flex flex-col">
      {/* Top Header */}
      <header className="h-16 border-b border-white/10 bg-[#0e1122]/90 backdrop-blur px-6 flex items-center justify-between sticky top-0 z-50">
        <div className="flex items-center space-x-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-[#3A5BFF] to-blue-500 flex items-center justify-center font-black text-white shadow-lg shadow-blue-500/20">
            AS
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <h1 className="font-bold text-base text-white tracking-wide">AwareScroll AI</h1>
              <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#3A5BFF]/20 text-[#3A5BFF] border border-[#3A5BFF]/30">
                Self-Regulation System
              </span>
            </div>
            <p className="text-[11px] text-slate-400">Pre-Launch Limit, 5m Interruption, Rapid Feedback & Chronotype Analytics</p>
          </div>
        </div>

        {/* Live sync indicators */}
        <div className="flex items-center space-x-4">
          <div className="flex items-center space-x-2 text-xs bg-black/40 px-3 py-1.5 rounded-xl border border-white/5">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-slate-300 font-medium">Cross-Platform Sync: Active</span>
          </div>

          <div className="flex items-center space-x-2 text-xs bg-black/40 px-3 py-1.5 rounded-xl border border-white/5">
            <Clock className="w-3.5 h-3.5 text-[#3A5BFF]" />
            <span className="text-slate-300 font-medium">Session Protection: {goal.defaultSessionLimit || 5}m</span>
          </div>
        </div>
      </header>

      {/* Main Dual-Pane Layout */}
      <div className="flex-1 max-w-[1700px] w-full mx-auto p-6 grid grid-cols-12 gap-6 items-start">
        
        {/* LEFT COLUMN: Smartphone Simulator */}
        <div className="col-span-12 xl:col-span-5 flex flex-col items-center sticky top-22">
          <div className="w-full flex items-center justify-between mb-3 px-2">
            <div className="flex items-center space-x-2">
              <Activity className="w-4 h-4 text-[#3A5BFF]" />
              <span className="text-xs font-bold uppercase tracking-wider text-slate-300">
                Live Interactive Mobile Client
              </span>
            </div>
            <span className="text-xs text-slate-500">Android & iOS Responsive</span>
          </div>

          {/* Device Frame */}
          <div className="w-full flex justify-center">
            {childrenPhone}
          </div>
        </div>

        {/* RIGHT COLUMN: Behavioral Telemetry & Step Controls */}
        <div className="col-span-12 xl:col-span-7 flex flex-col space-y-6">
          
          {/* 1. System Step Stepper */}
          <div className="bg-[#13162b] rounded-2xl p-5 border border-white/10 shadow-xl space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-bold text-white flex items-center space-x-2">
                <Sparkles className="w-4 h-4 text-blue-400" />
                <span>Client Workflow Sequence</span>
              </h2>
              <span className="text-xs text-slate-400">Step 1 through 10</span>
            </div>

            <div className="grid grid-cols-5 gap-2">
              {steps.map((step) => (
                <button
                  key={step.id}
                  onClick={() => onSelectStep(step.id)}
                  className={`p-2.5 rounded-xl text-left border transition-all cursor-pointer ${
                    activeStep === step.id
                      ? 'bg-[#3A5BFF] text-white border-blue-400 shadow-md shadow-blue-600/30 font-bold'
                      : 'bg-black/30 hover:bg-white/5 text-slate-300 border-white/5'
                  }`}
                >
                  <div className="text-xs truncate">{step.label}</div>
                  <div className="text-[10px] opacity-70 truncate">{step.desc}</div>
                </button>
              ))}
            </div>
          </div>

          {/* 2. Top Metric Cards */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-[#13162b] rounded-2xl p-4 border border-white/10">
              <div className="text-xs font-semibold text-slate-400">Total Today</div>
              <div className="text-3xl font-black text-white mt-2">
                {summary.totalMinutesToday} <span className="text-xs text-slate-500 font-normal">/ {summary.dailyLimitMinutes}m</span>
              </div>
              <div className="text-[11px] text-blue-400 mt-1">Social media usage</div>
            </div>

            <div className="bg-[#13162b] rounded-2xl p-4 border border-white/10">
              <div className="text-xs font-semibold text-slate-400">1st Reminder Adherence</div>
              <div className="text-3xl font-black text-emerald-400 mt-2">{summary.firstReminderSuccessRate}%</div>
              <div className="text-[11px] text-emerald-400 mt-1">Closed without extending</div>
            </div>

            <div className="bg-[#13162b] rounded-2xl p-4 border border-white/10">
              <div className="text-xs font-semibold text-slate-400">Top Feeling</div>
              <div className="text-xl font-bold text-amber-400 mt-2 truncate">{summary.topScrollFeeling}</div>
              <div className="text-[11px] text-slate-400 mt-1">Post-scroll sentiment</div>
            </div>

            <div className="bg-[#13162b] rounded-2xl p-4 border border-white/10">
              <div className="text-xs font-semibold text-slate-400">Supposed To Do</div>
              <div className="text-xl font-bold text-rose-400 mt-2 truncate">{summary.topSupposedActivity}</div>
              <div className="text-[11px] text-slate-400 mt-1">Delayed activity</div>
            </div>
          </div>

          {/* 3. Chronotype / Time-of-Day Analysis */}
          <div className="bg-[#13162b] rounded-2xl p-5 border border-white/10 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <BarChart3 className="w-5 h-5 text-blue-400" />
                <h3 className="font-bold text-sm text-white">Chronotype & Peak Usage Detection</h3>
              </div>
              <span className="text-xs font-mono text-blue-300 bg-blue-500/10 px-2.5 py-1 rounded-full border border-blue-500/30">
                Timestamp Telemetry
              </span>
            </div>

            <div className="grid grid-cols-4 gap-3">
              <div className="bg-black/30 p-3 rounded-xl border border-white/5 text-center">
                <Sunrise className="w-4 h-4 text-amber-400 mx-auto mb-1" />
                <div className="text-[11px] text-slate-400">Morning (6am-12pm)</div>
                <div className="text-base font-bold text-white mt-1">{summary.morningMinutes} min</div>
              </div>
              <div className="bg-black/30 p-3 rounded-xl border border-white/5 text-center">
                <Sun className="w-4 h-4 text-yellow-400 mx-auto mb-1" />
                <div className="text-[11px] text-slate-400">Afternoon (12-5pm)</div>
                <div className="text-base font-bold text-white mt-1">{summary.afternoonMinutes} min</div>
              </div>
              <div className="bg-black/30 p-3 rounded-xl border border-white/5 text-center">
                <Sunset className="w-4 h-4 text-orange-400 mx-auto mb-1" />
                <div className="text-[11px] text-slate-400">Evening (5-9pm)</div>
                <div className="text-base font-bold text-white mt-1">{summary.eveningMinutes} min</div>
              </div>
              <div className="bg-black/30 p-3 rounded-xl border border-white/5 text-center">
                <Moon className="w-4 h-4 text-indigo-400 mx-auto mb-1" />
                <div className="text-[11px] text-slate-400">Night (9pm-6am)</div>
                <div className="text-base font-bold text-white mt-1">{summary.nightMinutes} min</div>
              </div>
            </div>
          </div>

          {/* 4. Live Sessions Database Table */}
          <div className="bg-[#13162b] rounded-2xl p-5 border border-white/10 shadow-xl space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <Database className="w-4 h-4 text-blue-400" />
                <h3 className="font-bold text-sm text-white">Social Media Session & Feedback History</h3>
              </div>
              <span className="text-xs text-slate-400">Total recorded: {sessions.length}</span>
            </div>

            <div className="overflow-x-auto max-h-60 overflow-y-auto rounded-xl border border-white/5">
              <table className="w-full text-left text-xs text-slate-300">
                <thead className="bg-black/50 text-slate-400 uppercase text-[10px] tracking-wider sticky top-0">
                  <tr>
                    <th className="py-2.5 px-3">App</th>
                    <th className="py-2.5 px-3">Purpose</th>
                    <th className="py-2.5 px-3">Limit</th>
                    <th className="py-2.5 px-3">Actual</th>
                    <th className="py-2.5 px-3">Time of Day</th>
                    <th className="py-2.5 px-3">Outcome</th>
                    <th className="py-2.5 px-3">Feedback</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5 bg-black/20 font-mono text-[11px]">
                  {sessions.map((s) => (
                    <tr key={s.id} className="hover:bg-white/5 transition-colors">
                      <td className="py-2 px-3 text-[#3A5BFF] font-bold font-sans">{s.appName || 'Instagram'}</td>
                      <td className="py-2 px-3 text-white truncate max-w-[150px] font-sans">"{s.initialPurpose}"</td>
                      <td className="py-2 px-3">{s.intendedLimitMinutes}m</td>
                      <td className="py-2 px-3">{s.actualDurationMinutes}m</td>
                      <td className="py-2 px-3 capitalize font-sans">{s.timeOfDay}</td>
                      <td className="py-2 px-3">
                        <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                          s.closedOnFirstReminder ? 'bg-emerald-500/20 text-emerald-300' : 'bg-amber-500/20 text-amber-300'
                        }`}>
                          {s.closedOnFirstReminder ? 'Closed on 1st' : s.hardLocked ? 'Hard Locked' : 'Extended'}
                        </span>
                      </td>
                      <td className="py-2 px-3 text-slate-300 font-sans">
                        {s.feedback ? (
                          <span className="truncate block max-w-[180px]">
                            {s.feedback.decisionTrigger} • {s.feedback.feeling}
                          </span>
                        ) : (
                          <span className="text-slate-500">None (Closed early)</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};
