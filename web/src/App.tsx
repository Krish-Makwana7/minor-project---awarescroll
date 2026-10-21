import React, { useState, useEffect } from 'react';
import { SlidersHorizontal, BarChart2 } from 'lucide-react';
import { DemoStep, RestrictedApp } from './types';
import { StorageService } from './services/storage';
import { GoogleAuthView } from './components/views/GoogleAuthView';
import { InstagramDashboardView } from './components/views/InstagramDashboardView';
import { AppSelectorView } from './components/views/AppSelectorView';
import { ClassCohortView } from './components/views/ClassCohortView';
import { AwareScrollView } from './components/views/AwareScrollView';
import { SetLimitModal } from './components/views/SetLimitModal';

export function App() {
  const [activeStep, setActiveStep] = useState<DemoStep>(() => {
    if (typeof window !== 'undefined') {
      return StorageService.isUserSignedIn() ? 'dashboard' : 'auth';
    }
    return 'dashboard';
  });

  const [isSetLimitOpen, setIsSetLimitOpen] = useState(false);
  const [selectedApp, setSelectedApp] = useState<RestrictedApp>({
    id: 'instagram',
    name: 'Instagram',
    icon: 'photo_camera',
    packageName: 'com.instagram.android',
    isGuarded: true,
    dailyMinutesBudget: 30
  });

  // Active session parameters
  const [sessionParams, setSessionParams] = useState({
    limitMinutes: 5,
    purpose: 'Reply to a message'
  });

  useEffect(() => {
    StorageService.init();

    if (!StorageService.isUserSignedIn()) {
      setActiveStep('auth');
    }
  }, []);

  const handleLaunchApp = (limitMinutes: number, purpose: string) => {
    setSessionParams({ limitMinutes, purpose });
    setIsSetLimitOpen(false);
    setActiveStep('instagram_scroll');
  };

  const handleSelectAppToLaunch = (app: RestrictedApp) => {
    setSelectedApp(app);
    setIsSetLimitOpen(true);
  };

  const getScreenTitle = () => {
    switch (activeStep) {
      case 'auth': return 'Sign In';
      case 'dashboard': return 'AwareScroll';
      case 'app_selector': return 'Restricted Apps';
      case 'cohort_study': return 'Cohort Research';
      case 'set_limit': return `Set Limit (${selectedApp.name})`;
      case 'instagram_scroll': return `${selectedApp.name} (Protected)`;
      default: return 'AwareScroll';
    }
  };

  const isScrolling = activeStep === 'instagram_scroll';
  const isAuth = activeStep === 'auth';

  return (
    <div className="w-full min-h-screen h-[100dvh] bg-[#F8F9FE] text-slate-800 flex flex-col font-sans overflow-hidden select-none">
      
      {/* Native App Top Header (iOS & Android) */}
      {!isScrolling && !isAuth && (
        <header className="pt-safe bg-white border-b border-slate-200/80 shrink-0 z-30 shadow-xs">
          <div className="h-14 px-4 flex items-center justify-between">
            <div className="flex items-center space-x-2.5">
              <div className="w-7 h-7 rounded-lg bg-[#3A5BFF] flex items-center justify-center text-white shadow-xs">
                <span className="material-symbols-outlined text-[18px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                  shield_with_heart
                </span>
              </div>
              <div>
                <h1 className="font-extrabold text-sm text-slate-900 leading-tight tracking-tight">
                  {getScreenTitle()}
                </h1>
                <p className="text-[10px] text-slate-400 font-medium">Digital Self-Regulation</p>
              </div>
            </div>

            <div className="flex items-center space-x-2">
              <button
                onClick={() => setActiveStep('cohort_study')}
                className={`p-2 rounded-xl transition-all cursor-pointer ${
                  activeStep === 'cohort_study' 
                    ? 'bg-blue-50 text-[#3A5BFF]' 
                    : 'text-slate-400 hover:text-slate-700 hover:bg-slate-50'
                }`}
                title="Class Cohort Study"
              >
                <BarChart2 className="w-4 h-4" />
              </button>

              <button
                onClick={() => setIsSetLimitOpen(true)}
                className="text-[11px] font-bold px-3 py-1.5 rounded-full bg-[#3A5BFF] text-white hover:bg-[#2B4CE0] active:scale-95 transition-all flex items-center space-x-1 shadow-xs cursor-pointer"
                title="Set Pre-Launch Limit"
              >
                <SlidersHorizontal className="w-3 h-3" />
                <span>Limit</span>
              </button>
            </div>
          </div>
        </header>
      )}

      {/* Main Screen Body */}
      <main className="flex-1 flex flex-col overflow-y-auto relative">
        {activeStep === 'auth' && (
          <GoogleAuthView onAuthenticated={() => setActiveStep('dashboard')} />
        )}

        {activeStep === 'app_selector' && (
          <AppSelectorView 
            onSelectAppToLaunch={handleSelectAppToLaunch}
            onBackToDashboard={() => setActiveStep('dashboard')}
          />
        )}

        {activeStep === 'dashboard' && (
          <InstagramDashboardView 
            onOpenSetLimit={() => setIsSetLimitOpen(true)}
            onOpenClassCohort={() => setActiveStep('cohort_study')}
            onOpenAppSelector={() => setActiveStep('app_selector')}
            onSignOut={() => {
              StorageService.signOut();
              setActiveStep('auth');
            }}
          />
        )}

        {activeStep === 'cohort_study' && (
          <ClassCohortView onBackToDashboard={() => setActiveStep('dashboard')} />
        )}

        {activeStep === 'set_limit' && (
          <div className="flex-1 flex items-center justify-center p-4">
            <SetLimitModal
              isOpen={true}
              appName={selectedApp.name}
              onClose={() => setActiveStep('dashboard')}
              onLaunchInstagram={handleLaunchApp}
              canCancel={true}
            />
          </div>
        )}

        {activeStep === 'instagram_scroll' && (
          <AwareScrollView
            intendedLimitMinutes={sessionParams.limitMinutes}
            intendedPurpose={sessionParams.purpose}
            appName={selectedApp.name}
            onFinishSession={() => setActiveStep('dashboard')}
            onStartNewLimit={() => {
              setActiveStep('dashboard');
              setIsSetLimitOpen(true);
            }}
          />
        )}
      </main>

      {/* Native Bottom Navigation Bar for Mobile */}
      {!isScrolling && !isAuth && (
        <nav className="border-t border-slate-200/80 bg-white/95 backdrop-blur-xl flex items-center justify-around px-4 z-40 select-none shrink-0 pb-safe shadow-lg relative">
          
          {/* Dashboard Tab */}
          <button
            onClick={() => setActiveStep('dashboard')}
            className={`flex flex-col items-center justify-center w-16 h-14 transition-colors relative cursor-pointer ${
              activeStep === 'dashboard' ? 'text-[#3A5BFF] font-bold' : 'text-slate-400 hover:text-slate-700'
            }`}
          >
            <span 
              className="material-symbols-outlined text-[24px]" 
              style={{ fontVariationSettings: activeStep === 'dashboard' ? "'FILL' 1" : "'FILL' 0" }}
            >
              dashboard
            </span>
            <span className="text-[11px] mt-0.5">Dashboard</span>
            {activeStep === 'dashboard' && (
              <span className="absolute bottom-1 w-6 h-1 rounded-full bg-[#3A5BFF]" />
            )}
          </button>

          {/* Central Protected Launch Button */}
          <div className="relative -top-4 flex flex-col items-center">
            <button
              onClick={() => setIsSetLimitOpen(true)}
              aria-label="Open Social App Protected"
              className="w-14 h-14 rounded-full text-white shadow-xl flex items-center justify-center hover:scale-105 active:scale-95 transition-transform border-4 border-white cursor-pointer"
              style={{ backgroundColor: '#3A5BFF' }}
            >
              <span className="material-symbols-outlined text-[28px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                shield_with_heart
              </span>
            </button>
            <span className="text-[10px] font-semibold text-slate-700 mt-0.5">Launch</span>
          </div>

          {/* App Restrictions Tab */}
          <button
            onClick={() => setActiveStep('app_selector')}
            className={`flex flex-col items-center justify-center w-16 h-14 transition-colors relative cursor-pointer ${
              activeStep === 'app_selector' ? 'text-[#3A5BFF] font-bold' : 'text-slate-400 hover:text-slate-700'
            }`}
          >
            <span 
              className="material-symbols-outlined text-[24px]"
              style={{ fontVariationSettings: activeStep === 'app_selector' ? "'FILL' 1" : "'FILL' 0" }}
            >
              apps
            </span>
            <span className="text-[11px] mt-0.5">Apps</span>
            {activeStep === 'app_selector' && (
              <span className="absolute bottom-1 w-6 h-1 rounded-full bg-[#3A5BFF]" />
            )}
          </button>
        </nav>
      )}

      {/* Pre-launch Limit Modal */}
      <SetLimitModal
        isOpen={isSetLimitOpen}
        appName={selectedApp.name}
        onClose={() => setIsSetLimitOpen(false)}
        onLaunchInstagram={handleLaunchApp}
        canCancel={StorageService.isLimitConfigured()}
      />
    </div>
  );
}

export default App;
