//
//  UIImage+Resize.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import UIKit

extension UIImage {
  func resized(toMaxDimension maxDim: CGFloat) -> UIImage? {
    let aspect = size.width / size.height
    let newSize = size.width > size.height
      ? CGSize(width: maxDim, height: maxDim / aspect)
      : CGSize(width: maxDim * aspect, height: maxDim)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
    draw(in: CGRect(origin: .zero, size: newSize))
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result
  }
}
