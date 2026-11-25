package com.igz.kizuvia

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** "Dosis berikutnya" widget. Text is written by Dart (HomeWidget.saveWidgetData). */
class NextDoseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.next_dose_widget).apply {
                setTextViewText(
                    R.id.widget_title,
                    widgetData.getString("title", null) ?: context.getString(R.string.widget_none),
                )
                setTextViewText(R.id.widget_body, widgetData.getString("body", "") ?: "")
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
