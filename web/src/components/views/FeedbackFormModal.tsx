import React, { useState } from 'react';
import { 
  ClientFeedbackResponse, 
  DecisionTrigger, 
  ContentCategory, 
  PlannedWorkImpact, 
  PostScrollFeeling, 
  SupposedToBeDoing, 
  HelpfulStopper 
} from '../../types';
import { QuoteEngine } from '../../services/quoteEngine';

interface FeedbackFormModalProps {
  sessionId: string;
  onSubmitFeedback: (response: ClientFeedbackResponse) => void;
  onClose: () => void;
}

export const FeedbackFormModal: React.FC<FeedbackFormModalProps> = ({
  sessionId,
  onSubmitFeedback,
  onClose
}) => {
  // Fast 1-tap defaults so user can submit in 3 seconds or adjust any chip
  const [decisionTrigger, setDecisionTrigger] = useState<DecisionTrigger>('Interesting content');
  const [contentCategory, setContentCategory] = useState<ContentCategory>('Comedy / Memes');
  const [workImpact, setWorkImpact] = useState<PlannedWorkImpact>('Delayed a task');
  const [feeling, setFeeling] = useState<PostScrollFeeling>('Stressed / regretful');
  const [supposedToBeDoing, setSupposedToBeDoing] = useState<SupposedToBeDoing>('Studying');
  const [helpfulStopper, setHelpfulStopper] = useState<HelpfulStopper>('App closure');
  const [timePerception, setTimePerception] = useState<'Felt like 1 min (Lost track of time)' | 'Felt like 5 mins' | 'Felt longer'>('Felt like 1 min (Lost track of time)');

  const handleSubmit = () => {
    const quote = QuoteEngine.generateQuote({
      decisionTrigger,
      contentCategory,
      workImpact,
      feeling,
      supposedToBeDoing,
      helpfulStopper
    });

    const response: ClientFeedbackResponse = {
      id: 'fb-' + Date.now(),
      sessionId,
      decisionTrigger,
      contentCategory,
      workImpact,
      feeling,
      supposedToBeDoing,
      helpfulStopper,
      timePerception,
      submittedAt: new Date().toISOString(),
      generatedQuote: quote
    };

    onSubmitFeedback(response);
  };

  return (
    <div className="absolute inset-0 z-50 bg-[#0E1021]/75 backdrop-blur-[8px] flex flex-col justify-end animate-in fade-in duration-200 select-none text-slate-800">
      <div className="w-full flex flex-col bg-white rounded-t-[28px] shadow-2xl overflow-hidden pt-3.5 max-h-[94%] overflow-y-auto">
        
        {/* Grab Handle */}
        <div className="w-12 h-1.5 rounded-full bg-[#FF9F43] mx-auto mb-2" />

        {/* Header */}
        <div className="px-5 pb-2.5 flex items-center justify-between border-b border-slate-100">
          <div>
            <div className="flex items-center space-x-1.5">
              <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-[#3A5BFF] bg-blue-50 px-2 py-0.5 rounded-full">
                3-SECOND RAPID CHECK-IN
              </span>
              <span className="text-[10px] font-mono font-bold text-slate-400">⚡ 1-Tap Chips</span>
            </div>
            <h2 className="text-lg font-bold text-slate-900 tracking-tight mt-1">
              Why did you choose to continue?
            </h2>
            <p className="text-[11px] text-slate-500">
              Your answers calibrate your next motivational quote & habit analytics.
            </p>
          </div>

          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-500 transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>

        {/* Scrollable Questions Form */}
        <div className="px-5 py-3 flex flex-col gap-4 text-xs">
          
          {/* Q1: What most influenced your decision to continue? */}
          <div className="space-y-1.5">
            <span className="font-bold text-slate-900 block">
              1. What most influenced your decision to continue?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['Interesting content', 'Boredom', 'Stress / mood', 'Notifications / messages', 'Habitual scrolling', 'Unfinished original purpose'] as DecisionTrigger[]).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setDecisionTrigger(opt)}
                  className={`px-3 py-1.5 rounded-xl border text-[11px] transition-all cursor-pointer font-medium ${
                    decisionTrigger === opt
                      ? 'bg-[#3A5BFF] text-white border-blue-600 shadow-xs font-bold'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Q2: Which content category kept you engaged? */}
          <div className="space-y-1.5">
            <span className="font-bold text-slate-900 block">
              2. Which content category kept you engaged?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['Comedy / Memes', 'Education / Technology', 'News / Politics', 'Stories / Personal content', 'Fitness / Lifestyle', 'Music / Entertainment', 'Other / Mixed'] as ContentCategory[]).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setContentCategory(opt)}
                  className={`px-3 py-1.5 rounded-xl border text-[11px] transition-all cursor-pointer font-medium ${
                    contentCategory === opt
                      ? 'bg-[#FF9F43] text-white border-orange-500 shadow-xs font-bold'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Q3: What were you supposed to be doing? */}
          <div className="space-y-1.5">
            <span className="font-bold text-slate-900 block">
              3. What were you supposed to be doing right now?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['Studying', 'Working', 'Sleeping', 'Socializing', 'Relaxing', 'Nothing planned'] as SupposedToBeDoing[]).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setSupposedToBeDoing(opt)}
                  className={`px-3 py-1.5 rounded-xl border text-[11px] transition-all cursor-pointer font-medium ${
                    supposedToBeDoing === opt
                      ? 'bg-rose-500 text-white border-rose-600 shadow-xs font-bold'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Q4: How did this session affect your planned work? */}
          <div className="space-y-1.5">
            <span className="font-bold text-slate-900 block">
              4. How did this session affect your planned work?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['No task planned', 'Delayed a task', 'Interrupted a task', 'No negative impact / planned break'] as PlannedWorkImpact[]).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setWorkImpact(opt)}
                  className={`px-3 py-1.5 rounded-xl border text-[11px] transition-all cursor-pointer font-medium ${
                    workImpact === opt
                      ? 'bg-[#3A5BFF] text-white border-blue-600 shadow-xs font-bold'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Q5: How do you feel after scrolling? */}
          <div className="space-y-1.5">
            <span className="font-bold text-slate-900 block">
              5. How do you feel after scrolling?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['Satisfied', 'Relaxed', 'Neutral', 'Bored', 'Stressed / regretful'] as PostScrollFeeling[]).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setFeeling(opt)}
                  className={`px-3 py-1.5 rounded-xl border text-[11px] transition-all cursor-pointer font-medium ${
                    feeling === opt
                      ? 'bg-[#FF9F43] text-white border-orange-500 shadow-xs font-bold'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Q6: What would have helped you stop? */}
          <div className="space-y-1.5">
            <span className="font-bold text-slate-900 block">
              6. What would have helped you stop?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['Time warning', 'Original-purpose reminder', 'Mood check', 'Break suggestion', 'App closure'] as HelpfulStopper[]).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setHelpfulStopper(opt)}
                  className={`px-3 py-1.5 rounded-xl border text-[11px] transition-all cursor-pointer font-medium ${
                    helpfulStopper === opt
                      ? 'bg-[#00B894] text-white border-emerald-600 shadow-xs font-bold'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Q7: High-Quality Time Perception Index */}
          <div className="space-y-1.5 bg-blue-50/50 p-2.5 rounded-xl border border-blue-100">
            <span className="font-bold text-slate-900 block text-[11px]">
              ⭐ Pattern Discovery: How did the 5 minutes feel?
            </span>
            <div className="flex flex-wrap gap-1.5">
              {(['Felt like 1 min (Lost track of time)', 'Felt like 5 mins', 'Felt longer'] as const).map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => setTimePerception(opt)}
                  className={`px-2.5 py-1 rounded-lg border text-[10px] transition-all cursor-pointer ${
                    timePerception === opt
                      ? 'bg-[#3A5BFF] text-white border-blue-600 font-bold'
                      : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

        </div>

        {/* Submit Action */}
        <div className="p-4 bg-white border-t border-slate-100">
          <button
            type="button"
            onClick={handleSubmit}
            className="w-full h-12 rounded-full bg-[#FF9F43] hover:bg-orange-600 active:scale-[0.98] text-white text-xs font-bold tracking-wider uppercase shadow-md flex items-center justify-center space-x-1.5 transition-all cursor-pointer"
          >
            <span>SUBMIT &amp; GENERATE MOTIVATIONAL QUOTE</span>
            <span className="material-symbols-outlined text-[18px]">psychology</span>
          </button>
        </div>

      </div>
    </div>
  );
};
