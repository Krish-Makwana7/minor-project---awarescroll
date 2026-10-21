import React, { useState, useEffect } from 'react';
import { 
  Heart, 
  MessageCircle, 
  Send, 
  Bookmark, 
  FastForward, 
  Zap
} from 'lucide-react';
import { LimitExpiryModal } from './LimitExpiryModal';
import { FeedbackFormModal } from './FeedbackFormModal';
import { MotivationalQuoteView } from './MotivationalQuoteView';
import { StrictHardLockView } from './StrictHardLockView';
import { InstagramSessionRecord, ClientFeedbackResponse, MotivationalQuote } from '../../types';
import { StorageService, getTimeOfDayBucket } from '../../services/storage';

interface AwareScrollViewProps {
  intendedLimitMinutes: number;
  intendedPurpose: string;
  appName?: string;
  onFinishSession: () => void;
  onStartNewLimit?: () => void;
}

export const AwareScrollView: React.FC<AwareScrollViewProps> = ({
  intendedLimitMinutes,
  intendedPurpose,
  appName = 'Instagram',
  onFinishSession,
  onStartNewLimit
}) => {
  const [elapsedSeconds, setElapsedSeconds] = useState(0);
  const [speedMultiplier, setSpeedMultiplier] = useState(1);
  const [isInitialLimitReached, setIsInitialLimitReached] = useState(false);
  const [showExpiryModal, setShowExpiryModal] = useState(false);
  const [showFeedbackModal, setShowFeedbackModal] = useState(false);
  const [showQuoteView, setShowQuoteView] = useState(false);
  const [isFreeUsageActive, setIsFreeUsageActive] = useState(false);
  const [freeElapsedSeconds, setFreeElapsedSeconds] = useState(0);
  const [isHardLocked, setIsHardLocked] = useState(false);
  const [currentQuote, setCurrentQuote] = useState<MotivationalQuote | null>(null);

  const totalLimitSeconds = intendedLimitMinutes * 60;
  const freeExtensionSeconds = 5 * 60; // Exactly 5 minutes of free usage time
  const sessionId = 'session-' + Date.now();
  const [startTime] = useState(Date.now());

  // Timer loop
  useEffect(() => {
    const interval = setInterval(() => {
      // 1. Initial 5-minute countdown loop
      if (!isInitialLimitReached && !isFreeUsageActive) {
        setElapsedSeconds((prev) => {
          const next = prev + speedMultiplier;
          if (next >= totalLimitSeconds) {
            setIsInitialLimitReached(true);
            setShowExpiryModal(true);
          }
          return next;
        });
      }

      // 2. Post-quote 5-minute free usage countdown loop
      if (isFreeUsageActive && !isHardLocked) {
        setFreeElapsedSeconds((prev) => {
          const next = prev + speedMultiplier;
          if (next >= freeExtensionSeconds) {
            // Automatically close the app!
            setIsHardLocked(true);
            StorageService.markHardLocked(sessionId);
          }
          return next;
        });
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [speedMultiplier, totalLimitSeconds, isInitialLimitReached, isFreeUsageActive, isHardLocked, sessionId]);

  const triggerLimitImmediate = () => {
    if (!isFreeUsageActive) {
      setElapsedSeconds(totalLimitSeconds);
      setIsInitialLimitReached(true);
      setShowExpiryModal(true);
    } else {
      setFreeElapsedSeconds(freeExtensionSeconds);
      setIsHardLocked(true);
      StorageService.markHardLocked(sessionId);
    }
  };

  // CLOSE Button: Positive response stored in database!
  const handleCloseOnFirstReminder = () => {
    const actualMins = Math.round((elapsedSeconds / 60) * 10) / 10;
    const record: InstagramSessionRecord = {
      id: sessionId,
      appName,
      intendedLimitMinutes,
      actualDurationMinutes: actualMins,
      initialPurpose: intendedPurpose,
      timeOfDay: getTimeOfDayBucket(new Date(startTime)),
      exceededLimit: false,
      closedOnFirstReminder: true, // Positive success response
      startTime: new Date(startTime).toISOString(),
      endTime: new Date().toISOString()
    };
    StorageService.addSession(record);
    setShowExpiryModal(false);
    onFinishSession();
  };

  // CONTINUE Button: Opens rapid feedback form
  const handleContinueToFeedback = () => {
    setShowExpiryModal(false);
    setShowFeedbackModal(true);
  };

  // Feedback form submitted -> generates quote and shows Quote View
  const handleFeedbackSubmitted = (response: ClientFeedbackResponse) => {
    const actualMins = Math.round((elapsedSeconds / 60) * 10) / 10;
    const record: InstagramSessionRecord = {
      id: sessionId,
      appName,
      intendedLimitMinutes,
      actualDurationMinutes: actualMins,
      initialPurpose: intendedPurpose,
      timeOfDay: getTimeOfDayBucket(new Date(startTime)),
      exceededLimit: true,
      closedOnFirstReminder: false,
      feedback: response,
      extensionGranted: true,
      startTime: new Date(startTime).toISOString(),
      endTime: new Date().toISOString()
    };
    StorageService.addSession(record);

    if (response.generatedQuote) {
      setCurrentQuote(response.generatedQuote);
    }
    setShowFeedbackModal(false);
    setShowQuoteView(true);
  };

  // Start 5-Minute Free Extension
  const handleStartFreeUsage = () => {
    setShowQuoteView(false);
    setIsFreeUsageActive(true);
  };

  // Immediate close from quote
  const handleCloseFromQuote = () => {
    setShowQuoteView(false);
    onFinishSession();
  };

  // Time calculations
  const remainingSeconds = Math.max(0, totalLimitSeconds - elapsedSeconds);
  const minsRemaining = Math.floor(remainingSeconds / 60);
  const secsRemaining = remainingSeconds % 60;
  const timeDisplay = `${minsRemaining.toString().padStart(2, '0')}:${secsRemaining.toString().padStart(2, '0')}`;

  const freeRemaining = Math.max(0, freeExtensionSeconds - freeElapsedSeconds);
  const freeMins = Math.floor(freeRemaining / 60);
  const freeSecs = freeRemaining % 60;
  const freeDisplay = `${freeMins.toString().padStart(2, '0')}:${freeSecs.toString().padStart(2, '0')}`;

  const stories = [
    { name: 'Your Story', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=60' },
    { name: 'tech.coder', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=60' },
    { name: 'design.hub', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=60' },
    { name: 'campus.daily', avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=60' }
  ];

  return (
    <div className="flex-1 flex flex-col bg-[#0E1021] text-white relative overflow-hidden select-none">
      
      {/* Floating Telemetry Pill */}
      <div className={`absolute top-2 left-3 right-3 z-40 backdrop-blur-md rounded-2xl p-2.5 shadow-2xl flex flex-col space-y-1 border ${
        isFreeUsageActive
          ? 'bg-[#18122B]/95 border-amber-500/40'
          : 'bg-[#0E1021]/95 border-[#3A5BFF]/30'
      }`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <span className={`w-2 h-2 rounded-full animate-ping ${isFreeUsageActive ? 'bg-amber-400' : 'bg-[#00B894]'}`} />
            <span className={`text-[10px] font-mono font-bold uppercase tracking-wider ${isFreeUsageActive ? 'text-amber-300' : 'text-[#3A5BFF]'}`}>
              {isFreeUsageActive ? 'FINAL 5M EXTENSION (AUTO-CLOSE ACTIVE)' : `${appName.toUpperCase()} GUARD ACTIVE`}
            </span>
          </div>

          <span className={`text-xs font-mono font-bold px-2 py-0.5 rounded-lg ${
            isFreeUsageActive
              ? 'bg-amber-500/20 text-amber-300'
              : isInitialLimitReached
              ? 'bg-red-500/20 text-red-400'
              : 'bg-blue-500/20 text-[#3A5BFF]'
          }`}>
            {isFreeUsageActive ? `${freeDisplay} left` : `${timeDisplay} left`}
          </span>
        </div>

        <div className="flex items-center justify-between text-[11px] text-slate-300 pt-0.5">
          <span className="truncate max-w-[190px]">
            Target: <strong className="text-white font-medium">"{intendedPurpose}"</strong>
          </span>

          <div className="flex items-center space-x-1.5">
            <button
              onClick={() => setSpeedMultiplier(speedMultiplier === 1 ? 15 : 1)}
              className={`px-2 py-0.5 rounded text-[10px] font-bold border transition-all cursor-pointer ${
                speedMultiplier > 1
                  ? 'bg-[#FF9F43] text-white border-orange-400'
                  : 'bg-white/10 text-slate-300 border-white/10 hover:bg-white/20'
              }`}
              title="Fast forward demo"
            >
              <FastForward className="w-3 h-3 inline mr-0.5" />
              {speedMultiplier}x
            </button>

            <button
              onClick={triggerLimitImmediate}
              className="px-2 py-0.5 rounded text-[10px] font-bold bg-[#FF9F43]/20 text-[#FF9F43] border border-[#FF9F43]/40 hover:bg-[#FF9F43]/30 transition-all flex items-center space-x-1 cursor-pointer"
            >
              <Zap className="w-3 h-3 text-[#FF9F43]" />
              <span>Hit Limit</span>
            </button>
          </div>
        </div>
      </div>

      {/* Simulated Feed Header */}
      <div className="pt-20 pb-2 px-4 flex items-center justify-between border-b border-neutral-800 bg-[#0E1021] z-10">
        <span className="font-serif text-xl font-bold tracking-tight text-white">{appName}</span>
        <div className="flex items-center space-x-4">
          <Heart className="w-5 h-5 text-white" />
          <MessageCircle className="w-5 h-5 text-white" />
        </div>
      </div>

      {/* Main Feed Content */}
      <div className="flex-1 overflow-y-auto pb-14 space-y-4">
        {/* Stories */}
        <div className="flex items-center space-x-3 px-3 py-2 overflow-x-auto border-b border-neutral-900">
          {stories.map((s, idx) => (
            <div key={idx} className="flex flex-col items-center space-y-1 shrink-0">
              <div className="w-14 h-14 rounded-full p-[2px] bg-gradient-to-tr from-[#FF9F43] to-[#3A5BFF]">
                <img src={s.avatar} alt={s.name} className="w-full h-full rounded-full object-cover border-2 border-[#0E1021]" />
              </div>
              <span className="text-[10px] text-slate-300 truncate max-w-[60px]">{s.name}</span>
            </div>
          ))}
        </div>

        {/* Post */}
        <div className="space-y-3 pb-6">
          <div className="flex items-center justify-between px-3">
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 rounded-full bg-slate-700 overflow-hidden">
                <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100" alt="avatar" className="w-full h-full object-cover" />
              </div>
              <div>
                <span className="text-xs font-bold block text-white">studio_mindful</span>
                <span className="text-[10px] text-slate-400">Sponsored • Mindful Living</span>
              </div>
            </div>
          </div>

          <div className="w-full h-72 bg-neutral-900 flex items-center justify-center overflow-hidden">
            <img 
              src="https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=80" 
              alt="post media"
              className="w-full h-full object-cover" 
            />
          </div>

          <div className="px-3 flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Heart className="w-5 h-5 text-rose-500 fill-rose-500" />
              <MessageCircle className="w-5 h-5 text-white" />
              <Send className="w-5 h-5 text-white" />
            </div>
            <Bookmark className="w-5 h-5 text-white" />
          </div>

          <div className="px-3 text-xs text-slate-300 space-y-1">
            <p><strong className="text-white">studio_mindful</strong> Taking an intentional breath between tasks. Remember that your attention is your most precious currency today.</p>
          </div>
        </div>
      </div>

      {/* 1. Limit Expiry Box Modal (Close or Continue) */}
      {showExpiryModal && (
        <LimitExpiryModal
          limitMinutes={intendedLimitMinutes}
          actualMinutes={Math.round((elapsedSeconds / 60) * 10) / 10}
          appName={appName}
          onCloseApp={handleCloseOnFirstReminder}
          onContinue={handleContinueToFeedback}
        />
      )}

      {/* 2. Rapid 3-5s Feedback Form */}
      {showFeedbackModal && (
        <FeedbackFormModal
          sessionId={sessionId}
          onSubmitFeedback={handleFeedbackSubmitted}
          onClose={handleCloseOnFirstReminder}
        />
      )}

      {/* 3. Motivational Quote View (Before 5m Free Usage) */}
      {showQuoteView && currentQuote && (
        <MotivationalQuoteView
          quote={currentQuote}
          onStartFreeUsage={handleStartFreeUsage}
          onCloseNow={handleCloseFromQuote}
        />
      )}

      {/* 4. Strict Hard Lock View (Auto-Closure After 5m Free Usage) */}
      {isHardLocked && (
        <StrictHardLockView
          totalMinutes={Math.round(((elapsedSeconds + freeElapsedSeconds) / 60) * 10) / 10}
          initialPurpose={intendedPurpose}
          appName={appName}
          onReturnToDashboard={onFinishSession}
          onStartNewSession={() => {
            if (onStartNewLimit) onStartNewLimit();
            else onFinishSession();
          }}
        />
      )}

    </div>
  );
};
