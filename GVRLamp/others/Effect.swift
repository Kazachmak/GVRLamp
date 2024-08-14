import Foundation

public class Effect {
  var bright: Int?
  var speed: Int?
  var scale: Int?
  
  let name: String
  let id: Int
  let maxSpeed: Int
  let minSpeed: Int
  let maxScale: Int
  let minScale: Int
  let speedRange: Int
  let scaleRange: Int

  init(_ str: String) {
    self.name = str.components(separatedBy: ",")[0].components(separatedBy: ".")[1]
    self.id = Int(str.components(separatedBy: ",")[0].components(separatedBy: ".")[0]) ?? 0
    self.maxSpeed = Self.getMaxSpeed(str)
    self.minSpeed = Self.getMinSpeed(str)
    self.maxScale = Self.getMaxScale(str)
    self.minScale = Self.getMinScale(str)
    self.speedRange = maxSpeed - minSpeed == 0 ? 100 : maxSpeed - minSpeed
    self.scaleRange = maxScale - minScale == 0 ? 100 : maxScale - minScale
  }

  static func getMaxSpeed(_ str: String) -> Int {
    guard
      str.components(separatedBy: ",").count > 2,
      let speed = Int(str.components(separatedBy: ",")[2])
      else {
        return 255
      }
    return speed
  }

  static func getMinSpeed(_ str: String) -> Int {
    guard
      str.components(separatedBy: ",").count > 1,
      let speed = Int(str.components(separatedBy: ",")[1])
      else {
        return 0
      }
     return speed
  }

  static func getMaxScale(_ str: String) -> Int {
    guard
      str.components(separatedBy: ",").count > 4,
      let scale = Int(str.components(separatedBy: ",")[4])
      else {
        return 255
      }
      return scale
  }

  static func getMinScale(_ str: String) -> Int {
    guard
      str.components(separatedBy: ",").count > 3,
      let scale = Int(str.components(separatedBy: ",")[3])
      else {
        return 0
      }
    return scale
  }
}
