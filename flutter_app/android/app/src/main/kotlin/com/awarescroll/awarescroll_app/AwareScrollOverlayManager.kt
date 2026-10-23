package com.awarescroll.awarescroll_app

import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.*

object AwareScrollOverlayManager {

    private const val TAG = "AwareScrollOverlay"
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var breathAnimator: ValueAnimator? = null

    @Volatile var isShowing = false

    @SuppressLint("InflateParams")
    fun show(context: Context, appName: String = "Instagram", limitMinutes: Int = 5) {
        mainHandler.post {
            if (isShowing && overlayView != null) {
                Log.d(TAG, "Overlay is already showing")
                return@post
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                Log.w(TAG, "SYSTEM_ALERT_WINDOW permission not granted. Falling back to Activity.")
                fallbackToActivity(context, appName, limitMinutes)
                return@post
            }

            try {
                windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
                if (windowManager == null) {
                    fallbackToActivity(context, appName, limitMinutes)
                    return@post
                }

                val layoutParamsType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                }

                val params = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    layoutParamsType,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                    PixelFormat.TRANSLUCENT
                ).apply {
                    gravity = Gravity.FILL
                }

                val root = createOverlayView(context, appName, limitMinutes)
                overlayView = root
                windowManager?.addView(root, params)
                isShowing = true
                AwareScrollMonitor.isBlockerShowing = true
                Log.d(TAG, "Fullscreen Instagram overlay successfully attached to WindowManager!")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to attach overlay window", e)
                fallbackToActivity(context, appName, limitMinutes)
            }
        }
    }

    fun hide() {
        mainHandler.post {
            breathAnimator?.cancel()
            breathAnimator = null

            if (overlayView != null && windowManager != null) {
                try {
                    windowManager?.removeView(overlayView)
                    Log.d(TAG, "Overlay view removed from WindowManager")
                } catch (e: Exception) {
                    Log.e(TAG, "Error removing overlay view", e)
                }
            }
            overlayView = null
            isShowing = false
            AwareScrollMonitor.isBlockerShowing = false
        }
    }

    private fun fallbackToActivity(context: Context, appName: String, limitMinutes: Int) {
        try {
            val intent = Intent(context, AwareScrollBlockerActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("APP_NAME", appName)
                putExtra("LIMIT_MINUTES", limitMinutes)
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Fallback activity failed", e)
        }
    }

    // ==========================================
    // UI BUILDER: MINDFUL DIGITAL FOCUS OVERLAY
    // ==========================================
    private fun createOverlayView(context: Context, appName: String, limitMinutes: Int): View {
        val root = FrameLayout(context).apply {
            setBackgroundColor(Color.parseColor("#FCF8FF")) // Light Mindful Canvas
            isClickable = true
            isFocusable = true
        }

        renderGateState(context, root, appName, limitMinutes)
        return root
    }

    // ------------------------------------------
    // STATE 1: GATE & BREATHING
    // ------------------------------------------
    private fun renderGateState(context: Context, root: FrameLayout, appName: String, limitMinutes: Int) {
        root.removeAllViews()
        breathAnimator?.cancel()

        val scroll = ScrollView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            isVerticalScrollBarEnabled = false
        }

        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dpToPx(context, 24), dpToPx(context, 48), dpToPx(context, 24), dpToPx(context, 36))
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
        }
        scroll.addView(container)
        root.addView(scroll)

        // 1. Amber Badge: "05:00 LIMIT REACHED"
        val badge = TextView(context).apply {
            text = String.format("%02d:00 LIMIT REACHED", limitMinutes)
            setTextColor(Color.parseColor("#7A4300"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(context, 16), dpToPx(context, 6), dpToPx(context, 16), dpToPx(context, 6))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FFF4E8"))
                setStroke(dpToPx(context, 1), Color.parseColor("#FFDCC2"))
                cornerRadius = dpToPx(context, 20).toFloat()
            }
        }
        container.addView(badge)

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 24)) })

        // 2. Breathing Circle Container
        val circleContainer = FrameLayout(context).apply {
            val size = dpToPx(context, 150)
            layoutParams = LinearLayout.LayoutParams(size, size).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
        }

        val outerGlow = View(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                colors = intArrayOf(
                    Color.parseColor("#4D3A5BFF"),
                    Color.parseColor("#33FF9F43"),
                    Color.parseColor("#1A00B894")
                )
            }
        }
        circleContainer.addView(outerGlow)

        val innerCircle = LinearLayout(context).apply {
            val innerSize = dpToPx(context, 116)
            layoutParams = FrameLayout.LayoutParams(innerSize, innerSize).apply {
                gravity = Gravity.CENTER
            }
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.WHITE)
                setStroke(dpToPx(context, 1), Color.parseColor("#E2E4F0"))
            }
        }

        val icon = ImageView(context).apply {
            val iconSize = dpToPx(context, 38)
            layoutParams = LinearLayout.LayoutParams(iconSize, iconSize)
            setImageResource(android.R.drawable.ic_lock_idle_alarm)
            setColorFilter(Color.parseColor("#3A5BFF"))
        }
        innerCircle.addView(icon)

        val breathText = TextView(context).apply {
            text = "BREATHE"
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, dpToPx(context, 2), 0, 0)
        }
        innerCircle.addView(breathText)

        circleContainer.addView(innerCircle)
        container.addView(circleContainer)

        // Pulsing animation
        breathAnimator = ValueAnimator.ofFloat(0.92f, 1.08f).apply {
            duration = 3500
            repeatMode = ValueAnimator.REVERSE
            repeatCount = ValueAnimator.INFINITE
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener { anim ->
                val scale = anim.animatedValue as Float
                circleContainer.scaleX = scale
                circleContainer.scaleY = scale
            }
            start()
        }

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 18)) })

        // 3. Inhale/Exhale Pill
        val inhalePill = TextView(context).apply {
            text = "Take a breath • 4s Inhale, 4s Exhale"
            setTextColor(Color.parseColor("#7A4300"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(dpToPx(context, 14), dpToPx(context, 5), dpToPx(context, 14), dpToPx(context, 5))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FFF4E8"))
                cornerRadius = dpToPx(context, 16).toFloat()
            }
        }
        container.addView(inhalePill)

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 20)) })

        // 4. Headline
        val title = TextView(context).apply {
            text = "Your time is up!\nWhat would you like to do?"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.25f)
        }
        container.addView(title)

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 10)) })

        val subtitle = TextView(context).apply {
            text = "You set a $limitMinutes-minute boundary for $appName.\nTake an intentional pause before continuing or wrapping up."
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.3f)
        }
        container.addView(subtitle)

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 32)) })

        // 5. Button 1: Close Instagram
        val closeBtn = Button(context).apply {
            text = "Close Instagram"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#3A5BFF"))
                cornerRadius = dpToPx(context, 14).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(context, 52)
            )
            setOnClickListener {
                closeInstagramToHome(context)
            }
        }
        container.addView(closeBtn)

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 12)) })

        // 6. Button 2: Continue (Requires Reflection)
        val continueBtn = Button(context).apply {
            text = "Continue (Requires Reflection)"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(context, 1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(context, 14).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(context, 50)
            )
            setOnClickListener {
                renderSurveyState(context, root, appName, limitMinutes)
            }
        }
        container.addView(continueBtn)
    }

    // ------------------------------------------
    // STATE 2: CONSCIOUS REFLECTION SURVEY
    // ------------------------------------------
    private fun renderSurveyState(context: Context, root: FrameLayout, appName: String, limitMinutes: Int) {
        root.removeAllViews()
        breathAnimator?.cancel()

        var selectedPurpose = "Reply to a message"
        var selectedTrigger = "Interesting content"
        var selectedCategory = "Comedy / Memes"
        var selectedWorkImpact = "Delayed a task"
        var selectedFeeling = "Neutral"
        var selectedSupposedActivity = "Working"
        var selectedHelpStop = "Time warning"
        var selectedExtensionMin = 5

        val scroll = ScrollView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            isVerticalScrollBarEnabled = false
        }

        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(context, 16), dpToPx(context, 40), dpToPx(context, 16), dpToPx(context, 36))
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
        }
        scroll.addView(container)
        root.addView(scroll)

        // Top Navigation Row
        val topNav = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        val backBtn = TextView(context).apply {
            text = "← Back"
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(dpToPx(context, 10), dpToPx(context, 6), dpToPx(context, 10), dpToPx(context, 6))
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(context, 1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(context, 10).toFloat()
            }
            setOnClickListener {
                renderGateState(context, root, appName, limitMinutes)
            }
        }
        topNav.addView(backBtn)

        val spacer = View(context).apply {
            layoutParams = LinearLayout.LayoutParams(0, 1, 1f)
        }
        topNav.addView(spacer)

        val reconsiderTag = TextView(context).apply {
            text = "● RECONSIDERATION"
            setTextColor(Color.parseColor("#00B894"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(dpToPx(context, 10), dpToPx(context, 4), dpToPx(context, 10), dpToPx(context, 4))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E0F7F8"))
                cornerRadius = dpToPx(context, 12).toFloat()
            }
        }
        topNav.addView(reconsiderTag)
        container.addView(topNav)

        container.addView(View(context).apply { layoutParams = LinearLayout.LayoutParams(1, dpToPx(context, 14)) })

        // Title
        val heading = TextView(context).apply {
            text = "Conscious Reflection"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            typeface = Typeface.DEFAULT_BOLD
        }
        container.addView(heading)

        val hint = TextView(context).apply {
            text = "Answer the following reflections to unlock a temporary extension."
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setPadding(0, dpToPx(context, 2), 0, dpToPx(context, 14))
        }
        container.addView(hint)

        // All 7 Questions
        addSurveyQuestion(
            context, container, "1", "Purpose of Usage",
            "Why do you want use it, clearly mention your purpose?",
            listOf(
                "Reply to a message",
                "Checking someone's reply",
                "Check updates",
                "Nothing to do, so watch reels",
                "Finished all tasks, want to watch reels",
                "Study or research",
                "Opened automatically / out of habit"
            )
        ) { selectedPurpose = it }

        addSurveyQuestion(
            context, container, "2", "Decision Factor",
            "What most influenced your decision to continue?",
            listOf(
                "Interesting content",
                "Boredom",
                "Stress / mood",
                "Notifications / messages",
                "Habitual scrolling",
                "Unfinished original purpose"
            )
        ) { selectedTrigger = it }

        addSurveyQuestion(
            context, container, "3", "Content Category",
            "Which content category kept you engaged?",
            listOf(
                "Comedy / Memes",
                "Education / Technology",
                "News / Politics",
                "Stories / Personal content",
                "Fitness / Lifestyle",
                "Music / Entertainment",
                "Other / Mixed"
            )
        ) { selectedCategory = it }

        addSurveyQuestion(
            context, container, "4", "Effect on Planned Work",
            "How did this session affect your planned work?",
            listOf(
                "No task planned",
                "Delayed a task",
                "Interrupted a task",
                "No negative impact / planned break"
            )
        ) { selectedWorkImpact = it }

        addSurveyQuestion(
            context, container, "5", "Emotional State",
            "How do you feel after scrolling?",
            listOf(
                "Satisfied",
                "Relaxed",
                "Neutral",
                "Bored",
                "Stressed / regretful"
            )
        ) { selectedFeeling = it }

        addSurveyQuestion(
            context, container, "6", "Displaced Intention",
            "What were you supposed to be doing?",
            listOf(
                "Studying",
                "Working",
                "Sleeping",
                "Socializing",
                "Relaxing",
                "Nothing planned"
            )
        ) { selectedSupposedActivity = it }

        addSurveyQuestion(
            context, container, "7", "Intervention Help",
            "What would have helped you stop?",
            listOf(
                "Time warning",
                "Original-purpose reminder",
                "Mood check",
                "Break suggestion",
                "App closure"
            )
        ) { selectedHelpStop = it }

        // Question 8: Extension Commitment
        val extCard = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(context, 1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(context, 16).toFloat()
            }
            setPadding(dpToPx(context, 16), dpToPx(context, 16), dpToPx(context, 16), dpToPx(context, 16))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(context, 16)
            }
        }

        val extHeader = TextView(context).apply {
            text = "8. Extension Commitment"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
        }
        extCard.addView(extHeader)

        val extSub = TextView(context).apply {
            text = "Choose your conscious extension duration:"
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setPadding(0, dpToPx(context, 2), 0, dpToPx(context, 10))
        }
        extCard.addView(extSub)

        val durations = listOf(2, 5, 10, 15)
        val durRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        val durViews = mutableListOf<TextView>()
        lateinit var confirmBtn: Button

        for (d in durations) {
            val tv = TextView(context).apply {
                text = "+${d}m"
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(dpToPx(context, 6), dpToPx(context, 10), dpToPx(context, 6), dpToPx(context, 10))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    marginEnd = dpToPx(context, 6)
                }
            }

            fun updateDurations() {
                for (k in durations.indices) {
                    val isSel = (durations[k] == selectedExtensionMin)
                    durViews[k].apply {
                        setTextColor(if (isSel) Color.parseColor("#00B894") else Color.parseColor("#6B6F8C"))
                        background = GradientDrawable().apply {
                            setColor(if (isSel) Color.parseColor("#E0F7F8") else Color.parseColor("#FCF8FF"))
                            setStroke(dpToPx(context, if (isSel) 2 else 1), if (isSel) Color.parseColor("#00B894") else Color.parseColor("#E2E4F0"))
                            cornerRadius = dpToPx(context, 12).toFloat()
                        }
                    }
                }
                confirmBtn.text = "Confirm & Unlock (+${selectedExtensionMin} Min Extension)"
            }

            tv.setOnClickListener {
                selectedExtensionMin = d
                updateDurations()
            }

            durViews.add(tv)
            durRow.addView(tv)
        }

        // Initialize duration chips styling
        for (k in durations.indices) {
            val isSel = (durations[k] == selectedExtensionMin)
            durViews[k].apply {
                setTextColor(if (isSel) Color.parseColor("#00B894") else Color.parseColor("#6B6F8C"))
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#E0F7F8") else Color.parseColor("#FCF8FF"))
                    setStroke(dpToPx(context, if (isSel) 2 else 1), if (isSel) Color.parseColor("#00B894") else Color.parseColor("#E2E4F0"))
                    cornerRadius = dpToPx(context, 12).toFloat()
                }
            }
        }
        extCard.addView(durRow)
        container.addView(extCard)

        // Confirm & Unlock CTA
        confirmBtn = Button(context).apply {
            text = "Confirm & Unlock (+${selectedExtensionMin} Min Extension)"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#00B894"))
                cornerRadius = dpToPx(context, 16).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(context, 52)
            )
            setOnClickListener {
                // Record telemetry for Data Science
                AwareScrollTelemetry.recordSurveyResponse(
                    context = context,
                    appName = appName,
                    packageName = AwareScrollMonitor.targetPackageName,
                    limitMinutes = limitMinutes,
                    elapsedSeconds = AwareScrollMonitor.elapsedSeconds,
                    extensionMinutes = selectedExtensionMin,
                    purpose = selectedPurpose,
                    trigger = selectedTrigger,
                    category = selectedCategory,
                    workImpact = selectedWorkImpact,
                    feeling = selectedFeeling,
                    supposedActivity = selectedSupposedActivity,
                    helpStop = selectedHelpStop,
                    sessionOutcome = "extended"
                )

                // Grant extension and unlock Instagram!
                AwareScrollMonitor.grantExtension(selectedExtensionMin)
                hide()
            }
        }
        container.addView(confirmBtn)

        val note = TextView(context).apply {
            text = "Instagram will re-lock immediately when this extension expires."
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f)
            gravity = Gravity.CENTER
            setPadding(0, dpToPx(context, 8), 0, 0)
        }
        container.addView(note)
    }

    private fun addSurveyQuestion(
        context: Context,
        parent: LinearLayout,
        number: String,
        title: String,
        subtitle: String,
        options: List<String>,
        onSelect: ((String) -> Unit)? = null
    ) {
        val card = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(dpToPx(context, 1), Color.parseColor("#E2E4F0"))
                cornerRadius = dpToPx(context, 16).toFloat()
            }
            setPadding(dpToPx(context, 16), dpToPx(context, 16), dpToPx(context, 16), dpToPx(context, 16))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(context, 14)
            }
        }

        val header = TextView(context).apply {
            text = "$number. $title"
            setTextColor(Color.parseColor("#141528"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
        }
        card.addView(header)

        val sub = TextView(context).apply {
            text = subtitle
            setTextColor(Color.parseColor("#6B6F8C"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setPadding(0, dpToPx(context, 2), 0, dpToPx(context, 10))
        }
        card.addView(sub)

        var selectedIdx = 0
        val optionViews = mutableListOf<TextView>()

        for (i in options.indices) {
            val opt = options[i]
            val tv = TextView(context).apply {
                text = opt
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setPadding(dpToPx(context, 14), dpToPx(context, 10), dpToPx(context, 14), dpToPx(context, 10))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(context, 6)
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
                            setStroke(dpToPx(context, if (isSel) 2 else 1), if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#E2E4F0"))
                            cornerRadius = dpToPx(context, 12).toFloat()
                        }
                    }
                }
            }

            tv.setOnClickListener {
                selectedIdx = i
                update()
                onSelect?.invoke(opt)
            }

            optionViews.add(tv)
            card.addView(tv)
        }

        // Initialize option styles and trigger default selection callback
        for (j in optionViews.indices) {
            val isSel = (j == 0)
            optionViews[j].apply {
                setTextColor(if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#141528"))
                typeface = if (isSel) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
                background = GradientDrawable().apply {
                    setColor(if (isSel) Color.parseColor("#EEECFF") else Color.parseColor("#FCF8FF"))
                    setStroke(dpToPx(context, if (isSel) 2 else 1), if (isSel) Color.parseColor("#3A5BFF") else Color.parseColor("#E2E4F0"))
                    cornerRadius = dpToPx(context, 12).toFloat()
                }
            }
        }
        if (options.isNotEmpty()) {
            onSelect?.invoke(options[0])
        }

        parent.addView(card)
    }

    private fun closeInstagramToHome(context: Context) {
        hide()

        // 1. Accessibility Service sends global HOME action
        val closedViaAccessibility = AwareScrollAccessibilityService.instance?.closeAppToHome() ?: false

        if (!closedViaAccessibility) {
            // 2. Fallback HOME Intent
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(homeIntent)
        }
    }

    private fun dpToPx(context: Context, dp: Int): Int {
        return (dp * context.resources.displayMetrics.density).toInt()
    }
}
