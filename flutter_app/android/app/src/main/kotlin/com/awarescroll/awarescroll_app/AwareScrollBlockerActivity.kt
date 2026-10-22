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
            setBackgroundColor(Color.parseColor("#14152B")) // Dark cosmic background
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
                setColor(Color.parseColor("#3A5BFF")) // Primary brand blue
                cornerRadius = dpToPx(14).toFloat()
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
                setColor(Color.parseColor("#1C1E3A"))
                setStroke(dpToPx(1), Color.parseColor("#2E335B"))
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
    // SCENE 4: CONSCIOUS FOLLOW-UP QUESTION
    // ==========================================
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
            setPadding(0, dpToPx(16), 0, dpToPx(16))
        }
        scroll.addView(inner)
        container.addView(scroll)

        // Tag
        val tag = TextView(this).apply {
            text = "CONSCIOUS REFLECTION"
            setTextColor(Color.parseColor("#00B894")) // Green
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(12), dpToPx(4), dpToPx(12), dpToPx(4))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#2600B894"))
                cornerRadius = dpToPx(12).toFloat()
            }
        }
        inner.addView(tag)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(14)) })

        // Follow-Up Question
        val question = TextView(this).apply {
            text = "What most influenced your decision to continue scrolling?"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.2f)
        }
        inner.addView(question)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(8)) })

        val hint = TextView(this).apply {
            text = "Please choose a reason before proceeding."
            setTextColor(Color.parseColor("#A0A5BD"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            gravity = Gravity.CENTER
        }
        inner.addView(hint)

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(20)) })

        // Answer Options
        val options = listOf(
            "Interesting content",
            "Boredom",
            "Stress / mood",
            "Notifications / messages",
            "Habitual scrolling",
            "Unfinished original purpose"
        )

        var selectedIndex = 0
        val optionViews = mutableListOf<TextView>()

        for (i in options.indices) {
            val opt = options[i]
            val tv = TextView(this).apply {
                text = opt
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                setPadding(dpToPx(16), dpToPx(14), dpToPx(16), dpToPx(14))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(8)
                }
            }

            fun updateSelection() {
                for (j in optionViews.indices) {
                    val isSel = (j == selectedIndex)
                    optionViews[j].apply {
                        setTextColor(if (isSel) Color.WHITE else Color.parseColor("#8E94B3"))
                        background = GradientDrawable().apply {
                            setColor(if (isSel) Color.parseColor("#29357A") else Color.parseColor("#1C1E3A"))
                            setStroke(dpToPx(1), if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#252847"))
                            cornerRadius = dpToPx(12).toFloat()
                        }
                    }
                }
            }

            tv.setOnClickListener {
                selectedIndex = i
                updateSelection()
            }

            optionViews.add(tv)
            inner.addView(tv)
        }

        // Initialize selection styling
        for (j in optionViews.indices) {
            val isSel = (j == 0)
            optionViews[j].apply {
                setTextColor(if (isSel) Color.WHITE else Color.parseColor("#8E94B3"))
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#29357A") else Color.parseColor("#1C1E3A"))
                    setStroke(dpToPx(1), if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#252847"))
                    cornerRadius = dpToPx(12).toFloat()
                }
            }
        }

        inner.addView(View(this).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(16)) })

        // Confirm & Continue Button
        val confirmBtn = Button(this).apply {
            text = "Confirm & Continue (5m Extension)"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#00B894")) // Green extension action
                cornerRadius = dpToPx(14).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(52)
            )
            setOnClickListener {
                // Grant 5-minute extension to monitor
                AwareScrollMonitor.grantExtension(5)
                finish()
            }
        }
        inner.addView(confirmBtn)
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
