package com.awarescroll.awarescroll_app

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.*

class AwareScrollBlockerActivity : Activity() {

    private lateinit var container: LinearLayout
    private var appName: String = "Instagram"
    private var limitMinutes: Int = 5

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        appName = intent.getStringExtra("APP_NAME") ?: "Instagram"
        limitMinutes = intent.getIntExtra("LIMIT_MINUTES", 5)

        // Root View with Mindful Light Canvas
        container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#FCF8FF")) // Mindful Light Canvas
            setPadding(dpToPx(24), dpToPx(32), dpToPx(24), dpToPx(32))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }

        setContentView(container)

        // Render Scene: Limit Expiry Prompt
        showExpiryPrompt()
    }

    // ==========================================
    // RESTRICTION SCREEN (MINDFUL FOCUS)
    // ==========================================
    private fun showExpiryPrompt() {
        container.removeAllViews()

        // 1. Badge: "05:00 LIMIT REACHED"
        val badge = TextView(this).apply {
            text = String.format("%02d:00 LIMIT REACHED", limitMinutes)
            setTextColor(Color.parseColor("#7A4300")) // Mindful amber text
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(16), dpToPx(6), dpToPx(16), dpToPx(6))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FFF4E8")) // Amber container
                setStroke(dpToPx(1), Color.parseColor("#FFDCC2"))
                cornerRadius = dpToPx(20).toFloat()
            }
        }
        container.addView(badge)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(24))
        })

        // 2. Title: "Your time is up! What would you like to do?"
        val title = TextView(this).apply {
            text = "Your time is up!\nWhat would you like to do?"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.2f)
        }
        container.addView(title)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(12))
        })

        // Subtitle: Explains configured boundary
        val subtitle = TextView(this).apply {
            text = "You set a $limitMinutes-minute boundary for $appName.\nTake an intentional pause before continuing or wrapping up."
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.3f)
        }
        container.addView(subtitle)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(36))
        })

        // 3. Option 1: CLOSE INSTAGRAM Button (Primary Blue)
        val closeBtn = Button(this).apply {
            text = "Close Instagram"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#3A5BFF")) // Primary Action Blue
                cornerRadius = dpToPx(14).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(52)
            )
            setOnClickListener {
                closeAppAndExit()
            }
        }
        container.addView(closeBtn)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(12))
        })

        // 4. Option 2: CONTINUE (Requires Reflection) Button
        val continueBtn = Button(this).apply {
            text = "Continue (Requires Reflection)"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(14).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(50)
            )
            setOnClickListener {
                showFollowUpQuestion()
            }
        }
        container.addView(continueBtn)
    }

    // ==========================================
    // EXTENSION SURVEY FORM (7 QUESTIONS + DURATION)
    // ==========================================
    private var selectedExtensionMin = 5
    private lateinit var confirmBtn: Button

    private fun showFollowUpQuestion() {
        container.removeAllViews()

        val scroll = ScrollView(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
            isVerticalScrollBarEnabled = false
        }

        val inner = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(0, dpToPx(8), 0, dpToPx(32))
        }
        scroll.addView(inner)
        container.addView(scroll)

        // Header Tag
        val tag = TextView(this).apply {
            text = "● RECONSIDERATION"
            setTextColor(Color.parseColor("#00B894")) // Emerald
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(12), dpToPx(4), dpToPx(12), dpToPx(4))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E0F7F8"))
                cornerRadius = dpToPx(12).toFloat()
            }
        }
        inner.addView(tag)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(10)) })

        // Title & Description
        val heading = TextView(this).apply {
            text = "Conscious Reflection"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        inner.addView(heading)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(4)) })

        val hint = TextView(this).apply {
            text = "Answer the following reflections to unlock a temporary extension."
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            gravity = Gravity.CENTER
        }
        inner.addView(hint)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(18)) })

        // Q1: Purpose
        addSurveyQuestion(
            inner,
            number = "1",
            title = "Purpose of Usage",
            subtitle = "Why do you want use it, clearly mention your purpose?",
            options = listOf(
                "Reply to a message",
                "Checking someone's reply",
                "Check updates",
                "Nothing to do, so watch reels",
                "Finished all tasks, want to watch reels",
                "Study or research",
                "Opened automatically / out of habit"
            )
        )

        // Q2: Decision to continue
        addSurveyQuestion(
            inner,
            number = "2",
            title = "Decision Factor",
            subtitle = "What most influenced your decision to continue?",
            options = listOf(
                "Interesting content",
                "Boredom",
                "Stress / mood",
                "Notifications / messages",
                "Habitual scrolling",
                "Unfinished original purpose"
            )
        )

        // Q3: Content Category
        addSurveyQuestion(
            inner,
            number = "3",
            title = "Content Category",
            subtitle = "Which content category kept you engaged?",
            options = listOf(
                "Comedy / Memes",
                "Education / Technology",
                "News / Politics",
                "Stories / Personal content",
                "Fitness / Lifestyle",
                "Music / Entertainment",
                "Other / Mixed"
            )
        )

        // Q4: Effect on planned work
        addSurveyQuestion(
            inner,
            number = "4",
            title = "Effect on Planned Work",
            subtitle = "How did this session affect your planned work?",
            options = listOf(
                "No task planned",
                "Delayed a task",
                "Interrupted a task",
                "No negative impact / planned break"
            )
        )

        // Q5: Feeling after scrolling
        addSurveyQuestion(
            inner,
            number = "5",
            title = "Emotional State",
            subtitle = "How do you feel after scrolling?",
            options = listOf(
                "Satisfied",
                "Relaxed",
                "Neutral",
                "Bored",
                "Stressed / regretful"
            )
        )

        // Q6: Supposed to be doing
        addSurveyQuestion(
            inner,
            number = "6",
            title = "Intended Activity",
            subtitle = "What were you supposed to be doing?",
            options = listOf(
                "Studying",
                "Working",
                "Sleeping",
                "Socializing",
                "Relaxing",
                "Nothing planned"
            )
        )

        // Q7: What would have helped stop
        addSurveyQuestion(
            inner,
            number = "7",
            title = "Intervention Help",
            subtitle = "What would have helped you stop?",
            options = listOf(
                "Time warning",
                "Original-purpose reminder",
                "Mood check",
                "Break suggestion",
                "App closure"
            )
        )

        // Q8: Extension Duration
        addExtensionDurationSection(inner)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(16)) })

        // Confirm & Continue Button
        confirmBtn = Button(this).apply {
            text = "Confirm & Unlock (+${selectedExtensionMin} Min Extension)"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#00B894")) // Emerald accent
                cornerRadius = dpToPx(16).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(52)
            )
            setOnClickListener {
                AwareScrollMonitor.grantExtension(selectedExtensionMin)
                finish()
            }
        }
        inner.addView(confirmBtn)
    }

    private fun addSurveyQuestion(
        parent: LinearLayout,
        number: String,
        title: String,
        subtitle: String,
        options: List<String>
    ) {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(16).toFloat()
            }
            setPadding(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(16))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(14)
            }
        }

        // Question Title Row
        val header = TextView(this).apply {
            text = "$number. $title"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
        }
        card.addView(header)

        val sub = TextView(this).apply {
            text = subtitle
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setPadding(0, dpToPx(2), 0, dpToPx(10))
        }
        card.addView(sub)

        var selectedIdx = 0
        val optionViews = mutableListOf<TextView>()

        for (i in options.indices) {
            val opt = options[i]
            val tv = TextView(this).apply {
                text = opt
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setPadding(dpToPx(14), dpToPx(10), dpToPx(14), dpToPx(10))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(6)
                }
            }

            fun update() {
                for (j in optionViews.indices) {
                    val isSel = (j == selectedIdx)
                    optionViews[j].apply {
                        setTextColor(if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#141528"))
                        typeface = if (isSel) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
                        background = GradientDrawable().apply {
                            setColor(if (isSel) Color.parseColor("#EEECFF") else Color.parseColor("#FCF8FF"))
                            setStroke(dpToPx(if (isSel) 2 else 1), if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#E2E4F0"))
                            cornerRadius = dpToPx(12).toFloat()
                        }
                    }
                }
            }

            tv.setOnClickListener {
                selectedIdx = i
                update()
            }

            optionViews.add(tv)
            card.addView(tv)
        }

        // Initialize styling
        for (j in optionViews.indices) {
            val isSel = (j == 0)
            optionViews[j].apply {
                setTextColor(if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#141528"))
                typeface = if (isSel) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#EEECFF") else Color.parseColor("#FCF8FF"))
                    setStroke(dpToPx(if (isSel) 2 else 1), if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#E2E4F0"))
                    cornerRadius = dpToPx(12).toFloat()
                }
            }
        }

        parent.addView(card)
    }

    private fun addExtensionDurationSection(parent: LinearLayout) {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(16).toFloat()
            }
            setPadding(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(16))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(14)
            }
        }

        val header = TextView(this).apply {
            text = "8. Extension Commitment"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
        }
        card.addView(header)

        val sub = TextView(this).apply {
            text = "Choose your conscious extension duration:"
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setPadding(0, dpToPx(2), 0, dpToPx(10))
        }
        card.addView(sub)

        val durations = listOf(2, 5, 10, 15)
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        val durViews = mutableListOf<TextView>()

        for (d in durations) {
            val tv = TextView(this).apply {
                text = "+${d}m"
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(dpToPx(6), dpToPx(10), dpToPx(6), dpToPx(10))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    marginEnd = dpToPx(6)
                }
            }

            fun updateDurations() {
                for (k in durations.indices) {
                    val isSel = (durations[k] == selectedExtensionMin)
                    durViews[k].apply {
                        setTextColor(if (isSel) Color.parseColor("#00B894") else Color.parseColor("#6B6F8C"))
                        background = GradientDrawable().apply {
                            setColor(if (isSel) Color.parseColor("#E0F7F8") else Color.parseColor("#FCF8FF"))
                            setStroke(dpToPx(if (isSel) 2 else 1), if (isSel) Color.parseColor("#00B894") else Color.parseColor("#E2E4F0"))
                            cornerRadius = dpToPx(12).toFloat()
                        }
                    }
                }
                if (::confirmBtn.isInitialized) {
                    confirmBtn.text = "Confirm & Unlock (+${selectedExtensionMin} Min Extension)"
                }
            }

            tv.setOnClickListener {
                selectedExtensionMin = d
                updateDurations()
            }

            durViews.add(tv)
            row.addView(tv)
        }

        // Initialize durations styling
        for (k in durations.indices) {
            val isSel = (durations[k] == selectedExtensionMin)
            durViews[k].apply {
                setTextColor(if (isSel) Color.parseColor("#00B894") else Color.parseColor("#6B6F8C"))
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#E0F7F8") else Color.parseColor("#FCF8FF"))
                    setStroke(dpToPx(if (isSel) 2 else 1), if (isSel) Color.parseColor("#00B894") else Color.parseColor("#E2E4F0"))
                    cornerRadius = dpToPx(12).toFloat()
                }
            }
        }

        card.addView(row)
        parent.addView(card)
    }

    private fun closeAppAndExit() {
        AwareScrollMonitor.isBlockerShowing = false

        // 1. Accessibility Service sends global HOME action
        val closedViaAccessibility = AwareScrollAccessibilityService.instance?.closeAppToHome() ?: false

        if (!closedViaAccessibility) {
            // 2. Direct Android HOME Intent fallback
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(homeIntent)
        }

        finish()
    }

    override fun onBackPressed() {
        // Prevent bypassing restriction via Android back button
        closeAppAndExit()
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }
}
