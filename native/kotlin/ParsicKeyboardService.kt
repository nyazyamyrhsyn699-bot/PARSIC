package com.parsic.parsic

import android.inputmethodservice.InputMethodService
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView

class ParsicKeyboardService : InputMethodService() {

    data class KeySpec(
        val glyph: String,
        val hint: String = "",
        val value: String = glyph,
        val action: String = "text",
        val weight: Float = 1f
    )

    private val glyphs = mapOf(
        "ا" to "𐎠",
        "ب" to "𐎡",
        "پ" to "𐎢",
        "ت" to "𐎣",
        "ث" to "𐎤",
        "ج" to "𐎥",
        "چ" to "𐎦",
        "ح" to "𐎧",
        "خ" to "𐎨",
        "د" to "𐎩",
        "ذ" to "𐎪",
        "ر" to "𐎫",
        "ز" to "𐎬",
        "ژ" to "𐎭",
        "س" to "𐎮",
        "ش" to "𐎯",
        "ص" to "𐎰",
        "ض" to "𐎱",
        "ط" to "𐎲",
        "ظ" to "𐎳",
        "ع" to "𐎴",
        "غ" to "𐎵",
        "ف" to "𐎶",
        "ق" to "𐎷",
        "ک" to "𐎸",
        "گ" to "𐎹",
        "ل" to "𐎺",
        "م" to "𐎻",
        "ن" to "𐎼",
        "و" to "𐎽",
        "ه" to "𐎾",
        "ی" to "𐎿",
        "ئ" to "𐎿"
    )

    private fun letter(value: String): KeySpec {
        return KeySpec(
            glyph = glyphs[value] ?: value,
            hint = value,
            value = glyphs[value] ?: value
        )
    }

    private fun special(
        glyph: String,
        hint: String,
        value: String = "",
        action: String = "text",
        weight: Float = 1f
    ) = KeySpec(glyph, hint, value, action, weight)

    private val rows = listOf(
        "ض ص ث ق ف غ ع ه خ ح ج چ".split(" ").map { letter(it) },
        "ش س ی ب ل ا ت ن م ک گ".split(" ").map { letter(it) },
        "ظ ط ز ر ذ د ئ و پ".split(" ").map { letter(it) } +
            special("⌫", "حذف", action = "backspace", weight = 1.35f)
    )

    private fun dp(v: Int): Int =
        (v * resources.displayMetrics.density).toInt()

    private fun makeKey(key: KeySpec): LinearLayout {
        val cell = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(1), dp(1), dp(1), dp(1))

            background = GradientDrawable().apply {
                setColor(Color.rgb(54, 48, 43))
                cornerRadius = dp(6).toFloat()
                setStroke(dp(1), Color.rgb(105, 91, 76))
            }
        }

        val top = TextView(this).apply {
            text = key.glyph
            gravity = Gravity.CENTER
            textSize = if (key.action == "text") 21f else 15f
            setTextColor(Color.WHITE)
            includeFontPadding = true
        }

        val bottom = TextView(this).apply {
            text = key.hint
            gravity = Gravity.CENTER
            textSize = 8f
            setTextColor(Color.rgb(230, 194, 143))
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
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 0.65f
            )
        )

        cell.setOnClickListener {
            val input = currentInputConnection ?: return@setOnClickListener

            when (key.action) {
                "backspace" -> input.deleteSurroundingText(1, 0)
                "space" -> input.commitText(" ", 1)
                "enter" -> input.commitText("\n", 1)
                else -> input.commitText(key.value, 1)
            }
        }

        return cell
    }

    private fun addRow(
        root: LinearLayout,
        keys: List<KeySpec>,
        height: Int
    ) {
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }

        keys.forEach { key ->
            val params = LinearLayout.LayoutParams(
                0, dp(height), key.weight
            )
            params.setMargins(dp(2), dp(2), dp(2), dp(2))
            row.addView(makeKey(key), params)
        }

        root.addView(
            row,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(height + 4)
            )
        )
    }

    override fun onCreateInputView(): android.view.View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(3), dp(4), dp(3), dp(4))
            setBackgroundColor(Color.rgb(29, 27, 26))
        }

        rows.forEachIndexed { index, keys ->
            addRow(root, keys, 47)
        }

        val bottom = listOf(
            special("؟۱۲۳", "علائم", "؟"),
            special("،", "ویرگول", "،"),
            special("فاصله", " ", action = "space", weight = 3.8f),
            special(".", "نقطه", "."),
            special("↵", "ورود", action = "enter")
        )

        addRow(root, bottom, 48)

        return root
    }
}
