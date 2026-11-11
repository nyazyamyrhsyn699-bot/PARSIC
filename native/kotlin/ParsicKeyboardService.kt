package com.parsic.parsic

import android.inputmethodservice.InputMethodService
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.graphics.Typeface

class ParsicKeyboardService : InputMethodService() {

    private val rows = listOf(
        listOf("𐎠","𐎡","𐎢","𐎣","𐎥","𐎧"),
        listOf("𐎩","𐎫","𐎭","𐎱","𐎲","𐎼"),
        listOf("𐎿","𐏁","𐏃","𐎴","𐎶","⌫"),
        listOf("؟",".","،","فاصله","↵")
    )

    override fun onCreateInputView(): View {
        val root = LinearLayout(this)
        root.orientation = LinearLayout.VERTICAL
        root.setBackgroundColor(Color.rgb(25,25,30))
        root.setPadding(5,8,5,8)

        for (row in rows) {
            val line = LinearLayout(this)
            line.orientation = LinearLayout.HORIZONTAL

            for (key in row) {
                val button = Button(this)
                button.text = key
                button.textSize = if (key.length > 2) 13f else 23f
                button.setTextColor(Color.WHITE)
                button.setBackgroundColor(Color.rgb(65,55,42))

                val params = LinearLayout.LayoutParams(
                    0, 58, 1f
                )
                params.setMargins(2,2,2,2)
                line.addView(button, params)

                button.setOnClickListener {
                    val connection = currentInputConnection ?: return@setOnClickListener
                    when(key) {
                        "⌫" -> connection.deleteSurroundingText(1,0)
                        "فاصله" -> connection.commitText(" ",1)
                        "↵" -> connection.commitText("\n",1)
                        else -> connection.commitText(key,1)
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
