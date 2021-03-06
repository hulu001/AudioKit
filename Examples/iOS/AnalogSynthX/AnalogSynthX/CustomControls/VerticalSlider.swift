//
//  VerticalSlider.swift
//  Analog Synth X
//
//  Created by Matthew Fecher, revision history on Githbub.
//  Copyright (c) 2016 AudioKit. All rights reserved.

// Slider code adapted from:
// http://www.totem.training/swift-ios-tips-tricks-tutorials-blog/paint-code-and-live-views

import UIKit

protocol VerticalSliderDelegate: class {
    func sliderValueDidChange(_ value: Double, tag: Int)
}

let sliderTopImage = "slider_top.png"
let sliderTrackImage = "slider_track.png"

@IBDesignable
class VerticalSlider: UIControl {

    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    var currentValue: CGFloat = 0.45 {
        didSet {
            if currentValue < 0 {
                currentValue = 0
            }
            if currentValue > maxValue {
                currentValue = maxValue
            }
            self.sliderValue = CGFloat((currentValue - minValue) / (maxValue - minValue))
            setupView()
        }
    }

    let knobSize = CGSize(width: 43, height: 31)
    let barMargin: CGFloat = 20.0
    var knobRect: CGRect!
    var barLength: CGFloat = 164.0
    var isSliding = false
    var sliderValue: CGFloat = 0.5
    weak var delegate: VerticalSliderDelegate?

    //// Image Declarations
    var sliderTop = UIImage(named: sliderTopImage)
    var sliderTrack = UIImage(named: sliderTrackImage)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    class override var requiresConstraintBasedLayout: Bool {
        return true
    }
}

// MARK: - Lifecycle
extension VerticalSlider {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {

        knobRect = CGRect(x: 0,
                          y: convertValueToY(currentValue) - (knobSize.height / 2),
                          width: knobSize.width,
                          height: knobSize.height)
        barLength = bounds.height - (barMargin * 2)

        let bundle = Bundle(for: type(of: self))
        sliderTop = UIImage(named: sliderTopImage, in: bundle, compatibleWith: self.traitCollection)
        sliderTrack = UIImage(named: sliderTrackImage, in: bundle, compatibleWith: self.traitCollection)
    }

    override func draw(_ rect: CGRect) {
        drawVerticalSlider(controlFrame: CGRect(x: 0,
                                                y: 0,
                                                width: bounds.width,
                                                height: bounds.height),
                           knobRect: knobRect)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}

// MARK: - Helpers
extension VerticalSlider {
    func convertYToValue(_ y: CGFloat) -> CGFloat {
        let offsetY = bounds.height - barMargin - y
        let value = (offsetY * maxValue) / barLength
        return value
    }
    func convertValueToY(_ value: CGFloat) -> CGFloat {
        let rawY = (value * barLength) / maxValue
        let offsetY = bounds.height - barMargin - rawY
        return offsetY
    }
}

// MARK: - Control Touch Handling
extension VerticalSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if knobRect.contains(touch.location(in: self)) {
            isSliding = true
        }
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let rawY = touch.location(in: self).y

        if isSliding {
            let value = convertYToValue(rawY)

            if value != minValue || value != maxValue {
                currentValue = value
                delegate?.sliderValueDidChange(Double(currentValue), tag: self.tag)
                setNeedsDisplay()
            }
        }
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isSliding = false
    }

    func drawVerticalSlider(controlFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 216),
                            knobRect: CGRect = CGRect(x: 0, y: 89, width: 36, height: 32)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Background Drawing
        let backgroundRect = CGRect(x: controlFrame.minX + 2, y: controlFrame.minY + 10, width: 38, height: 144)
        let backgroundPath = UIBezierPath(rect: backgroundRect)
        context?.saveGState()
        backgroundPath.addClip()
        sliderTrack?.draw(in: CGRect(x: floor(backgroundRect.minX + 0.5),
                                     y: floor(backgroundRect.minY + 0.5),
                                     width: sliderTrack?.size.width ?? 0,
                                     height: sliderTrack?.size.height ?? 0))
        context?.restoreGState()

        //// Slider Top Drawing
        let sliderTopRect = CGRect(x: knobRect.origin.x,
                                   y: knobRect.origin.y,
                                   width: knobRect.size.width,
                                   height: knobRect.size.height)
        let sliderTopPath = UIBezierPath(rect: sliderTopRect)
        context?.saveGState()
        sliderTopPath.addClip()
        sliderTop?.draw(in: CGRect(x: floor(sliderTopRect.minX + 0.5),
                                   y: floor(sliderTopRect.minY + 0.5),
                                   width: sliderTop?.size.width ?? 0,
                                   height: sliderTop?.size.height ?? 0))
        context?.restoreGState()
    }
}
