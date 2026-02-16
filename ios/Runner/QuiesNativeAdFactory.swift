import Foundation
import google_mobile_ads

class QuiesNativeAdFactory: FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [String: Any]? = nil
    ) -> GADNativeAdView? {
        let adView = GADNativeAdView(frame: .zero)
        adView.backgroundColor = .clear

        let sponsoredLabel = UILabel()
        sponsoredLabel.text = "Sponsored"
        sponsoredLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        sponsoredLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        sponsoredLabel.translatesAutoresizingMaskIntoConstraints = false

        let headlineLabel = UILabel()
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = UIFont(name: "Georgia-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        headlineLabel.textColor = UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1.0)
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        adView.headlineView = headlineLabel

        let bodyLabel = UILabel()
        bodyLabel.text = nativeAd.body ?? ""
        bodyLabel.font = UIFont.systemFont(ofSize: 13)
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        bodyLabel.numberOfLines = 2
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        adView.bodyView = bodyLabel

        let iconView = UIImageView()
        iconView.image = nativeAd.icon?.image
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 4
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHidden = nativeAd.icon == nil
        adView.iconView = iconView

        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(nativeAd.callToAction ?? "Learn More", for: .normal)
        ctaButton.setTitleColor(UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0), for: .normal)
        ctaButton.backgroundColor = .white
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        ctaButton.layer.cornerRadius = 6
        ctaButton.isUserInteractionEnabled = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        adView.callToActionView = ctaButton

        adView.addSubview(sponsoredLabel)
        adView.addSubview(headlineLabel)
        adView.addSubview(bodyLabel)
        adView.addSubview(iconView)
        adView.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            sponsoredLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            sponsoredLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            sponsoredLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),

            headlineLabel.topAnchor.constraint(equalTo: sponsoredLabel.bottomAnchor, constant: 6),
            headlineLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),

            iconView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 10),
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            iconView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),

            ctaButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            ctaButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        adView.nativeAd = nativeAd
        return adView
    }
}
