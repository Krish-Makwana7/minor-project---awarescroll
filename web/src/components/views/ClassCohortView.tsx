import React, { useState } from 'react';
import { StorageService } from '../../services/storage';
import { ClassCohortSummary, UserProfile } from '../../types';

interface ClassCohortViewProps {
  onBackToDashboard: () => void;
}

export const ClassCohortView: React.FC<ClassCohortViewProps> = ({ onBackToDashboard }) => {
  const [cohort] = useState<ClassCohortSummary>(StorageService.getClassCohortSummary());
  const [user] = useState<UserProfile | null>(StorageService.getUserProfile());
  const [exportNotice, setExportNotice] = useState<string | null>(null);

  const handleDownloadDataset = () => {
    const jsonStr = StorageService.exportClassResearchDataset();
    const blob = new Blob([jsonStr], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `awarescroll_class_cohort_dataset_${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);

    setExportNotice('Classroom research dataset exported! Ready for presentation slides.');
    setTimeout(() => setExportNotice(null), 4000);
  };

  return (
    <div className="flex-1 p-5 overflow-y-auto flex flex-col space-y-4 bg-[#F8F9FE] text-slate-800 pb-20 select-none">
      
      {/* Header */}
      <div className="flex items-center justify-between">
        <button
          onClick={onBackToDashboard}
          className="flex items-center space-x-1 text-xs font-bold text-[#3A5BFF] hover:underline cursor-pointer"
        >
          <span className="material-symbols-outlined text-[16px]">arrow_back</span>
          <span>Personal Dashboard</span>
        </button>

        <span className="text-[10px] font-mono font-bold px-2.5 py-0.5 rounded-full bg-blue-50 text-[#3A5BFF] border border-blue-200">
          PRESENTATION MODE
        </span>
      </div>

      {/* Title */}
      <div>
        <div className="flex items-center space-x-1.5 text-[#3A5BFF] text-xs font-mono font-bold uppercase tracking-wider">
          <span className="material-symbols-outlined text-[16px]">groups</span>
          <span>Class Cohort Research Study</span>
        </div>
        <h1 className="text-2xl font-black text-slate-900 tracking-tight mt-0.5">
          End-of-Month Class Data
        </h1>
        <p className="text-xs text-slate-500 mt-1 leading-relaxed">
          Aggregated findings across {cohort.totalStudents} student participants over a {cohort.totalStudyDays}-day observation period.
        </p>
      </div>

      {exportNotice && (
        <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-3 text-xs text-emerald-800 flex items-center space-x-2 animate-in fade-in">
          <span className="material-symbols-outlined text-[18px] text-[#00B894]">verified</span>
          <span>{exportNotice}</span>
        </div>
      )}

      {/* Hero Big Stat Card: 384.5 Collective Hours */}
      <div 
        className="rounded-[28px] p-5 text-white shadow-xl relative overflow-hidden border border-slate-800"
        style={{ backgroundColor: 'rgb(14, 16, 33)' }}
      >
        <div className="absolute -right-6 -bottom-6 w-40 h-40 bg-[#3A5BFF]/20 rounded-full blur-3xl pointer-events-none" />
        
        <div className="relative z-10 flex flex-col space-y-2">
          <span className="text-[10px] font-mono font-bold tracking-widest text-[#00B894] uppercase">
            COLLECTIVE IMPACT REPORT
          </span>
          <div className="flex items-baseline space-x-2">
            <span className="text-4xl font-black font-mono text-white tracking-tight">
              {cohort.totalCollectiveHours}
            </span>
            <span className="text-base text-slate-400 font-bold">hours recorded</span>
          </div>
          <p className="text-xs text-slate-300 leading-relaxed">
            Total Instagram time logged across <strong>{cohort.totalStudents} students</strong>. AwareScroll's 5-minute friction successfully prevented an estimated <strong>142 hours</strong> of unintentional overrun.
          </p>
        </div>
      </div>

      {/* 2x2 Findings Grid */}
      <div className="grid grid-cols-2 gap-3">
        {/* Intervention Adherence */}
        <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs flex flex-col justify-between">
          <div>
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
              Class Adherence
            </span>
            <div className="text-3xl font-black font-mono text-[#00B894] mt-1">
              {cohort.overallAdherenceRate}%
            </div>
          </div>
          <p className="text-[10px] text-slate-500 mt-2 font-medium">
            Sessions closed on 5-min timer pause without extension.
          </p>
        </div>

        {/* Mindless Scroll Ratio */}
        <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs flex flex-col justify-between">
          <div>
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
              Mindless Scroll
            </span>
            <div className="text-3xl font-black font-mono text-[#FF9F43] mt-1">
              {cohort.classMindlessPercent}%
            </div>
          </div>
          <p className="text-[10px] text-slate-500 mt-2 font-medium">
            Surveys rated sessions as non-essential distraction.
          </p>
        </div>
      </div>

      {/* Why Students Extended Past 5 Mins (Root Cause Breakdown) */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="text-xs font-black uppercase tracking-wider text-slate-700">
            Why Students Overrun Limits
          </h3>
          <span className="text-[10px] font-mono text-slate-400">Class survey results</span>
        </div>

        <div className="space-y-2 pt-1">
          {cohort.topExtensionReasons.map((item) => (
            <div key={item.reason} className="space-y-1">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold text-slate-800 truncate max-w-[210px]">{item.reason}</span>
                <span className="font-mono font-bold text-[#FF9F43]">{item.percentage}%</span>
              </div>
              <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
                <div 
                  className="h-full rounded-full bg-[#FF9F43]"
                  style={{ width: `${item.percentage}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 4-Week Behavioral Progression */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="text-xs font-black uppercase tracking-wider text-slate-700">
            4-Week Intervention Trend
          </h3>
          <span className="text-[10px] font-mono text-[#00B894] font-bold">+29% Improvement</span>
        </div>

        <div className="grid grid-cols-4 gap-2 pt-1">
          {cohort.weeklyAdherenceTrend.map((t, idx) => (
            <div key={t.week} className="flex flex-col items-center bg-slate-50 rounded-xl p-2 border border-slate-100">
              <span className="text-[9px] font-bold text-slate-400">W{idx + 1}</span>
              <span className="text-base font-black font-mono text-[#3A5BFF] mt-1">{t.compliance}%</span>
              <span className="text-[8px] text-slate-500 text-center mt-0.5 truncate w-full">Adherence</span>
            </div>
          ))}
        </div>
      </div>

      {/* Export Button for Class Presentation */}
      <div className="pt-2">
        <button
          onClick={handleDownloadDataset}
          className="w-full h-12 bg-[#3A5BFF] hover:bg-blue-600 active:scale-[0.98] text-white font-extrabold text-xs uppercase tracking-wider rounded-2xl shadow-lg shadow-blue-500/30 transition-all flex items-center justify-center space-x-2 cursor-pointer"
        >
          <span className="material-symbols-outlined text-[18px]">download</span>
          <span>EXPORT CLASS DATASET (JSON REPORT)</span>
        </button>
      </div>

    </div>
  );
};
