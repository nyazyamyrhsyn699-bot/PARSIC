package com.parsic.parsic

import android.inputmethodservice.InputMethodService
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout

class ParsicKeyboardService : InputMethodService() {

    private val rows = listOf(
        listOf("𐎠","𐎡","𐎢","𐎣","𐎤","𐎥"),
        listOf("𐎦","𐎧","𐎨","𐎩","𐎪","𐎫"),
        listOf("𐎬","𐎭","𐎮","𐎯","𐎰","𐎱"),
        listOf("𐎲","𐎳","𐎴","𐎵","𐎶","𐎷"),
        listOf("𐎸","𐎹","𐎺","𐎻","𐎼","𐎽"),
        listOf("𐎾","𐎿","⌫","،",".","؟"),
        listOf("فاصله","↵")
    )

    override fun onCreateInputView(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.rgb(20,20,25))
            setPadding(4,6,4,6)
        }

        for (row in rows) {
            val line = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
            }

            for (key in row) {
                val button = Button(this).apply {
                    text = key
                    textSize = if (key == "فاصله") 12f else 21f
                    setTextColor(Color.WHITE)
                    setBackgroundColor(Color.rgb(75,62,43))
                    isAllCaps = false
                    setPadding(0,0,0,0)
                }

                val params = LinearLayout.LayoutParams(0,48,1f)
                params.setMargins(2,2,2,2)
                line.addView(button,params)

                button.setOnClickListener {
                    val connection = currentInputConnection ?: return@setOnClickListener
                    when (key) {
                        "⌫" -> connection.deleteSurroundingTextInCodePoints(1,0)
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
