import React, { useState, useEffect } from 'react';
import { StorageService } from '../../services/storage';
import { InstagramDashboardSummary, InstagramSessionRecord, UserGoal, UserProfile } from '../../types';

interface InstagramDashboardViewProps {
  onOpenSetLimit: () => void;
  onOpenClassCohort: () => void;
  onOpenAppSelector: () => void;
  onSignOut?: () => void;
}

export const InstagramDashboardView: React.FC<InstagramDashboardViewProps> = ({
  onOpenSetLimit,
  onOpenClassCohort,
  onOpenAppSelector,
  onSignOut
}) => {
  const [summary, setSummary] = useState<InstagramDashboardSummary>(StorageService.getDashboardSummary());
  const [sessions, setSessions] = useState<InstagramSessionRecord[]>(StorageService.getSessions());
  const [goal, setGoal] = useState<UserGoal>(StorageService.getGoal());
  const [user, setUser] = useState<UserProfile | null>(StorageService.getUserProfile());
  const [isEditingGoal, setIsEditingGoal] = useState(false);
  const [newDailyGoal, setNewDailyGoal] = useState(goal.instagramDailyLimit);

  useEffect(() => {
    const unsub = StorageService.subscribe(() => {
      setSummary(StorageService.getDashboardSummary());
      setSessions(StorageService.getSessions());
      setGoal(StorageService.getGoal());
      setUser(StorageService.getUserProfile());
    });
    return unsub;
  }, []);

  const handleUpdateGoal = () => {
    const updated = { ...goal, instagramDailyLimit: newDailyGoal };
    StorageService.saveGoal(updated);
    setIsEditingGoal(false);
  };

  const usagePercent = Math.min(100, Math.round((summary.totalMinutesToday / summary.dailyLimitMinutes) * 100));

  // Determine peak time of day
  const timeBuckets = [
    { label: 'Morning (05:00-12:00)', short: 'Morning', minutes: summary.morningMinutes, icon: 'wb_sunny', color: '#FF9F43' },
    { label: 'Afternoon (12:00-17:00)', short: 'Afternoon', minutes: summary.afternoonMinutes, icon: 'wb_cloudy', color: '#3A5BFF' },
    { label: 'Evening (17:00-21:00)', short: 'Evening', minutes: summary.eveningMinutes, icon: 'wb_twilight', color: '#8B5CF6' },
    { label: 'Nighttime (21:00-05:00)', short: 'Night', minutes: summary.nightMinutes, icon: 'bedtime', color: '#00B894' }
  ];

  const peakBucket = [...timeBuckets].sort((a, b) => b.minutes - a.minutes)[0];

  return (
    <div className="flex-1 p-4 overflow-y-auto flex flex-col space-y-4 bg-[#F8F9FE] text-slate-800 pb-20 select-none">
      
      {/* Sub-header & User Context */}
      <div className="flex items-center justify-between pt-1">
        <div className="flex flex-col">
          <span className="text-[11px] font-bold tracking-wider text-[#3A5BFF] uppercase font-mono">
            {user?.name || 'STUDENT DASHBOARD'} • {user?.studentId || 'CS-2026'}
          </span>
          <span className="text-[14px] font-semibold text-slate-800 tracking-tight mt-0.5">
            Personal Analytics &amp; Behavioral Guard
          </span>
        </div>
        <div className="flex items-center gap-1.5">
          <button
            onClick={onOpenClassCohort}
            title="Class Presentation Mode"
            className="px-2.5 py-1 rounded-full bg-blue-50 hover:bg-blue-100 text-[#3A5BFF] border border-blue-200 text-[11px] font-bold flex items-center gap-1 transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-[15px]">school</span>
            <span>Class Study</span>
          </button>
          <button
            onClick={onOpenAppSelector}
            title="App Restrictions"
            className="w-8 h-8 rounded-full bg-white shadow-xs border border-slate-200/60 flex items-center justify-center text-slate-700 hover:bg-slate-50 transition-transform active:scale-95 cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">apps</span>
          </button>
        </div>
      </div>

      {/* Adjust Goal Card (If editing) */}
      {isEditingGoal && (
        <div className="bg-white rounded-2xl p-4 border border-blue-200 shadow-sm space-y-2 animate-in fade-in">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-800">Set Daily Instagram Ceiling:</span>
            <button onClick={handleUpdateGoal} className="text-xs font-bold text-[#00B894] hover:underline">
              Save
            </button>
          </div>
          <div className="flex items-center gap-2 pt-1">
            {[15, 30, 45, 60].map((mins) => (
              <button
                key={mins}
                onClick={() => setNewDailyGoal(mins)}
                className={`flex-1 py-1.5 rounded-xl text-xs font-mono font-bold border transition-all ${
                  newDailyGoal === mins
                    ? 'bg-[#3A5BFF] text-white border-blue-600'
                    : 'bg-slate-50 text-slate-600 border-slate-200'
                }`}
              >
                {mins}m
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Hero Card: Intentional Gatekeeper in Deep Navy #0E1021 */}
      <div 
        className="relative overflow-hidden rounded-3xl p-5 text-white shadow-lg border border-slate-800"
        style={{ backgroundColor: 'rgb(14, 16, 33)' }}
      >
        <div className="absolute -right-6 -bottom-6 w-40 h-40 bg-[#3A5BFF]/20 rounded-full blur-3xl pointer-events-none" />
        <div className="relative z-10 flex flex-col space-y-3">
          <div 
            className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold tracking-wider uppercase self-start"
            style={{ backgroundColor: 'rgba(0, 184, 148, 0.15)', color: '#00B894', border: '1px solid rgba(0, 184, 148, 0.3)' }}
          >
            <span className="material-symbols-outlined text-[14px]" style={{ fontVariationSettings: "'FILL' 1" }}>
              verified_user
            </span>
            <span>RESTRICTION GUARD ACTIVE: 5M CAP</span>
          </div>

          <div>
            <h2 className="text-[20px] font-bold text-white tracking-tight">Open Social Media Mindfully</h2>
            <p className="text-[13px] text-slate-300 mt-1 leading-relaxed">
              Every launch triggers a 5-minute pre-set limit. When complete, choose Close or answer a 3s check-in.
            </p>
          </div>

          <div className="pt-1 flex items-center space-x-2">
            <button
              onClick={onOpenSetLimit}
              className="flex-1 py-3.5 px-5 rounded-full text-white font-bold text-[13px] tracking-wide flex items-center justify-center gap-2 shadow-md hover:brightness-110 active:scale-[0.98] transition-all cursor-pointer"
              style={{ backgroundColor: '#3A5BFF' }}
            >
              <span className="material-symbols-outlined text-[18px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                shield
              </span>
              <span>SET LIMIT &amp; OPEN INSTAGRAM</span>
            </button>

            <button
              onClick={onOpenAppSelector}
              title="Select Apps"
              className="p-3.5 rounded-full bg-white/10 hover:bg-white/20 text-white transition-all cursor-pointer"
            >
              <span className="material-symbols-outlined text-[18px]">tune</span>
            </button>
          </div>
        </div>
      </div>

      {/* Primary Telemetry 2x2 Grid */}
      <div className="grid grid-cols-2 gap-3">
        {/* Card 1: Time Today */}
        <div className="bg-white rounded-2xl p-4 flex flex-col justify-between shadow-xs border border-slate-200/80">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-medium text-slate-500">Time Today</span>
            <span className="material-symbols-outlined text-[18px] text-[#FF9F43]">timer</span>
          </div>
          <div className="my-2">
            <div className="flex items-baseline gap-1 font-mono font-semibold text-[22px] text-slate-900 tracking-tight">
              <span>{summary.totalMinutesToday}:00</span>
              <span className="text-[12px] text-slate-400 font-normal">/ {summary.dailyLimitMinutes}:00</span>
            </div>
            <div className="w-full h-2 rounded-full bg-slate-100 mt-2 overflow-hidden flex">
              <div 
                className="h-full rounded-l-full" 
                style={{ width: `${Math.min(75, usagePercent)}%`, backgroundColor: '#3A5BFF' }} 
              />
              <div 
                className="h-full rounded-r-full" 
                style={{ width: `${Math.max(0, usagePercent - 75)}%`, backgroundColor: '#FF9F43' }} 
              />
            </div>
          </div>
          <div className="inline-flex items-center gap-1 self-start px-2 py-0.5 rounded-full bg-rose-50 text-rose-600 border border-rose-200/50">
            <span className="material-symbols-outlined text-[12px]">trending_up</span>
            <span className="text-[10px] font-semibold font-mono">{summary.totalSessionsToday} sessions</span>
          </div>
        </div>

        {/* Card 2: First-Reminder Close Success Rate (Positive Response) */}
        <div className="bg-white rounded-2xl p-4 flex flex-col justify-between shadow-xs border border-slate-200/80">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-medium text-slate-500">1st Reminder Success</span>
            <span className="material-symbols-outlined text-[18px] text-[#00B894]" style={{ fontVariationSettings: "'FILL' 1" }}>
              thumb_up
            </span>
          </div>
          <div className="my-2">
            <span className="font-mono font-bold text-[24px] tracking-tight text-[#00B894]">
              {summary.firstReminderSuccessRate}%
            </span>
            <p className="font-mono text-[11px] text-slate-500 mt-0.5 font-medium">
              Closed on 1st reminder
            </p>
          </div>
          <div 
            className="inline-flex items-center gap-1 self-start px-2 py-0.5 rounded-full text-[10px] font-semibold border"
            style={{ backgroundColor: 'rgba(0, 184, 148, 0.1)', color: '#00B894', borderColor: 'rgba(0, 184, 148, 0.25)' }}
          >
            <span className="material-symbols-outlined text-[12px]">verified</span>
            <span>Positive DB Response</span>
          </div>
        </div>
      </div>

      {/* Time-of-Day Chronotype Analysis (Morning, Afternoon, Evening, Nighttime) */}
      <div className="bg-white rounded-2xl p-4 shadow-xs space-y-3 border border-slate-200/80">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[19px] text-[#3A5BFF]">schedule</span>
            <h3 className="text-[14px] font-bold text-slate-800">Time-of-Day Usage Breakdown</h3>
          </div>
          <span className="text-[10px] font-mono font-bold px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 border border-amber-200">
            Peak: {peakBucket.short}
          </span>
        </div>

        <p className="text-[11px] text-slate-500 leading-relaxed">
          AwareScroll logs exact timestamps to detect what time you use social media the most:
        </p>

        <div className="grid grid-cols-4 gap-2 pt-1">
          {timeBuckets.map((bucket) => {
            const isPeak = bucket.short === peakBucket.short;
            return (
              <div 
                key={bucket.short} 
                className={`p-2.5 rounded-xl border flex flex-col items-center text-center transition-all ${
                  isPeak ? 'bg-blue-50/80 border-[#3A5BFF] shadow-xs' : 'bg-slate-50 border-slate-200/70'
                }`}
              >
                <span className="material-symbols-outlined text-[18px] mb-1" style={{ color: bucket.color }}>
                  {bucket.icon}
                </span>
                <span className="text-[10px] font-bold text-slate-700">{bucket.short}</span>
                <span className="font-mono text-xs font-black text-slate-900 mt-0.5">{bucket.minutes}m</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Procrastination Analysis: What were you supposed to be doing? */}
      <div className="bg-white rounded-2xl p-4 shadow-xs space-y-2 border border-slate-200/80">
        <div className="flex items-center justify-between">
          <h3 className="text-[13px] font-bold text-slate-800 flex items-center gap-1.5">
            <span className="material-symbols-outlined text-[#FF9F43] text-[18px]">psychology</span>
            <span>Procrastination &amp; Emotion Trigger</span>
          </h3>
          <span className="text-[10px] font-mono text-slate-400">Pattern Discovery</span>
        </div>

        <div className="grid grid-cols-2 gap-2 pt-1">
          <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-200/70">
            <span className="text-[10px] text-slate-500 block uppercase font-mono font-bold">Top Delayed Task:</span>
            <span className="text-sm font-black text-rose-600 mt-0.5 block truncate">
              {summary.topSupposedActivity}
            </span>
          </div>

          <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-200/70">
            <span className="text-[10px] text-slate-500 block uppercase font-mono font-bold">Post-Scroll Mood:</span>
            <span className="text-sm font-black text-[#FF9F43] mt-0.5 block truncate">
              {summary.topScrollFeeling}
            </span>
          </div>
        </div>
      </div>

      {/* Classroom Research Cohort Banner */}
      <div 
        onClick={onOpenClassCohort}
        className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200/80 rounded-2xl p-3 flex items-center justify-between hover:bg-blue-100/60 transition-all cursor-pointer shadow-xs"
      >
        <div className="flex items-center space-x-2.5">
          <div className="w-8 h-8 rounded-xl bg-[#3A5BFF] text-white flex items-center justify-center shrink-0 shadow-xs">
            <span className="material-symbols-outlined text-[18px]">co_present</span>
          </div>
          <div>
            <span className="text-xs font-bold text-slate-900 block">
              Classroom Presentation Dataset
            </span>
            <span className="text-[10px] text-slate-500">
              Aggregated findings from 42 students for monthly presentation
            </span>
          </div>
        </div>
        <span className="material-symbols-outlined text-slate-400 text-[18px]">chevron_right</span>
      </div>

      {/* Recent Activity & Timestamped Session Log */}
      <div className="space-y-2">
        <div className="flex items-center justify-between px-1">
          <h3 className="text-[14px] font-bold text-slate-800">Exact Session Logs (Database)</h3>
          <span className="text-[11px] text-slate-400 font-medium font-mono">Date &amp; Time Logged</span>
        </div>

        <div className="space-y-2">
          {sessions.map((s) => {
            return (
              <div 
                key={s.id}
                className="bg-white rounded-2xl p-3.5 shadow-xs border border-slate-200/80 space-y-2"
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center shrink-0 border border-slate-200/60">
                      <span className="material-symbols-outlined text-[#3A5BFF] text-[18px]">photo_camera</span>
                    </div>
                    <div className="flex flex-col">
                      <span className="font-mono text-[14px] font-semibold text-slate-900">
                        {s.actualDurationMinutes}m session • {s.appName || 'Instagram'}
                      </span>
                      <span className="text-[11px] text-slate-500">
                        Purpose: <span className="font-medium text-slate-700 bg-slate-100 px-1.5 py-0.5 rounded text-[10px]">{s.initialPurpose}</span>
                      </span>
                    </div>
                  </div>

                  <span 
                    className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold border"
                    style={
                      s.closedOnFirstReminder
                        ? { backgroundColor: 'rgba(0, 184, 148, 0.12)', color: '#00B894', borderColor: 'rgba(0, 184, 148, 0.3)' }
                        : { backgroundColor: 'rgba(255, 159, 67, 0.14)', color: '#FF9F43', borderColor: 'rgba(255, 159, 67, 0.35)' }
                    }
                  >
                    {s.closedOnFirstReminder ? 'Positive: Closed 1st Warning' : s.hardLocked ? 'Hard Locked 10m' : 'Extended'}
                  </span>
                </div>

                <div className="flex items-center justify-between text-slate-400 text-[10px] pt-1 border-t border-slate-100 font-mono">
                  <span>Logged: {new Date(s.startTime).toLocaleDateString([], { month: 'short', day: 'numeric' })} at {new Date(s.startTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                  <span className="capitalize">{s.timeOfDay} session</span>
                </div>

                {s.feedback?.generatedQuote && (
                  <div className="bg-slate-50 p-2 rounded-xl text-[11px] text-slate-600 italic border border-slate-200/60">
                    "{s.feedback.generatedQuote.text}" — <strong className="not-italic">{s.feedback.generatedQuote.author}</strong>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

    </div>
  );
};
