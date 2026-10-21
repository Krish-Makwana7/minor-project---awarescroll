export type SessionType = 'instagram' | 'youtube' | 'snapchat' | 'reddit' | 'tiktok';

export type TimeOfDayBucket = 'morning' | 'afternoon' | 'evening' | 'night';

export type ScrollImportance = 'important' | 'mindless';

export type ClientSessionPurpose =
  | 'Reply to a message'
  | 'Checking someone\'s reply'
  | 'Check updates'
  | 'Nothing to do, so watch reels'
  | 'Finished all tasks, want to watch reels'
  | 'Study or research'
  | 'Opened automatically / out of habit';

export type DecisionTrigger =
  | 'Interesting content'
  | 'Boredom'
  | 'Stress / mood'
  | 'Notifications / messages'
  | 'Habitual scrolling'
  | 'Unfinished original purpose';

export type ContentCategory =
  | 'Comedy / Memes'
  | 'Education / Technology'
  | 'News / Politics'
  | 'Stories / Personal content'
  | 'Fitness / Lifestyle'
  | 'Music / Entertainment'
  | 'Other / Mixed';

export type PlannedWorkImpact =
  | 'No task planned'
  | 'Delayed a task'
  | 'Interrupted a task'
  | 'No negative impact / planned break';

export type PostScrollFeeling =
  | 'Satisfied'
  | 'Relaxed'
  | 'Neutral'
  | 'Bored'
  | 'Stressed / regretful';

export type SupposedToBeDoing =
  | 'Studying'
  | 'Working'
  | 'Sleeping'
  | 'Socializing'
  | 'Relaxing'
  | 'Nothing planned';

export type HelpfulStopper =
  | 'Time warning'
  | 'Original-purpose reminder'
  | 'Mood check'
  | 'Break suggestion'
  | 'App closure';

export interface RestrictedApp {
  id: string;
  name: string;
  icon: string;
  packageName: string;
  isGuarded: boolean;
  dailyMinutesBudget: number;
}

export interface MotivationalQuote {
  id: string;
  text: string;
  author: string;
  theme: string;
  rationale: string;
}

export interface ClientFeedbackResponse {
  id: string;
  sessionId: string;
  decisionTrigger: DecisionTrigger;
  contentCategory: ContentCategory;
  workImpact: PlannedWorkImpact;
  feeling: PostScrollFeeling;
  supposedToBeDoing: SupposedToBeDoing;
  helpfulStopper: HelpfulStopper;
  timePerception?: 'Felt like 1 min (Lost track of time)' | 'Felt like 5 mins' | 'Felt longer';
  submittedAt: string;
  generatedQuote?: MotivationalQuote;
}

export interface InstagramSessionRecord {
  id: string;
  appId?: string;
  appName?: string;
  intendedLimitMinutes: number;
  actualDurationMinutes: number;
  initialPurpose: ClientSessionPurpose | string;
  timeOfDay: TimeOfDayBucket;
  exceededLimit: boolean;
  closedOnFirstReminder: boolean; // "positive" response stored in database
  feedback?: ClientFeedbackResponse;
  extensionGranted?: boolean; // Granted 5m free usage
  hardLocked?: boolean; // Automatically closed after 5m free usage
  startTime: string;
  endTime: string;
}

export interface UserGoal {
  id: string;
  instagramDailyLimit: number;
  defaultSessionLimit: number;
  avoidHoursEnabled: boolean;
  activeQuestions: string[]; // User-configurable question list
  updatedAt: string;
}

export interface InstagramDashboardSummary {
  totalMinutesToday: number;
  dailyLimitMinutes: number;
  totalSessionsToday: number;
  firstReminderSuccessRate: number; // % times user clicked "Close" on 1st reminder
  morningMinutes: number;
  afternoonMinutes: number;
  eveningMinutes: number;
  nightMinutes: number;
  topSupposedActivity: string;
  topScrollFeeling: string;
  averageSessionMinutes: number;
}

export interface UserProfile {
  name: string;
  email: string;
  studentId: string;
  cohort: string;
  signedInAt: string;
  isGuest?: boolean;
}

export interface ClassCohortSummary {
  totalStudents: number;
  totalStudyDays: number;
  totalCollectiveHours: number;
  overallAdherenceRate: number;
  classMeaningfulPercent: number;
  classMindlessPercent: number;
  topExtensionReasons: { reason: string; percentage: number; count: number }[];
  weeklyAdherenceTrend: { week: string; compliance: number }[];
}

export type DeviceMode = 'phone' | 'tablet' | 'desktop' | 'fullscreen';
export type DemoStep =
  | 'auth'
  | 'app_selector'
  | 'dashboard'
  | 'set_limit'
  | 'instagram_scroll'
  | 'limit_expiry'
  | 'feedback_form'
  | 'motivational_quote'
  | 'hard_lock'
  | 'cohort_study';
