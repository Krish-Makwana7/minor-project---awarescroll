import { ClientFeedbackResponse, MotivationalQuote } from '../types';

export class QuoteEngine {
  public static generateQuote(feedback: Partial<ClientFeedbackResponse>): MotivationalQuote {
    const { feeling, supposedToBeDoing, decisionTrigger, workImpact } = feedback;

    // 1. Procrastinating on Studying
    if (supposedToBeDoing === 'Studying') {
      if (feeling === 'Stressed / regretful' || workImpact === 'Delayed a task') {
        return {
          id: 'quote-study-regret',
          text: 'The pain of discipline weighs ounces, but the pain of regret weighs tons. Return to your books; your future self is watching.',
          author: 'Jim Rohn',
          theme: 'Academic Focus & Procrastination',
          rationale: 'Addresses your stress around delayed study tasks with clear perspective.'
        };
      }
      return {
        id: 'quote-study-focus',
        text: 'Deep work is the superpower of the 21st century. Reclaim your focus for the next 25 minutes.',
        author: 'Cal Newport',
        theme: 'Deep Work',
        rationale: 'Tailored for your study session to cut through algorithmic noise.'
      };
    }

    // 2. Supposed to be Sleeping (Revenge bedtime scrolling)
    if (supposedToBeDoing === 'Sleeping') {
      return {
        id: 'quote-sleep',
        text: 'Sleep is the greatest investment in tomorrow’s clarity. Put the phone down and let your mind recharge peacefully.',
        author: 'Matthew Walker',
        theme: 'Circadian Restoration',
        rationale: 'Helps break late-night dopamine loops so you get restorative rest.'
      };
    }

    // 3. Boredom Triggered Infinite Scroll
    if (decisionTrigger === 'Boredom' || feeling === 'Bored') {
      return {
        id: 'quote-boredom',
        text: 'Boredom is the birthplace of creativity. Don’t drown it in algorithmic short-form distraction.',
        author: 'Manoush Zomorodi',
        theme: 'Conscious Awareness',
        rationale: 'Re-frames boredom as a creative spark rather than a cue to scroll.'
      };
    }

    // 4. Hooked on Reels / Algorithmic Trap
    if (decisionTrigger === 'Interesting content' || decisionTrigger === 'Habitual scrolling') {
      return {
        id: 'quote-algorithm',
        text: 'Thousands of engineers are paid to capture your attention. The greatest rebellion is choosing where you look.',
        author: 'Tristan Harris',
        theme: 'Digital Autonomy',
        rationale: 'Reinforces your intentionality against feed retention algorithms.'
      };
    }

    // 5. Stress / Mood Relief Seeking
    if (decisionTrigger === 'Stress / mood' || feeling === 'Stressed / regretful') {
      return {
        id: 'quote-stress',
        text: 'Peace comes from within. Social media promises relief, but real calm is found when you disconnect and breathe.',
        author: 'Seneca',
        theme: 'Emotional Regulation',
        rationale: 'Encourages genuine mindfulness over temporary screen numbing.'
      };
    }

    // Default inspiring wisdom
    return {
      id: 'quote-general',
      text: 'You have power over your mind — not outside events. Realize this, and you will find immense strength.',
      author: 'Marcus Aurelius',
      theme: 'Self-Mastery',
      rationale: 'Grounding wisdom for your final 5-minute intention window.'
    };
  }
}
