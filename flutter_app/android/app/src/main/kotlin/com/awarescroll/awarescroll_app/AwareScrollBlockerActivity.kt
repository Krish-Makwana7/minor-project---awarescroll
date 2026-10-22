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

        // Root View
        container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0B0D13")) // Deep obsidian background
            setPadding(dpToPx(24), dpToPx(32), dpToPx(24), dpToPx(32))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }

        setContentView(container)

        // Render Scene 3: Limit Expiry Prompt
        showExpiryPrompt()
    }

    // ==========================================
    // SCENE 3: RESTRICTION SCREEN
    // ==========================================
    private fun showExpiryPrompt() {
        container.removeAllViews()

        // 1. Badge: "05:00 LIMIT REACHED"
        val badge = TextView(this).apply {
            text = String.format("%02d:00 LIMIT REACHED", limitMinutes)
            setTextColor(Color.parseColor("#FF9F43")) // AccentReflect orange
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(16), dpToPx(6), dpToPx(16), dpToPx(6))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#26FF9F43"))
                cornerRadius = dpToPx(16).toFloat()
            }
        }
        container.addView(badge)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(24))
        })

        // 2. Title: "Your time is up! What would you like to do?"
        val title = TextView(this).apply {
            text = "Your time is up! What would you like to do?"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.2f)
        }
        container.addView(title)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(12))
        })

        // Subtitle: Explains the configured boundary
        val subtitle = TextView(this).apply {
            text = "You reached your configured $limitMinutes-minute limit for $appName.\nTake a mindful pause."
            setTextColor(Color.parseColor("#A0A5BD"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.2f)
        }
        container.addView(subtitle)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(40))
        })

        // 3. Option 1: CLOSE APP Button
        val closeBtn = Button(this).apply {
            text = "Close App"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E1306C")) // Instagram berry pink
                cornerRadius = dpToPx(16).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(54)
            )
            setOnClickListener {
                closeAppAndExit()
            }
        }
        container.addView(closeBtn)

        // Spacer
        container.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(1, dpToPx(14))
        })

        // 4. Option 2: CONTINUE Button
        val continueBtn = Button(this).apply {
            text = "Continue"
            setTextColor(Color.parseColor("#CBD0E2"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1B1F30"))
                setStroke(dpToPx(1), Color.parseColor("#2E3550"))
                cornerRadius = dpToPx(16).toFloat()
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
    // SCENE 4: EXTENSION SURVEY FORM
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
            text = "● EXTENSION SURVEY"
            setTextColor(Color.parseColor("#00E676")) // Green
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(12), dpToPx(4), dpToPx(12), dpToPx(4))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#2600E676"))
                cornerRadius = dpToPx(12).toFloat()
            }
        }
        inner.addView(tag)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(10)) })

        // Title & Description
        val heading = TextView(this).apply {
            text = "Mindful Extension Survey"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        inner.addView(heading)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(4)) })

        val hint = TextView(this).apply {
            text = "Please complete these reflections to consciously unlock an extension."
            setTextColor(Color.parseColor("#8E97B0"))
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
            text = "Confirm & Extend Time (+${selectedExtensionMin}m)"
            setTextColor(Color.parseColor("#0B0D13"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#00E676")) // Vibrant emerald green
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
                setColor(Color.parseColor("#151824"))
                setStroke(dpToPx(1), Color.parseColor("#262B3D"))
                cornerRadius = dpToPx(16).toFloat()
            }
            setPadding(dpToPx(14), dpToPx(14), dpToPx(14), dpToPx(14))
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
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
        }
        card.addView(header)

        val sub = TextView(this).apply {
            text = subtitle
            setTextColor(Color.parseColor("#7E869E"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
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
                        setTextColor(if (isSel) Color.WHITE else Color.parseColor("#8E94B3"))
                        background = GradientDrawable().apply {
                            setColor(if (isSel) Color.parseColor("#2A1B2E") else Color.parseColor("#111319"))
                            setStroke(dpToPx(if (isSel) 1 else 1), if (isSel) Color.parseColor("#E1306C") else Color.parseColor("#202538"))
                            cornerRadius = dpToPx(10).toFloat()
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
                setTextColor(if (isSel) Color.WHITE else Color.parseColor("#8E94B3"))
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#2A1B2E") else Color.parseColor("#111319"))
                    setStroke(dpToPx(1), if (isSel) Color.parseColor("#E1306C") else Color.parseColor("#202538"))
                    cornerRadius = dpToPx(10).toFloat()
                }
            }
        }

        parent.addView(card)
    }

    private fun addExtensionDurationSection(parent: LinearLayout) {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#151824"))
                setStroke(dpToPx(1), Color.parseColor("#262B3D"))
                cornerRadius = dpToPx(16).toFloat()
            }
            setPadding(dpToPx(14), dpToPx(14), dpToPx(14), dpToPx(14))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(14)
            }
        }

        val header = TextView(this).apply {
            text = "8. Extension Duration"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
        }
        card.addView(header)

        val sub = TextView(this).apply {
            text = "How much time do you consciously commit to extend?"
            setTextColor(Color.parseColor("#7E869E"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
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
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(dpToPx(8), dpToPx(12), dpToPx(8), dpToPx(12))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    marginEnd = dpToPx(6)
                }
            }

            fun updateDurations() {
                for (k in durations.indices) {
                    val isSel = (durations[k] == selectedExtensionMin)
                    durViews[k].apply {
                        setTextColor(if (isSel) Color.parseColor("#00E676") else Color.WHITE)
                        background = GradientDrawable().apply {
                            setColor(if (isSel) Color.parseColor("#2600E676") else Color.parseColor("#111319"))
                            setStroke(dpToPx(1), if (isSel) Color.parseColor("#00E676") else Color.parseColor("#202538"))
                            cornerRadius = dpToPx(10).toFloat()
                        }
                    }
                }
                if (::confirmBtn.isInitialized) {
                    confirmBtn.text = "Confirm & Extend Time (+${selectedExtensionMin}m)"
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
                setTextColor(if (isSel) Color.parseColor("#00E676") else Color.WHITE)
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#2600E676") else Color.parseColor("#111319"))
                    setStroke(dpToPx(1), if (isSel) Color.parseColor("#00E676") else Color.parseColor("#202538"))
                    cornerRadius = dpToPx(10).toFloat()
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
