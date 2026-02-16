package com.example.quies

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class QuiesNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_quies, null) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        bodyView.text = nativeAd.body ?: ""
        adView.bodyView = bodyView

        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon!!.drawable)
            iconView.visibility = android.view.View.VISIBLE
        } else {
            iconView.visibility = android.view.View.GONE
        }
        adView.iconView = iconView

        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        ctaView.text = nativeAd.callToAction ?: "Learn More"
        adView.callToActionView = ctaView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
