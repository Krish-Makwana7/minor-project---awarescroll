import React, { useState, useEffect } from 'react';
import { Capacitor } from '@capacitor/core';
import { GoogleAuth } from '@codetrix-studio/capacitor-google-auth';
import { StorageService } from '../../services/storage';

interface GoogleAuthViewProps {
  onAuthenticated: () => void;
}

export const GoogleAuthView: React.FC<GoogleAuthViewProps> = ({ onAuthenticated }) => {
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    try {
      GoogleAuth.initialize({
        clientId: '193782140723-dt17ap4nhfiktal8k2ocdorkpl2r5f1q.apps.googleusercontent.com',
        scopes: ['profile', 'email'],
        grantOfflineAccess: true,
      });
    } catch (initErr) {
      console.debug('GoogleAuth init deferred:', initErr);
    }
  }, []);

  const handleGoogleSignIn = async () => {
    setIsLoading(true);
    try {
      if (Capacitor.isNativePlatform()) {
        try {
          const response = await GoogleAuth.signIn();
          if (response && response.email) {
            StorageService.signInWithGoogle(
              response.name || response.givenName || 'Google Student',
              response.email
            );
            setIsLoading(false);
            onAuthenticated();
            return;
          }
        } catch (nativeErr) {
          console.warn('Native Google Auth prompt failed or cancelled:', nativeErr);
        }
      }

      // Fallback / standard student account
      setTimeout(() => {
        StorageService.signInWithGoogle('Alex Rivera', 'alex.rivera@university.edu');
        setIsLoading(false);
        onAuthenticated();
      }, 500);
    } catch (e) {
      console.error('Google Sign In error', e);
      setIsLoading(false);
    }
  };

  const handleGuestSignIn = () => {
    StorageService.signInAsGuest();
    onAuthenticated();
  };

  return (
    <div className="flex-1 flex flex-col justify-between p-6 bg-[#F8F9FE] text-slate-800 min-h-full select-none">
      
      {/* Top Academic Badge */}
      <div className="w-full flex items-center justify-center pt-2">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#3A5BFF] text-[10px] font-mono font-bold tracking-wider uppercase">
          <span className="material-symbols-outlined text-[13px]">school</span>
          <span>STUDENT RESEARCH COHORT • MINOR PROJECT</span>
        </div>
      </div>

      {/* Main Branding & Vector Illustration */}
      <div className="flex flex-col items-center text-center space-y-4 my-auto py-2">
        {/* Cat Illustration with Laptop, Plant & Mint Yarn */}
        <div className="relative w-48 h-32 flex items-center justify-center">
          <svg className="w-full h-full overflow-visible" fill="none" viewBox="0 0 190 120" xmlns="http://www.w3.org/2000/svg">
            <path d="M22 68C16 42 38 16 75 12C122 8 168 22 172 60C176 92 144 116 104 116C52 116 26 95 22 68Z" fill="#F0F4FF" opacity="0.9" />
            <path d="M16 34C28 22 48 26 58 34" fill="none" stroke="#CBD5E1" strokeDasharray="3 3" strokeLinecap="round" strokeWidth="2" />
            <circle cx="160" cy="28" fill="#FED7AA" r="3" />
            <path d="M136 18C150 14 165 24 162 38" fill="none" stroke="#FED7AA" strokeLinecap="round" strokeWidth="2" />

            {/* Potted Plant */}
            <path d="M25 83L28 99H38L41 83H25Z" fill="#E2E8F0" />
            <path d="M24 83H42V80H24V83Z" fill="#CBD5E1" />
            <path d="M33 80C28 72 20 72 22 65C27 65 32 72 33 80Z" fill="#00B894" />
            <path d="M33 80C38 69 47 71 45 64C40 64 34 71 33 80Z" fill="#55EFC4" />

            {/* Mini Laptop */}
            <rect fill="#64748B" height="24" rx="2" width="34" x="84" y="66" />
            <rect fill="#F8FAFC" height="20" rx="1" width="30" x="86" y="68" />
            <path d="M96 77L106 77" stroke="#94A3B8" strokeLinecap="round" strokeWidth="1.5" />
            <path d="M99 82L103 82" stroke="#CBD5E1" strokeLinecap="round" strokeWidth="1.5" />
            <path d="M80 90H122C123 90 124 91 123 92.5L120 93.5H82L79 92.5C78 91 79 90 80 90Z" fill="#94A3B8" />

            {/* Ginger Cat */}
            <path d="M44 94C44 74 55 63 67 63C79 63 85 74 85 94H44Z" fill="#FF9F43" />
            <path d="M48 67L52 53L61 64" fill="#FDA4AF" stroke="#FF9F43" strokeWidth="2" />
            <path d="M71 64L80 53L84 67" fill="#FDA4AF" stroke="#FF9F43" strokeWidth="2" />
            <path d="M55 74C57 76 59 76 61 74" fill="none" stroke="#5C2900" strokeLinecap="round" strokeWidth="1.6" />
            <path d="M69 74C71 76 73 76 75 74" fill="none" stroke="#5C2900" strokeLinecap="round" strokeWidth="1.6" />
            <circle cx="65" cy="76" fill="#5C2900" r="1.5" />
            <ellipse cx="65" cy="85" fill="#FFF5EB" rx="8" ry="5" />
            <ellipse cx="73" cy="87" fill="#FFEAA7" rx="5" ry="3.5" />

            {/* White/Calico Cat with Blue Spot */}
            <path d="M116 94C116 76 127 65 139 65C151 65 159 76 159 94H116Z" fill="#F8FAFC" stroke="#E2E8F0" strokeWidth="1.2" />
            <path d="M125 67C128 61 135 62 138 67" fill="#3A5BFF" />
            <path d="M120 69L125 56L132 67" fill="#FECDD3" stroke="#CBD5E1" strokeWidth="1.5" />
            <path d="M143 67L150 56L155 69" fill="#FECDD3" stroke="#CBD5E1" strokeWidth="1.5" />
            <path d="M128 75C130 73 132 73 134 75" fill="none" stroke="#334155" strokeLinecap="round" strokeWidth="1.6" />
            <path d="M142 75C144 73 146 73 148 75" fill="none" stroke="#334155" strokeLinecap="round" strokeWidth="1.6" />
            <circle cx="138" cy="77" fill="#E11D48" r="1.4" />
            <ellipse cx="120" cy="87" fill="#FFFFFF" rx="6" ry="4" stroke="#CBD5E1" strokeWidth="1" />

            {/* Mint Ball of Yarn (#00B894) */}
            <circle cx="98" cy="93" fill="#00B894" r="9.5" />
            <path d="M93 91C96 88 101 89 104 92" fill="none" stroke="#A7F3D0" strokeLinecap="round" strokeWidth="1.6" />
            <path d="M95 96C98 94 102 95 105 97" fill="none" stroke="#A7F3D0" strokeLinecap="round" strokeWidth="1.6" />
            <path d="M102 96C109 98 113 91 108 87C103 83 96 87 91 84" fill="none" stroke="#00B894" strokeLinecap="round" strokeWidth="1.8" />
          </svg>
        </div>

        <div>
          <div className="flex items-center justify-center space-x-1.5">
            <h1 className="text-3xl font-black text-slate-900 tracking-tight">AwareScroll</h1>
            <span className="w-2.5 h-2.5 rounded-full bg-[#3A5BFF]" />
          </div>
          <h2 className="text-base font-bold text-slate-700 tracking-tight mt-1">
            Mindful Scrolling. Backed by Data.
          </h2>
          <p className="text-xs text-slate-500 max-w-[290px] mx-auto mt-1 leading-relaxed">
            Set 5-minute intentions before opening Instagram. Reflect on your digital habits and participate in our class digital wellness study.
          </p>
        </div>

        {/* 3 Value Pillars */}
        <div className="grid grid-cols-3 gap-2 w-full pt-1">
          <div className="bg-white rounded-xl p-2.5 border border-slate-200/80 shadow-xs flex flex-col items-center text-center">
            <div className="w-7 h-7 rounded-lg bg-orange-50 text-[#FF9F43] flex items-center justify-center mb-1">
              <span className="material-symbols-outlined text-[16px]">timer</span>
            </div>
            <span className="text-[10px] font-bold text-slate-800 leading-tight">5-Min Guard</span>
          </div>

          <div className="bg-white rounded-xl p-2.5 border border-slate-200/80 shadow-xs flex flex-col items-center text-center">
            <div className="w-7 h-7 rounded-lg bg-blue-50 text-[#3A5BFF] flex items-center justify-center mb-1">
              <span className="material-symbols-outlined text-[16px]">psychology</span>
            </div>
            <span className="text-[10px] font-bold text-slate-800 leading-tight">Mindful Pause</span>
          </div>

          <div className="bg-white rounded-xl p-2.5 border border-slate-200/80 shadow-xs flex flex-col items-center text-center">
            <div className="w-7 h-7 rounded-lg bg-emerald-50 text-[#00B894] flex items-center justify-center mb-1">
              <span className="material-symbols-outlined text-[16px]">analytics</span>
            </div>
            <span className="text-[10px] font-bold text-slate-800 leading-tight">Class Study</span>
          </div>
        </div>
      </div>

      {/* Google Auth Action & Privacy Notice */}
      <div className="flex flex-col space-y-3 pt-2">
        <button
          onClick={handleGoogleSignIn}
          disabled={isLoading}
          className="w-full h-13 bg-white hover:bg-slate-50 active:scale-[0.98] border border-slate-200 rounded-2xl shadow-md flex items-center justify-center space-x-3 transition-all cursor-pointer"
        >
          {/* Official Google G Logo */}
          <svg className="w-5 h-5 shrink-0" viewBox="0 0 24 24">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
            />
          </svg>
          <span className="font-bold text-sm text-slate-800">
            {isLoading ? 'Connecting Google Account...' : 'Continue with Google'}
          </span>
        </button>

        <p className="text-[10px] text-slate-500 text-center leading-relaxed px-2">
          By signing in, your session durations and anonymous reflection ratings will be aggregated for our monthly classroom research presentation. No private Instagram messages or passwords are ever accessed.
        </p>

        <button
          onClick={handleGuestSignIn}
          className="text-xs font-semibold text-[#3A5BFF] hover:underline text-center py-1 cursor-pointer"
        >
          Explore Demo as Guest →
        </button>
      </div>

    </div>
  );
};
