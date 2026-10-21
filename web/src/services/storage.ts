import {
  UserGoal,
  InstagramSessionRecord,
  ClientFeedbackResponse,
  InstagramDashboardSummary,
  UserProfile,
  ClassCohortSummary,
  RestrictedApp,
  TimeOfDayBucket
} from '../types';
import { QuoteEngine } from './quoteEngine';

const STORAGE_KEYS = {
  GOAL: 'awarescroll_goal',
  SESSIONS: 'awarescroll_instagram_sessions',
  LIMIT_CONFIGURED: 'awarescroll_limit_configured',
  USER_PROFILE: 'awarescroll_user_profile',
  RESTRICTED_APPS: 'awarescroll_restricted_apps'
};

const DEFAULT_RESTRICTED_APPS: RestrictedApp[] = [
  { id: 'instagram', name: 'Instagram', icon: 'photo_camera', packageName: 'com.instagram.android', isGuarded: true, dailyMinutesBudget: 30 },
  { id: 'youtube', name: 'YouTube / Shorts', icon: 'smart_display', packageName: 'com.google.android.youtube', isGuarded: true, dailyMinutesBudget: 25 },
  { id: 'snapchat', name: 'Snapchat', icon: 'chat_bubble', packageName: 'com.snapchat.android', isGuarded: false, dailyMinutesBudget: 15 },
  { id: 'reddit', name: 'Reddit', icon: 'forum', packageName: 'com.reddit.frontpage', isGuarded: false, dailyMinutesBudget: 20 },
  { id: 'tiktok', name: 'TikTok', icon: 'movie', packageName: 'com.zhiliaoapp.musically', isGuarded: false, dailyMinutesBudget: 20 }
];

const DEFAULT_USER: UserProfile = {
  name: 'Alex Rivera',
  email: 'alex.rivera@university.edu',
  studentId: 'CS-2026-409',
  cohort: 'Computer Science - Section B (Minor Project)',
  signedInAt: new Date().toISOString(),
  isGuest: false
};

const DEFAULT_GOAL: UserGoal = {
  id: 'goal-001',
  instagramDailyLimit: 30,
  defaultSessionLimit: 5,
  avoidHoursEnabled: true,
  activeQuestions: [
    'decisionTrigger',
    'contentCategory',
    'workImpact',
    'feeling',
    'supposedToBeDoing',
    'helpfulStopper'
  ],
  updatedAt: new Date().toISOString()
};

export const getTimeOfDayBucket = (date: Date = new Date()): TimeOfDayBucket => {
  const hours = date.getHours();
  if (hours >= 5 && hours < 12) return 'morning';
  if (hours >= 12 && hours < 17) return 'afternoon';
  if (hours >= 17 && hours < 21) return 'evening';
  return 'night';
};

const INITIAL_SESSIONS: InstagramSessionRecord[] = [
  {
    id: 'session-01',
    appId: 'instagram',
    appName: 'Instagram',
    intendedLimitMinutes: 5,
    actualDurationMinutes: 4.8,
    initialPurpose: 'Reply to a message',
    timeOfDay: 'morning',
    exceededLimit: false,
    closedOnFirstReminder: true, // Closed on first reminder
    startTime: new Date(Date.now() - 1000 * 60 * 60 * 6).toISOString(),
    endTime: new Date(Date.now() - 1000 * 60 * 60 * 5.92).toISOString()
  },
  {
    id: 'session-02',
    appId: 'instagram',
    appName: 'Instagram',
    intendedLimitMinutes: 5,
    actualDurationMinutes: 14.5,
    initialPurpose: 'Nothing to do, so watch reels',
    timeOfDay: 'evening',
    exceededLimit: true,
    closedOnFirstReminder: false,
    extensionGranted: true,
    hardLocked: true,
    startTime: new Date(Date.now() - 1000 * 60 * 60 * 3).toISOString(),
    endTime: new Date(Date.now() - 1000 * 60 * 60 * 2.75).toISOString(),
    feedback: {
      id: 'fb-02',
      sessionId: 'session-02',
      decisionTrigger: 'Interesting content',
      contentCategory: 'Comedy / Memes',
      workImpact: 'Delayed a task',
      feeling: 'Stressed / regretful',
      supposedToBeDoing: 'Studying',
      helpfulStopper: 'App closure',
      timePerception: 'Felt like 1 min (Lost track of time)',
      submittedAt: new Date(Date.now() - 1000 * 60 * 60 * 2.75).toISOString(),
      generatedQuote: {
        id: 'quote-study-regret',
        text: 'The pain of discipline weighs ounces, but the pain of regret weighs tons. Return to your books; your future self is watching.',
        author: 'Jim Rohn',
        theme: 'Academic Focus',
        rationale: 'Generated for delayed study session with regret feeling.'
      }
    }
  },
  {
    id: 'session-03',
    appId: 'instagram',
    appName: 'Instagram',
    intendedLimitMinutes: 5,
    actualDurationMinutes: 5.0,
    initialPurpose: 'Check updates',
    timeOfDay: 'afternoon',
    exceededLimit: false,
    closedOnFirstReminder: true,
    startTime: new Date(Date.now() - 1000 * 60 * 60 * 1).toISOString(),
    endTime: new Date(Date.now() - 1000 * 60 * 60 * 0.92).toISOString()
  }
];

