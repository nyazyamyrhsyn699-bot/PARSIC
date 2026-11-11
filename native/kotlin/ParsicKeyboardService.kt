package com.parsic.parsic

import android.inputmethodservice.InputMethodService
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView

class ParsicKeyboardService : InputMethodService() {

    data class Key(
        val glyph: String,
        val hint: String = "",
        val value: String = glyph,
        val action: String = "text",
        val weight: Float = 1f
    )

    private fun k(g: String, p: String) = Key(g, p)

    private val rows = listOf(
        listOf(
            k("𐎠","ا"), k("𐎡","ب"), k("𐎢","پ"),
            k("𐎣","ت"), k("𐎤","ث"), k("𐎥","ج")
        ),
        listOf(
            k("𐎦","چ"), k("𐎧","ح"), k("𐎨","خ"),
            k("𐎩","د"), k("𐎪","ذ"), k("𐎫","ر")
        ),
        listOf(
            k("𐎬","ز"), k("𐎭","ژ"), k("𐎮","س"),
            k("𐎯","ش"), k("𐎰","ص"), k("𐎱","ض")
        ),
        listOf(
            k("𐎲","ط"), k("𐎳","ظ"), k("𐎴","ع"),
            k("𐎵","غ"), k("𐎶","ف"), k("𐎷","ق")
        ),
        listOf(
            k("𐎸","ک"), k("𐎹","گ"), k("𐎺","ل"),
            k("𐎻","م"), k("𐎼","ن"), k("𐎽","و")
        ),
        listOf(
            k("𐎾","ه"), k("𐎿","ی")
        ),
        listOf(
            Key("،","ویرگول","،"),
            Key(".","نقطه","."),
            Key("؟","پرسش","؟"),
            Key("⌫","حذف",action="backspace"),
            Key("فاصله","فاصله"," ", "space", 2.5f),
            Key("↵","سطر بعد",action="enter")
        )
    )

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    override fun onCreateInputView(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(4), dp(5), dp(4), dp(5))
            setBackgroundColor(Color.rgb(20, 20, 25))
        }

        rows.forEach { row ->
            val line = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
            }

            row.forEach { key ->
                val cell = LinearLayout(this).apply {
                    orientation = LinearLayout.VERTICAL
                    gravity = Gravity.CENTER
                    isClickable = true
                    isFocusable = true

                    background = GradientDrawable().apply {
                        setColor(Color.rgb(72, 58, 40))
                        cornerRadius = dp(6).toFloat()
                        setStroke(dp(1), Color.rgb(135, 105, 62))
                    }

                    setPadding(dp(1), dp(2), dp(1), dp(2))
                }

                val top = TextView(this).apply {
                    text = key.glyph
                    gravity = Gravity.CENTER
                    textSize = if (key.action == "text") 22f else 13f
                    setTextColor(Color.WHITE)
                }

                val bottom = TextView(this).apply {
                    text = key.hint
                    gravity = Gravity.CENTER
                    textSize = 10f
                    setTextColor(Color.rgb(255, 213, 145))
                }

                cell.addView(
                    top,
                    LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, 0, 1.2f
                    )
                )

                cell.addView(
                    bottom,
                    LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, 0, 0.7f
                    )
                )

                val params = LinearLayout.LayoutParams(
                    0, dp(47), key.weight
                )
                params.setMargins(dp(2), dp(2), dp(2), dp(2))
                line.addView(cell, params)

                cell.setOnClickListener {
                    val connection = currentInputConnection
                        ?: return@setOnClickListener

                    when (key.action) {
                        "backspace" ->
                            connection.deleteSurroundingTextInCodePoints(1, 0)

                        "space" ->
                            connection.commitText(" ", 1)

                        "enter" ->
                            connection.commitText("\n", 1)

                        else ->
                            connection.commitText(key.value, 1)
                    }
                }
            }

            root.addView(
                line,
                LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            )
        }

        return root
    }
}
