//
//  AudioDiskCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//
import UIKit
import Kingfisher

final class AudioDiskCell: UICollectionViewCell {

    static let identifier = "AudioDiskCell"

    private let diskLayer = CAShapeLayer()
    private let labelLayer = CAShapeLayer()
    private let holeLayer = CAShapeLayer()
    private var grooveLayers = [CAShapeLayer]()
    private let spinLayer = CALayer()

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 0.75
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 10, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.85)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: 108),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: -4)
        ])
        contentView.layer.shouldRasterize = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.rasterizationScale = traitCollection.displayScale
        buildDisk()
    }

    func configure(with item: LibraryItem) {
        titleLabel.text = item.title
        if let url = item.coverURL {
            coverImageView.kf.setImage(with: url)
        }
    }

    func animateSpin() {
        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue  = 0
        spin.toValue = CGFloat.pi * 2
        spin.duration = 1.4
        spin.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        spinLayer.add(spin, forKey: "spin")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        spinLayer.removeAllAnimations()
    }

    private func buildDisk() {
        spinLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        grooveLayers.forEach { $0.removeFromSuperlayer() }
        grooveLayers.removeAll()
        spinLayer.removeFromSuperlayer()

        let size     = min(contentView.bounds.width,
                           96.0)
        let center   = CGPoint(x: contentView.bounds.midX,
                               y: size / 2)
        let radius   = size / 2

        spinLayer.frame    = CGRect(x: center.x - radius,
                                    y: center.y - radius,
                                    width: size, height: size)
        spinLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        contentView.layer.insertSublayer(spinLayer, at: 0)

        let diskPath = UIBezierPath(arcCenter: CGPoint(x: radius,
                                                       y: radius),
                                    radius: radius,
                                    startAngle: 0,
                                    endAngle: .pi * 2, clockwise: true)
        diskLayer.path      = diskPath.cgPath
        //Assetsden Cagir
        diskLayer.fillColor = UIColor(hex: "#1A1A1A").cgColor
        spinLayer.addSublayer(diskLayer)

        var grooveRadius = radius - 4
        while grooveRadius > radius * 0.38 {
            let gl = CAShapeLayer()
            let gp = UIBezierPath(arcCenter: CGPoint(x: radius,
                                                     y: radius),
                                   radius: grooveRadius,
                                  startAngle: 0,
                                   endAngle: .pi * 2,
                                  clockwise: true)
            gl.path = gp.cgPath
            gl.fillColor = UIColor.clear.cgColor
            gl.strokeColor = UIColor.white.withAlphaComponent(0.04).cgColor
            gl.lineWidth = 1
            spinLayer.addSublayer(gl)
            grooveLayers.append(gl)
            grooveRadius -= 4
        }

        let labelRadius = radius * 0.36
        let labelPath   = UIBezierPath(arcCenter: CGPoint(x: radius,
                                                          y: radius),
                                        radius: labelRadius,
                                       startAngle: 0,
                                        endAngle: .pi * 2,
                                       clockwise: true)
        labelLayer.path      = labelPath.cgPath
        //Assetsden Cagir
        labelLayer.fillColor = UIColor(hex: "#C0392B").cgColor
        spinLayer.addSublayer(labelLayer)

        let imgSize = labelRadius * 1.4
        let imgCenter = CGPoint(x: radius,
                                 y: radius)
        coverImageView.frame = CGRect(
            x:
                imgCenter.x - imgSize / 2,
            y:
                imgCenter.y - imgSize / 2,
            width: imgSize, height: imgSize
        )
        coverImageView.layer.cornerRadius = imgSize / 2
        coverImageView.removeFromSuperview()
        spinLayer.addSublayer(coverImageView.layer)
        contentView.addSubview(coverImageView)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverImageView.centerXAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                    constant: center.x),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.topAnchor,
                                                    constant: center.y),
            coverImageView.widthAnchor.constraint(equalToConstant: imgSize),
            coverImageView.heightAnchor.constraint(equalToConstant: imgSize)
        ])

        let holeRadius = radius * 0.06
        let holePath   = UIBezierPath(arcCenter: CGPoint(x: radius,
                                                         y: radius),
                                       radius: holeRadius,
                                      startAngle: 0,
                                       endAngle: .pi * 2,
                                      clockwise: true)
        holeLayer.path      = holePath.cgPath
        //Assetsden
        holeLayer.fillColor = UIColor(hex: "#0A0A0A").cgColor
        spinLayer.addSublayer(holeLayer)

        contentView.layer.shadowColor   = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowRadius  = 6
        contentView.layer.shadowOffset  = CGSize(width: 3,
                                                 height: 3)
    }
}