export class StorageService {
  private static listeners: Set<() => void> = new Set();

  public static init() {
    if (typeof window === 'undefined') return;

    if (!localStorage.getItem(STORAGE_KEYS.GOAL)) {
      localStorage.setItem(STORAGE_KEYS.GOAL, JSON.stringify(DEFAULT_GOAL));
    }
    if (!localStorage.getItem(STORAGE_KEYS.SESSIONS)) {
      localStorage.setItem(STORAGE_KEYS.SESSIONS, JSON.stringify(INITIAL_SESSIONS));
    }
    if (!localStorage.getItem(STORAGE_KEYS.RESTRICTED_APPS)) {
      localStorage.setItem(STORAGE_KEYS.RESTRICTED_APPS, JSON.stringify(DEFAULT_RESTRICTED_APPS));
    }
  }

  public static subscribe(listener: () => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private static notifyListeners() {
    this.listeners.forEach((fn) => fn());
  }

  // --- Restricted Apps Management ---
  public static getRestrictedApps(): RestrictedApp[] {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.RESTRICTED_APPS);
      return data ? JSON.parse(data) : DEFAULT_RESTRICTED_APPS;
    } catch {
      return DEFAULT_RESTRICTED_APPS;
    }
  }

  public static toggleRestrictedApp(appId: string) {
    const list = this.getRestrictedApps();
    const app = list.find((a) => a.id === appId);
    if (app) {
      app.isGuarded = !app.isGuarded;
      localStorage.setItem(STORAGE_KEYS.RESTRICTED_APPS, JSON.stringify(list));
      this.notifyListeners();
    }
  }

  // --- User Profile & Auth ---
  public static isUserSignedIn(): boolean {
    try {
      return localStorage.getItem(STORAGE_KEYS.USER_PROFILE) !== null;
    } catch {
      return false;
    }
  }

  public static getUserProfile(): UserProfile | null {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.USER_PROFILE);
      return data ? JSON.parse(data) : null;
    } catch {
      return null;
    }
  }

  public static saveUserProfile(profile: UserProfile) {
    localStorage.setItem(STORAGE_KEYS.USER_PROFILE, JSON.stringify(profile));
    this.notifyListeners();
  }

  public static signInWithGoogle(customName?: string, customEmail?: string) {
    const profile: UserProfile = {
      name: customName || 'Alex Rivera',
      email: customEmail || 'alex.rivera@university.edu',
      studentId: 'CS-2026-409',
      cohort: 'Computer Science - Section B (Minor Project)',
      signedInAt: new Date().toISOString(),
      isGuest: false
    };
    this.saveUserProfile(profile);
  }

  public static signInAsGuest() {
    const profile: UserProfile = {
      name: 'Guest Student',
      email: 'guest@classroom.local',
      studentId: 'DEMO-USER',
      cohort: 'Classroom Evaluation Mode',
      signedInAt: new Date().toISOString(),
      isGuest: true
    };
    this.saveUserProfile(profile);
  }

  public static signOut() {
    localStorage.removeItem(STORAGE_KEYS.USER_PROFILE);
    this.notifyListeners();
  }

  // --- Limits & Goals ---
  public static isLimitConfigured(): boolean {
    try {
      return localStorage.getItem(STORAGE_KEYS.LIMIT_CONFIGURED) === 'true';
    } catch {
      return false;
    }
  }

  public static getGoal(): UserGoal {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.GOAL);
      return data ? JSON.parse(data) : DEFAULT_GOAL;
    } catch {
      return DEFAULT_GOAL;
    }
  }

  public static saveGoal(goal: UserGoal) {
    goal.updatedAt = new Date().toISOString();
    localStorage.setItem(STORAGE_KEYS.GOAL, JSON.stringify(goal));
    this.notifyListeners();
  }

  public static saveConfiguredLimit(sessionLimitMinutes: number) {
    const goal = this.getGoal();
    goal.defaultSessionLimit = sessionLimitMinutes;
    this.saveGoal(goal);
    try {
      localStorage.setItem(STORAGE_KEYS.LIMIT_CONFIGURED, 'true');
    } catch (e) {
      console.warn(e);
    }
    this.notifyListeners();
  }

  // --- Sessions & Client Feedback ---
  public static getSessions(): InstagramSessionRecord[] {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.SESSIONS);
      return data ? JSON.parse(data) : INITIAL_SESSIONS;
    } catch {
      return INITIAL_SESSIONS;
    }
  }

  public static addSession(session: InstagramSessionRecord) {
    const list = this.getSessions();
    list.unshift(session);
    localStorage.setItem(STORAGE_KEYS.SESSIONS, JSON.stringify(list));
    this.notifyListeners();
  }

  public static saveFeedback(sessionId: string, feedback: ClientFeedbackResponse) {
    const list = this.getSessions();
    const item = list.find((s) => s.id === sessionId);
    if (item) {
      item.feedback = feedback;
      item.extensionGranted = true;
      localStorage.setItem(STORAGE_KEYS.SESSIONS, JSON.stringify(list));
      this.notifyListeners();
    }
  }

  public static markHardLocked(sessionId: string) {
    const list = this.getSessions();
    const item = list.find((s) => s.id === sessionId);
    if (item) {
      item.hardLocked = true;
      localStorage.setItem(STORAGE_KEYS.SESSIONS, JSON.stringify(list));
      this.notifyListeners();
    }
  }

  // --- In-Built Dashboard with Chronotype / Time-of-Day Analysis ---
  public static getDashboardSummary(): InstagramDashboardSummary {
    const sessions = this.getSessions();
    const goal = this.getGoal();

    const totalMinutes = sessions.reduce((acc, s) => acc + s.actualDurationMinutes, 0);
    const avgMinutes = sessions.length > 0 ? totalMinutes / sessions.length : 5;

    // First-reminder success rate: How often user clicked "Close" immediately on first 5-min alarm
    const closedOnFirst = sessions.filter((s) => s.closedOnFirstReminder).length;
    const firstReminderRate = sessions.length > 0 ? Math.round((closedOnFirst / sessions.length) * 100) : 75;

    // Time-of-day distribution (Morning, Afternoon, Evening, Night)
    let morningMins = 0;
    let afternoonMins = 0;
    let eveningMins = 0;
    let nightMins = 0;

    sessions.forEach((s) => {
      const mins = s.actualDurationMinutes;
      if (s.timeOfDay === 'morning') morningMins += mins;
      else if (s.timeOfDay === 'afternoon') afternoonMins += mins;
      else if (s.timeOfDay === 'evening') eveningMins += mins;
      else nightMins += mins;
    });

    // Procrastination insight: What was user supposed to be doing?
    const supposedCounts: Record<string, number> = {};
    const feelingCounts: Record<string, number> = {};

    sessions.forEach((s) => {
      if (s.feedback?.supposedToBeDoing) {
        supposedCounts[s.feedback.supposedToBeDoing] = (supposedCounts[s.feedback.supposedToBeDoing] || 0) + 1;
      }
      if (s.feedback?.feeling) {
        feelingCounts[s.feedback.feeling] = (feelingCounts[s.feedback.feeling] || 0) + 1;
      }
    });

    const topSupposed = Object.entries(supposedCounts).sort((a, b) => b[1] - a[1])[0]?.[0] || 'Studying';
    const topFeeling = Object.entries(feelingCounts).sort((a, b) => b[1] - a[1])[0]?.[0] || 'Stressed / regretful';

    return {
      totalMinutesToday: Math.round(totalMinutes * 10) / 10,
      dailyLimitMinutes: goal.instagramDailyLimit,
      totalSessionsToday: sessions.length,
      firstReminderSuccessRate: firstReminderRate,
      morningMinutes: Math.round(morningMins * 10) / 10,
      afternoonMinutes: Math.round(afternoonMins * 10) / 10,
      eveningMinutes: Math.round(eveningMins * 10) / 10,
      nightMinutes: Math.round(nightMins * 10) / 10,
      topSupposedActivity: topSupposed,
      topScrollFeeling: topFeeling,
      averageSessionMinutes: Math.round(avgMinutes * 10) / 10
    };
  }

  // --- Classroom Cohort Research Presentation Dataset ---
  public static getClassCohortSummary(): ClassCohortSummary {
    return {
      totalStudents: 42,
      totalStudyDays: 30,
      totalCollectiveHours: 384.5,
      overallAdherenceRate: 68,
      classMeaningfulPercent: 32,
      classMindlessPercent: 68,
      topExtensionReasons: [
        { reason: 'Got hooked on Reels / algorithm', percentage: 48, count: 214 },
        { reason: 'Avoiding academic work / assignments', percentage: 26, count: 116 },
        { reason: 'Finishing a direct message conversation', percentage: 16, count: 71 },
        { reason: 'Pure boredom / subconscious habit', percentage: 10, count: 45 }
      ],
      weeklyAdherenceTrend: [
        { week: 'Week 1 (Baseline)', compliance: 42 },
        { week: 'Week 2 (5m Intervention)', compliance: 58 },
        { week: 'Week 3 (Reflections)', compliance: 65 },
        { week: 'Week 4 (Sustained Guard)', compliance: 71 }
      ]
    };
  }

  public static exportClassResearchDataset(): string {
    const user = this.getUserProfile() || DEFAULT_USER;
    const sessions = this.getSessions();
    const summary = this.getDashboardSummary();
    const cohort = this.getClassCohortSummary();

    const exportPayload = {
      project: 'AwareScroll - Digital Self-Regulation & Behavioral Reflection Study',
      studyCohort: 'CS-2026 Minor Project Classroom Cohort',
      studentContributor: {
        name: user.name,
        studentId: user.studentId,
        cohort: user.cohort
      },
      individualTelemetry: {
        summary,
        recordedSessions: sessions
      },
      classCohortAggregation: cohort,
      exportedAt: new Date().toISOString()
    };

    return JSON.stringify(exportPayload, null, 2);
  }
}
